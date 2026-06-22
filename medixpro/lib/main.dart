import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import 'package:medixpro/core/connectivity/connectivity_service.dart';
import 'package:medixpro/core/widgets/connectivity_wrapper.dart';
import 'package:medixpro/features/settings/domain/repositories/settings_repository.dart';

// ================= CORE =================
import 'core/network/api_client.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/localization/locale_cubit.dart';

// ================= AUTH =================
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/role_selection_page.dart';

// ================= DASHBOARD =================
import 'features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'features/dashboard/data/repositories_impl/dashboard_repository_impl.dart';
import 'features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'features/dashboard/domain/usecases/get_today_appointments_usecase.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

// ================= SETTINGS =================
import 'features/settings/data/datasources/settings_remote_datasource.dart';
import 'features/settings/data/repositories_impl/settings_repository_impl.dart';
import 'features/settings/domain/usecases/get_profile_usecase.dart';
import 'features/settings/domain/usecases/update_profile_usecase.dart';
import 'features/settings/domain/usecases/get_notifications_usecase.dart';
import 'features/settings/domain/usecases/logout_usecase.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/settings/presentation/pages/profile_page.dart';
import 'features/settings/presentation/pages/notifications_page.dart';

// ================= PATIENTS =================
import 'features/patients/data/datasources/patients_remote_datasource.dart';
import 'features/patients/data/repositories_impl/patients_repository_impl.dart';
import 'features/patients/domain/usecases/get_patients_usecase.dart';
import 'features/patients/domain/usecases/add_patient_usecase.dart';
import 'features/patients/domain/usecases/update_patient_usecase.dart';
import 'features/patients/domain/usecases/delete_patient_usecase.dart';
import 'features/patients/presentation/cubit/patients_cubit.dart';
import 'features/patients/presentation/pages/patients_list_page.dart';

// ================= REPORTS =================
import 'features/reports/data/datasources/reports_remote_datasource.dart';
import 'features/reports/data/repositories_impl/reports_repository_impl.dart';
import 'features/reports/domain/usecases/get_reports_usecase.dart';
import 'features/reports/domain/usecases/add_report_usecase.dart';
import 'features/reports/domain/usecases/update_report_usecase.dart';
import 'features/reports/domain/usecases/delete_report_usecase.dart';
import 'features/reports/presentation/cubit/reports_cubit.dart';
import 'features/reports/presentation/pages/reports_page.dart';

