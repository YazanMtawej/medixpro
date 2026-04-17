from django.contrib import admin
from .models import Notification


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display  = ("id", "user", "title", "category", "is_read", "created_at")
    list_filter   = ("category", "is_read")
    search_fields = ("title", "message", "user__username")
    ordering      = ("-created_at",)