import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // ─── Singleton ────────────────────────────────────────────────────────────
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ─── Channel IDs ──────────────────────────────────────────────────────────
  static const _mainChannelId    = "medixpro_main";
  static const _mainChannelName  = "MedixPro Alerts";
  static const _schedChannelId   = "medixpro_scheduled";
  static const _schedChannelName = "MedixPro Scheduled";

  // ─── Init ─────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings("@mipmap/ic_launcher");

      const windowsSettings = WindowsInitializationSettings(
        appName: "MedixPro",
        appUserModelId: "com.medixpro.clinic",
        guid: "A9E86E2B-4C1F-4D3A-B5E8-7F2D3A1C9B4E",
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        windows: windowsSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onTap,
      );

      // إنشاء channels على Android
      final android = _plugin.resolvePlatformSpecificImplementation
          <AndroidFlutterLocalNotificationsPlugin>();

      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _mainChannelId,
          _mainChannelName,
          description: "Instant clinic management alerts",
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _schedChannelId,
          _schedChannelName,
          description: "Scheduled appointment reminders",
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      await android?.requestNotificationsPermission();

      _initialized = true;
    } catch (_) {
      // لا نوقف التطبيق إذا فشل الإشعار
    }
  }

  void _onTap(NotificationResponse response) {}

  // ─── Show Instant ─────────────────────────────────────────────────────────
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    _MedixCategory category = _MedixCategory.system,
  }) async {
    try {
      if (!_initialized) await init();

      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _mainChannelId,
            _mainChannelName,
            channelDescription: "Instant clinic management alerts",
            importance: Importance.max,
            priority: Priority.high,
            icon: "@mipmap/ic_launcher",
            category: category.androidCategory,
            styleInformation: BigTextStyleInformation(
              body,
              contentTitle: title,
              summaryText: category.label,
            ),
          ),
          windows: const WindowsNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (_) {}
  }

  // ─── Schedule ─────────────────────────────────────────────────────────────
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      if (!_initialized) await init();

      final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _schedChannelId,
            _schedChannelName,
            channelDescription: "Scheduled appointment reminders",
            importance: Importance.max,
            priority: Priority.high,
            icon: "@mipmap/ic_launcher",
            category: AndroidNotificationCategory.reminder,
            styleInformation: BigTextStyleInformation(
              body,
              contentTitle: title,
            ),
          ),
          windows: const WindowsNotificationDetails(),
        ),
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {}
  }

  // ─── Cancel ───────────────────────────────────────────────────────────────
  Future<void> cancel(int id) async {
    try { await _plugin.cancel(id); } catch (_) {}
  }

  Future<void> cancelAll() async {
    try { await _plugin.cancelAll(); } catch (_) {}
  }

  // ─── Auth Shortcuts ───────────────────────────────────────────────────────
  Future<void> notifyLogin(String username) => showNotification(
        id: 9001,
        title: "Welcome back 👋",
        body: "You're logged in as $username.",
        category: _MedixCategory.auth,
      );

  Future<void> notifyLogout() => showNotification(
        id: 9002,
        title: "Logged Out",
        body: "You have been logged out of MedixPro.",
        category: _MedixCategory.auth,
      );

  // ─── Patient Shortcuts ────────────────────────────────────────────────────
  Future<void> notifyPatientAdded(String name) => showNotification(
        id: _uid(),
        title: "New Patient Registered",
        body: "Patient '$name' has been added successfully.",
        category: _MedixCategory.patient,
      );

  Future<void> notifyPatientDeleted(String name) => showNotification(
        id: _uid(),
        title: "Patient Removed",
        body: "Patient '$name' and all related records were deleted.",
        category: _MedixCategory.warning,
      );

  // ─── Appointment Shortcuts ────────────────────────────────────────────────
  Future<void> notifyAppointmentCreated(String title, String patient) =>
      showNotification(
        id: _uid(),
        title: "Appointment Scheduled",
        body: "'$title' for $patient has been created.",
        category: _MedixCategory.appointment,
      );

  Future<void> notifyAppointmentUpdated(String title, String status) =>
      showNotification(
        id: _uid(),
        title: "Appointment Updated",
        body: "'$title' is now: $status.",
        category: _MedixCategory.appointment,
      );

  Future<void> notifyAppointmentDeleted(String title) => showNotification(
        id: _uid(),
        title: "Appointment Removed",
        body: "Appointment '$title' has been deleted.",
        category: _MedixCategory.warning,
      );

  Future<void> scheduleAppointmentReminder({
    required int id,
    required String title,
    required String patientName,
    required DateTime appointmentTime,
  }) =>
      scheduleNotification(
        id: id,
        title: "⏰ Upcoming Appointment",
        body: "'$title' for $patientName in 30 minutes.",
        scheduledTime: appointmentTime.subtract(const Duration(minutes: 30)),
      );

  // ─── Medication Shortcuts ─────────────────────────────────────────────────
  Future<void> notifyMedicationAdded(String name, String patient) =>
      showNotification(
        id: _uid(),
        title: "Prescription Added",
        body: "$name prescribed to $patient.",
        category: _MedixCategory.medication,
      );

  Future<void> notifyMedicationDeleted(String name) => showNotification(
        id: _uid(),
        title: "Prescription Removed",
        body: "Medication '$name' has been deleted.",
        category: _MedixCategory.warning,
      );

  // ─── Report Shortcuts ─────────────────────────────────────────────────────
  Future<void> notifyReportCreated(String title, String patient) =>
      showNotification(
        id: _uid(),
        title: "Report Created",
        body: "Medical report '$title' for $patient is ready.",
        category: _MedixCategory.report,
      );

  Future<void> notifyReportFinalized(String title) => showNotification(
        id: _uid(),
        title: "Report Finalized ✅",
        body: "Report '$title' has been marked as final.",
        category: _MedixCategory.report,
      );

  Future<void> notifyReportDeleted(String title) => showNotification(
        id: _uid(),
        title: "Report Deleted",
        body: "Report '$title' has been permanently deleted.",
        category: _MedixCategory.warning,
      );

  // ─── Generic ──────────────────────────────────────────────────────────────
  Future<void> notifyWarning(String message) => showNotification(
        id: _uid(),
        title: "⚠️ Warning",
        body: message,
        category: _MedixCategory.warning,
      );

  Future<void> notifySuccess(String message) => showNotification(
        id: _uid(),
        title: "✅ Done",
        body: message,
        category: _MedixCategory.system,
      );

  // ─── Helper ───────────────────────────────────────────────────────────────
  int _uid() => DateTime.now().millisecondsSinceEpoch % 100000;
}

// ─── Category ─────────────────────────────────────────────────────────────────
enum _MedixCategory {
  auth(       "Auth",        AndroidNotificationCategory.message),
  patient(    "Patient",     AndroidNotificationCategory.message),
  appointment("Appointment", AndroidNotificationCategory.event),
  medication( "Medication",  AndroidNotificationCategory.reminder),
  report(     "Report",      AndroidNotificationCategory.message),
  warning(    "Warning",     AndroidNotificationCategory.error),
  system(     "System",      AndroidNotificationCategory.status);

  final String                     label;
  final AndroidNotificationCategory androidCategory;
  const _MedixCategory(this.label, this.androidCategory);
}