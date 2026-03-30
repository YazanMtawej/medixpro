# =====================================
# 🔥 Unified Response Helper
# =====================================
def api_response(success, message, data=None):
    return {
        "success": success,
        "message": message,
        "data": data
    }