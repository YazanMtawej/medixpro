from django.db import models


class Patient(models.Model):

    class Gender(models.TextChoices):
     MALE = "male", "Male"      # ✅ lowercase
     FEMALE = "female", "Female"

    class BloodType(models.TextChoices):
        A_POS = "A+", "A+"
        A_NEG = "A-", "A-"
        B_POS = "B+", "B+"
        B_NEG = "B-", "B-"
        AB_POS = "AB+", "AB+"
        AB_NEG = "AB-", "AB-"
        O_POS = "O+", "O+"
        O_NEG = "O-", "O-"
        UNKNOWN = "unknown", "Unknown"

    # ─── Basic Info ───────────────────────────────────────────────────────────
    name            = models.CharField(max_length=120)
    age             = models.PositiveIntegerField()
    gender          = models.CharField(max_length=10, choices=Gender.choices)
    birth_date      = models.DateField(null=True, blank=True)
    national_id     = models.CharField(max_length=20, blank=True)

    # ─── Contact ──────────────────────────────────────────────────────────────
    phone           = models.CharField(max_length=20)
    email           = models.EmailField(blank=True)
    address         = models.TextField(blank=True)
    emergency_contact_name  = models.CharField(max_length=120, blank=True)
    emergency_contact_phone = models.CharField(max_length=20, blank=True)

    # ─── Medical Info ─────────────────────────────────────────────────────────
    blood_type      = models.CharField(
                        max_length=10,
                        choices=BloodType.choices,
                        default=BloodType.UNKNOWN,
                      )
    allergies       = models.TextField(blank=True)
    chronic_diseases = models.TextField(blank=True)
    previous_surgeries = models.TextField(blank=True)
    current_medications = models.TextField(blank=True)
    notes           = models.TextField(blank=True)

    created_at      = models.DateTimeField(auto_now_add=True)
    updated_at      = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return f"{self.name} ({self.age})"