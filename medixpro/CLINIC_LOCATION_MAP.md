# Clinic Location on Map — Implementation Guide

This document explains every change made to add the **clinic location on a
map** feature to MedixPro:

- A **location** floating action button (FAB) on the home screen.
- **Patient** taps it → sees the doctor's clinic pin on a map (read-only).
- **Doctor** taps it → taps the map to drop/move the clinic pin and saves it.

The map uses **OpenStreetMap** via the free `flutter_map` package (no API key,
no billing).

> Where the same pattern repeats, only **one** representative example is shown.

---

## 1. Overview

| Concern | Solution |
|---|---|
| Map widget | `flutter_map` (OpenStreetMap tiles) + `latlong2` for `LatLng` |
| Where coordinates live | `Profile.latitude` / `Profile.longitude` on the Django backend |
| Doctor saves location | Existing `PUT /api/v1/profile/` (taps map → save) |
| Patient reads location | New endpoint `GET /api/v1/clinic-location/` |
| Role detection | `AuthCubit` → `AuthAuthenticated.user.isDoctor` |
| Entry point | One reusable FAB on both home screens |

**Flow**

```
Doctor                                   Patient
  │ tap location FAB                        │ tap location FAB
  ▼                                         ▼
ClinicMapPage(editable: true)            ClinicMapPage(editable: false)
  │ loads own saved pin (GET profile/)     │ GET clinic-location/
  │ tap map → move pin                      │ shows doctor's pin (read-only)
  │ Save → PUT profile/ {lat,lng}           │
  ▼                                         ▼
 stored on Profile  ───────────────────►  displayed to patient
```

---

## 2. Backend (Django)

### 2.1 Model — `users/models.py`
Two nullable coordinate fields added to `Profile`:
```python
class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    full_name = models.CharField(max_length=120, blank=True)
    clinic_name = models.CharField(max_length=120, blank=True)
    address = models.TextField(blank=True)
    latitude = models.FloatField(null=True, blank=True)    # <-- added
    longitude = models.FloatField(null=True, blank=True)   # <-- added
    avatar = models.ImageField(upload_to="avatars/", blank=True, null=True)
```

### 2.2 Serializer — `users/serializers.py`
`latitude` and `longitude` added to the `fields` list so they are both
read and written through `ProfileView`.

### 2.3 Migration
```bash
python manage.py makemigrations users   # -> 0003_profile_latitude_profile_longitude.py
python manage.py migrate users
```
(Already generated **and applied**.)

### 2.4 New endpoint — `users/views.py`
Returns the doctor's clinic location for any authenticated user (patient):
```python
class ClinicLocationView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # first doctor who has set coordinates
        profile = (
            Profile.objects
            .filter(user__role=User.Role.DOCTOR,
                    latitude__isnull=False, longitude__isnull=False)
            .select_related("user")
            .first()
        )
        if profile is None:
            return Response(api_response(False, "No clinic location set yet"),
                            status=404)
        return Response(api_response(True, "Clinic location fetched", {
            "clinic_name": profile.clinic_name,
            "address": profile.address,
            "latitude": profile.latitude,
            "longitude": profile.longitude,
        }))
```

### 2.5 URL — `medixpro_backend/urls.py`
```python
from users.views import ClinicLocationView
# ...
path('api/v1/clinic-location/', ClinicLocationView.as_view()),
```

> **Note (single clinic):** the endpoint returns the **first** doctor with a
> location. That's correct for a one-clinic setup. For multiple doctors per
> patient, resolve the specific doctor (e.g. via the patient's
> appointment/request relation) instead of `.first()`.

---

## 3. Flutter — packages

```bash
flutter pub add flutter_map latlong2
```
- `flutter_map` — renders OpenStreetMap tiles, markers, tap handling.
- `latlong2` — provides the `LatLng` type used by `flutter_map`.

No Google Maps key, no `geolocator`/GPS — the doctor sets the pin by tapping.

---

## 4. Flutter — data layer

`lib/features/clinic_map/data/clinic_location_datasource.dart`

```dart
class ClinicLocation {
  final double latitude;
  final double longitude;
  final String clinicName;
  final String address;
  // ...
}

class ClinicLocationDataSource {
  final ApiClient api;
  const ClinicLocationDataSource(this.api);

  // Patient: doctor's clinic (null if none set / 404)
  Future<ClinicLocation?> fetchClinicLocation() async {
    final res = await api.dio.get("clinic-location/");
    final data = res.data["data"] as Map<String, dynamic>?;
    // ... parse lat/lng, return ClinicLocation or null
  }

  // Doctor: own already-saved pin (to pre-fill the map)
  Future<ClinicLocation?> fetchMyLocation() async {
    final res = await api.dio.get("profile/");
    // ... same parsing as above
  }

  // Doctor: persist picked coordinates
  Future<void> saveClinicLocation(double latitude, double longitude) async {
    await api.dio.put("profile/", data: {
      "latitude": latitude,
      "longitude": longitude,
    });
  }
}
```

---

## 5. Flutter — the map page

`lib/features/clinic_map/presentation/clinic_map_page.dart`

One page handles **both** roles via the `editable` flag.

**Key parts:**
```dart
ClinicMapPage({
  required this.dataSource,
  this.initialLocation,   // optional pre-known LatLng
  this.editable = false,  // doctor = true, patient = false
});
```

