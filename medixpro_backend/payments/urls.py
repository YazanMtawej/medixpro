from django.urls import path

from .views import (
    BookAppointmentView,
    PaymentStatusView,
    ShamCashWebhookView,
    PaymentRedirectView,
    PayoutView,
)

urlpatterns = [
    path("payments/book/", BookAppointmentView.as_view()),
    path("payments/<int:pk>/status/", PaymentStatusView.as_view()),
    path("payments/webhook/shamcash/", ShamCashWebhookView.as_view()),
    path("payments/redirect/", PaymentRedirectView.as_view()),
    path("payments/payouts/", PayoutView.as_view()),
]
