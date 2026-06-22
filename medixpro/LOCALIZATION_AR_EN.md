# Arabic (AR) + English (EN) Localization — Implementation Guide

This document explains every change made to add full **English / Arabic**
support to the MedixPro Flutter app, including automatic **RTL** layout for
Arabic and an in-app language switch placed in the Drawer.

> Where the same pattern is repeated across many files, only **one
> representative example** is shown. The same approach was applied to every
> screen/widget listed.

---

## 1. Overview

| Concern | Solution |
|---|---|
| Translation engine | Flutter's official `flutter_localizations` + `intl` + `gen-l10n` |
| Translation storage | ARB files: `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb` (353 keys each) |
| Generated code | `lib/l10n/app_localizations.dart` (+ `_en` / `_ar`) |
| Runtime language state | `LocaleCubit` (flutter_bloc) persisted with `shared_preferences` |
| Language switch UI | `SwitchListTile` inside `AppDrawer` |
| Backend language hint | `Accept-Language` header added by a Dio interceptor |
| RTL | Automatic — Flutter flips the layout for `ar` with no manual work |

---

## 2. Dependencies & configuration

### `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:      # <-- added
    sdk: flutter
  intl: any                   # <-- added

flutter:
  generate: true              # <-- added: enables gen-l10n
```

### `l10n.yaml` (new file at project root)
Tells `flutter gen-l10n` where the ARB files live and what to generate:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

> `nullable-getter: false` lets us call `AppLocalizations.of(context)`
> directly (non-null), instead of `AppLocalizations.of(context)!`.

**Generate the code after any ARB change:**
```bash
flutter gen-l10n
```

---

## 3. Translation files (ARB)

Every user-facing string is a key in **both** ARB files. The two files must
have the **exact same set of keys** (verified with `diff`).

### `lib/l10n/app_en.arb`
```json
{
  "@@locale": "en",
  "appTitle": "MedixPro",
  "totalPatients": "Total Patients",
  "initializingSystems": "Initializing systems...",
  "patientsCount": "{count} patients",
  "@patientsCount": {
    "placeholders": { "count": { "type": "int" } }
  }
}
```

### `lib/l10n/app_ar.arb`
```json
{
  "@@locale": "ar",
  "appTitle": "ميديكس برو",
  "totalPatients": "إجمالي المرضى",
  "initializingSystems": "جاري تهيئة النظام...",
  "patientsCount": "{count} مريض"
}
```

**Notes**
- Keys with `{placeholder}` (e.g. `patientsCount`) use ICU message format;
  the `@key` metadata declaring placeholder types only needs to live in the
  **template** file (`app_en.arb`).
- The generated getter is a **method** when it has placeholders:
  `l10n.patientsCount(5)` → `"5 patients"` / `"5 مريض"`.
- Plain keys become simple getters: `l10n.totalPatients`.

---

## 4. Runtime language state — `LocaleCubit`

`lib/core/localization/locale_cubit.dart` (new). Mirrors the existing
`ThemeCubit` pattern and persists the choice so it survives app restarts.

```dart
class LocaleCubit extends Cubit<Locale> {
  static const _key = 'app_locale';
  static const englishLocale = Locale('en');
  static const arabicLocale = Locale('ar');

