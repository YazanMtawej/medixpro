from django.contrib import admin
from .models import Appointment


@admin.register(Appointment)
class AppointmentAdmin(admin.ModelAdmin):
    list_display   = ["id", "title", "patient", "type", "date_time", "status", "duration_minutes"]
    list_filter    = ["status", "type", "date_time"]
    search_fields  = ["title", "patient__name"]
    ordering       = ["-date_time"]