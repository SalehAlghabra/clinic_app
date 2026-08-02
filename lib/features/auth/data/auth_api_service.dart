import 'package:dio/dio.dart' as dio;
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

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

  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    final response = await _apiClient.post(
      ApiEndpoints.resendOtp,
      data: {'email': email},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> verifyResetOtp(String email, String otp) async {
    await _apiClient.post(
      ApiEndpoints.verifyResetOtp,
      data: {'email': email, 'otp': otp},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? currentPassword,
    String? password,
    String? profilePictureUrl,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final map = <String, dynamic>{};
    if (name != null && name.isNotEmpty) map['name'] = name;
    if (phone != null) map['phone'] = phone;
    if (password != null && password.isNotEmpty) {
      map['password'] = password;
      map['password_confirmation'] = password;
      if (currentPassword != null) map['current_password'] = currentPassword;
    }
    if (fileBytes != null && fileName != null) {
      map['profile_picture'] = dio.MultipartFile.fromBytes(fileBytes, filename: fileName);
    } else if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      map['profile_picture'] = profilePictureUrl;
    }

    final formData = dio.FormData.fromMap(map);

    final response = await _apiClient.post(
      ApiEndpoints.updateProfile,
      data: formData,
    );

    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateFcmToken(String fcmToken) async {
    await _apiClient.post(
      ApiEndpoints.fcmToken,
      data: {'fcm_token': fcmToken},
    );
  }
}
