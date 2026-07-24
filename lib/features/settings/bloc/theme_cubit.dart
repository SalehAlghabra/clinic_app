import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/storage_service.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final StorageService _storageService;

  ThemeCubit(this._storageService)
      : super(const ThemeState(themeMode: ThemeMode.light)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeName = await _storageService.getThemeMode();
    final primaryHex = await _storageService.getPrimaryColor();

    ThemeMode mode = ThemeMode.light;
    if (themeName != null) {
      if (themeName == 'dark') {
        mode = ThemeMode.dark;
      } else if (themeName == 'system') {
        mode = ThemeMode.system;
      }
    }

    Color? primaryColor;
    if (primaryHex != null && primaryHex.isNotEmpty) {
      try {
        final val = int.parse(primaryHex, radix: 16);
        primaryColor = Color(val);
      } catch (_) {}
    }

    emit(ThemeState(themeMode: mode, primaryColor: primaryColor));
  }

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(state.copyWith(themeMode: newMode));
    await _storageService.saveThemeMode(newMode.name);
  }

  Future<void> setPrimaryColor(Color color) async {
    emit(state.copyWith(primaryColor: color));
    final hexString = color.toARGB32().toRadixString(16);
    await _storageService.savePrimaryColor(hexString);
  }
}
