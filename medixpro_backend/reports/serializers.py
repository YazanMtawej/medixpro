from rest_framework import serializers
from .models import Report
from medications.models import Medication
from patients.models import Patient
from appointments.models import Appointment

class ReportSerializer(serializers.ModelSerializer):
    medication_ids = serializers.PrimaryKeyRelatedField(
        source='medications',
        queryset=Medication.objects.all(),
        many=True
    )

    class Meta:
        model = Report
        fields = [
            "id",
            "title",
            "diagnosis",
            "notes",
            "status",
            "patient_id",
            "medication_ids",
            "appointment_id",
            "created_at"
        ]

    def create(self, validated_data):
        medications_data = validated_data.pop('medications', [])
        report = Report.objects.create(**validated_data)
        report.medications.set(medications_data)
        return report

    def update(self, instance, validated_data):
        medications_data = validated_data.pop('medications', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        if medications_data is not None:
            instance.medications.set(medications_data)
        instance.save()
        return instance