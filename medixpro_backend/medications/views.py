from rest_framework import viewsets
from rest_framework.permissions import AllowAny
from .models import Medication
from .serializers import MedicationSerializer


class MedicationViewSet(viewsets.ModelViewSet):

    serializer_class = MedicationSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        queryset = Medication.objects.all().order_by("-created_at")

        patient_id = self.request.query_params.get("patient")

        if patient_id:
            queryset = queryset.filter(patient_id=patient_id)

        return queryset