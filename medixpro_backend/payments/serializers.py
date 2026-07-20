from rest_framework import serializers

from .models import Payment, PayoutSettlement


class PaymentSerializer(serializers.ModelSerializer):
    request_id = serializers.IntegerField(source="appointment_request_id", read_only=True)
    doctor_name = serializers.SerializerMethodField()

    class Meta:
        model = Payment
        fields = [
            "id", "bill_no", "request_id",
            "doctor", "doctor_name",
            "receipt_amount", "fee_rate", "amount", "currency_id",
            "status", "shamcash_status_id", "payment_url",
            "refunded_amount", "refund_reason",
            "created_at", "paid_at", "refunded_at",
        ]
        read_only_fields = fields

    def get_doctor_name(self, obj):
        profile = getattr(obj.doctor, "profile", None)
        if profile and profile.full_name:
            return profile.full_name
        return obj.doctor.get_full_name() or obj.doctor.username


class PayoutSettlementSerializer(serializers.ModelSerializer):
    doctor_name = serializers.SerializerMethodField()

    class Meta:
        model = PayoutSettlement
        fields = [
            "id", "doctor", "doctor_name",
            "period_year", "period_month",
            "handled_count", "total_amount", "currency_id",
            "status", "paid_reference", "note",
            "created_at", "paid_at",
        ]
        read_only_fields = [
            "id", "doctor", "doctor_name", "period_year", "period_month",
            "handled_count", "total_amount", "currency_id", "created_at", "paid_at",
        ]

    def get_doctor_name(self, obj):
        profile = getattr(obj.doctor, "profile", None)
        if profile and profile.full_name:
            return profile.full_name
        return obj.doctor.get_full_name() or obj.doctor.username
