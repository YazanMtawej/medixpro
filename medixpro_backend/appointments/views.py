from django.contrib.auth import get_user_model
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Appointment, AppointmentRequest
from .serializers import AppointmentSerializer, AppointmentRequestSerializer
from patients.models import Patient
from core.utils import api_response
from notifications.models import Notification

User = get_user_model()


class AppointmentViewSet(viewsets.ModelViewSet):
    serializer_class   = AppointmentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user   = self.request.user
        qs     = Appointment.objects.select_related("patient").order_by("-date_time")

        # ✅ المريض يرى مواعيده فقط
        if user.is_patient():
            try:
                patient = Patient.objects.get(user=user) if hasattr(Patient, 'user') else None
                # إذا كان Patient مرتبط بـ user مباشرة
                qs = qs.filter(patient__user=user)
            except Exception:
                qs = qs.none()
        else:
            patient_id = self.request.query_params.get("patient")
            if patient_id:
                qs = qs.filter(patient_id=patient_id)

        status_f = self.request.query_params.get("status")
        search   = self.request.query_params.get("search", "")
        if status_f: qs = qs.filter(status=status_f)
        if search:
            qs = qs.filter(title__icontains=search) | qs.filter(patient__name__icontains=search)
        return qs

    def list(self, request, *args, **kwargs):
        serializer = self.get_serializer(self.get_queryset(), many=True)
        return Response(api_response(True, "Appointments fetched", serializer.data))

    def retrieve(self, request, *args, **kwargs):
        return Response(api_response(True, "Appointment fetched", self.get_serializer(self.get_object()).data))

    def create(self, request, *args, **kwargs):
        # ✅ المريض لا يستطيع إضافة موعد مباشرة
        if request.user.is_patient():
            return Response(api_response(False, "Patients cannot create appointments directly. Please send a request."), status=403)
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(api_response(True, "Appointment created", serializer.data), status=201)

    def update(self, request, *args, **kwargs):
        if request.user.is_patient():
            return Response(api_response(False, "Patients cannot modify appointments."), status=403)
        partial    = kwargs.pop("partial", False)
        serializer = self.get_serializer(self.get_object(), data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(api_response(True, "Appointment updated", serializer.data))

    def destroy(self, request, *args, **kwargs):
        if request.user.is_patient():
            return Response(api_response(False, "Patients cannot delete appointments."), status=403)
        self.get_object().delete()
        return Response(api_response(True, "Appointment deleted"))


class AppointmentRequestViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class   = AppointmentRequestSerializer

    def get_queryset(self):
        user = self.request.user
        if user.is_patient():
            # المريض يرى طلباته فقط
            return AppointmentRequest.objects.filter(requested_by=user).order_by("-created_at")
        # الطبيب يرى الطلبات الموجهة إليه أو الكل
        return AppointmentRequest.objects.all().order_by("-created_at")

    def list(self, request, *args, **kwargs):
        serializer = self.get_serializer(self.get_queryset(), many=True)
        return Response(api_response(True, "Requests fetched", serializer.data))

    def create(self, request, *args, **kwargs):
        """المريض يُرسل طلب موعد"""
        if request.user.is_doctor():
            return Response(api_response(False, "Doctors cannot send appointment requests."), status=403)

        data = request.data.copy()
        data["requested_by"] = request.user.id

        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        req = serializer.save(requested_by=request.user)

        # إشعار لجميع الأطباء
        doctors = User.objects.filter(role="doctor")
        Notification.objects.bulk_create([
            Notification(
                user=d,
                title="New Appointment Request",
                message=f"Patient {request.user.username} requested '{req.title}' on {req.preferred_date.strftime('%Y-%m-%d %H:%M')}.",
                category="appointment",
            )
            for d in doctors
        ])

        return Response(api_response(True, "Request sent successfully", serializer.data), status=201)

    @action(detail=True, methods=["post"], url_path="accept")
    def accept(self, request, pk=None):
        """الطبيب يقبل الطلب وينشئ موعداً"""
        if request.user.is_patient():
            return Response(api_response(False, "Only doctors can accept requests."), status=403)

        req = self.get_object()
        if req.status != AppointmentRequest.RequestStatus.PENDING:
            return Response(api_response(False, f"Request is already {req.status}."), status=400)

        # إنشاء الموعد تلقائياً
        appointment = Appointment.objects.create(
            patient          = req.patient,
            title            = req.title,
            type             = req.type,
            date_time        = req.preferred_date,
            duration_minutes = 30,
            status           = "scheduled",
            reason           = req.reason,
            symptoms         = req.symptoms,
            notes            = request.data.get("notes", ""),
        )

        req.status      = AppointmentRequest.RequestStatus.ACCEPTED
        req.doctor      = request.user
        req.appointment = appointment
        req.save()

        # إشعار للمريض
        Notification.objects.create(
            user     = req.requested_by,
            title    = "Appointment Accepted ✅",
            message  = f"Your appointment '{req.title}' has been confirmed for {appointment.date_time.strftime('%Y-%m-%d %H:%M')}.",
            category = "appointment",
        )

        return Response(api_response(True, "Request accepted and appointment created", AppointmentSerializer(appointment).data))

    @action(detail=True, methods=["post"], url_path="suggest")
    def suggest(self, request, pk=None):
        """الطبيب يقترح موعداً بديلاً"""
        if request.user.is_patient():
            return Response(api_response(False, "Only doctors can suggest alternatives."), status=403)

        req            = self.get_object()
        suggested_date = request.data.get("suggested_date")
        doctor_note    = request.data.get("doctor_note", "")

        if not suggested_date:
            return Response(api_response(False, "suggested_date is required."), status=400)

        req.status         = AppointmentRequest.RequestStatus.SUGGESTED
        req.doctor         = request.user
        req.suggested_date = suggested_date
        req.doctor_note    = doctor_note
        req.save()

        # إشعار للمريض
        Notification.objects.create(
            user     = req.requested_by,
            title    = "Alternative Time Suggested",
            message  = f"Doctor suggested a new time for '{req.title}': {suggested_date}. Note: {doctor_note}",
            category = "appointment",
        )

        return Response(api_response(True, "Alternative time suggested", AppointmentRequestSerializer(req).data))

    @action(detail=True, methods=["post"], url_path="confirm-suggestion")
    def confirm_suggestion(self, request, pk=None):
        """المريض يوافق على الموعد المقترح"""
        req = self.get_object()
        if req.requested_by != request.user:
            return Response(api_response(False, "Not authorized."), status=403)
        if req.status != AppointmentRequest.RequestStatus.SUGGESTED:
            return Response(api_response(False, "No suggestion to confirm."), status=400)

        appointment = Appointment.objects.create(
            patient          = req.patient,
            title            = req.title,
            type             = req.type,
            date_time        = req.suggested_date,
            duration_minutes = 30,
            status           = "scheduled",
            reason           = req.reason,
            symptoms         = req.symptoms,
        )

        req.status      = AppointmentRequest.RequestStatus.ACCEPTED
        req.appointment = appointment
        req.save()

        Notification.objects.create(
            user     = req.doctor,
            title    = "Suggestion Confirmed ✅",
            message  = f"Patient confirmed your suggested time for '{req.title}'.",
            category = "appointment",
        )

        return Response(api_response(True, "Appointment confirmed", AppointmentSerializer(appointment).data))

    @action(detail=True, methods=["post"], url_path="reject")
    def reject(self, request, pk=None):
        """الطبيب يرفض الطلب"""
        if request.user.is_patient():
            return Response(api_response(False, "Only doctors can reject requests."), status=403)

        req             = self.get_object()
        req.status      = AppointmentRequest.RequestStatus.REJECTED
        req.doctor      = request.user
        req.doctor_note = request.data.get("doctor_note", "")
        req.save()

        Notification.objects.create(
            user     = req.requested_by,
            title    = "Appointment Request Rejected",
            message  = f"Your request '{req.title}' was rejected. {req.doctor_note}",
            category = "appointment",
        )

        return Response(api_response(True, "Request rejected", AppointmentRequestSerializer(req).data))