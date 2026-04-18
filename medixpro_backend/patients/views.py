from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Patient
from .serializers import PatientSerializer
from core.utils import api_response


class PatientViewSet(ModelViewSet):
    serializer_class = PatientSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
     user = self.request.user
    # ✅ المريض يرى بياناته فقط إذا كان Patient مرتبطاً بـ user
     if user.is_patient():
        return Patient.objects.filter(user=user)
     return Patient.objects.all().order_by("-created_at")

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        return Response(api_response(True, "Patients fetched", serializer.data))

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return Response(api_response(True, "Patient fetched", serializer.data))

    def create(self, request, *args, **kwargs):
        if request.user.is_patient():
            return Response(api_response(False, "Patients cannot add records."), status=403)
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(api_response(True, "Patient added", serializer.data), status=201)

    def update(self, request, *args, **kwargs):
        if request.user.is_patient():
            return Response(api_response(False, "Patients cannot modify records."), status=403)
        partial = kwargs.pop("partial", False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(api_response(True, "Patient updated", serializer.data))

    def destroy(self, request, *args, **kwargs):
        if request.user.is_patient():
            return Response(api_response(False, "Patients cannot delete records."), status=403)
        instance = self.get_object()
        instance.delete()
        return Response(api_response(True, "Patient deleted"))