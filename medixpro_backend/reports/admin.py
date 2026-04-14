from django.contrib import admin
from .models import Report


@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display         = ("id", "title", "patient", "status", "created_at")
    search_fields        = ("title", "diagnosis", "patient__name")
    list_filter          = ("status", "created_at")
    list_select_related  = ("patient",)
    ordering             = ("-created_at",)
    filter_horizontal    = ("medications",)