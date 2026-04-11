from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import AllowAny
from .models import Patient
from .serializers import PatientSerializer


class PatientViewSet(ModelViewSet):

    queryset = Patient.objects.all().order_by("-created_at")

    serializer_class = PatientSerializer

    permission_classes = [AllowAny]