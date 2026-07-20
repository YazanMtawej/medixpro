from rest_framework import serializers
from .models import Appointment, AppointmentRequest


class AppointmentSerializer(serializers.ModelSerializer):
    patient_name  = serializers.CharField(source="patient.name",  read_only=True)
    patient_phone = serializers.CharField(source="patient.phone", read_only=True)
    patient_age   = serializers.IntegerField(source="patient.age", read_only=True)

    class Meta:
        model  = Appointment
        fields = [
            "id", "patient", "patient_name", "patient_phone", "patient_age",
            "title", "type", "date_time", "duration_minutes", "status",
            "reason", "symptoms", "diagnosis", "notes", "follow_up_date",
            "created_at", "updated_at",
        ]
        read_only_fields = [
            "id", "patient_name", "patient_phone", "patient_age",
            "created_at", "updated_at",
        ]


class AppointmentRequestSerializer(serializers.ModelSerializer):
    patient_name      = serializers.CharField(source="patient.name",          read_only=True)
    doctor_name       = serializers.SerializerMethodField()
    requested_by_name = serializers.CharField(source="requested_by.username", read_only=True)

    # 📍 موقع عيادة الطبيب الذي قبل الطلب — يظهر للمريض بعد القبول
    doctor_clinic_name = serializers.SerializerMethodField()
    doctor_address     = serializers.SerializerMethodField()
    doctor_latitude    = serializers.SerializerMethodField()
    doctor_longitude   = serializers.SerializerMethodField()

    # 💳 Booking-fee payment status
    payment_status = serializers.SerializerMethodField()
    payment_amount = serializers.SerializerMethodField()

    class Meta:
        model  = AppointmentRequest
        fields = [
            "id",
            "patient", "patient_name",
            "requested_by", "requested_by_name",
            "doctor", "doctor_name",
            "doctor_clinic_name", "doctor_address",
            "doctor_latitude", "doctor_longitude",
            "title", "type",
            "preferred_date", "reason", "symptoms",
            "status", "awaiting_payment", "suggested_date", "doctor_note",
            "payment_status", "payment_amount",
            "appointment", "created_at", "updated_at",
        ]
        read_only_fields = [
            "id",
            # ✅ هذه تُعيَّن server-side — لا يرسلها الـ client
            "patient", "patient_name",
            "requested_by", "requested_by_name",
            "doctor", "doctor_name",
            "doctor_clinic_name", "doctor_address",
            "doctor_latitude", "doctor_longitude",
            "status", "awaiting_payment", "suggested_date", "doctor_note",
            "payment_status", "payment_amount",
            "appointment", "created_at", "updated_at",
        ]

    def get_payment_status(self, obj):
        payment = getattr(obj, "payment", None)
        return payment.status if payment else None

    def get_payment_amount(self, obj):
        payment = getattr(obj, "payment", None)
        return str(payment.amount) if payment else None

    def get_doctor_name(self, obj):
        if not obj.doctor:
            return ""
        return obj.doctor.get_full_name() or obj.doctor.username

    def _doctor_profile(self, obj):
        if not obj.doctor:
            return None
        return getattr(obj.doctor, "profile", None)

    def get_doctor_clinic_name(self, obj):
        profile = self._doctor_profile(obj)
        return profile.clinic_name if profile else ""

    def get_doctor_address(self, obj):
        profile = self._doctor_profile(obj)
        return profile.address if profile else ""

    def get_doctor_latitude(self, obj):
        profile = self._doctor_profile(obj)
        return profile.latitude if profile else None

    def get_doctor_longitude(self, obj):
        profile = self._doctor_profile(obj)
        return profile.longitude if profile else None