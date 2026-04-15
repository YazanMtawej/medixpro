from datetime import date
from django.utils.timezone import localtime
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from patients.models import Patient
from appointments.models import Appointment
from reports.models import Report
from medications.models import Medication
from core.utils import api_response


class DashboardStatsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = date.today()

        total_patients       = Patient.objects.count()
        appointments_today   = Appointment.objects.filter(date_time__date=today).count()
        total_reports        = Report.objects.count()
        total_medications    = Medication.objects.count()
        final_reports        = Report.objects.filter(status="final").count()
        draft_reports        = Report.objects.filter(status="draft").count()
        scheduled_today      = Appointment.objects.filter(
                                 date_time__date=today,
                                 status="scheduled"
                               ).count()
        completed_today      = Appointment.objects.filter(
                                 date_time__date=today,
                                 status="completed"
                               ).count()
        male_patients        = Patient.objects.filter(gender="male").count()
        female_patients      = Patient.objects.filter(gender="female").count()

        return Response(
            api_response(True, "Dashboard stats fetched", {
                "total_patients":     total_patients,
                "appointments_today": appointments_today,
                "total_reports":      total_reports,
                "total_medications":  total_medications,
                "final_reports":      final_reports,
                "draft_reports":      draft_reports,
                "scheduled_today":    scheduled_today,
                "completed_today":    completed_today,
                "male_patients":      male_patients,
                "female_patients":    female_patients,
                "revenue":            0.0,
            })
        )


class TodayAppointmentsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today        = date.today()
        appointments = Appointment.objects.filter(
            date_time__date=today
        ).select_related("patient").order_by("date_time")

        data = [
            {
                "id":           a.id,
                "title":        a.title,
                "patient_name": a.patient.name,
                "patient_age":  a.patient.age,
                "time":         localtime(a.date_time).strftime("%H:%M"),
                "type":         a.type,
                "status":       a.status,
                "duration":     a.duration_minutes,
            }
            for a in appointments
        ]

        return Response(api_response(True, "Today appointments fetched", data))