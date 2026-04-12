from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Medication, CommonMedication
from .serializers import MedicationSerializer, CommonMedicationSerializer
from core.utils import api_response


class CommonMedicationViewSet(viewsets.ReadOnlyModelViewSet):
    """قائمة الأدوية الشائعة — للقراءة فقط"""
    serializer_class = CommonMedicationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = CommonMedication.objects.all()
        search = self.request.query_params.get("search", "")
        if search:
            queryset = queryset.filter(name__icontains=search)
        return queryset

    def list(self, request, *args, **kwargs):
        qs = self.get_queryset()
        serializer = self.get_serializer(qs, many=True)
        return Response(api_response(True, "Common medications fetched", serializer.data))


class MedicationViewSet(viewsets.ModelViewSet):
    serializer_class = MedicationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Medication.objects.select_related("patient").order_by("-created_at")
        patient_id = self.request.query_params.get("patient")
        search = self.request.query_params.get("search", "")
        if patient_id:
            queryset = queryset.filter(patient_id=patient_id)
        if search:
            queryset = queryset.filter(name__icontains=search) | \
                       queryset.filter(patient__name__icontains=search)
        return queryset

    def list(self, request, *args, **kwargs):
        serializer = self.get_serializer(self.get_queryset(), many=True)
        return Response(api_response(True, "Medications fetched", serializer.data))

    def retrieve(self, request, *args, **kwargs):
        serializer = self.get_serializer(self.get_object())
        return Response(api_response(True, "Medication fetched", serializer.data))

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            api_response(True, "Medication added", serializer.data), status=201
        )

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop("partial", False)
        serializer = self.get_serializer(
            self.get_object(), data=request.data, partial=partial
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(api_response(True, "Medication updated", serializer.data))

    def destroy(self, request, *args, **kwargs):
        self.get_object().delete()
        return Response(api_response(True, "Medication deleted"))