import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetProfileUseCase       getProfileUseCase;
  final UpdateProfileUseCase    updateProfileUseCase;
  final GetNotificationsUseCase getNotificationsUseCase;
  final LogoutUseCase           logoutUseCase;
  final TokenStorage            tokenStorage;
  final SettingsRepository      _repository;

  SettingsCubit(
    this.getProfileUseCase,
    this.updateProfileUseCase,
    this.getNotificationsUseCase,
    this.logoutUseCase,
    this.tokenStorage,
    this._repository,
  ) : super(SettingsInitial());

  Future<void> loadProfile() async {
    emit(SettingsLoading());
    try {
      final profile = await getProfileUseCase();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(SettingsError("Failed to load profile"));
    }
  }

  Future<void> loadNotifications() async {
    emit(SettingsLoading());
    try {
      final result = await getNotificationsUseCase();
      final List<NotificationItem> list =
          result["notifications"] as List<NotificationItem>;
      final int unread = result["unread_count"] as int;
      emit(NotificationsLoaded(list, unread));
    } catch (e) {
      emit(SettingsError("Failed to load notifications"));
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      await loadNotifications();
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await loadNotifications();
    } catch (_) {}
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _repository.deleteNotification(id);
      await loadNotifications();
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      await _repository.clearAllNotifications();
      await loadNotifications();
    } catch (_) {}
  }

  Future<void> logout() async {
    emit(SettingsLoading());
    try {
      final refresh = await tokenStorage.getRefreshToken();
      if (refresh != null) await logoutUseCase(refresh);
      await tokenStorage.clear();
      emit(SettingsLoggedOut());
    } catch (_) {
      await tokenStorage.clear();
      emit(SettingsLoggedOut());
    }
  }
}