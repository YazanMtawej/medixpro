from rest_framework import serializers
from .models import Patient


class PatientSerializer(serializers.ModelSerializer):

    class Meta:
        model = Patient
        fields = [
            "id",
            "name",
            "age",
            "phone",
            "gender",
            "birth_date",
            "notes",
            "created_at",
        ]

    def validate_age(self, value):
        if value <= 0 or value > 120:
            raise serializers.ValidationError("Age must be between 1 and 120")
        return value

    def validate_phone(self, value):
        if len(value) < 7:
            raise serializers.ValidationError("Invalid phone number")
        return value