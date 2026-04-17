from django.db import models
from django.conf import settings


class Notification(models.Model):

    class Category(models.TextChoices):
        PATIENT     = "patient",     "Patient"
        APPOINTMENT = "appointment", "Appointment"
        REPORT      = "report",      "Report"
        MEDICATION  = "medication",  "Medication"
        AUTH        = "auth",        "Auth"
        SYSTEM      = "system",      "System"
        WARNING     = "warning",     "Warning"

    user       = models.ForeignKey(
                   settings.AUTH_USER_MODEL,
                   on_delete=models.CASCADE,
                   related_name="notifications",
                 )
    title      = models.CharField(max_length=200)
    message    = models.TextField()
    category   = models.CharField(
                   max_length=20,
                   choices=Category.choices,
                   default=Category.SYSTEM,
                 )
    is_read    = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return f"{self.user.username} — {self.title}"