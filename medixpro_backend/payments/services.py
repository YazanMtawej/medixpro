"""Business logic for booking payments, refunds, and monthly doctor payouts."""
from __future__ import annotations

import logging
import uuid
from decimal import Decimal, ROUND_HALF_UP

from django.conf import settings
from django.db import transaction
from django.db.models import Sum, Count
from django.utils import timezone

from appointments.models import Appointment, AppointmentRequest
from .models import Payment, PayoutSettlement, WebhookEvent
from . import shamcash

logger = logging.getLogger("payments")

TWO_PLACES = Decimal("0.01")


class PaymentError(Exception):
    pass


def _money(value) -> Decimal:
    return Decimal(value).quantize(TWO_PLACES, rounding=ROUND_HALF_UP)


def _public_url(path: str) -> str:
    base = settings.PUBLIC_BASE_URL.rstrip("/")
    return f"{base}{path}"


def fee_for(receipt_amount) -> Decimal:
    """The platform's booking fee = receipt * PLATFORM_FEE_RATE (2 decimals)."""
    rate = Decimal(str(settings.PLATFORM_FEE_RATE))
    return _money(Decimal(str(receipt_amount)) * rate)


def _next_bill_no(payment: Payment) -> str:
    """MEDIX-<paymentId>-<attempt>. New attempt each time we (re)create a bill."""
    return f"MEDIX-{payment.id}-{payment.attempt}"


# ─── Booking ──────────────────────────────────────────────────────────────────

@transaction.atomic
def create_booking_payment(*, patient_user, doctor_user, request_data: dict) -> Payment:
    """
    Create a payment-gated AppointmentRequest and a matching ShamCash bill.

    The request stays hidden from the doctor (awaiting_payment=True) until the
    ShamCash webhook confirms payment. Returns the Payment (with payment_url).
    """
    from patients.models import Patient  # local import to avoid app-loading cycle

    try:
        patient = patient_user.patient_profile
    except Exception:
        patient = Patient.objects.filter(user=patient_user).first()
    if patient is None:
        raise PaymentError("Your patient profile is not set up.")

    profile = getattr(doctor_user, "profile", None)
    receipt = getattr(profile, "receipt_amount", None) if profile else None
    if not receipt or Decimal(str(receipt)) <= 0:
        raise PaymentError("This doctor has not set a consultation fee yet.")

    fee = fee_for(receipt)
    if fee < Decimal("0.01"):
        raise PaymentError("Computed booking fee is below the minimum allowed.")

    req = AppointmentRequest.objects.create(
        patient=patient,
        requested_by=patient_user,
        doctor=doctor_user,
        title=(request_data.get("title") or "").strip(),
        type=request_data.get("type", "general"),
        preferred_date=request_data.get("preferred_date"),
        reason=request_data.get("reason", ""),
        symptoms=request_data.get("symptoms", ""),
        status=AppointmentRequest.Status.PENDING,
        awaiting_payment=True,
    )

    payment = Payment.objects.create(
        appointment_request=req,
        patient=patient_user,
        doctor=doctor_user,
        bill_no="",  # set after we have the id
        receipt_amount=_money(receipt),
        fee_rate=Decimal(str(settings.PLATFORM_FEE_RATE)),
        amount=fee,
        currency_id=settings.SHAMCASH_CURRENCY_ID,
        status=Payment.Status.PENDING,
    )
    payment.bill_no = _next_bill_no(payment)
    payment.save(update_fields=["bill_no"])

    _create_shamcash_bill(payment, req)
    return payment


def _create_shamcash_bill(payment: Payment, req: AppointmentRequest) -> None:
    client = shamcash.get_client()
    note = f"MedixPro booking fee — {req.title}"[:250]
    try:
        resp = client.create_bill(
            bill_no=payment.bill_no,
            amount=payment.amount,
            currency_id=payment.currency_id,
            callback_url=_public_url("/api/v1/payments/webhook/shamcash/"),
            redirect_url=_public_url(f"/api/v1/payments/redirect/?bill_no={payment.bill_no}"),
            note=note,
        )
    except shamcash.ShamCashError as exc:
        payment.status = Payment.Status.FAILED
        payment.save(update_fields=["status", "updated_at"])
        raise PaymentError(f"Payment gateway error: {exc.message}") from exc

    if not resp.ok:
        # 1704 (bill already exists) means our earlier request actually landed —
        # fall back to polling the existing bill rather than failing.
        if resp.result == shamcash.CODE_BILL_ALREADY_EXISTS:
            info = client.get_bill_info(payment.bill_no)
            if info.ok and info.data:
                _apply_bill_data(payment, info.data)
                return
        payment.status = Payment.Status.FAILED
        payment.save(update_fields=["status", "updated_at"])
        raise PaymentError(resp.message or "Failed to create payment bill.")

    _apply_bill_data(payment, resp.data or {})


