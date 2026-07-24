import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/notification_service.dart';
import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthOtpVerifyRequested>(_onOtpVerifyRequested);
    on<AuthOtpResendRequested>(_onOtpResendRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  /// Called on app start — validates stored token via GET /auth/me
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _repository.getCurrentUser();

    if (result.isSuccess) {
      emit(AuthAuthenticated(result.data!));
      NotificationService().registerFcmToken(_repository);
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Step 1: POST /auth/login — direct login if verified, otherwise sends OTP and triggers verify-redirect
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _repository.login(
      email: event.email,
      password: event.password,
    );

    if (result.isSuccess) {
      final loginResponse = result.data!;
      if (loginResponse.isVerified) {
        emit(AuthAuthenticated(loginResponse.user!));
        NotificationService().registerFcmToken(_repository);
      } else {
        emit(AuthOtpSent(
          email: loginResponse.email!,
          message: 'Email not verified. OTP sent to your email. Please verify to complete login.',
        ));
      }
    } else {
      _emitFailure(emit, result.failure!);
    }
  }

  /// Step 2: POST /auth/verify-otp — verify OTP, receive token
  Future<void> _onOtpVerifyRequested(
    AuthOtpVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _repository.verifyOtp(
      email: event.email,
      otp: event.otp,
    );

    if (result.isSuccess) {
      emit(AuthAuthenticated(result.data!));
      NotificationService().registerFcmToken(_repository);
    } else {
      _emitFailure(emit, result.failure!);
    }
  }

  /// POST /auth/resend-otp
  Future<void> _onOtpResendRequested(
    AuthOtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _repository.resendOtp(email: event.email);

    if (result.isSuccess) {
      emit(AuthOtpResent(
        email: event.email,
        message: 'OTP resent to your email.',
      ));
    } else {
      _emitFailure(emit, result.failure!);
    }
  }

  /// POST /auth/register — patients only, requires OTP verification afterward
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _repository.register(
      name: event.name,
      email: event.email,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
      phone: event.phone,
    );

    if (result.isSuccess) {
      emit(AuthOtpSent(
        email: result.data!,
        message: 'Registration successful. OTP sent to your email.',
      ));
    } else {
      _emitFailure(emit, result.failure!);
    }
  }

  /// POST /auth/logout + clear local storage
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }

  void _emitFailure(Emitter<AuthState> emit, Failure failure) {
    if (failure is ValidationFailure) {
      emit(AuthValidationError(message: failure.message, errors: failure.errors));
    } else {
      emit(AuthError(failure.message));
    }
  }
}
