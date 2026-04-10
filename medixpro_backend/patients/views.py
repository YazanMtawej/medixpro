from rest_framework.viewsets import ModelViewSet
from rest_framework.response import Response
from rest_framework import status
from django.db.models import ProtectedError

from .models import Patient
from .serializers import PatientSerializer


class PatientViewSet(ModelViewSet):
    queryset = Patient.objects.all().order_by("-created_at")
    serializer_class = PatientSerializer

    def destroy(self, request, *args, **kwargs):
        try:
            instance = self.get_object()
            self.perform_destroy(instance)

            return Response(
                {"message": "Patient deleted successfully"},
                status=status.HTTP_200_OK
            )

        except ProtectedError:
            return Response(
                {
                    "error": "Cannot delete patient because it is linked to medications or other records"
                },
                status=status.HTTP_400_BAD_REQUEST
            )