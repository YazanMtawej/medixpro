from django.db import models
from patients.models import Patient


class CommonMedication(models.Model):
    """قائمة الأدوية الشائعة — يختار منها الطبيب أو يكتب دواء مخصص"""
    name = models.CharField(max_length=120, unique=True)
    category = models.CharField(max_length=80, blank=True)

    def __str__(self) -> str:
        return self.name

    class Meta:
        ordering = ["name"]


class Medication(models.Model):
    class Frequency(models.TextChoices):
        ONCE_DAILY = "once_daily", "Once Daily"
        TWICE_DAILY = "twice_daily", "Twice Daily"
        THREE_TIMES = "three_times_daily", "Three Times Daily"
        FOUR_TIMES = "four_times_daily", "Four Times Daily"
        EVERY_8H = "every_8_hours", "Every 8 Hours"
        EVERY_12H = "every_12_hours", "Every 12 Hours"
        AS_NEEDED = "as_needed", "As Needed"
        WEEKLY = "weekly", "Weekly"

    class Route(models.TextChoices):
        ORAL = "oral", "Oral"
        INJECTION = "injection", "Injection"
        TOPICAL = "topical", "Topical"
        INHALATION = "inhalation", "Inhalation"
        SUBLINGUAL = "sublingual", "Sublingual"
        IV = "iv", "Intravenous (IV)"
        EYE_DROPS = "eye_drops", "Eye Drops"
        EAR_DROPS = "ear_drops", "Ear Drops"

    patient = models.ForeignKey(
        Patient,
        on_delete=models.CASCADE,
        related_name="medications",
    )
    name = models.CharField(max_length=120)
    dosage = models.CharField(max_length=120)          # e.g. "500mg"
    frequency = models.CharField(
        max_length=30,
        choices=Frequency.choices,
        default=Frequency.ONCE_DAILY,
    )
    route = models.CharField(
        max_length=20,
        choices=Route.choices,
        default=Route.ORAL,
    )
    duration_days = models.PositiveIntegerField(null=True, blank=True)  # عدد الأيام
    start_date = models.DateField(null=True, blank=True)
    end_date = models.DateField(null=True, blank=True)
    instructions = models.TextField(blank=True)        # تعليمات خاصة
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return f"{self.name} — {self.patient.name}"