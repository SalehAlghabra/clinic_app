import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired on app start — checks stored token via GET /auth/me
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Patient/Doctor/Admin login — Step 1: credentials → OTP email
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Login — Step 2: submit OTP to receive token
class AuthOtpVerifyRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthOtpVerifyRequested({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

/// Resend OTP to the pending email
class AuthOtpResendRequested extends AuthEvent {
  final String email;

  const AuthOtpResendRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Register a new patient account
class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String? phone;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.phone,
  });

  @override
  List<Object?> get props => [name, email, password, passwordConfirmation, phone];
}

/// Log out the current user
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
