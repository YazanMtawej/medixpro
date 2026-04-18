import 'package:medixpro/features/auth/domain/entities/user.dart';

class RoleGuard {
  final User user;
  const RoleGuard(this.user);

  bool get isDoctor  => user.isDoctor;
  bool get isPatient => user.isPatient;

  bool canAdd()    => isDoctor;
  bool canEdit()   => isDoctor;
  bool canDelete() => isDoctor;
  bool canViewAllPatients() => isDoctor;
  bool canViewAllReports()  => isDoctor;
  bool canManageAppointments() => isDoctor;
  bool canSendRequest()   => isPatient;
  bool canAcceptRequest() => isDoctor;
}