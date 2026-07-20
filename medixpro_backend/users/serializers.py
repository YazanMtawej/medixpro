from decimal import Decimal

from django.conf import settings as django_settings
from rest_framework import serializers
from .models import Profile, User


class ProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source="user.username", read_only=True)
    email = serializers.EmailField(source="user.email", read_only=True)
    role = serializers.CharField(source="user.role", read_only=True)
    booking_fee = serializers.SerializerMethodField()

    class Meta:
        model = Profile
        fields = [
            "username",
            "email",
            "role",
            "full_name",
            "clinic_name",
            "address",
            "latitude",
            "longitude",
            "avatar",
            "receipt_amount",
            "booking_fee",
        ]

    def get_booking_fee(self, obj):
        """The percentage of the receipt the patient actually pays to book."""
        if obj.receipt_amount is None:
            return None
        rate = Decimal(str(getattr(django_settings, "PLATFORM_FEE_RATE", "0.20")))
        return str((obj.receipt_amount * rate).quantize(Decimal("0.01")))