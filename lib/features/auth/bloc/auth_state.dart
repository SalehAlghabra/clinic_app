import 'package:equatable/equatable.dart';
import '../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — app just started, nothing determined yet
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Any async operation in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Token is valid — user is authenticated
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// No valid token — must go to login
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Login step 1 succeeded — OTP sent to email
class AuthOtpSent extends AuthState {
  final String email;
  final String message;

  const AuthOtpSent({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

/// OTP resent successfully
class AuthOtpResent extends AuthState {
  final String email;
  final String message;

  const AuthOtpResent({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

/// Any operation that produces an error message
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Validation errors (field-level, from Laravel 422)
class AuthValidationError extends AuthState {
  final String message;
  final Map<String, dynamic> errors;

  const AuthValidationError({required this.message, required this.errors});

  @override
  List<Object?> get props => [message, errors];
}
