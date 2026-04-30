from django.contrib.auth import get_user_model
from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
import logging

from .models import Patient
from .serializers import PatientSerializer
from core.utils import api_response

User   = get_user_model()
logger = logging.getLogger(__name__)


class PatientViewSet(viewsets.ModelViewSet):
    serializer_class   = PatientSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user

        if user.is_patient():
            return Patient.objects.filter(user=user).select_related("user")

        qs     = Patient.objects.select_related("user").order_by("-created_at")
        search = self.request.query_params.get("search", "")
        gender = self.request.query_params.get("gender")

        if search: qs = qs.filter(name__icontains=search)
        if gender: qs = qs.filter(gender=gender)
        return qs

    def list(self, request, *args, **kwargs):
        s = self.get_serializer(self.get_queryset(), many=True)
        return Response(api_response(True, "Patients fetched", s.data))

    def retrieve(self, request, *args, **kwargs):
        s = self.get_serializer(self.get_object())
        return Response(api_response(True, "Patient fetched", s.data))

    def create(self, request, *args, **kwargs):
        if request.user.is_patient():
            return Response(api_response(False, "Not allowed."), status=403)
        s = self.get_serializer(data=request.data)
        s.is_valid(raise_exception=True)
        s.save()
        return Response(api_response(True, "Patient added", s.data), status=201)

    def update(self, request, *args, **kwargs):
        if request.user.is_patient():
            return Response(api_response(False, "Not allowed."), status=403)
        partial = kwargs.pop("partial", False)
        s = self.get_serializer(
            self.get_object(), data=request.data, partial=partial
        )
        s.is_valid(raise_exception=True)
        s.save()
        return Response(api_response(True, "Patient updated", s.data))

    def destroy(self, request, *args, **kwargs):
        if request.user.is_patient():
            return Response(api_response(False, "Not allowed."), status=403)
        try:
            patient = self.get_object()
            # ✅ فصل الحساب أولاً قبل الحذف لمنع cascade على الـ user
            if patient.user is not None:
                patient.user = None
                patient.save(update_fields=["user"])
            patient.delete()
            return Response(api_response(True, "Patient deleted successfully"))
        except Exception as e:
            logger.error(f"delete patient error: {e}")
            return Response(api_response(False, "Failed to delete patient"), status=400)