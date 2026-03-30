from django.contrib import admin
from django.urls import include, path
from rest_framework.routers import DefaultRouter
from dashboard.views import DashboardStatsView, TodayAppointmentsView
from users.views import (
    LogoutView,
    ProfileView,
    LoginView,
    RegisterView,
    RefreshTokenView
)

from patients.views import PatientViewSet

# ✅ تم تعديل الاستيراد هنا
#from dashboard.views import DashboardStatsView, TodayAppointmentsView

from django.conf import settings
from django.conf.urls.static import static


router = DefaultRouter()
router.register(r'patients', PatientViewSet, basename='patients')


urlpatterns = [
    path('admin/', admin.site.urls),

    # 🔐 AUTH
    path('api/v1/auth/register/', RegisterView.as_view()),
    path('api/v1/auth/login/', LoginView.as_view()),
    path('api/v1/auth/refresh/', RefreshTokenView.as_view()),
    path("api/v1/auth/logout/", LogoutView.as_view()),

    # 👤 PROFILE
    path('api/v1/profile/', ProfileView.as_view()),
    # 📊 DASHBOARD
    path('api/v1/dashboard/stats/', DashboardStatsView.as_view()),
    path('api/v1/dashboard/today-appointments/', TodayAppointmentsView.as_view()),
    # 📄 REPORTS
    path('api/v1/reports/', include('reports.urls')),

    # 🏥 PATIENTS
    path('api/v1/', include(router.urls)),

    # 💊 MEDICATIONS
    path('api/v1/', include('medications.urls')),

    # 📅 APPOINTMENTS
    path('api/v1/', include('appointments.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)