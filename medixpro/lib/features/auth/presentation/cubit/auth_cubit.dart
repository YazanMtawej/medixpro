import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/features/auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

/// ================= STATES =================

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthLoggedOut extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

/// ================= CUBIT =================

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthCubit(
    this.repository, {
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(AuthInitial());

  /// 🔥 المصدر الوحيد لتحديد المسار
  Future<void> autoLogin() async {
    try {
      final isLoggedIn = await repository.isLoggedIn();

      if (isLoggedIn) {
        emit(AuthAuthenticated(
          User(username: "cached", email: "cached"),
        ));
      } else {
        emit(AuthLoggedOut());
      }
    } catch (_) {
      emit(AuthLoggedOut());
    }
  }

  Future<void> login(
    String username,
    String email,
    String password,
  ) async {
    emit(AuthLoading());

    try {
      final user = await loginUseCase(
        LoginRequest(
          username: username,
          email: email,
          password: password,
        ),
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(
    String username,
    String email,
    String password,
  ) async {
    emit(AuthLoading());

    try {
      final user = await registerUseCase(
        LoginRequest(
          username: username,
          email: email,
          password: password,
        ),
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await repository.logout();
    emit(AuthLoggedOut());
  }
}