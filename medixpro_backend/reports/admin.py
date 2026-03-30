from django.contrib import admin
from .models import Report

@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = ("id", "title", "patient", "status", "short_diagnosis", "created_at")
    search_fields = ("title", "diagnosis", "patient__name")
    list_filter = ("status", "created_at", "patient")
    ordering = ("-created_at",)
    list_select_related = ("patient",)
    list_editable = ("status",)
    fieldsets = (
        ("Basic Info", {"fields": ("title", "patient", "status")}),
        ("Medical Data", {"fields": ("diagnosis", "notes", "medications", "appointment")}),
    )

    def short_diagnosis(self, obj):
        return obj.diagnosis[:50] + "..." if len(obj.diagnosis) > 50 else obj.diagnosis
    short_diagnosis.short_description = "Diagnosis Preview"