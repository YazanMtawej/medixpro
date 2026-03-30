import '../../domain/entities/user_profile.dart';
import '../../domain/entities/notification_item.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class ProfileLoaded extends SettingsState {

  final UserProfile profile;

  ProfileLoaded(this.profile);
}

class NotificationsLoaded extends SettingsState {

  final List<NotificationItem> notifications;

  NotificationsLoaded(this.notifications);
}

class SettingsError extends SettingsState {

  final String message;

  SettingsError(this.message);
}
class SettingsLoggedOut extends SettingsState {}