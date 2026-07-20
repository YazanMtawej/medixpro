from __future__ import annotations

from decimal import Decimal

from django.conf import settings
from django.db import models


class Payment(models.Model):
    """
    A patient's booking-fee payment (the platform's percentage of a doctor's
    receipt) collected through ShamCash into the MedixPro agent account.

    The full receipt amount and fee rate are *snapshotted* at booking time so
    later edits to a doctor's receipt never change historical money math.
    """

    class Status(models.TextChoices):
        PENDING = "pending", "Pending"           # bill created, awaiting payment
        PAID = "paid", "Paid"
        EXPIRED = "expired", "Expired"           # not paid within ShamCash's 10-min window
        FAILED = "failed", "Failed"              # createBill / gateway error
        REFUNDED = "refunded", "Refunded"        # fully refunded to the patient
        PARTLY_REFUNDED = "partly_refunded", "Partly Refunded"

    # A refunded payment never counts toward a doctor payout.
    REFUND_STATES = (Status.REFUNDED, Status.PARTLY_REFUNDED)

    appointment_request = models.OneToOneField(
        "appointments.AppointmentRequest",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="payment",
    )
    patient = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="payments_made"
    )
    doctor = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="payments_received"
    )

    # Unique bill number sent to ShamCash. We append an attempt suffix on retries
    # (doc recommendation: decouple from internal ids, e.g. MEDIX-12-1).
    bill_no = models.CharField(max_length=64, unique=True)
    attempt = models.PositiveIntegerField(default=1)

    # Money (snapshots).
    receipt_amount = models.DecimalField(max_digits=18, decimal_places=2)
    fee_rate = models.DecimalField(max_digits=5, decimal_places=4, default=Decimal("0.20"))
    amount = models.DecimalField(max_digits=18, decimal_places=2)  # = receipt_amount * fee_rate
    currency_id = models.PositiveSmallIntegerField(default=2)      # 1=USD, 2=SYP

    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    shamcash_status_id = models.PositiveSmallIntegerField(null=True, blank=True)

    payment_url = models.TextField(blank=True)
    tran_id = models.BigIntegerField(null=True, blank=True)        # ShamCash payment tranId

    # Refund tracking.
    refund_idempotency_key = models.CharField(max_length=100, blank=True)
    refund_tran_id = models.BigIntegerField(null=True, blank=True)
    refunded_amount = models.DecimalField(max_digits=18, decimal_places=2, default=Decimal("0"))
    refund_reason = models.CharField(max_length=255, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    refunded_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["doctor", "status"]),
            models.Index(fields=["status", "paid_at"]),
        ]

    def __str__(self) -> str:
        return f"{self.bill_no} — {self.amount} ({self.status})"

    @property
    def is_refundable(self) -> bool:
        return self.status == self.Status.PAID


class PayoutSettlement(models.Model):
    """
    A monthly settlement of what MedixPro owes a doctor: the sum of booking-fee
    amounts for the doctor's completed, paid, non-refunded visits in that month.

    The actual money transfer to the doctor is done out-of-band by the admin
    (the ShamCash E-Pay API has no third-party payout endpoint); this record
    tracks the amount owed and whether it was paid.
    """

    class Status(models.TextChoices):
        DUE = "due", "Due"
        PAID = "paid", "Paid"

    doctor = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="payout_settlements"
    )
    period_year = models.PositiveIntegerField()
    period_month = models.PositiveSmallIntegerField()  # 1-12

    handled_count = models.PositiveIntegerField(default=0)
    total_amount = models.DecimalField(max_digits=18, decimal_places=2, default=Decimal("0"))
    currency_id = models.PositiveSmallIntegerField(default=2)

    status = models.CharField(max_length=10, choices=Status.choices, default=Status.DUE)
    paid_reference = models.CharField(max_length=120, blank=True)  # transfer ref entered by admin
    note = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    paid_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ["-period_year", "-period_month"]
        unique_together = ("doctor", "period_year", "period_month")

    def __str__(self) -> str:
        return f"{self.doctor} {self.period_year}-{self.period_month:02d}: {self.total_amount}"


class WebhookEvent(models.Model):
    """Audit + idempotency log for inbound ShamCash callbacks."""

    bill_no = models.CharField(max_length=64, db_index=True)
    status_id = models.PositiveSmallIntegerField(null=True, blank=True)
    tran_id = models.BigIntegerField(null=True, blank=True)
    payload = models.JSONField(default=dict, blank=True)
    processed = models.BooleanField(default=False)
    received_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-received_at"]

    def __str__(self) -> str:
        return f"webhook {self.bill_no} status={self.status_id}"
