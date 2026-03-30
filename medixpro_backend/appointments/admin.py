from django.contrib import admin
from .models import Appointment

@admin.register(Appointment)
class AppointmentAdmin(admin.ModelAdmin):

    list_display = [
        'id',
        'title',
        'patient',  # 🔥 بدل patient_name
        'date_time',
        'status',
    ]

    list_filter = [
        'status',
        'date_time',
    ]

    search_fields = [
        'title',
        'patient__name',  # 🔥 مهم للبحث باسم المريض
    ]

    ordering = ['-date_time']