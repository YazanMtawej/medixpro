from django.db import models
from patients.models import Patient
from medications.models import Medication
from appointments.models import Appointment


class Report(models.Model):

    class Status(models.TextChoices):
        DRAFT = "draft", "Draft"
        FINAL = "final", "Final"

    patient     = models.ForeignKey(
                    Patient,
                    on_delete=models.CASCADE,
                    related_name="reports",
                  )
    appointment = models.ForeignKey(
                    Appointment,
                    on_delete=models.SET_NULL,
                    null=True,
                    blank=True,
                    related_name="reports",
                  )
    medications = models.ManyToManyField(
                    Medication,
                    blank=True,
                    related_name="reports",
                  )

    title       = models.CharField(max_length=255)
    status      = models.CharField(
                    max_length=10,
                    choices=Status.choices,
                    default=Status.DRAFT,
                  )

    # ─── Clinical ─────────────────────────────────────────────────────
    chief_complaint  = models.TextField(blank=True)   # الشكوى الرئيسية
    history          = models.TextField(blank=True)   # التاريخ المرضي
    examination      = models.TextField(blank=True)   # نتائج الفحص
    diagnosis        = models.TextField()
    treatment_plan   = models.TextField(blank=True)   # خطة العلاج
    notes = models.TextField(null=True, blank=True)
    follow_up_date   = models.DateField(null=True, blank=True)

    created_at  = models.DateTimeField(auto_now_add=True)
    updated_at  = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return f"{self.title} — {self.patient.name}"