from django.contrib import admin

from .models import Payment, PayoutSettlement, WebhookEvent


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ("bill_no", "patient", "doctor", "amount", "currency_id",
                    "status", "paid_at", "refunded_at", "created_at")
    list_filter = ("status", "currency_id", "created_at")
    search_fields = ("bill_no", "patient__username", "doctor__username", "tran_id")
    readonly_fields = ("created_at", "updated_at", "paid_at", "refunded_at",
                       "tran_id", "refund_tran_id")


@admin.register(PayoutSettlement)
class PayoutSettlementAdmin(admin.ModelAdmin):
    list_display = ("doctor", "period_year", "period_month", "handled_count",
                    "total_amount", "currency_id", "status", "paid_at")
    list_filter = ("status", "period_year", "period_month")
    search_fields = ("doctor__username", "paid_reference")


@admin.register(WebhookEvent)
class WebhookEventAdmin(admin.ModelAdmin):
    list_display = ("bill_no", "status_id", "tran_id", "processed", "received_at")
    list_filter = ("status_id", "processed")
    search_fields = ("bill_no", "tran_id")
    readonly_fields = ("received_at",)
