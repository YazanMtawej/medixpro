from rest_framework import serializers
from .models import Medication, CommonMedication


class CommonMedicationSerializer(serializers.ModelSerializer):
    class Meta:
        model = CommonMedication
        fields = ["id", "name", "category"]


class MedicationSerializer(serializers.ModelSerializer):
    patient_name = serializers.CharField(source="patient.name", read_only=True)

    class Meta:
        model = Medication
        fields = [
            "id",
            "patient",
            "patient_name",
            "name",
            "dosage",
            "frequency",
            "route",
            "duration_days",
            "start_date",
            "end_date",
            "instructions",
            "notes",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "patient_name", "created_at", "updated_at"]

    def validate_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Medication name is required")
        return value.strip()

    def validate_dosage(self, value):
        if not value.strip():
            raise serializers.ValidationError("Dosage is required")
        return value.strip()