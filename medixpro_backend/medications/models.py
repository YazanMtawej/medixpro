from django.db import models
from patients.models import Patient

class Medication(models.Model):
    patient = models.ForeignKey(
    Patient,
    on_delete=models.CASCADE,
    related_name="medications",
)

    name = models.CharField(max_length=120)
    dosage = models.CharField(max_length=120)
    description = models.TextField()

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} - {self.patient.name}"