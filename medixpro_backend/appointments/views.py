from rest_framework import viewsets
from rest_framework.permissions import AllowAny
from .models import Appointment
from .serializers import AppointmentSerializer

class AppointmentViewSet(viewsets.ModelViewSet):

    queryset = Appointment.objects.all().order_by("-date_time")
    serializer_class = AppointmentSerializer
    permission_classes = [AllowAny]