Loading logic (in `initState` → `_load`):
```dart
final loc = widget.editable
    ? await widget.dataSource.fetchMyLocation()      // doctor's saved pin
    : await widget.dataSource.fetchClinicLocation(); // doctor's clinic (patient)
```

The map itself:
```dart
FlutterMap(
  options: MapOptions(
    initialCenter: _selected ?? _fallbackCenter,   // fallback only until known
    initialZoom: _selected != null ? 15 : 5,
    onTap: widget.editable
        ? (_, point) => setState(() => _selected = point)  // drop/move pin
        : null,                                            // read-only
  ),
  children: [
    TileLayer(
      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      userAgentPackageName: "com.medixpro.app",
    ),
    if (_selected != null)
      MarkerLayer(markers: [
        Marker(point: _selected!, width: 48, height: 48,
               child: Icon(Icons.location_on, size: 48,
                           color: Theme.of(context).colorScheme.primary)),
      ]),
  ],
)
```

Save (doctor only — shown as an extended FAB):
```dart
await widget.dataSource.saveClinicLocation(_selected!.latitude, _selected!.longitude);
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.locationSaved)));
Navigator.of(context).pop(_selected);
```

An info banner at the top shows the hint (`tapToSetLocation` for the doctor)
or the clinic name/address (for the patient).

---

## 6. Flutter — the FAB

`lib/features/clinic_map/presentation/clinic_location_fab.dart`

A single reusable FAB that switches behavior by role:
```dart
final isDoctor = authState is AuthAuthenticated && authState.user.isDoctor;

FloatingActionButton(
  tooltip: isDoctor ? l10n.setClinicLocation : l10n.viewClinicLocation,
  child: const Icon(Icons.location_on),
  onPressed: () {
    final dataSource = ClinicLocationDataSource(context.read<ApiClient>());
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ClinicMapPage(dataSource: dataSource, editable: isDoctor),
    ));
  },
);
```

---

## 7. Flutter — wiring it in

### 7.1 Provide `ApiClient` — `lib/main.dart`
The FAB reads `ApiClient` from the widget tree, so it's now provided:
```dart
RepositoryProvider.value(value: apiClient),   // added next to tokenStorage
```

### 7.2 Patient home — `patient_dashboard_home.dart`
```dart
Scaffold(
  floatingActionButton: const ClinicLocationFab(),  // patient = view-only
  // ...
);
```

### 7.3 Doctor home — `dashboard_page.dart`
Shown only on the doctor's home tab (patients get theirs from the nested
`patient_dashboard_home` Scaffold):
```dart
Scaffold(
  floatingActionButton: (isDoctor && safeIndex == 0)
      ? const ClinicLocationFab()
      : null,
  // ...
);
```

### 7.4 Profile entity — `user_profile.dart`
`UserProfile` now carries the coordinates parsed from the API:
```dart
final double? latitude;
final double? longitude;
// ...
latitude:  (data["latitude"]  as num?)?.toDouble(),
longitude: (data["longitude"] as num?)?.toDouble(),
```

---

## 8. Localization

8 keys added to **both** `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`,
then `flutter gen-l10n`:

| Key | English |
|---|---|
| `clinicLocation` | Clinic Location |
| `setClinicLocation` | Set Clinic Location |
| `saveLocation` | Save Location |
| `locationSaved` | Clinic location saved |
| `locationSaveFailed` | Could not save location. Please try again. |
| `tapToSetLocation` | Tap on the map to set your clinic location |
| `noClinicLocation` | No clinic location set yet |
| `viewClinicLocation` | View clinic location |

(Arabic equivalents added in `app_ar.arb`; the map auto-flips to RTL in Arabic.)

---

## 9. Android permission

Map tiles are downloaded over the network. The release manifest was missing
`INTERNET` (it's only auto-added to debug/profile builds), so it was added:

`android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 10. Files changed / added

**Backend**
- `users/models.py` — `latitude` / `longitude` on `Profile`
- `users/serializers.py` — fields added
- `users/views.py` — `ClinicLocationView`
- `medixpro_backend/urls.py` — `clinic-location/` route
- `users/migrations/0003_profile_latitude_profile_longitude.py` — new (applied)

**Flutter**
- `pubspec.yaml` — `flutter_map`, `latlong2`
- `lib/features/clinic_map/data/clinic_location_datasource.dart` — new
- `lib/features/clinic_map/presentation/clinic_map_page.dart` — new
- `lib/features/clinic_map/presentation/clinic_location_fab.dart` — new
- `lib/main.dart` — provide `ApiClient`
- `lib/features/appointments/presentation/pages/patient_dashboard_home.dart` — FAB
- `lib/features/dashboard/presentation/pages/dashboard_page.dart` — FAB (doctor home tab)
- `lib/features/settings/domain/entities/user_profile.dart` — lat/lng fields
- `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb` — 8 keys each
- `android/app/src/main/AndroidManifest.xml` — INTERNET permission

---

## 11. How to test

1. Run the backend (`python manage.py runserver`) and the app.
2. Log in as a **doctor** → home tab → tap the location FAB → tap a spot on
   the map → **Save Location**.
3. Log in as a **patient** → tap the location FAB → the doctor's pin and
   clinic name/address appear (read-only).

---

## 12. Known limitation / future work

- **Single clinic:** patient endpoint returns the first doctor with a
  location. Switch `.first()` to resolve the patient's specific doctor when
  multi-doctor support is added.
- **No GPS:** the doctor sets the pin manually by tapping. A "use my current
  location" button could be added later with the `geolocator` package
  (requires a location permission).
