from pathlib import Path
from datetime import timedelta
import os

BASE_DIR = Path(__file__).resolve().parent.parent

# ─── Security ─────────────────────────────────────────────────────────────────
SECRET_KEY       = os.environ.get("DJANGO_SECRET_KEY", "change-me-in-production")
DEBUG            = os.environ.get("DEBUG", "True") == "True"
ALLOWED_HOSTS    = os.environ.get("ALLOWED_HOSTS", "*").split(",")
DOCTOR_SECRET_KEY = os.environ.get("DOCTOR_SECRET_KEY", "MEDIX-DOCTOR-2026")

# Render injects the service's public hostname here — trust it automatically.
RENDER_EXTERNAL_HOSTNAME = os.environ.get("RENDER_EXTERNAL_HOSTNAME")
CSRF_TRUSTED_ORIGINS = []
if RENDER_EXTERNAL_HOSTNAME:
    ALLOWED_HOSTS.append(RENDER_EXTERNAL_HOSTNAME)
    CSRF_TRUSTED_ORIGINS.append(f"https://{RENDER_EXTERNAL_HOSTNAME}")

# ─── Production hardening (only when DEBUG is off) ─────────────────────────────
if not DEBUG:
    # Render terminates TLS at its proxy and forwards this header.
    SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_HSTS_SECONDS = 31536000  # 1 year
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "rest_framework",
    "rest_framework.authtoken",
    "rest_framework_simplejwt.token_blacklist",
    "corsheaders",
    "core",
    "users",
    "patients",
    "appointments",
    "medications",
    "notifications",
    "reports",
    "payments",
]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF    = "medixpro_backend.urls"
AUTH_USER_MODEL = "users.User"

import dj_database_url

DATABASES = {
    # On Render (and any host that sets DATABASE_URL) this uses Postgres.
    # Locally, with no DATABASE_URL set, it falls back to SQLite.
    "default": dj_database_url.config(
        default=f"sqlite:///{BASE_DIR / 'db.sqlite3'}",
        conn_max_age=600,
        conn_health_checks=True,
    )
}
TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "templates"],  # optional
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",  # 🔥 مهم للـ admin
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]
# ─── REST Framework ────────────────────────────────────────────────────────────
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
    "DEFAULT_PAGINATION_CLASS": "core.pagination.StandardPagination",
    "PAGE_SIZE": 20,
    "EXCEPTION_HANDLER": "core.exceptions.custom_exception_handler",
    # ✅ throttling للحماية من brute force
    "DEFAULT_THROTTLE_CLASSES": [
        "rest_framework.throttling.AnonRateThrottle",
        "rest_framework.throttling.UserRateThrottle",
        "rest_framework.throttling.ScopedRateThrottle",
    ],
    "DEFAULT_THROTTLE_RATES": {
        "anon": "30/minute",
        "user": "500/hour",
        "login": "5/minute", 
    },
}

# ─── JWT ──────────────────────────────────────────────────────────────────────
SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME":  timedelta(hours=6),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
    "ROTATE_REFRESH_TOKENS":  True,
    "BLACKLIST_AFTER_ROTATION": True,
    "AUTH_HEADER_TYPES": ("Bearer",),
    "UPDATE_LAST_LOGIN": True,
}

# ─── CORS ─────────────────────────────────────────────────────────────────────
CORS_ALLOW_ALL_ORIGINS = DEBUG  # ✅ production: False
CORS_ALLOWED_ORIGINS   = os.environ.get(
    "CORS_ORIGINS", "http://localhost:8000"
).split(",")

# ─── Logging ──────────────────────────────────────────────────────────────────
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "verbose": {
            "format": "[{levelname}] {asctime} {module}: {message}",
            "style": "{",
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "verbose",
        },
        "file": {
            "class": "logging.FileHandler",
            "filename": BASE_DIR / "medixpro.log",
            "formatter": "verbose",
        },
    },
    "loggers": {
        "django":        {"handlers": ["console", "file"], "level": "WARNING"},
        "appointments":  {"handlers": ["console", "file"], "level": "DEBUG"},
        "patients":      {"handlers": ["console", "file"], "level": "DEBUG"},
        "notifications": {"handlers": ["console", "file"], "level": "DEBUG"},
    },
}

# ─── Misc ─────────────────────────────────────────────────────────────────────
LANGUAGE_CODE      = "en-us"
TIME_ZONE          = "UTC"
USE_TZ             = True
STATIC_URL         = "/static/"
STATIC_ROOT        = BASE_DIR / "staticfiles"
MEDIA_URL          = "/media/"
MEDIA_ROOT         = BASE_DIR / "media"
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# WhiteNoise serves compressed, hashed static files straight from the web process.
STORAGES = {
    "default": {"BACKEND": "django.core.files.storage.FileSystemStorage"},
    "staticfiles": {
        "BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage",
    },
}

# ─── Celery ───────────────────────────────────────────────────────────────────
# On the free tier there is no Redis broker / worker, so tasks run inline
# (synchronously) inside the web process. Set CELERY_TASK_ALWAYS_EAGER=False and
# provide CELERY_BROKER_URL once you add a real worker + Redis.
CELERY_BROKER_URL = os.environ.get("CELERY_BROKER_URL", "")
CELERY_TASK_ALWAYS_EAGER = os.environ.get("CELERY_TASK_ALWAYS_EAGER", "True") == "True"
CELERY_TASK_EAGER_PROPAGATES = True

# ─── Sham Cash E-Payment ──────────────────────────────────────────────────────
# The AES secretKey authorises the whole agent account — keep it server-side only.
SHAMCASH_BASE_URL    = os.environ.get("SHAMCASH_BASE_URL", "https://dev.shamlogix.tech/services")
SHAMCASH_AGENT_KEY   = os.environ.get("SHAMCASH_AGENT_KEY", "JKAWASLaflka1351FLPG")
SHAMCASH_SECRET_KEY  = os.environ.get("SHAMCASH_SECRET_KEY", "fuQMtK4kd7PcpNgWzLjFlogoIXNBw2TG6O4BHgsxt8o=")
SHAMCASH_CURRENCY_ID = int(os.environ.get("SHAMCASH_CURRENCY_ID", "2"))  # 1=USD, 2=SYP

# Fraction of a doctor's receipt the patient pays as a booking fee (0.20 = 20%).
PLATFORM_FEE_RATE = os.environ.get("PLATFORM_FEE_RATE", "0.20")

# Publicly reachable base URL ShamCash uses for callbackUrl/redirectUrl.
# In local dev, expose the backend via a tunnel (e.g. ngrok) and set this env var,
# otherwise ShamCash cannot deliver the payment webhook.
PUBLIC_BASE_URL = os.environ.get("PUBLIC_BASE_URL", "http://127.0.0.1:8000")