import logging
from rest_framework.views     import exception_handler
from rest_framework.response  import Response
from rest_framework.exceptions import AuthenticationFailed, NotAuthenticated

logger = logging.getLogger(__name__)


def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    if response is None:
        logger.error(f"Unhandled exception: {exc}", exc_info=True)
        return Response(
            {"success": False, "message": "Internal server error", "data": None},
            status=500,
        )

    # رسائل واضحة للمستخدم
    if isinstance(exc, (NotAuthenticated, AuthenticationFailed)):
        return Response(
            {"success": False, "message": "Authentication required. Please log in again.", "data": None},
            status=401,
        )

    # استخراج رسالة الخطأ
    message = "An error occurred"
    if hasattr(exc, "detail"):
        detail = exc.detail
        if isinstance(detail, dict):
            first_key = next(iter(detail))
            val = detail[first_key]
            message = val[0] if isinstance(val, list) else str(val)
        elif isinstance(detail, list):
            message = str(detail[0])
        else:
            message = str(detail)

    return Response(
        {"success": False, "message": message, "data": None},
        status=response.status_code,
    )