// ================= MEDICATIONS =================
import 'features/medications/data/datasources/medications_remote_datasource.dart';
import 'features/medications/data/repositories_impl/medications_repository_impl.dart';
import 'features/medications/domain/usecases/get_medications_usecase.dart';
import 'features/medications/domain/usecases/add_medication_usecase.dart';
import 'features/medications/domain/usecases/update_medication_usecase.dart';
import 'features/medications/domain/usecases/delete_medication_usecase.dart';
import 'features/medications/presentation/cubit/medications_cubit.dart';
import 'features/medications/presentation/pages/medications_page.dart';
import 'features/medications/domain/usecases/get_common_medications_usecase.dart';
// ================= APPOINTMENTS =================
import 'features/appointments/data/datasources/appointments_remote_datasource.dart';
import 'features/appointments/data/repositories_impl/appointments_repository_impl.dart';
import 'features/appointments/presentation/cubit/appointments_cubit.dart';
import 'features/appointments/presentation/pages/appointments_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();
  ConnectivityService.instance.init();
  // ─── Core ─────────────────────────────────────────────────────────────────
  const secureStorage = FlutterSecureStorage();
  final tokenStorage = TokenStorage(secureStorage);
  final apiClient = ApiClient(tokenStorage);

  // ─── Data Sources ─────────────────────────────────────────────────────────
  final authRemote = AuthRemoteDataSource(apiClient);
  final dashboardRemote = DashboardRemoteDataSource(apiClient);
  final settingsRemote = SettingsRemoteDataSource(apiClient);
  final patientsRemote = PatientsRemoteDataSource(apiClient);
  final reportsRemote = ReportsRemoteDataSource(apiClient);
  final medicationsRemote = MedicationsRemoteDataSource(apiClient);
  final appointmentsRemote = AppointmentsRemoteDataSource(apiClient);

  // ─── Repositories ─────────────────────────────────────────────────────────
  final authRepository = AuthRepositoryImpl(authRemote, tokenStorage);
  final dashboardRepository = DashboardRepositoryImpl(dashboardRemote);
  final settingsRepository = SettingsRepositoryImpl(settingsRemote);
  final patientsRepository = PatientsRepositoryImpl(patientsRemote);
  final reportsRepository = ReportsRepositoryImpl(reportsRemote);
  final medicationsRepository = MedicationsRepositoryImpl(medicationsRemote);
  final appointmentsRepository = AppointmentsRepositoryImpl(appointmentsRemote);

  // ─── Use Cases ────────────────────────────────────────────────────────────

  // Auth
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);

  // Dashboard
  final getDashboardStats = GetDashboardStatsUseCase(dashboardRepository);
  final getTodayAppointments = GetTodayAppointmentsUseCase(dashboardRepository);

  // Settings
  final getProfile = GetProfileUseCase(settingsRepository);
  final updateProfile = UpdateProfileUseCase(settingsRepository);
  final getNotifications = GetNotificationsUseCase(settingsRepository);
  final logoutUseCase = LogoutUseCase(settingsRepository);

  // Patients
  final getPatients = GetPatientsUseCase(patientsRepository);
  final addPatient = AddPatientUseCase(patientsRepository);
  final updatePatient = UpdatePatientUseCase(patientsRepository);
  final deletePatient = DeletePatientUseCase(patientsRepository);

  // Reports
  final getReports = GetReportsUseCase(reportsRepository);
  final addReport = AddReportUseCase(reportsRepository);
  final updateReport = UpdateReportUseCase(reportsRepository);
  final deleteReport = DeleteReportUseCase(reportsRepository);

  // Medications
  final getMedications = GetMedicationsUseCase(medicationsRepository);
  final addMedication = AddMedicationUseCase(medicationsRepository);
  final updateMedication = UpdateMedicationUseCase(medicationsRepository);
  final deleteMedication = DeleteMedicationUseCase(medicationsRepository);
  final getCommonMedications = GetCommonMedicationsUseCase(
    medicationsRepository,
  );
  // ─── Cubits ───────────────────────────────────────────────────────────────

  final authCubit = AuthCubit(
    repository: authRepository,
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    tokenStorage: tokenStorage,
  );

  final dashboardCubit = DashboardCubit(
    getDashboardStats,
    getTodayAppointments,
  );

  final settingsCubit = SettingsCubit(
    getProfile,
    updateProfile,
    getNotifications,
    logoutUseCase,
    tokenStorage,
    settingsRepository,
  );

  final patientsCubit = PatientsCubit(
    getPatients,
    addPatient,
    updatePatient,
    deletePatient,
  );

  final reportsCubit = ReportsCubit(
    getReports,
    addReport,
    updateReport,
    deleteReport,
  );

  final medicationsCubit = MedicationsCubit(
    getMedications,
    addMedication,
    updateMedication,
    deleteMedication,
    getCommonMedications,
  );

  // ✅ AppointmentsCubit يأخذ الـ repository مباشرة
  final appointmentsCubit = AppointmentsCubit(appointmentsRepository);

  // ─── Run App ──────────────────────────────────────────────────────────────
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: dashboardRepository),
        RepositoryProvider<SettingsRepository>.value(value: settingsRepository),
        RepositoryProvider.value(value: patientsRepository),
        RepositoryProvider.value(value: reportsRepository),
        RepositoryProvider.value(value: medicationsRepository),
        RepositoryProvider.value(value: appointmentsRepository),
        RepositoryProvider.value(value: tokenStorage),
        RepositoryProvider.value(value: apiClient),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authCubit),
          BlocProvider.value(value: dashboardCubit),
          BlocProvider.value(value: settingsCubit),
          BlocProvider.value(value: patientsCubit),
          BlocProvider.value(value: reportsCubit),
          BlocProvider.value(value: medicationsCubit),
          BlocProvider.value(value: appointmentsCubit),
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => LocaleCubit()),
        ],
        child: const MedixProApp(),
      ),
    ),
  );
}

class MedixProApp extends StatelessWidget {
  const MedixProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final locale = context.watch<LocaleCubit>().state;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "MedixPro",
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeMode,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashPage(),
          builder: (context, child) => ConnectivityWrapper(child: child!),
          routes: {
            "/login": (_) => const LoginPage(),
            "/register": (_) => const RoleSelectionPage(),
            "/dashboard": (_) => const DashboardPage(),
            "/settings": (_) => const SettingsPage(),
            "/profile": (_) => const ProfilePage(),
            "/notifications": (_) => const NotificationsPage(),
            "/reports": (_) => const ReportsPage(),
            "/patients": (_) => const PatientsListPage(),
            "/medications": (_) => const MedicationsPage(),
            "/appointments": (_) => const AppointmentsPage(),
          },
        );
      },
    );
  }
}
