import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class StorageService {
  final FlutterSecureStorage _storage;

  StorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Convenience helper methods
  Future<void> saveToken(String token) async {
    await write(StorageKeys.token, token);
  }

  Future<String?> getToken() async {
    return await read(StorageKeys.token);
  }

  Future<void> saveRole(String role) async {
    await write(StorageKeys.role, role);
  }

  Future<String?> getRole() async {
    return await read(StorageKeys.role);
  }

  Future<void> saveThemeMode(String themeMode) async {
    await write(StorageKeys.themeMode, themeMode);
  }

  Future<String?> getThemeMode() async {
    return await read(StorageKeys.themeMode);
  }

  Future<void> savePrimaryColor(String colorHex) async {
    await write(StorageKeys.primaryColor, colorHex);
  }

  Future<String?> getPrimaryColor() async {
    return await read(StorageKeys.primaryColor);
  }

  Future<void> clearAuthData() async {
    await delete(StorageKeys.token);
    await delete(StorageKeys.role);
  }
}
