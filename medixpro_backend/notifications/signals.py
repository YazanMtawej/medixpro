from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model

from patients.models     import Patient
from appointments.models import Appointment
from medications.models  import Medication
from reports.models      import Report
from .models             import Notification

User = get_user_model()


def _notify_all_doctors(title: str, message: str, category: str):
    """ترسل إشعاراً لكل الأطباء."""
    doctors = User.objects.filter(role="doctor")
    Notification.objects.bulk_create([
        Notification(
            user=d, title=title, message=message, category=category
        )
        for d in doctors
    ])


def _notify_user(user, title: str, message: str, category: str):
    Notification.objects.create(
        user=user, title=title, message=message, category=category
    )


# ─── Patient ──────────────────────────────────────────────────────────────────
@receiver(post_save, sender=Patient)
def on_patient_saved(sender, instance, created, **kwargs):
    if created:
        _notify_all_doctors(
            title="New Patient Added",
            message=f"Patient '{instance.name}' has been registered.",
            category=Notification.Category.PATIENT,
        )


# ─── Appointment ──────────────────────────────────────────────────────────────
@receiver(post_save, sender=Appointment)
def on_appointment_saved(sender, instance, created, **kwargs):
    if created:
        _notify_all_doctors(
            title="New Appointment Scheduled",
            message=f"Appointment '{instance.title}' for {instance.patient.name} on "
                    f"{instance.date_time.strftime('%Y-%m-%d %H:%M')}.",
            category=Notification.Category.APPOINTMENT,
        )
    else:
        if instance.status in ["completed", "cancelled", "no_show"]:
            _notify_all_doctors(
                title=f"Appointment {instance.status.title()}",
                message=f"'{instance.title}' for {instance.patient.name} is now {instance.status}.",
                category=Notification.Category.APPOINTMENT,
            )


# ─── Medication ───────────────────────────────────────────────────────────────
@receiver(post_save, sender=Medication)
def on_medication_saved(sender, instance, created, **kwargs):
    if created:
        _notify_all_doctors(
            title="Prescription Added",
            message=f"{instance.name} ({instance.dosage}) prescribed to {instance.patient.name}.",
            category=Notification.Category.MEDICATION,
        )


# ─── Report ───────────────────────────────────────────────────────────────────
@receiver(post_save, sender=Report)
def on_report_saved(sender, instance, created, **kwargs):
    if created:
        _notify_all_doctors(
            title="New Medical Report",
            message=f"Report '{instance.title}' created for {instance.patient.name}.",
            category=Notification.Category.REPORT,
        )
    elif instance.status == "final":
        _notify_all_doctors(
            title="Report Finalized",
            message=f"Report '{instance.title}' for {instance.patient.name} is now final.",
            category=Notification.Category.REPORT,
        )