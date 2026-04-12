import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ================= CORE =================
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

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

// ================= APPOINTMENTS =================
import 'features/appointments/data/datasources/appointments_remote_datasource.dart';
import 'features/appointments/data/repositories_impl/appointments_repository_impl.dart';
import 'features/appointments/domain/usecases/get_appointments_usecase.dart';
import 'features/appointments/domain/usecases/add_appointment_usecase.dart';
import 'features/appointments/domain/usecases/update_appointment_usecase.dart';
import 'features/appointments/presentation/cubit/appointments_cubit.dart';
import 'features/appointments/presentation/pages/appointments_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ================= CORE =================
  const secureStorage = FlutterSecureStorage();
  final tokenStorage = TokenStorage(secureStorage);
  final apiClient = ApiClient(tokenStorage);

  // ================= DATA SOURCES =================
  final authRemote = AuthRemoteDataSource(apiClient);
  final dashboardRemote = DashboardRemoteDataSource(apiClient);
  final settingsRemote = SettingsRemoteDataSource(apiClient);
  final patientsRemote = PatientsRemoteDataSource(apiClient);
  final reportsRemote = ReportsRemoteDataSource(apiClient);
  final medicationsRemote = MedicationsRemoteDataSource(apiClient);
  final appointmentsRemote = AppointmentsRemoteDataSource(apiClient);

  // ================= REPOSITORIES =================
  final authRepository = AuthRepositoryImpl(authRemote, tokenStorage);
  final dashboardRepository = DashboardRepositoryImpl(dashboardRemote);
  final settingsRepository = SettingsRepositoryImpl(settingsRemote);
  final patientsRepository = PatientsRepositoryImpl(patientsRemote);
  final reportsRepository = ReportsRepositoryImpl(reportsRemote);
  final medicationsRepository = MedicationsRepositoryImpl(medicationsRemote);
  final appointmentsRepository = AppointmentsRepositoryImpl(appointmentsRemote);

  // ================= USE CASES =================

  // Auth
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);

  // Dashboard
  final getDashboardStatsUseCase = GetDashboardStatsUseCase(dashboardRepository);
  final getTodayAppointmentsUseCase = GetTodayAppointmentsUseCase(dashboardRepository);

  // Settings
  final getProfileUseCase = GetProfileUseCase(settingsRepository);
  final updateProfileUseCase = UpdateProfileUseCase(settingsRepository);
  final getNotificationsUseCase = GetNotificationsUseCase(settingsRepository);
  final logoutUseCase = LogoutUseCase(settingsRepository);

  // Patients
  final getPatientsUseCase = GetPatientsUseCase(patientsRepository);
  final addPatientUseCase = AddPatientUseCase(patientsRepository);
  final updatePatientUseCase = UpdatePatientUseCase(patientsRepository);
  final deletePatientUseCase = DeletePatientUseCase(patientsRepository);

  // Reports
  final getReportsUseCase = GetReportsUseCase(reportsRepository);
  final addReportUseCase = AddReportUseCase(reportsRepository);

  // Medications
  final getMedicationsUseCase = GetMedicationsUseCase(medicationsRepository);
  final addMedicationUseCase = AddMedicationUseCase(medicationsRepository);
  final updateMedicationUseCase = UpdateMedicationUseCase(medicationsRepository);
  final deleteMedicationUseCase = DeleteMedicationUseCase(medicationsRepository);

  // Appointments
  final getAppointmentsUseCase = GetAppointmentsUseCase(appointmentsRepository);
  final addAppointmentUseCase = AddAppointmentUseCase(appointmentsRepository);
  final updateAppointmentUseCase = UpdateAppointmentUseCase(appointmentsRepository);

  // ================= CUBITS =================
  final authCubit = AuthCubit(
    repository: authRepository,
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    tokenStorage: tokenStorage,
  );

  final dashboardCubit = DashboardCubit(
    getDashboardStatsUseCase,
    getTodayAppointmentsUseCase,
  );

  final settingsCubit = SettingsCubit(
    getProfileUseCase,
    updateProfileUseCase,
    getNotificationsUseCase,
    logoutUseCase,
    tokenStorage,
  );

  final patientsCubit = PatientsCubit(
    getPatientsUseCase,
    addPatientUseCase,
    updatePatientUseCase,
    deletePatientUseCase,
  );

  final reportsCubit = ReportsCubit(
    getReportsUseCase,
    addReportUseCase,
  );

  final medicationsCubit = MedicationsCubit(
    getMedicationsUseCase,
    addMedicationUseCase,
    updateMedicationUseCase,
    deleteMedicationUseCase,
  );

  final appointmentsCubit = AppointmentsCubit(
    getAppointmentsUseCase,
    addAppointmentUseCase,
    updateAppointmentUseCase,
  );

  // ================= RUN APP =================
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: dashboardRepository),
        RepositoryProvider.value(value: settingsRepository),
        RepositoryProvider.value(value: patientsRepository),
        RepositoryProvider.value(value: reportsRepository),
        RepositoryProvider.value(value: medicationsRepository),
        RepositoryProvider.value(value: appointmentsRepository),
        RepositoryProvider.value(value: tokenStorage),
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
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "MedixPro",
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeMode,
          home: const SplashPage(),
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