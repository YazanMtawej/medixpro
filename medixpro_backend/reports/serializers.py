from rest_framework import serializers
from .models import Report
from medications.serializers import MedicationSerializer
from appointments.serializers import AppointmentSerializer


class ReportSerializer(serializers.ModelSerializer):
    # ─── Read-only enriched fields ─────────────────────────────────────
    patient_name        = serializers.CharField(source="patient.name",        read_only=True)
    patient_age         = serializers.IntegerField(source="patient.age",      read_only=True)
    patient_phone       = serializers.CharField(source="patient.phone",       read_only=True)
    patient_blood_type  = serializers.CharField(source="patient.blood_type",  read_only=True)
    patient_allergies   = serializers.CharField(source="patient.allergies",   read_only=True)

    appointment_detail  = AppointmentSerializer(source="appointment", read_only=True)
    medications_detail  = MedicationSerializer(source="medications",  read_only=True, many=True)

    # ─── Write fields ──────────────────────────────────────────────────
    medication_ids = serializers.PrimaryKeyRelatedField(
        source="medications",
        queryset=__import__("medications.models", fromlist=["Medication"]).Medication.objects.all(),
        many=True,
        write_only=True,
        required=False,
    )

    class Meta:
        model  = Report
        fields = [
            "id",
            # Patient info
            "patient",
            "patient_name",
            "patient_age",
            "patient_phone",
            "patient_blood_type",
            "patient_allergies",
            # Appointment
            "appointment",
            "appointment_detail",
            # Medications
            "medication_ids",
            "medications_detail",
            # Report fields
            "title",
            "status",
            "chief_complaint",
            "history",
            "examination",
            "diagnosis",
            "treatment_plan",
            "notes",
            "follow_up_date",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id", "patient_name", "patient_age", "patient_phone",
            "patient_blood_type", "patient_allergies",
            "appointment_detail", "medications_detail",
            "created_at", "updated_at",
        ]

    def create(self, validated_data):
        medications = validated_data.pop("medications", [])
        report = Report.objects.create(**validated_data)
        report.medications.set(medications)
        return report

    def update(self, instance, validated_data):
        medications = validated_data.pop("medications", None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        if medications is not None:
            instance.medications.set(medications)
        instance.save()
        return instance