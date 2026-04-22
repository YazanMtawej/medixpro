from rest_framework.viewsets import ModelViewSet
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models      import Notification
from .serializers import NotificationSerializer
from core.utils   import api_response


class NotificationViewSet(ModelViewSet):
    serializer_class   = NotificationSerializer
    permission_classes = [IsAuthenticated]
    http_method_names  = ["get", "patch", "delete", "post", "head", "options"]

    def get_queryset(self):
        # ✅ only_fields + limit لتحسين الأداء
        return (
            Notification.objects
            .filter(user=self.request.user)
            .order_by("-created_at")[:100]  # ✅ حد أقصى 100
        )

    def list(self, request, *args, **kwargs):
        qs     = self.get_queryset()
        unread = Notification.objects.filter(
            user=request.user, is_read=False
        ).count()
        s = self.get_serializer(qs, many=True)
        return Response(api_response(True, "Notifications fetched", {
            "unread_count":  unread,
            "notifications": s.data,
        }))

    def partial_update(self, request, *args, **kwargs):
        instance         = self.get_object()
        instance.is_read = True
        instance.save(update_fields=["is_read"])  # ✅ update فقط حقل واحد
        return Response(api_response(True, "Marked as read"))

    def destroy(self, request, *args, **kwargs):
        self.get_object().delete()
        return Response(api_response(True, "Notification deleted"))

    @action(detail=False, methods=["post"], url_path="mark-all-read")
    def mark_all_read(self, request):
        Notification.objects.filter(
            user=request.user, is_read=False
        ).update(is_read=True)  # ✅ bulk update
        return Response(api_response(True, "All marked as read"))

    @action(detail=False, methods=["delete"], url_path="clear-all")
    def clear_all(self, request):
        Notification.objects.filter(user=request.user).delete()
        return Response(api_response(True, "All cleared"))