from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from patients.models import Patient

User = get_user_model()


class Command(BaseCommand):
    help = "Create Patient records for existing patient users who don't have one"

    def handle(self, *args, **options):
        patients_fixed = 0
        users = User.objects.filter(role="patient")

        for user in users:
            if not hasattr(user, "patient_profile") or user.patient_profile is None:
                Patient.objects.create(
                    user   = user,
                    name   = user.get_full_name() or user.username,
                    age    = 0,
                    gender = Patient.Gender.MALE,
                    phone  = "",
                )
                patients_fixed += 1
                self.stdout.write(f"✅ Created patient profile for: {user.username}")

        self.stdout.write(self.style.SUCCESS(
            f"\nDone. Fixed {patients_fixed} user(s)."
        ))