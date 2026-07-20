# MedixPro — Project Documentation

MedixPro is a clinic/medical-practice management system made up of two subprojects in this repository:

- **`medixpro_backend/`** — a Django 5 + Django REST Framework API (JWT auth, SQLite).
- **`medixpro/`** — a cross-platform Flutter app (BLoC + Clean Architecture) consuming that API, bilingual (English/Arabic).

Domain: patients, appointments (including patient-initiated appointment requests), medications, medical reports, notifications, dashboard stats, and clinic geolocation. Two user roles: **doctor** and **patient**.

---

## 1. Tech Stack

| Layer | Technology |
|---|---|
| Backend framework | Django 5.x + Django REST Framework |
| Auth | `djangorestframework-simplejwt` (JWT, access 6h / refresh 7d, rotation + blacklist) |
| Database | SQLite (`db.sqlite3`) |
| CORS | `django-cors-headers` |
| Images | Pillow |
| Async (partially wired) | Celery + Redis |
| Frontend framework | Flutter (Dart SDK `^3.9.2`) |
| State management | `flutter_bloc` / `bloc` (Cubit pattern) |
| Frontend architecture | Clean Architecture (`data` / `domain` / `presentation` per feature) |
| Networking (frontend) | `dio` |
| Local storage | `flutter_secure_storage`, `hive`, `shared_preferences` |
| DI | `get_it` |
| Maps | `flutter_map` + `latlong2` |
| Charts | `fl_chart` |
| Localization | `flutter_localizations` — English & Arabic (`lib/l10n`) |
| Platforms | Android, iOS, Web, Linux, macOS, Windows |

---

## 2. Backend — `medixpro_backend/`

### 2.1 Configuration highlights (`medixpro_backend/medixpro_backend/settings.py`)

- Custom user model: `AUTH_USER_MODEL = "users.User"`.
- DRF: JWT-only authentication, default permission `IsAuthenticated`, custom pagination (`core.pagination.StandardPagination`, page size 20, responses wrapped as `{success, message, data}`), custom exception handler (`core.exceptions.custom_exception_handler`), throttling (anon 30/min, user 500/hr, login scope 5/min).
- CORS: `CORS_ALLOW_ALL_ORIGINS = DEBUG`; otherwise restricted via `CORS_ORIGINS` env var.
- Env vars: `DJANGO_SECRET_KEY`, `DEBUG`, `ALLOWED_HOSTS`, `DOCTOR_SECRET_KEY` (default `MEDIX-DOCTOR-2026`, gates doctor self-registration), `CORS_ORIGINS`.
- Logging: console + `medixpro.log` file, per-app DEBUG loggers for appointments/patients/notifications.

### 2.2 Apps, models & endpoints

| App | Key models | Endpoints (under `/api/v1/`) |
|---|---|---|
| `core` | *(none — shared infra: pagination, exceptions, utils)* | — |
| `users` | `User` (role: doctor/patient), `Profile` (clinic name, address, lat/long, avatar), `UserPoints` | `auth/register/`, `auth/login/`, `auth/refresh/`, `auth/logout/`, `auth/verify-doctor-key/`, `profile/`, `patient-accounts/`, `clinic-location/` |
| `patients` | `Patient` (demographics, contact, medical history, optional link to `User`) | `patients/` (CRUD) |
| `appointments` | `Appointment` (type, date_time, status, diagnosis...), `AppointmentRequest` (patient-initiated booking) | `appointments/`, `appointment-requests/` (CRUD) |
| `medications` | `CommonMedication` (reference catalog), `Medication` (patient FK, dosage, frequency, route) | `medications/` (CRUD), `common-medications/` (read-only) |
| `notifications` | `Notification` (category: patient/appointment/report/medication/auth/system/warning) — auto-created via signals on Patient/Appointment/Medication/Report changes | `notifications/` (CRUD) |
| `reports` | `Report` (patient FK, optional appointment FK, M2M medications, diagnosis, treatment plan) | `reports/` (CRUD) |
| `dashboard` | *(none — views only)* | `dashboard/stats/`, `dashboard/today-appointments/` |

Auth model: doctors can manage patient user accounts via `PatientAccountManagementView`; doctor registration requires the shared `DOCTOR_SECRET_KEY`.

### 2.3 Dependencies (`requirements.txt`)

```
Django>=5.0,<5.2
djangorestframework
djangorestframework-simplejwt
django-cors-headers
Pillow
celery
redis
```

### 2.4 Known gaps / production-readiness notes

