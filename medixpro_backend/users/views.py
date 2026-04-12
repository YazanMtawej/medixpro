from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.models import update_last_login
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken

from .models import Profile
from .serializers import ProfileSerializer
from core.utils import api_response

User = get_user_model()


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get("username", "").strip()
        email = request.data.get("email", "").strip()
        password = request.data.get("password", "")
        role = request.data.get("role", User.Role.PATIENT)

        if not username or not email or not password:
            return Response(
                api_response(False, "All fields are required"),
                status=status.HTTP_400_BAD_REQUEST,
            )

        if role not in [User.Role.DOCTOR, User.Role.PATIENT]:
            return Response(
                api_response(False, "Invalid role. Must be 'doctor' or 'patient'"),
                status=status.HTTP_400_BAD_REQUEST,
            )

        if User.objects.filter(username=username).exists():
            return Response(
                api_response(False, "Username already exists"),
                status=status.HTTP_400_BAD_REQUEST,
            )

        if User.objects.filter(email=email).exists():
            return Response(
                api_response(False, "Email already exists"),
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = User.objects.create_user(
            username=username,
            email=email,
            password=password,
            role=role,
        )
        profile = Profile.objects.create(user=user)
        refresh = RefreshToken.for_user(user)
        update_last_login(None, user)

        return Response(
            api_response(True, "Account created successfully", {
                "access": str(refresh.access_token),
                "refresh": str(refresh),
                "user": ProfileSerializer(profile).data,
            }),
            status=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    permission_classes = [AllowAny]

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