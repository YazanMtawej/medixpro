from rest_framework import serializers
from .models import Profile


# =====================================
# 👤 Profile Serializer
# =====================================
class ProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = Profile
        fields = [
            'username',
            'email',
            'full_name',
            'clinic_name',
            'address',
            'avatar'
        ]