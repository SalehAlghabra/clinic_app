import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  /// POST /api/auth/register
  /// Body: { name, email, password, password_confirmation, phone? }
  /// Returns: { message, user, token }
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/auth/login
  /// Body: { email, password }
  /// Returns: { message, email } — sends OTP, no token yet
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/auth/verify-otp
  /// Body: { email, otp }
  /// Returns: { message, user, token }
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {
        'email': email,
        'otp': otp,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/auth/resend-otp
  /// Body: { email }
  /// Returns: { message, email }
  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    final response = await _apiClient.post(
      ApiEndpoints.resendOtp,
      data: {'email': email},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/auth/logout   [Protected]
  /// Returns: { message }
  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }

  /// GET /api/auth/me   [Protected]
  /// Returns: User object
  Future<Map<String, dynamic>> me() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/auth/fcm-token   [Protected]
  /// Body: { fcm_token }
  Future<void> updateFcmToken(String fcmToken) async {
    await _apiClient.post(
      ApiEndpoints.fcmToken,
      data: {'fcm_token': fcmToken},
    );
  }
}
