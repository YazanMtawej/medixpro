from django.db import models
from patients.models import Patient
from medications.models import Medication
from appointments.models import Appointment

class Report(models.Model):
    STATUS_CHOICES = (
        ('draft', 'Draft'),
        ('final', 'Final'),
    )

    title = models.CharField(max_length=255)
    diagnosis = models.TextField()
    notes = models.TextField(blank=True, null=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='draft')
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE, related_name='reports')
    medications = models.ManyToManyField(Medication, blank=True, related_name='reports')
    appointment = models.ForeignKey(Appointment, on_delete=models.CASCADE, related_name='reports')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} - {self.patient.name}"