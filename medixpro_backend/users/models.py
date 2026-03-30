from django.contrib.auth.models import AbstractUser
from django.db import models


# =====================================
# 👤 Custom User
# =====================================
class User(AbstractUser):
    phone = models.CharField(max_length=20, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)


# =====================================
# 👤 Profile (مرتبط بالمستخدم)
# =====================================
class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)

    full_name = models.CharField(max_length=120, blank=True)
    clinic_name = models.CharField(max_length=120, blank=True)
    address = models.TextField(blank=True)

    avatar = models.ImageField(upload_to="avatars/", blank=True)

    def __str__(self):
        return self.user.username


# =====================================
# 💰 User Points (History)
# =====================================
class UserPoints(models.Model):
    TRANSACTION_TYPES = (
        ('charge', 'Charge'),
        ('purchase', 'Purchase'),
    )

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    amount = models.IntegerField()
    type = models.CharField(max_length=10, choices=TRANSACTION_TYPES)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.type} - {self.amount}"