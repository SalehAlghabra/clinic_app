import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/storage_service.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  final StorageService _storageService;

  static const String _localeKey = 'app_locale';

  LocaleCubit(this._storageService) : super(const LocaleState(Locale('en'))) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final stored = await _storageService.read(_localeKey);
    if (stored != null) {
      emit(LocaleState(Locale(stored)));
    }
  }

  Future<void> setLocale(Locale locale) async {
    emit(LocaleState(locale));
    await _storageService.write(_localeKey, locale.languageCode);
  }

  Future<void> toggleLocale() async {
    final isArabic = state.locale.languageCode == 'ar';
    await setLocale(isArabic ? const Locale('en') : const Locale('ar'));
  }

  bool get isArabic => state.locale.languageCode == 'ar';
}
