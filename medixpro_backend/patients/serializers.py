from rest_framework import serializers
from .models import Patient


class PatientSerializer(serializers.ModelSerializer):

    class Meta:
        model = Patient
        fields = [
            "id",
            "name",
            "age",
            "gender",
            "birth_date",
            "national_id",
            "phone",
            "email",
            "address",
            "emergency_contact_name",
            "emergency_contact_phone",
            "blood_type",
            "allergies",
            "chronic_diseases",
            "previous_surgeries",
            "current_medications",
            "notes",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at"]

    def validate_age(self, value):
        if value <= 0 or value > 120:
            raise serializers.ValidationError("Age must be between 1 and 120")
        return value

    def validate_phone(self, value):
        if len(value) < 7:
            raise serializers.ValidationError("Invalid phone number")
        return value