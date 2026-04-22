from rest_framework.response import Response


def api_response(success: bool, message: str, data=None, status_code: int = 200) -> dict:
    """Response موحد لكل الـ endpoints."""
    return {
        "success": success,
        "message": message,
        "data":    data,
    }