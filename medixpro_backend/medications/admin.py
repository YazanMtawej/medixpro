from django.contrib import admin
from .models import Medication, CommonMedication


@admin.register(CommonMedication)
class CommonMedicationAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "category")
    search_fields = ("name", "category")


@admin.register(Medication)
class MedicationAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "patient", "dosage", "frequency", "route", "created_at")
    search_fields = ("name", "patient__name")
    list_filter = ("frequency", "route", "created_at")