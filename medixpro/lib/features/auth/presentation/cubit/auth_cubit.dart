import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/errors/app_error_handler.dart';
import 'package:medixpro/core/notifications/notification_service.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../../../core/storage/token_storage.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthState {}
class AuthInitial      extends AuthState {}
class AuthLoading      extends AuthState {}
class AuthLoggedOut    extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository  _repository;
  final LoginUseCase    _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final TokenStorage    _tokenStorage;

  AuthCubit({
    required AuthRepository  repository,
    required LoginUseCase    loginUseCase,
    required RegisterUseCase registerUseCase,
    required TokenStorage    tokenStorage,
  })  : _repository     = repository,
        _loginUseCase    = loginUseCase,
        _registerUseCase = registerUseCase,
        _tokenStorage    = tokenStorage,
        super(AuthInitial());

  Future<void> autoLogin() async {
    emit(AuthLoading());
    try {
      final user = await _repository.autoLogin();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthLoggedOut());
      }
    } catch (_) {
      emit(AuthLoggedOut());
    }
  }

  Future<void> login({
    required String password,
    String? username,
    String? email,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _loginUseCase(
        LoginRequest(username: username, email: email, password: password),
      );
      NotificationService().notifyLogin(user.username);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(AppErrorHandler.handle(e, context: "login")));
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? doctorSecretKey,
    // Patient-only fields
    String? fullName,
    String? age,
    String? phone,
    String? gender,
    // Doctor-only field: consultation receipt (full visit price, SYP)
    String? receiptAmount,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _registerUseCase(
        LoginRequest(
          username:        username,
          email:           email,
          password:        password,
          role:            role,
          doctorSecretKey: doctorSecretKey,
          extra: {
            if (fullName != null && fullName.isNotEmpty) "full_name": fullName,
            if (age      != null && age.isNotEmpty)      "age":       age,
            if (phone    != null && phone.isNotEmpty)    "phone":     phone,
            if (gender   != null && gender.isNotEmpty)   "gender":    gender,
            if (receiptAmount != null && receiptAmount.isNotEmpty)
              "receipt_amount": receiptAmount,
          },
        ),
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(AppErrorHandler.handle(e, context: "register")));
    }
  }

  Future<void> logout() async {
    try {
      final refresh = await _tokenStorage.getRefreshToken();
      await _repository.logout(refresh ?? "");
    } catch (_) {
      await _tokenStorage.clear();
    }
    NotificationService().notifyLogout();
    emit(AuthLoggedOut());
  }
  Future<bool> verifyDoctorKey(String code) async {
  try {
    await _repository.verifyDoctorKey(code);
    return true;
  } catch (_) {
    return false;
  }
}
}