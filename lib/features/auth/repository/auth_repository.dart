import '../../../core/api/api_exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/storage_service.dart';
import '../data/auth_api_service.dart';
import '../models/user_model.dart';

/// Result type to avoid Either/Result dependencies — simple sealed approach.
class AuthResult<T> {
  final T? data;
  final Failure? failure;

  const AuthResult.success(T value)
      : data = value,
        failure = null;

  const AuthResult.failure(Failure f)
      : data = null,
        failure = f;

  bool get isSuccess => failure == null;
}

class AuthRepository {
  final AuthApiService _apiService;
  final StorageService _storageService;

  AuthRepository({
    required AuthApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  /// Register a new patient account.
  /// Returns the created [UserModel] and saves the token + role locally.
  Future<AuthResult<UserModel>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      final data = await _apiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
      );

      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      await _storageService.saveToken(token);
      await _storageService.saveRole(user.role);

      return AuthResult.success(user);
    } on ValidationException catch (e) {
      return AuthResult.failure(ValidationFailure(e.message, e.errors));
    } on ApiException catch (e) {
      return AuthResult.failure(ServerFailure(e.message));
    } catch (e) {
      return AuthResult.failure(const NetworkFailure());
    }
  }

  /// Step 1 of login: send credentials, backend sends OTP email.
  /// Returns the email on success (to pass to OTP screen).
  Future<AuthResult<String>> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _apiService.login(email: email, password: password);
      // Backend returns: { message, email }
      return AuthResult.success(data['email'] as String);
    } on ValidationException catch (e) {
      return AuthResult.failure(ValidationFailure(e.message, e.errors));
    } on ApiException catch (e) {
      return AuthResult.failure(ServerFailure(e.message));
    } catch (e) {
      return AuthResult.failure(const NetworkFailure());
    }
  }

  /// Step 2 of login: verify OTP and receive the auth token.
  /// Saves token + role locally on success.
  Future<AuthResult<UserModel>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final data = await _apiService.verifyOtp(email: email, otp: otp);

      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      await _storageService.saveToken(token);
      await _storageService.saveRole(user.role);

      return AuthResult.success(user);
    } on ApiException catch (e) {
      return AuthResult.failure(ServerFailure(e.message));
    } catch (e) {
      return AuthResult.failure(const NetworkFailure());
    }
  }

  /// Resend OTP to the given email.
  Future<AuthResult<String>> resendOtp({required String email}) async {
    try {
      final data = await _apiService.resendOtp(email: email);
      return AuthResult.success(data['message'] as String);
    } on ApiException catch (e) {
      return AuthResult.failure(ServerFailure(e.message));
    } catch (e) {
      return AuthResult.failure(const NetworkFailure());
    }
  }

  /// Logout — revoke Sanctum token on backend, clear local storage.
  Future<AuthResult<void>> logout() async {
    try {
      await _apiService.logout();
    } catch (_) {
      // Even if the request fails, we still clear local storage
    }
    await _storageService.clearAuthData();
    return const AuthResult.success(null);
  }

  /// Validate stored token by calling GET /auth/me.
  /// Returns [UserModel] if token is still valid, failure otherwise.
  Future<AuthResult<UserModel>> getCurrentUser() async {
    try {
      final data = await _apiService.me();
      final user = UserModel.fromJson(data);
      // Refresh role in storage in case it changed
      await _storageService.saveRole(user.role);
      return AuthResult.success(user);
    } on ApiException catch (e) {
      // 401 means token is stale — clear storage
      if (e.statusCode == 401) {
        await _storageService.clearAuthData();
      }
      return AuthResult.failure(AuthFailure(e.message));
    } catch (e) {
      return AuthResult.failure(const NetworkFailure());
    }
  }
}
