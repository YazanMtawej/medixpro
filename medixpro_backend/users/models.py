from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    class Role(models.TextChoices):
        DOCTOR = "doctor", "Doctor"
        PATIENT = "patient", "Patient"

    phone = models.CharField(max_length=20, blank=True)
    role = models.CharField(
        max_length=10,
        choices=Role.choices,
        default=Role.PATIENT,
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def is_doctor(self) -> bool:
        return self.role == self.Role.DOCTOR

    def is_patient(self) -> bool:
        return self.role == self.Role.PATIENT

    def __str__(self) -> str:
        return f"{self.username} ({self.role})"


class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    full_name = models.CharField(max_length=120, blank=True)
    clinic_name = models.CharField(max_length=120, blank=True)
    address = models.TextField(blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    avatar = models.ImageField(upload_to="avatars/", blank=True, null=True)
    # Doctor's consultation receipt (full visit price). Patients pay a configured
    # percentage (PLATFORM_FEE_RATE) of this as a booking fee. Set at doctor
    # registration, editable later. In SYP.
    receipt_amount = models.DecimalField(
        max_digits=18, decimal_places=2, null=True, blank=True
    )

    def __str__(self) -> str:
        return f"{self.user.username} - profile"


class UserPoints(models.Model):
    class TransactionType(models.TextChoices):
        CHARGE = "charge", "Charge"
        PURCHASE = "purchase", "Purchase"

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="points")
    amount = models.IntegerField()
    type = models.CharField(max_length=10, choices=TransactionType.choices)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return f"{self.user.username} - {self.type} - {self.amount}"