def _apply_bill_data(payment: Payment, data: dict) -> None:
    """Populate a payment from a createBill / getBillInfo `data` object."""
    payment.payment_url = data.get("paymentUrl", payment.payment_url) or payment.payment_url
    status_id = data.get("statusId")
    if status_id is not None:
        payment.shamcash_status_id = status_id
        _sync_status_from_shamcash(payment, status_id, data.get("tranId"))
    payment.save()


# ─── Status transitions ─────────────────────────────────────────────────────

def _sync_status_from_shamcash(payment: Payment, status_id: int, tran_id=None) -> bool:
    """
    Map a ShamCash bill statusId onto our Payment.status and drive side effects.
    Returns True if the status changed. Idempotent.
    """
    changed = False
    if status_id == shamcash.STATUS_PAID and payment.status != Payment.Status.PAID:
        payment.status = Payment.Status.PAID
        payment.paid_at = payment.paid_at or timezone.now()
        if tran_id is not None:
            payment.tran_id = tran_id
        _on_paid(payment)
        changed = True
    elif status_id == shamcash.STATUS_EXPIRED and payment.status == Payment.Status.PENDING:
        payment.status = Payment.Status.EXPIRED
        _on_expired(payment)
        changed = True
    elif status_id == shamcash.STATUS_REFUND:
        payment.status = Payment.Status.REFUNDED
        changed = True
    elif status_id == shamcash.STATUS_PARTLY_REFUNDED:
        payment.status = Payment.Status.PARTLY_REFUNDED
        changed = True
    return changed


def _on_paid(payment: Payment) -> None:
    """Reveal the request to doctors and notify them."""
    req = payment.appointment_request
    if req and req.awaiting_payment:
        req.awaiting_payment = False
        req.save(update_fields=["awaiting_payment", "updated_at"])
        _notify_doctors_new_request(req)


def _on_expired(payment: Payment) -> None:
    """Discard the unpaid request so it never surfaces to a doctor."""
    req = payment.appointment_request
    if req and req.awaiting_payment and req.status == AppointmentRequest.Status.PENDING:
        # Detach first (FK is SET_NULL) so the audit Payment row survives.
        payment.appointment_request = None
        payment.save(update_fields=["appointment_request", "updated_at"])
        req.delete()


def _notify_doctors_new_request(req: AppointmentRequest) -> None:
    try:
        from notifications.models import Notification
        from django.utils.timezone import localtime, is_aware
        dt = req.preferred_date
        dt_str = localtime(dt).strftime("%Y-%m-%d %H:%M") if dt and is_aware(dt) else str(dt)
        target = req.doctor
        if target is not None:
            Notification.objects.create(
                user=target,
                title="🔔 New Paid Appointment Request",
                message=f"Patient {req.requested_by.username} requested '{req.title}' on {dt_str}.",
                category="appointment",
            )
    except Exception as exc:  # noqa: BLE001
        logger.error("notify doctor failed: %s", exc)


# ─── Webhook ────────────────────────────────────────────────────────────────

@transaction.atomic
def apply_webhook(payload: dict) -> Payment | None:
    """
    Process a decrypted ShamCash webhook payload {billNo, tranId, statusId, ...}.
    Idempotent: replays for an already-final payment are safely ignored.
    """
    bill_no = payload.get("billNo")
    status_id = payload.get("statusId")
    tran_id = payload.get("tranId")

    WebhookEvent.objects.create(
        bill_no=bill_no or "", status_id=status_id, tran_id=tran_id, payload=payload,
    )

    if not bill_no:
        return None
    payment = Payment.objects.select_for_update().filter(bill_no=bill_no).first()
    if payment is None:
        logger.warning("webhook for unknown bill_no=%s", bill_no)
        return None

    payment.shamcash_status_id = status_id
    if _sync_status_from_shamcash(payment, status_id, tran_id):
        payment.save()
    else:
        payment.save(update_fields=["shamcash_status_id", "updated_at"])
    return payment


