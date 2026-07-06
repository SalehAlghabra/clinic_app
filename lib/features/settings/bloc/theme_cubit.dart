import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/storage_service.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final StorageService _storageService;

  ThemeCubit(this._storageService) : super(const ThemeState(ThemeMode.light)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeName = await _storageService.getThemeMode();
    if (themeName != null) {
      if (themeName == 'dark') {
        emit(const ThemeState(ThemeMode.dark));
      } else if (themeName == 'light') {
        emit(const ThemeState(ThemeMode.light));
      } else {
        emit(const ThemeState(ThemeMode.system));
      }
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(ThemeState(newMode));
    await _storageService.saveThemeMode(newMode.name);
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    emit(ThemeState(themeMode));
    await _storageService.saveThemeMode(themeMode.name);
  }
}
