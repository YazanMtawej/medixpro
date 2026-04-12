from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import MedicationViewSet, CommonMedicationViewSet

router = DefaultRouter()
router.register(r"medications", MedicationViewSet, basename="medications")
router.register(r"common-medications", CommonMedicationViewSet, basename="common-medications")

urlpatterns = [
    path("", include(router.urls)),
]