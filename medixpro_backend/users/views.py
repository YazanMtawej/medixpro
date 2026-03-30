from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework import status

from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.models import update_last_login

from rest_framework_simplejwt.tokens import RefreshToken

from .models import Profile
from .serializers import ProfileSerializer
from core.utils import api_response

User = get_user_model()


# =======================================
# 🟢 Register
# =======================================
class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get("username")
        email = request.data.get("email")
        password = request.data.get("password")

        if not username or not email or not password:
            return Response(
                api_response(False, "All fields are required"),
                status=status.HTTP_400_BAD_REQUEST
            )

        if User.objects.filter(username=username).exists():
            return Response(
                api_response(False, "Username already exists"),
                status=status.HTTP_400_BAD_REQUEST
            )

        if User.objects.filter(email=email).exists():
            return Response(
                api_response(False, "Email already exists"),
                status=status.HTTP_400_BAD_REQUEST
            )

        user = User.objects.create_user(
            username=username,
            email=email,
            password=password
        )

        Profile.objects.create(user=user)

        refresh = RefreshToken.for_user(user)
        update_last_login(None, user)

        profile = Profile.objects.get(user=user)

        return Response(
            api_response(True, "Account created successfully", {
                "access": str(refresh.access_token),
                "refresh": str(refresh),
                "user": ProfileSerializer(profile).data
            }),
            status=status.HTTP_201_CREATED
        )


# =======================================
# 🔑 Login
# =======================================
class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get("username")
        email = request.data.get("email")
        password = request.data.get("password")

        user = None

        if username:
            user = authenticate(username=username, password=password)
        elif email:
            try:
                user_obj = User.objects.get(email=email)
                user = authenticate(username=user_obj.username, password=password)
            except User.DoesNotExist:
                user = None

        if user is None:
            return Response(
                api_response(False, "Invalid credentials"),
                status=status.HTTP_401_UNAUTHORIZED
            )

        refresh = RefreshToken.for_user(user)
        update_last_login(None, user)

        profile = Profile.objects.get(user=user)

        return Response(
            api_response(True, "Login successful", {
                "access": str(refresh.access_token),
                "refresh": str(refresh),
                "user": ProfileSerializer(profile).data
            })
        )


# =======================================
# 🔄 Refresh Token
# =======================================
class RefreshTokenView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        refresh_token = request.data.get("refresh")

        if not refresh_token:
            return Response(
                api_response(False, "Refresh token is required"),
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            refresh = RefreshToken(refresh_token)
            access_token = str(refresh.access_token)

            return Response(
                api_response(True, "Token refreshed", {
                    "access": access_token
                })
            )

        except Exception:
            return Response(
                api_response(False, "Invalid or expired refresh token"),
                status=status.HTTP_401_UNAUTHORIZED
            )


# =======================================
# 👤 Profile
# =======================================
class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        profile = Profile.objects.get(user=request.user)

        return Response(
            api_response(True, "Profile fetched", ProfileSerializer(profile).data)
        )

    def put(self, request):
        profile = Profile.objects.get(user=request.user)

        serializer = ProfileSerializer(profile, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(
            api_response(True, "Profile updated", serializer.data)
        )
    
# =======================================
# 👤 logout
# =======================================

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get("refresh")

            if refresh_token:
                token = RefreshToken(refresh_token)
                token.blacklist()

            return Response({"message": "Logged out successfully"}, status=200)

        except Exception as e:
            return Response({"error": str(e)}, status=400)