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
        read_only_fields = ["id", "patient_name", "patient_phone", "patient_age", "created_at", "updated_at"]

    def validate_duration_minutes(self, value):
        if value < 5 or value > 480:
            raise serializers.ValidationError("Duration must be between 5 and 480 minutes")
        return value


class AppointmentRequestSerializer(serializers.ModelSerializer):
    patient_name  = serializers.CharField(source="patient.name",          read_only=True)
    doctor_name   = serializers.CharField(source="doctor.username",        read_only=True)
    requested_by_name = serializers.CharField(source="requested_by.username", read_only=True)

    class Meta:
        model  = AppointmentRequest
        fields = [
            "id", "patient", "patient_name",
            "requested_by", "requested_by_name",
            "doctor", "doctor_name",
            "title", "type", "preferred_date", "reason", "symptoms",
            "status", "suggested_date", "doctor_note",
            "appointment", "created_at", "updated_at",
        ]
        read_only_fields = [
            "id", "patient_name", "doctor_name", "requested_by_name",
            "appointment", "created_at", "updated_at",
        ]