# ─── Refunds ────────────────────────────────────────────────────────────────

@transaction.atomic
def refund_payment(payment: Payment, reason: str = "") -> Payment:
    """
    Fully refund a paid booking fee to the patient via ShamCash refundBill.
    No-op (returns unchanged) if the payment isn't in a refundable state.
    Uses a stable idempotency key so retries never double-refund.
    """
    payment = Payment.objects.select_for_update().get(pk=payment.pk)
    if not payment.is_refundable:
        return payment

    if not payment.refund_idempotency_key:
        payment.refund_idempotency_key = uuid.uuid4().hex  # 32 chars, within 10-100
        payment.save(update_fields=["refund_idempotency_key"])

    client = shamcash.get_client()
    try:
        resp = client.refund_bill(
            bill_no=payment.bill_no,
            amount=payment.amount,
            idempotency_key=payment.refund_idempotency_key,
            note=reason or "MedixPro auto-refund",
        )
    except shamcash.ShamCashError as exc:
        logger.error("refund transport error for %s: %s", payment.bill_no, exc)
        raise PaymentError(f"Refund gateway error: {exc.message}") from exc

    if not resp.ok:
        logger.error("refund rejected for %s: result=%s msg=%s",
                     payment.bill_no, resp.result, resp.message)
        raise PaymentError(resp.message or "Refund was rejected by the gateway.")

    payment.status = Payment.Status.REFUNDED
    payment.refunded_amount = payment.amount
    payment.refunded_at = timezone.now()
    payment.refund_reason = (reason or "")[:255]
    if isinstance(resp.data, dict) and resp.data.get("tranId") is not None:
        payment.refund_tran_id = resp.data["tranId"]
    payment.save()
    return payment


def try_refund(payment: Payment | None, reason: str = "") -> None:
    """Best-effort refund used from request/appointment lifecycle hooks."""
    if payment is None:
        return
    try:
        refund_payment(payment, reason)
    except PaymentError as exc:
        logger.error("auto-refund failed for %s: %s",
                     getattr(payment, "bill_no", "?"), exc)


def refund_for_request(req: AppointmentRequest, reason: str) -> None:
    try_refund(getattr(req, "payment", None), reason)


def refund_for_appointment(appointment: Appointment, reason: str) -> None:
    req = getattr(appointment, "from_request", None)
    if req is not None:
        try_refund(getattr(req, "payment", None), reason)


# ─── Payouts ────────────────────────────────────────────────────────────────

def qualifying_payments(year: int, month: int):
    """
    Paid, non-refunded bookings whose visit was Completed in the given month.
    A completed appointment is reached via request → appointment.
    """
    return Payment.objects.filter(
        status=Payment.Status.PAID,
        appointment_request__appointment__status=Appointment.Status.COMPLETED,
        appointment_request__appointment__completed_at__year=year,
        appointment_request__appointment__completed_at__month=month,
    ).select_related("doctor")


def compute_payouts(year: int, month: int) -> list[dict]:
    """Aggregate what each doctor is owed for a month (no DB writes)."""
    rows = (
        qualifying_payments(year, month)
        .values("doctor_id", "currency_id")
        .annotate(handled_count=Count("id"), total_amount=Sum("amount"))
        .order_by("doctor_id")
    )
    return [dict(r) for r in rows]


@transaction.atomic
def build_settlements(year: int, month: int) -> list[PayoutSettlement]:
    """Materialise/refresh PayoutSettlement rows for a month. Skips already-paid ones."""
    results = []
    for row in compute_payouts(year, month):
        settlement, _ = PayoutSettlement.objects.get_or_create(
            doctor_id=row["doctor_id"], period_year=year, period_month=month,
            defaults={"currency_id": row["currency_id"]},
        )
        if settlement.status == PayoutSettlement.Status.PAID:
            continue
        settlement.handled_count = row["handled_count"]
        settlement.total_amount = row["total_amount"] or Decimal("0")
        settlement.currency_id = row["currency_id"]
        settlement.save()
        results.append(settlement)
    return results
