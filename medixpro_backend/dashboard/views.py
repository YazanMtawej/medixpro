from datetime import date
from django.utils.timezone import localtime
from django.db.models import Count
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from patients.models import Patient
from appointments.models import Appointment
from reports.models import Report


class DashboardStatsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = date.today()

        patients_count = Patient.objects.count()

        appointments_today = Appointment.objects.filter(
            date_time__date=today
        ).count()

        reports_count = Report.objects.count()

        # 🚀 ما عندك revenue → رجّع 0
        revenue = 0.0

        return Response({
            "patients": patients_count,
            "appointments_today": appointments_today,
            "reports": reports_count,
            "revenue": revenue,
        })


class TodayAppointmentsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = date.today()

        appointments = Appointment.objects.filter(
            date_time__date=today
        ).select_related("patient")

        data = []

        for appt in appointments:
            local_dt = localtime(appt.date_time)

            data.append({
                "id": appt.id,
                "patient_name": appt.patient.name,
                "time": local_dt.strftime("%H:%M"),
                "status": appt.status.lower(),  # 🔥 لتطابق Flutter
            })

        return Response(data)