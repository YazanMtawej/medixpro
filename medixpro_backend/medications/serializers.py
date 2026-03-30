from rest_framework import serializers
from .models import Medication


class MedicationSerializer(serializers.ModelSerializer):

    patient_name = serializers.CharField(
        source="patient.name",
        read_only=True
    )

    class Meta:
        model = Medication
        fields = [
            "id",
            "patient",
            "patient_name",
            "name",
            "description",
            "dosage",
            "created_at",
        ]

    def validate(self, data):

        if not data.get("name"):
            raise serializers.ValidationError("Name is required")

        if not data.get("dosage"):
            raise serializers.ValidationError("Dosage is required")

        return data