from django.db import models
from patients.models import Patient


class Appointment(models.Model):

    class Status(models.TextChoices):
        SCHEDULED  = "scheduled",  "Scheduled"
        COMPLETED  = "completed",  "Completed"
        CANCELLED  = "cancelled",  "Cancelled"
        NO_SHOW    = "no_show",    "No Show"
        RESCHEDULED = "rescheduled", "Rescheduled"

    class Type(models.TextChoices):
        GENERAL       = "general",       "General Checkup"
        FOLLOW_UP     = "follow_up",     "Follow Up"
        CONSULTATION  = "consultation",  "Consultation"
        EMERGENCY     = "emergency",     "Emergency"
        LAB_RESULTS   = "lab_results",   "Lab Results Review"
        PROCEDURE     = "procedure",     "Procedure"
        VACCINATION   = "vaccination",   "Vaccination"

    patient      = models.ForeignKey(
                     Patient,
                     on_delete=models.CASCADE,
                     related_name="appointments",
                   )
    title        = models.CharField(max_length=255)
    type         = models.CharField(
                     max_length=20,
                     choices=Type.choices,
                     default=Type.GENERAL,
                   )
    date_time    = models.DateTimeField()
    duration_minutes = models.PositiveIntegerField(default=30)
    status       = models.CharField(
                     max_length=20,
                     choices=Status.choices,
                     default=Status.SCHEDULED,
                   )
    reason       = models.TextField(blank=True)   # سبب الزيارة
    symptoms     = models.TextField(blank=True)   # الأعراض
    diagnosis    = models.TextField(blank=True)   # التشخيص
    notes        = models.TextField(blank=True)   # ملاحظات الطبيب
    follow_up_date = models.DateField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    updated_at   = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-date_time"]

    def __str__(self) -> str:
        return f"{self.title} — {self.patient.name} ({self.date_time:%Y-%m-%d})"