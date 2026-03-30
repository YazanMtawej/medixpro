from django.contrib import admin
from .models import Medication


@admin.register(Medication)
class MedicationAdmin(admin.ModelAdmin):

    list_display = (
        "id",
        "patient",
        "name",
        "description",
        "dosage",
        "created_at",
    )

    search_fields = ("name", "patient__name")

    list_filter = ("created_at",)