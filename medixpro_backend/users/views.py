from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.models import update_last_login
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.conf import settings as django_settings
from .models import Profile
from .serializers import ProfileSerializer
from core.utils import api_response
import logging
from rest_framework.throttling import ScopedRateThrottle

from .models import Profile
from .serializers import ProfileSerializer
from core.utils import api_response
from patients.models import Patient
User = get_user_model()
logger = logging.getLogger(__name__)

class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username   = request.data.get("username", "").strip()
        email      = request.data.get("email", "").strip()
        password   = request.data.get("password", "")
        role       = request.data.get("role", User.Role.PATIENT)
        secret_key = request.data.get("doctor_secret_key", "")

        # ─── Basic validation ─────────────────────────────────────────────
        if not username or not email or not password:
            return Response(
                api_response(False, "Username, email and password are required"),
                status=400,
            )

        if role not in [User.Role.DOCTOR, User.Role.PATIENT]:
            return Response(api_response(False, "Invalid role"), status=400)

        doctor_receipt = None
        if role == User.Role.DOCTOR:
            expected = getattr(django_settings, "DOCTOR_SECRET_KEY", "")
            if not expected or secret_key != expected:
                return Response(
                    api_response(False, "Invalid doctor verification code"),
                    status=403,
                )

            # Consultation receipt (full visit price). Patients pay a percentage
            # of this as the booking fee. Required at doctor registration.
            from decimal import Decimal, InvalidOperation
            receipt_raw = request.data.get("receipt_amount", "")
            try:
                doctor_receipt = Decimal(str(receipt_raw))
                if doctor_receipt <= 0:
                    raise InvalidOperation
            except (InvalidOperation, ValueError, TypeError):
                return Response(
                    api_response(False, "A valid consultation fee (receipt_amount) is required."),
                    status=400,
                )

        if User.objects.filter(username=username).exists():
            return Response(api_response(False, "Username already exists"), status=400)

        if User.objects.filter(email=email).exists():
            return Response(api_response(False, "Email already exists"), status=400)

        # ─── Patient profile validation ───────────────────────────────────
        patient_name   = None
        patient_age    = None
        patient_phone  = None
        patient_gender = None

        if role == User.Role.PATIENT:
            patient_name   = request.data.get("full_name", "").strip()
            patient_age_raw = request.data.get("age", "")
            patient_phone  = request.data.get("phone", "").strip()
            patient_gender = request.data.get("gender", "").strip()

            if not patient_name:
                return Response(
                    api_response(False, "Full name is required"), status=400
                )
            if not patient_phone:
                return Response(
                    api_response(False, "Phone number is required"), status=400
                )
            if not patient_age_raw:
                return Response(
                    api_response(False, "Age is required"), status=400
                )
            try:
                patient_age = int(patient_age_raw)
                if patient_age <= 0 or patient_age > 150:
                    raise ValueError
            except (ValueError, TypeError):
                return Response(
                    api_response(False, "Age must be a valid number between 1 and 150"),
                    status=400,
                )
            if patient_gender not in ["male", "female"]:
                return Response(
                    api_response(False, "Gender must be 'male' or 'female'"),
                    status=400,
                )

        # ─── Create user ──────────────────────────────────────────────────
        try:
            user    = User.objects.create_user(
                username=username, email=email,
                password=password, role=role,
            )
            profile = Profile.objects.create(user=user, receipt_amount=doctor_receipt)

            # ✅ إنشاء Patient مع البيانات الكاملة
            if role == User.Role.PATIENT:
                Patient.objects.create(
                    user   = user,
                    name   = patient_name,
                    age    = patient_age,
                    phone  = patient_phone,
                    gender = patient_gender,
                    email  = email,
                )

            refresh = RefreshToken.for_user(user)
            update_last_login(None, user)

            return Response(
                api_response(True, "Account created successfully", {
                    "access":  str(refresh.access_token),
                    "refresh": str(refresh),
                    "user":    ProfileSerializer(profile).data,
                }),
                status=201,
            )
        except Exception as e:
            logger.error(f"Register error: {e}")
            return Response(
                api_response(False, "Failed to create account. Please try again."),
                status=500,
            )
class LoginView(APIView):
    permission_classes = [AllowAny]
    throttle_classes=[ScopedRateThrottle]
    throttle_scope = "login"
    def post(self, request):
        username = request.data.get("username", "").strip()
        email = request.data.get("email", "").strip()
        password = request.data.get("password", "")

        user = None

        if username:
            user = authenticate(username=username, password=password)
        elif email:
            try:
                user_obj = User.objects.get(email=email)
                user = authenticate(username=user_obj.username, password=password)
            except User.DoesNotExist:
                pass

        if user is None:
            return Response(
                api_response(False, "Invalid credentials"),
                status=status.HTTP_401_UNAUTHORIZED,
            )

        profile, _ = Profile.objects.get_or_create(user=user)
        refresh = RefreshToken.for_user(user)
        update_last_login(None, user)

        return Response(
            api_response(True, "Login successful", {
                "access": str(refresh.access_token),
                "refresh": str(refresh),
                "user": ProfileSerializer(profile).data,
            })
        )