  LocaleCubit() : super(englishLocale) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) emit(Locale(code));
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  void toggleLocale() =>
      setLocale(isArabic ? englishLocale : arabicLocale);

  bool get isArabic => state.languageCode == 'ar';
}
```

---

## 5. Wiring the app — `lib/main.dart`

1. Register the cubit:
```dart
BlocProvider(create: (_) => LocaleCubit()),
```

2. Feed the locale + delegates into `MaterialApp`:
```dart
final locale = context.watch<LocaleCubit>().state;
return MaterialApp(
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,   // localized Material widgets
    GlobalWidgetsLocalizations.delegate,    // text direction (RTL/LTR)
    GlobalCupertinoLocalizations.delegate,
  ],
  // ...
);
```

When `locale` changes, `MaterialApp` rebuilds the whole tree, swaps the
strings, and **automatically flips to RTL** for Arabic.

---

## 6. Language switch UI — `AppDrawer`

`lib/core/widgets/app_drawer.dart` (new). Contains the requested
`SwitchListTile` for language, plus dark mode and a settings link.

```dart
SwitchListTile(
  title: Text(AppLocalizations.of(context).language),
  subtitle: Text(context.watch<LocaleCubit>().isArabic
      ? 'العربية' : 'English'),
  value: context.watch<LocaleCubit>().isArabic,
  activeThumbColor: Theme.of(context).colorScheme.primary,
  onChanged: (_) => context.read<LocaleCubit>().toggleLocale(),
),
```

> `activeThumbColor` is used instead of the deprecated `activeColor`.

The drawer is attached to a screen and opened from a hamburger button:
```dart
Scaffold(
  drawer: const AppDrawer(),
  // ...
  leading: IconButton(
    icon: const Icon(Icons.menu),
    onPressed: () => Scaffold.of(context).openDrawer(),
  ),
);
```

---

## 7. Using translations in screens (the core pattern)

This is the single pattern repeated across **every** page and widget.
Replace each hardcoded string:

**Before**
```dart
const Text("Total Patients")
```

**After**
```dart
Text(AppLocalizations.of(context).totalPatients)
```

When a widget uses many strings, grab the instance once:
```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return Column(children: [
    Text(l10n.totalPatients),
    Text(l10n.todaysAppointments),
    Text(l10n.medicalReports),
  ]);
}
```

> **Gotcha:** `AppLocalizations.of(context)` is not a constant, so you must
> remove `const` from any literal/list/Text that now references it.

**Screens & widgets converted with this pattern:**
- `splash_page.dart` (`initializingSystems`, `versionEdition`)
- `dashboard_page.dart` (stat cards, sections, bottom-nav labels, retry…)
- `stats_chart.dart` (chart titles, subtitles, axis labels, insights)
- All 7 appointment pages (see §8)
- Settings / profile / notifications, patients, reports, medications pages

---

## 8. Backend-coded values → localized labels (appointments)

Some values come from / go to the backend as **fixed codes** (e.g. a status
of `"scheduled"`). The UI must **display** a translated label but still
**submit the original code**. To avoid repeating `switch` blocks in 7 files,
shared helpers live in
`lib/features/appointments/presentation/appointment_l10n.dart`:

```dart
String appointmentStatusLabel(BuildContext context, String code) {
  final l10n = AppLocalizations.of(context);
  switch (code) {
    case 'scheduled': return l10n.statusScheduled;
    case 'completed': return l10n.statusCompleted;
    case 'cancelled': return l10n.statusCancelled;
    // pending / no_show / rescheduled ...
    default: return code;
  }
}
// also: appointmentRequestStatusLabel, patientRequestStatusLabel,
//       appointmentTypeLabel
```

**Dropdown pattern** — store codes, display labels:
```dart
DropdownButtonFormField<String>(
  value: selectedStatusCode,                 // backend code
  items: ['scheduled', 'completed', 'cancelled']
      .map((code) => DropdownMenuItem(
            value: code,                       // submitted to backend
            child: Text(appointmentStatusLabel(context, code)), // shown
          ))
      .toList(),
  onChanged: (code) => setState(() => selectedStatusCode = code),
);
```

This converted the previous `static const Map<code, EnglishLabel>` lists into
**code lists + label functions** in every appointment screen.

---

## 9. Telling the backend the language — Dio interceptor

`lib/core/network/api_client.dart` adds an interceptor that attaches the
saved language to every request so the API can localize its responses:

```dart
void _addLocaleInterceptor() {
  _dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString('app_locale') ?? 'en';
      options.headers['Accept-Language'] = code;
      handler.next(options);
    },
  ));
}
```

---

## 10. How to add a NEW translated string (checklist)

1. Add the key to **`lib/l10n/app_en.arb`**.
2. Add the **same key** (translated) to **`lib/l10n/app_ar.arb`**.
3. Run `flutter gen-l10n`.
4. Use it: `AppLocalizations.of(context).yourNewKey`.

Verify the two ARB files stay in sync:
```bash
diff <(grep -o '"[a-zA-Z0-9_]*":' lib/l10n/app_en.arb | sort) \
     <(grep -o '"[a-zA-Z0-9_]*":' lib/l10n/app_ar.arb | sort)
```
(Empty output = same keys in both.)

---

## 11. Verification done

- `flutter analyze lib/` → **0 errors**.
- ARB parity: **353 keys** in each file, `diff` empty.
- Manual sweep for hardcoded `Text` / `hintText` / `labelText` / `title` in
  pages & widgets → **0 visible strings remaining**.

---

## 12. Known limitation (deferred)

~36 **push-notification strings** inside cubits
(`appointments_cubit.dart`, `medications_cubit.dart`, `patients_cubit.dart`,
`reports_cubit.dart`) are still English, because cubits have no
`BuildContext`.

**Planned fix (not yet applied):** store the current locale statically in
`LocaleCubit` and resolve strings without context:
```dart
// in LocaleCubit: keep `static Locale current;` updated on every setLocale
AppLocalizations get appL10n => lookupAppLocalizations(LocaleCubit.current);
```
