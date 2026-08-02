import '../../../core/api/api_exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/storage_service.dart';
import '../data/auth_api_service.dart';
import '../models/user_model.dart';

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

class AuthLoginResponse {
  final UserModel? user;
  final String? email;
  final bool isVerified;

  const AuthLoginResponse({
    this.user,
    this.email,
    required this.isVerified,
  });
}

class AuthRepository {
  final AuthApiService _apiService;
  final StorageService _storageService;

  AuthRepository({
    required AuthApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  Future<AuthResult<String>> register({
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
      return AuthResult.success(data['email'] as String);
    } on ValidationException catch (e) {
      return AuthResult.failure(ValidationFailure(e.message, e.errors));
    } on ApiException catch (e) {
      return AuthResult.failure(ServerFailure(e.message));
    } catch (e) {
      return AuthResult.failure(const NetworkFailure());
    }
  }

  Future<AuthResult<AuthLoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _apiService.login(email: email, password: password);
      final isVerified = data['verified'] as bool? ?? false;

      if (isVerified) {
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        final token = data['token'] as String;

        await _storageService.saveToken(token);
        await _storageService.saveRole(user.role);

        return AuthResult.success(AuthLoginResponse(
          user: user,
          isVerified: true,
        ));
      } else {
        return AuthResult.success(AuthLoginResponse(
          email: data['email'] as String,
          isVerified: false,
        ));
      }
    } on ValidationException catch (e) {
      return AuthResult.failure(ValidationFailure(e.message, e.errors));
    } on ApiException catch (e) {
      return AuthResult.failure(ServerFailure(e.message));
    } catch (e) {
      return AuthResult.failure(const NetworkFailure());
    }
  }

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

  Future<AuthResult<void>> forgotPassword(String email) async {
    try {
      await _apiService.forgotPassword(email);
      return const AuthResult.success(null);
    } on ApiException catch (e) {
      return AuthResult.failure(ServerFailure(e.message));
    } catch (_) {
      return const AuthResult.failure(NetworkFailure());
    }
  }

  Future<AuthResult<void>> verifyResetOtp(String email, String otp) async {
    try {
      await _apiService.verifyResetOtp(email, otp);
      return const AuthResult.success(null);
    } on ApiException catch (e) {
      return AuthResult.failure(ServerFailure(e.message));
    } catch (_) {
      return const AuthResult.failure(NetworkFailure());
    }
  }

  Future<AuthResult<void>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _apiService.resetPassword(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const AuthResult.success(null);
    } on ApiException catch (e) {
      return AuthResult.failure(ServerFailure(e.message));
    } catch (_) {
      return const AuthResult.failure(NetworkFailure());
    }
  }

  Future<AuthResult<UserModel>> updateProfile({
    String? name,
    String? phone,
    String? currentPassword,
    String? password,
    String? profilePictureUrl,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    try {
      final data = await _apiService.updateProfile(
        name: name,
        phone: phone,
        currentPassword: currentPassword,
        password: password,
        profilePictureUrl: profilePictureUrl,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      return AuthResult.success(user);
    } on ApiException catch (e) {
      return AuthResult.failure(ServerFailure(e.message));
    } catch (e) {
      return AuthResult.failure(ServerFailure(e.toString()));
    }
  }

  Future<AuthResult<void>> logout() async {
    try {
      await _apiService.logout();
    } catch (_) {}
    await _storageService.clearAuthData();
    return const AuthResult.success(null);
  }

  Future<AuthResult<UserModel>> getCurrentUser() async {
    try {
      final data = await _apiService.me();
      final user = UserModel.fromJson(data);
      await _storageService.saveRole(user.role);
      return AuthResult.success(user);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _storageService.clearAuthData();
      }
      return AuthResult.failure(AuthFailure(e.message));
    } catch (e) {
      return AuthResult.failure(const NetworkFailure());
    }
  }

  Future<AuthResult<void>> updateFcmToken(String fcmToken) async {
    try {
      await _apiService.updateFcmToken(fcmToken);
      return const AuthResult.success(null);
    } catch (_) {
      return const AuthResult.failure(ServerFailure('Failed to update FCM token'));
    }
  }
}
