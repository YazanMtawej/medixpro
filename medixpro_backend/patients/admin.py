from django.contrib import admin
from .models import Patient


@admin.register(Patient)
class PatientAdmin(admin.ModelAdmin):
    list_display = (
        "id", "name", "age", "gender",
        "phone", "blood_type", "created_at",
    )
    search_fields = ("name", "phone", "national_id", "email")
    list_filter = ("gender", "blood_type")