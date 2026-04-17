import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _androidChannel = AndroidNotificationChannel(
    "medixpro_channel",
    "MedixPro Notifications",
    description: "Clinic management notifications",
    importance: Importance.high,
    playSound: true,
  );

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const windowsSettings = WindowsInitializationSettings(
      appName: "MedixPro",
      appUserModelId: "com.medixpro.app",
      guid: "d50f5e93-45b1-4e62-9d3f-8f4d6a123456",
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      windows: windowsSettings,
    );

    await _plugin.initialize(initSettings);

    // إنشاء الـ channel على Android
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(_androidChannel);

    _initialized = true;
  }

  Future<void> show({
    required String title,
    required String body,
    String category = "system",
    int? id,
  }) async {
    await init();

    final notifId = id ?? DateTime.now().millisecondsSinceEpoch % 100000;

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: "@mipmap/ic_launcher",
      color: const Color(0xFF1976D2),
      styleInformation: BigTextStyleInformation(body),
    );

    const windowsDetails = WindowsNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      windows: windowsDetails,
    );

    await _plugin.show(notifId, title, body, details);
  }

  // ─── Shortcuts ────────────────────────────────────────────────────────────

  Future<void> notifyLogin(String username) => show(
        title: "Welcome back!",
        body: "You are logged in as $username.",
        category: "auth",
      );

  Future<void> notifyPatientAdded(String name) => show(
        title: "Patient Added",
        body: "Patient '$name' has been successfully registered.",
        category: "patient",
      );

  Future<void> notifyAppointmentCreated(String title, String patientName) =>
      show(
        title: "Appointment Scheduled",
        body: "Appointment '$title' for $patientName has been created.",
        category: "appointment",
      );

  Future<void> notifyMedicationAdded(String name, String patientName) => show(
        title: "Prescription Added",
        body: "$name prescribed to $patientName.",
        category: "medication",
      );

  Future<void> notifyReportCreated(String reportTitle, String patientName) =>
      show(
        title: "Report Created",
        body: "Medical report '$reportTitle' for $patientName is ready.",
        category: "report",
      );

  Future<void> notifyLogout() => show(
        title: "Logged Out",
        body: "You have been successfully logged out.",
        category: "auth",
      );

  Future<void> notifyWarning(String message) => show(
        title: "Warning",
        body: message,
        category: "warning",
      );
}

// ignore: avoid_classes_with_only_static_members
class Color {
  final int value;
  const Color(this.value);
}