- `MEDIA_URL` / `MEDIA_ROOT` / `STATIC_ROOT` are **not defined** in `settings.py`, even though `urls.py` references `settings.MEDIA_URL`/`MEDIA_ROOT` to serve uploaded avatars in DEBUG — likely to raise an error until fixed.
- `celery` and `redis` are dependencies and `notifications/tasks.py` defines a `shared_task`, but no `CELERY_BROKER_URL`/`CELERY_RESULT_BACKEND` is configured — Celery integration is incomplete/unwired.
- `dashboard` app is **not listed in `INSTALLED_APPS`** despite its views being imported and routed directly in the root `urls.py`. Works today only because it defines no models.
- `SECRET_KEY` and `ALLOWED_HOSTS` fall back to insecure defaults (`"change-me-in-production"`, `"*"`) if their env vars are unset — must be set explicitly before any production deployment.

---

## 3. Frontend — `medixpro/`

### 3.1 Overview (`pubspec.yaml`)

- App name: `medixpro`, version `1.0.0+1`, Dart SDK `^3.9.2`.
- `README.md` in this folder is still the default Flutter boilerplate — not yet customized.

### 3.2 Architecture

Feature-based Clean Architecture. Each folder under `lib/features/<name>/` contains:

- `data/` — datasources, models, repository implementations
- `domain/` — entities, repository interfaces, usecases
- `presentation/` — Cubit + state, pages, widgets

Shared infrastructure lives in `lib/core/`:

- `auth/role_guard.dart`
- `connectivity/connectivity_service.dart`
- `errors/app_error_handler.dart`
- `localization/locale_cubit.dart`
- `network/api_client.dart` (Dio wrapper)
- `notifications/notification_service.dart`
- `storage/token_storage.dart`
- `theme/` (colors, theme, theme cubit)
- `widgets/` (app drawer, connectivity wrapper, language toggle, medical animations/loading, skeletons)

### 3.3 Features (`lib/features/`)

| Feature | Purpose |
|---|---|
| `auth` | Login, register, splash, onboarding, role selection |
| `appointments` | List/details/add/edit, doctor & patient appointment requests, patient dashboard home |
| `dashboard` | Stats and today's appointments, chart widgets (`fl_chart`) |
| `medications` | List/add/edit medications, common-medication lookup |
| `patients` | List/details/add/edit patient, patient card & search |
| `reports` | List/detail/add/edit medical reports |
| `settings` | Profile, notifications, patient account management, app settings |
| `clinic_map` | Clinic location display and picker (`flutter_map`) |

### 3.4 Localization

`lib/l10n/` (driven by `l10n.yaml`) generates `AppLocalizations` from `app_en.arb` and `app_ar.arb` — the app supports **English and Arabic**.

### 3.5 Platforms

Android, iOS, Web, Linux, macOS, and Windows platform folders are all present — full multi-platform Flutter project.

### 3.6 Key dependencies

- State: `bloc`, `flutter_bloc`
- Networking: `dio`
- Storage: `flutter_secure_storage`, `hive`, `shared_preferences`
- DI: `get_it`
- Maps: `flutter_map`, `latlong2`
- Notifications: `flutter_local_notifications`, `timezone`
- Charts: `fl_chart`
- Misc: `connectivity_plus`, `lottie`, `url_launcher`, `intl`, `flutter_localizations`
- Dev: `flutter_lints`, `flutter_test`

---

## 4. Repository layout summary

```
medixpro/                      (repo root)
├── medixpro_backend/          Django REST API
│   ├── core/                  shared pagination/exceptions/utils (no models)
│   ├── users/                 auth, profiles, doctor/patient roles
│   ├── patients/               patient records
│   ├── appointments/           appointments + appointment requests
│   ├── medications/             medications + common medication catalog
│   ├── notifications/          in-app notifications (signal-driven)
│   ├── reports/                 medical reports
│   ├── dashboard/               stats endpoints (not in INSTALLED_APPS)
│   └── medixpro_backend/        settings, root urls, wsgi/asgi
└── medixpro/                   Flutter app
    ├── lib/core/                shared infra (network, storage, theme, auth guard...)
    ├── lib/features/            auth, appointments, dashboard, medications,
    │                            patients, reports, settings, clinic_map
    └── lib/l10n/                English + Arabic translations
```

---

*Generated by reading the repository source (Django settings/models/urls and Flutter pubspec/lib structure) on 2026-07-16. Not derived from `e-store.docx` or `medixpro-documentation.docx`, which were left unread.*
