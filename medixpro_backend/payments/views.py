import logging

from django.shortcuts import render
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from core.utils import api_response
from . import services, shamcash
from .models import Payment, PayoutSettlement
from .serializers import PaymentSerializer, PayoutSettlementSerializer

logger = logging.getLogger("payments")

# How long after creation before we trust getBillInfo as a fallback (doc: ~10 min).
_FALLBACK_AFTER_SECONDS = 600


class BookAppointmentView(APIView):
    """
    Patient books a specific doctor and pays the booking fee.
    Creates a payment-gated request + ShamCash bill, returns the payment_url.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.is_doctor():
            return Response(api_response(False, "Doctors cannot book appointments."), status=403)

        doctor_id = request.data.get("doctor")
        if not doctor_id:
            return Response(api_response(False, "A doctor must be selected."), status=400)

        from django.contrib.auth import get_user_model
        User = get_user_model()
        doctor = User.objects.filter(id=doctor_id, role=User.Role.DOCTOR).first()
        if doctor is None:
            return Response(api_response(False, "Selected doctor not found."), status=404)

        title = (request.data.get("title") or "").strip()
        preferred_date = request.data.get("preferred_date")
        if not title:
            return Response(api_response(False, "Title is required."), status=400)
        if not preferred_date:
            return Response(api_response(False, "Preferred date is required."), status=400)

        try:
            payment = services.create_booking_payment(
                patient_user=request.user,
                doctor_user=doctor,
                request_data={
                    "title": title,
                    "type": request.data.get("type", "general"),
                    "preferred_date": preferred_date,
                    "reason": request.data.get("reason", ""),
                    "symptoms": request.data.get("symptoms", ""),
                },
            )
        except services.PaymentError as exc:
            return Response(api_response(False, str(exc)), status=400)
        except Exception as exc:  # noqa: BLE001
            logger.exception("book error: %s", exc)
            return Response(api_response(False, "Failed to start payment. Please try again."), status=500)

        return Response(
            api_response(True, "Payment initiated", {
                "payment_id": payment.id,
                "request_id": payment.appointment_request_id,
                "bill_no": payment.bill_no,
                "amount": str(payment.amount),
                "currency_id": payment.currency_id,
                "payment_url": payment.payment_url,
                "status": payment.status,
            }),
            status=201,
        )


class PaymentStatusView(APIView):
    """
    Patient polls their payment. Falls back to getBillInfo only after the
    ShamCash safety window if we still haven't heard from the webhook.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        payment = Payment.objects.filter(pk=pk, patient=request.user).first()
        if payment is None:
            return Response(api_response(False, "Payment not found."), status=404)

        if payment.status == Payment.Status.PENDING:
            age = (services.timezone.now() - payment.created_at).total_seconds()
            if age >= _FALLBACK_AFTER_SECONDS:
                self._reconcile(payment)

        return Response(api_response(True, "Payment status", PaymentSerializer(payment).data))

    @staticmethod
    def _reconcile(payment):
        try:
            info = shamcash.get_client().get_bill_info(payment.bill_no)
            if info.ok and isinstance(info.data, dict):
                services.apply_webhook({
                    "billNo": payment.bill_no,
                    "statusId": info.data.get("statusId"),
                    "tranId": info.data.get("tranId"),
                })
                payment.refresh_from_db()
        except shamcash.ShamCashError as exc:
            logger.error("fallback getBillInfo failed for %s: %s", payment.bill_no, exc)


@method_decorator(csrf_exempt, name="dispatch")
class ShamCashWebhookView(APIView):
    """
    Server-to-server callback. ShamCash POSTs {"encData": JWE}; we decrypt with
    our secret key, apply the state change idempotently, and return 200 quickly.
    """
    permission_classes = [AllowAny]
    authentication_classes = []

    def post(self, request):
        enc = request.data.get("encData")
        if not enc:
            return Response(api_response(False, "Missing encData"), status=400)
        try:
            payload = shamcash.get_client().decrypt(enc)
        except shamcash.ShamCashError as exc:
            logger.warning("webhook decrypt rejected: %s", exc)
            # 400 tells ShamCash the payload was invalid (not a processing failure).
            return Response(api_response(False, "Invalid payload"), status=400)

        try:
            services.apply_webhook(payload)
        except Exception as exc:  # noqa: BLE001
            logger.exception("webhook processing error: %s", exc)
            # Return 500 so ShamCash retries; our processing is idempotent.
            return Response(api_response(False, "Processing error"), status=500)

        return Response(api_response(True, "OK"))


class PaymentRedirectView(APIView):
    """Landing page ShamCash returns the user's browser to after checkout."""
    permission_classes = [AllowAny]
    authentication_classes = []

    def get(self, request):
        bill_no = request.query_params.get("bill_no", "")
        payment = Payment.objects.filter(bill_no=bill_no).first() if bill_no else None
        return render(request, "payments/redirect.html", {
            "payment": payment,
            "status": payment.status if payment else "unknown",
        })


class PayoutView(APIView):
    """
    Admin-only monthly payout review.
    GET  ?year=&month=  → build/refresh settlements and return them.
    POST {settlement_id, paid_reference, note} → mark a settlement paid.
    """
    permission_classes = [IsAuthenticated]

    def _guard(self, request):
        return request.user.is_staff or request.user.is_superuser

    def get(self, request):
        if not self._guard(request):
            return Response(api_response(False, "Admins only."), status=403)
        now = services.timezone.now()
        try:
            year = int(request.query_params.get("year", now.year))
            month = int(request.query_params.get("month", now.month))
        except (TypeError, ValueError):
            return Response(api_response(False, "Invalid year/month."), status=400)

        services.build_settlements(year, month)
        qs = PayoutSettlement.objects.filter(period_year=year, period_month=month)
        return Response(api_response(True, "Payouts", {
            "year": year, "month": month,
            "settlements": PayoutSettlementSerializer(qs, many=True).data,
        }))

    def post(self, request):
        if not self._guard(request):
            return Response(api_response(False, "Admins only."), status=403)
        settlement = PayoutSettlement.objects.filter(pk=request.data.get("settlement_id")).first()
        if settlement is None:
            return Response(api_response(False, "Settlement not found."), status=404)
        settlement.status = PayoutSettlement.Status.PAID
        settlement.paid_reference = (request.data.get("paid_reference") or "")[:120]
        settlement.note = request.data.get("note", "")
        settlement.paid_at = services.timezone.now()
        settlement.save()
        return Response(api_response(True, "Settlement marked paid",
                                     PayoutSettlementSerializer(settlement).data))
