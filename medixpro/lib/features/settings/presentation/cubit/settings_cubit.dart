// ===========================
// SettingsCubit (Logout ثابت وصحيح)
// ===========================
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetProfileUseCase getProfile;
  final UpdateProfileUseCase updateProfile;
  final GetNotificationsUseCase getNotifications;
  final LogoutUseCase logoutUseCase;
  final TokenStorage tokenStorage;

  SettingsCubit(
    this.getProfile,
    this.updateProfile,
    this.getNotifications,
    this.logoutUseCase,
    this.tokenStorage,
  ) : super(SettingsInitial());

  Future<void> loadProfile() async {
    emit(SettingsLoading());
    try {
      final profile = await getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> loadNotifications() async {
    emit(SettingsLoading());
    try {
      final data = await getNotifications();
      emit(NotificationsLoaded(data));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
Future<void> logout() async {
  emit(SettingsLoading());
  try {
    final refresh = await tokenStorage.getRefreshToken();
    if (refresh != null) {
      await logoutUseCase(refresh); // تمرير التوكن
    }
    await tokenStorage.clear(); // مسح كل التوكن
    emit(SettingsLoggedOut()); // ✅ هذه الحالة يجب أن يلتقطها BlocListener
  } catch (e) {
    emit(SettingsError(e.toString()));
  }
}
}