from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Appointment
from .serializers import AppointmentSerializer
from core.utils import api_response


class AppointmentViewSet(viewsets.ModelViewSet):
    serializer_class   = AppointmentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs         = Appointment.objects.select_related("patient").order_by("-date_time")
        patient_id = self.request.query_params.get("patient")
        status     = self.request.query_params.get("status")
        search     = self.request.query_params.get("search", "")

        if patient_id:
            qs = qs.filter(patient_id=patient_id)
        if status:
            qs = qs.filter(status=status)
        if search:
            qs = qs.filter(title__icontains=search) | \
                 qs.filter(patient__name__icontains=search)
        return qs

    def list(self, request, *args, **kwargs):
        serializer = self.get_serializer(self.get_queryset(), many=True)
        return Response(api_response(True, "Appointments fetched", serializer.data))

    def retrieve(self, request, *args, **kwargs):
        serializer = self.get_serializer(self.get_object())
        return Response(api_response(True, "Appointment fetched", serializer.data))

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            api_response(True, "Appointment created", serializer.data),
            status=201,
        )

    def update(self, request, *args, **kwargs):
        partial    = kwargs.pop("partial", False)
        serializer = self.get_serializer(
            self.get_object(), data=request.data, partial=partial
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(api_response(True, "Appointment updated", serializer.data))

    def destroy(self, request, *args, **kwargs):
        self.get_object().delete()
        return Response(api_response(True, "Appointment deleted"))