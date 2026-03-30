from rest_framework import serializers
from .models import Appointment

class AppointmentSerializer(serializers.ModelSerializer):

    patient_name = serializers.CharField(
        source='patient.name',
        read_only=True
    )

    class Meta:
        model = Appointment
        fields = '__all__'