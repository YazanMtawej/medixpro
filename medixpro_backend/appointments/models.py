from django.db import models
from django.conf import settings
from patients.models import Patient


class Appointment(models.Model):
    # ... نفس الكود السابق بدون تغيير ...
    class Status(models.TextChoices):
        SCHEDULED   = "scheduled",   "Scheduled"
        COMPLETED   = "completed",   "Completed"
        CANCELLED   = "cancelled",   "Cancelled"
        NO_SHOW     = "no_show",     "No Show"
        RESCHEDULED = "rescheduled", "Rescheduled"

    class Type(models.TextChoices):
        GENERAL      = "general",      "General Checkup"
        FOLLOW_UP    = "follow_up",    "Follow Up"
        CONSULTATION = "consultation", "Consultation"
        EMERGENCY    = "emergency",    "Emergency"
        LAB_RESULTS  = "lab_results",  "Lab Results Review"
        PROCEDURE    = "procedure",    "Procedure"
        VACCINATION  = "vaccination",  "Vaccination"

    patient          = models.ForeignKey(Patient, on_delete=models.CASCADE, related_name="appointments")
    title            = models.CharField(max_length=255)
    type             = models.CharField(max_length=20, choices=Type.choices, default=Type.GENERAL)
    date_time        = models.DateTimeField()
    duration_minutes = models.PositiveIntegerField(default=30)
    status           = models.CharField(max_length=20, choices=Status.choices, default=Status.SCHEDULED)
    reason           = models.TextField(blank=True)
    symptoms         = models.TextField(blank=True)
    diagnosis        = models.TextField(blank=True)
    notes            = models.TextField(blank=True)
    follow_up_date   = models.DateField(null=True, blank=True)
    created_at       = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    updated_at       = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-date_time"]

    def __str__(self):
        return f"{self.title} — {self.patient.name}"


class AppointmentRequest(models.Model):
    """طلب موعد من المريض للطبيب"""

    class RequestStatus(models.TextChoices):
        PENDING   = "pending",   "Pending"
        ACCEPTED  = "accepted",  "Accepted"
        REJECTED  = "rejected",  "Rejected"
        SUGGESTED = "suggested", "Doctor Suggested Alternative"

    patient         = models.ForeignKey(
                        Patient,
                        on_delete=models.CASCADE,
                        related_name="appointment_requests",
                      )
    requested_by    = models.ForeignKey(
                        settings.AUTH_USER_MODEL,
                        on_delete=models.CASCADE,
                        related_name="sent_requests",
                      )
    doctor          = models.ForeignKey(
                        settings.AUTH_USER_MODEL,
                        on_delete=models.SET_NULL,
                        null=True,
                        blank=True,
                        related_name="received_requests",
                      )
    title           = models.CharField(max_length=255)
    type            = models.CharField(
                        max_length=20,
                        choices=Appointment.Type.choices,
                        default=Appointment.Type.GENERAL,
                      )
    preferred_date  = models.DateTimeField()
    reason          = models.TextField(blank=True)
    symptoms        = models.TextField(blank=True)
    status          = models.CharField(
                        max_length=20,
                        choices=RequestStatus.choices,
                        default=RequestStatus.PENDING,
                      )
    # عند اقتراح الطبيب موعداً بديلاً
    suggested_date  = models.DateTimeField(null=True, blank=True)
    doctor_note     = models.TextField(blank=True)
    # الـ appointment المُنشأ بعد القبول
    appointment     = models.OneToOneField(
                        Appointment,
                        on_delete=models.SET_NULL,
                        null=True,
                        blank=True,
                        related_name="from_request",
                      )
    created_at      = models.DateTimeField(auto_now_add=True)
    updated_at      = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.patient.name} → {self.title} ({self.status})"