class RefreshTokenView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        refresh_token = request.data.get("refresh", "")

        if not refresh_token:
            return Response(
                api_response(False, "Refresh token is required"),
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            refresh = RefreshToken(refresh_token)

            # ✅ ROTATE_REFRESH_TOKENS=True → احفظ الـ refresh الجديد
            new_refresh = str(refresh)
            new_access = str(refresh.access_token)

            return Response(
                api_response(True, "Token refreshed", {
                    "access": new_access,
                    "refresh": new_refresh,
                })
            )
        except Exception:
            return Response(
                api_response(False, "Invalid or expired refresh token"),
                status=status.HTTP_401_UNAUTHORIZED,
            )

class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        profile, _ = Profile.objects.get_or_create(user=request.user)
        return Response(
            api_response(True, "Profile fetched", ProfileSerializer(profile).data)
        )

    def put(self, request):
        profile, _ = Profile.objects.get_or_create(user=request.user)
        serializer = ProfileSerializer(profile, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            api_response(True, "Profile updated", serializer.data)
        )


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        refresh_token = request.data.get("refresh", "")

        if not refresh_token:
            return Response(
                api_response(False, "Refresh token is required"),
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response(api_response(True, "Logged out successfully"))
        except Exception:
            return Response(
                api_response(False, "Invalid token"),
                status=status.HTTP_400_BAD_REQUEST,
            )
class PatientAccountManagementView(APIView):
    """الطبيب يدير حسابات المرضى — يرى القائمة ويحذف"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not request.user.is_doctor():
            return Response(api_response(False, "Doctors only."), status=403)

        from patients.models import Patient
        # المرضى الذين لديهم حسابات فعلية فقط
        patients = Patient.objects.filter(
            user__isnull=False
        ).select_related("user").order_by("-user__date_joined")

        data = [
            {
                "patient_id":  p.id,
                "user_id":     p.user.id,
                "username":    p.user.username,
                "email":       p.user.email,
                "name":        p.name,
                "phone":       p.phone,
                "joined":      p.user.date_joined.strftime("%Y-%m-%d"),
                "is_active":   p.user.is_active,
            }
            for p in patients
        ]
        return Response(api_response(True, "Patient accounts fetched", data))

    def delete(self, request):
        if not request.user.is_doctor():
            return Response(api_response(False, "Doctors only."), status=403)

        user_id = request.data.get("user_id")
        if not user_id:
            return Response(
                api_response(False, "user_id is required"), status=400
            )

        try:
            target = User.objects.get(id=user_id, role="patient")
        except User.DoesNotExist:
            return Response(
                api_response(False, "Patient account not found"), status=404
            )

        # لا يمكن للطبيب حذف نفسه
        if target == request.user:
            return Response(
                api_response(False, "Cannot delete your own account"), status=400
            )

        username = target.username
        # cascade يحذف Patient + Appointments + Requests تلقائياً
        target.delete()

        logger.info(f"Doctor {request.user.username} deleted patient account: {username}")
        return Response(
            api_response(True, f"Account '{username}' deleted permanently")
        )
class VerifyDoctorKeyView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        code = request.data.get("doctor_secret_key", "").strip()

        if not code:
            return Response(
                api_response(False, "Verification code required"),
                status=400
            )

        expected = getattr(django_settings, "DOCTOR_SECRET_KEY", "")

        if code == expected:
            return Response(
                api_response(True, "Code valid")
            )

        return Response(
            api_response(False, "Invalid verification code"),
            status=403
        )


class DoctorListView(APIView):
    """
    List doctors a patient can book with, including each doctor's receipt and the
    computed booking fee (the percentage the patient actually pays).
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from decimal import Decimal
        rate = Decimal(str(getattr(django_settings, "PLATFORM_FEE_RATE", "0.20")))
        currency_id = getattr(django_settings, "SHAMCASH_CURRENCY_ID", 2)

        profiles = (
            Profile.objects
            .filter(user__role=User.Role.DOCTOR, user__is_active=True)
            .select_related("user")
            .order_by("full_name")
        )
        data = []
        for p in profiles:
            fee = None
            if p.receipt_amount is not None:
                fee = str((p.receipt_amount * rate).quantize(Decimal("0.01")))
            data.append({
                "id": p.user.id,
                "username": p.user.username,
                "full_name": p.full_name or p.user.get_full_name() or p.user.username,
                "clinic_name": p.clinic_name,
                "address": p.address,
                "latitude": p.latitude,
                "longitude": p.longitude,
                "receipt_amount": str(p.receipt_amount) if p.receipt_amount is not None else None,
                "booking_fee": fee,
                "currency_id": currency_id,
                "bookable": p.receipt_amount is not None,
            })
        return Response(api_response(True, "Doctors fetched", data))


class ClinicLocationView(APIView):
    """يرجع موقع عيادة الطبيب للمريض ليشاهده على الخريطة."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # أول طبيب لديه إحداثيات محددة
        profile = (
            Profile.objects
            .filter(
                user__role=User.Role.DOCTOR,
                latitude__isnull=False,
                longitude__isnull=False,
            )
            .select_related("user")
            .first()
        )

        if profile is None:
            return Response(
                api_response(False, "No clinic location set yet"),
                status=404,
            )

        return Response(
            api_response(True, "Clinic location fetched", {
                "clinic_name": profile.clinic_name,
                "address": profile.address,
                "latitude": profile.latitude,
                "longitude": profile.longitude,
            })
        )