from django.contrib.auth import get_user_model
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
import logging

from .models import Appointment, AppointmentRequest
from .serializers import AppointmentSerializer, AppointmentRequestSerializer
from core.utils import api_response
from notifications.models import Notification

User   = get_user_model()
logger = logging.getLogger(__name__)


def _notify(user, title, message, category="appointment"):
    try:
        Notification.objects.create(
            user=user, title=title, message=message, category=category
        )
    except Exception as e:
        logger.error(f"Notification failed: {e}")


def _notify_all_doctors(title, message, category="appointment"):
    try:
        doctors = User.objects.filter(role="doctor")
        if doctors.exists():
            Notification.objects.bulk_create([
                Notification(user=d, title=title, message=message, category=category)
                for d in doctors
            ])
    except Exception as e:
        logger.error(f"Notify doctors failed: {e}")


def _get_patient_for_user(user):
    try:
        return user.patient_profile
    except Exception:
        return None


# ─── Appointment ViewSet ──────────────────────────────────────────────────────

class AppointmentViewSet(viewsets.ModelViewSet):
    serializer_class   = AppointmentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        qs   = Appointment.objects.select_related("patient").order_by("-date_time")

        if user.is_patient():
            patient = _get_patient_for_user(user)
            if not patient:
                return qs.none()
            return qs.filter(patient=patient)

        patient_id = self.request.query_params.get("patient")
        status_f   = self.request.query_params.get("status")
        search     = self.request.query_params.get("search", "")

        if patient_id: qs = qs.filter(patient_id=patient_id)
        if status_f:   qs = qs.filter(status=status_f)
        if search:
            qs = (qs.filter(title__icontains=search) |
                  qs.filter(patient__name__icontains=search))
        return qs

    def list(self, request, *args, **kwargs):
        try:
            s = self.get_serializer(self.get_queryset(), many=True)
            return Response(api_response(True, "Appointments fetched", s.data))
        except Exception as e:
            logger.error(f"list appointments: {e}")
            return Response(api_response(False, "Failed to load appointments"), status=500)

    def retrieve(self, request, *args, **kwargs):
        try:
            s = self.get_serializer(self.get_object())
            return Response(api_response(True, "Appointment fetched", s.data))
        except Exception as e:
            logger.error(f"retrieve appointment: {e}")
            return Response(api_response(False, "Appointment not found"), status=404)

    def create(self, request, *args, **kwargs):
        if request.user.is_patient():
            return Response(
                api_response(False, "Patients cannot create appointments directly."),
                status=403,
            )
        try:
            s = self.get_serializer(data=request.data)
            s.is_valid(raise_exception=True)
            s.save()
            return Response(api_response(True, "Appointment created", s.data), status=201)
        except Exception as e:
            logger.error(f"create appointment: {e}")
            return Response(api_response(False, "Failed to create appointment"), status=400)

    def update(self, request, *args, **kwargs):
        if request.user.is_patient():
            return Response(api_response(False, "Not allowed."), status=403)
        try:
            partial = kwargs.pop("partial", False)
            s = self.get_serializer(
                self.get_object(), data=request.data, partial=partial
            )
            s.is_valid(raise_exception=True)
            s.save()
            return Response(api_response(True, "Appointment updated", s.data))
        except Exception as e:
            logger.error(f"update appointment: {e}")
            return Response(api_response(False, "Failed to update appointment"), status=400)

    def destroy(self, request, *args, **kwargs):
        if request.user.is_patient():
            return Response(api_response(False, "Not allowed."), status=403)
        try:
            self.get_object().delete()
            return Response(api_response(True, "Appointment deleted"))
        except Exception as e:
            logger.error(f"delete appointment: {e}")
            return Response(api_response(False, "Failed to delete appointment"), status=400)


# ─── Appointment Request ViewSet ──────────────────────────────────────────────

class AppointmentRequestViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class   = AppointmentRequestSerializer

    def get_queryset(self):
        user = self.request.user
        if user.is_patient():
            return AppointmentRequest.objects.filter(
                requested_by=user
            ).order_by("-created_at")
        return AppointmentRequest.objects.select_related(
            "patient", "requested_by", "doctor"
        ).order_by("-created_at")

    def list(self, request, *args, **kwargs):
        try:
            s = self.get_serializer(self.get_queryset(), many=True)
            return Response(api_response(True, "Requests fetched", s.data))
        except Exception as e:
            logger.error(f"list requests: {e}")
            return Response(api_response(False, "Failed to load requests"), status=500)

    def create(self, request, *args, **kwargs):
        """المريض يرسل طلب موعد"""
        if request.user.is_doctor():
            return Response(
                api_response(False, "Doctors cannot send appointment requests."),
                status=403,
            )

        patient = _get_patient_for_user(request.user)
        if not patient:
            logger.error(
                f"No patient profile: {request.user.username} (id={request.user.id})"
            )
            return Response(
                api_response(False, "Your patient profile is not set up. Please contact support."),
                status=400,
            )

        data = {
            "title":          request.data.get("title", "").strip(),
            "type":           request.data.get("type", "general"),
            "preferred_date": request.data.get("preferred_date", ""),
            "reason":         request.data.get("reason", ""),
            "symptoms":       request.data.get("symptoms", ""),
        }

        if not data["title"]:
            return Response(api_response(False, "Title is required."), status=400)
        if not data["preferred_date"]:
            return Response(api_response(False, "Preferred date is required."), status=400)

        try:
            req = AppointmentRequest.objects.create(
                patient        = patient,
                requested_by   = request.user,
                title          = data["title"],
                type           = data["type"],
                preferred_date = data["preferred_date"],
                reason         = data["reason"],
                symptoms       = data["symptoms"],
            )
        except Exception as e:
            logger.error(f"create request DB error | {request.user.username} | {e}")
            return Response(
                api_response(False, "Failed to save request. Please try again."),
                status=500,
            )

        try:
            from django.utils.timezone import localtime, is_aware
            dt     = req.preferred_date
            dt_str = localtime(dt).strftime("%Y-%m-%d %H:%M") if is_aware(dt) else dt.strftime("%Y-%m-%d %H:%M")
            _notify_all_doctors(
                title   = "🔔 New Appointment Request",
                message = f"Patient {request.user.username} requested '{req.title}' on {dt_str}.",
            )
        except Exception as e:
            logger.error(f"Notify error (non-critical): {e}")

        try:
            serializer = AppointmentRequestSerializer(req)
            return Response(
                api_response(True, "Request sent successfully", serializer.data),
                status=201,
            )
        except Exception as e:
            logger.error(f"Serializer error: {e}")
            return Response(
                api_response(True, "Request sent successfully", {"id": req.id}),
                status=201,
            )

    # ─── Accept ───────────────────────────────────────────────────────────────
    @action(detail=True, methods=["post"], url_path="accept")
    def accept(self, request, pk=None):
        """الطبيب يقبل الطلب وينشئ موعداً"""
        if request.user.is_patient():
            return Response(api_response(False, "Only doctors can accept."), status=403)

        try:
            req = self.get_object()
        except Exception:
            return Response(api_response(False, "Request not found."), status=404)

        if req.status != AppointmentRequest.Status.PENDING:
            return Response(
                api_response(False, f"Request is already {req.status}."), status=400
            )

        try:
            appointment = Appointment.objects.create(
                patient          = req.patient,
                title            = req.title,
                type             = req.type,
                date_time        = req.preferred_date,
                duration_minutes = 30,
                status           = Appointment.Status.SCHEDULED,
                reason           = req.reason,
                symptoms         = req.symptoms,
                notes            = request.data.get("notes", ""),
            )
            req.status      = AppointmentRequest.Status.ACCEPTED
            req.doctor      = request.user
            req.appointment = appointment
            req.save()

            _notify(
                user    = req.requested_by,
                title   = "✅ Appointment Confirmed",
                message = f"Your request '{req.title}' confirmed for {appointment.date_time.strftime('%Y-%m-%d %H:%M')}.",
            )
            return Response(
                api_response(True, "Accepted", AppointmentSerializer(appointment).data)
            )
        except Exception as e:
            logger.error(f"accept error: {e}")
            return Response(api_response(False, "Failed to accept."), status=500)

    # ─── Suggest ──────────────────────────────────────────────────────────────
    @action(detail=True, methods=["post"], url_path="suggest")
    def suggest(self, request, pk=None):
        """الطبيب يقترح موعداً بديلاً"""
        if request.user.is_patient():
            return Response(api_response(False, "Only doctors can suggest."), status=403)

        try:
            req = self.get_object()
        except Exception:
            return Response(api_response(False, "Request not found."), status=404)

        suggested_date = request.data.get("suggested_date")
        doctor_note    = request.data.get("doctor_note", "")

        if not suggested_date:
            return Response(api_response(False, "suggested_date is required."), status=400)

        try:
            req.status         = AppointmentRequest.Status.SUGGESTED
            req.doctor         = request.user
            req.suggested_date = suggested_date
            req.doctor_note    = doctor_note
            req.save()

            _notify(
                user    = req.requested_by,
                title   = "📅 Doctor Suggested New Time",
                message = f"Dr. {request.user.username} suggested a new time for '{req.title}'. Note: {doctor_note}",
            )
            return Response(
                api_response(True, "Suggestion sent", AppointmentRequestSerializer(req).data)
            )
        except Exception as e:
            logger.error(f"suggest error: {e}")
            return Response(api_response(False, "Failed to suggest."), status=500)

    # ─── Confirm (Patient accepts suggestion) ─────────────────────────────────
    @action(detail=True, methods=["post"], url_path="confirm")
    def confirm(self, request, pk=None):
        """المريض يوافق على الموعد المقترح"""
        try:
            req = self.get_object()
        except Exception:
            return Response(api_response(False, "Request not found."), status=404)

        if req.requested_by != request.user:
            return Response(api_response(False, "Not authorized."), status=403)
        if req.status != AppointmentRequest.Status.SUGGESTED:
            return Response(api_response(False, "No suggestion to confirm."), status=400)

        try:
            appointment = Appointment.objects.create(
                patient          = req.patient,
                title            = req.title,
                type             = req.type,
                date_time        = req.suggested_date,
                duration_minutes = 30,
                status           = Appointment.Status.SCHEDULED,
                reason           = req.reason,
                symptoms         = req.symptoms,
            )
            req.status      = AppointmentRequest.Status.ACCEPTED
            req.appointment = appointment
            req.save()

            if req.doctor:
                _notify(
                    user    = req.doctor,
                    title   = "✅ Patient Confirmed Your Suggestion",
                    message = f"Patient confirmed the suggested time for '{req.title}'.",
                )
            return Response(
                api_response(True, "Appointment confirmed", AppointmentSerializer(appointment).data)
            )
        except Exception as e:
            logger.error(f"confirm error: {e}")
            return Response(api_response(False, "Failed to confirm."), status=500)

    # ─── Decline suggestion (Patient rejects suggestion) ─────────────────────
    @action(detail=True, methods=["post"], url_path="decline")
    def decline(self, request, pk=None):
        """المريض يرفض الموعد المقترح من الطبيب"""
        try:
            req = self.get_object()
        except Exception:
            return Response(api_response(False, "Request not found."), status=404)

        if req.requested_by != request.user:
            return Response(api_response(False, "Not authorized."), status=403)
        if req.status != AppointmentRequest.Status.SUGGESTED:
            return Response(api_response(False, "No suggestion to decline."), status=400)

        try:
            patient_note    = request.data.get("patient_note", "")
            req.status      = AppointmentRequest.Status.REJECTED
            req.doctor_note = f"[Patient declined] {patient_note}".strip()
            req.save()

            if req.doctor:
                _notify(
                    user    = req.doctor,
                    title   = "❌ Patient Declined Suggestion",
                    message = f"Patient declined your suggested time for '{req.title}'. {patient_note}",
                )
            return Response(
                api_response(True, "Suggestion declined", AppointmentRequestSerializer(req).data)
            )
        except Exception as e:
            logger.error(f"decline error: {e}")
            return Response(api_response(False, "Failed to decline."), status=500)

    # ─── Reject (Doctor rejects request) ─────────────────────────────────────
    @action(detail=True, methods=["post"], url_path="reject")
    def reject(self, request, pk=None):
        """الطبيب يرفض الطلب"""
        if request.user.is_patient():
            return Response(api_response(False, "Only doctors can reject."), status=403)

        try:
            req = self.get_object()
        except Exception:
            return Response(api_response(False, "Request not found."), status=404)

        try:
            req.status      = AppointmentRequest.Status.REJECTED
            req.doctor      = request.user
            req.doctor_note = request.data.get("doctor_note", "")
            req.save()

            _notify(
                user    = req.requested_by,
                title   = "❌ Request Rejected",
                message = f"Your request '{req.title}' was not approved. {req.doctor_note}",
            )
            return Response(
                api_response(True, "Rejected", AppointmentRequestSerializer(req).data)
            )
        except Exception as e:
            logger.error(f"reject error: {e}")
            return Response(api_response(False, "Failed to reject."), status=500)

    # ─── Clear completed ──────────────────────────────────────────────────────
    @action(detail=False, methods=["delete"], url_path="clear-completed")
    def clear_completed(self, request):
        """حذف الطلبات المنجزة من الذاكرة"""
        try:
            user = request.user
            qs   = AppointmentRequest.objects.filter(
                status__in=[
                    AppointmentRequest.Status.ACCEPTED,
                    AppointmentRequest.Status.REJECTED,
                ],
            )
            if user.is_patient():
                qs = qs.filter(requested_by=user)

            count, _ = qs.delete()
            return Response(
                api_response(True, f"Cleared {count} completed request(s)")
            )
        except Exception as e:
            logger.error(f"clear_completed error: {e}")
            return Response(api_response(False, "Failed to clear."), status=500)