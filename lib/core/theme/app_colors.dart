import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color border;
  final Color error;
  final Color success;
  final Color warning;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.border,
    required this.error,
    required this.success,
    required this.warning,
  });

  factory AppColors.light([Color? customPrimary]) {
    final primaryColor = customPrimary ?? const Color(0xFF0077B6);
    return AppColors(
      primary: primaryColor,
      secondary: primaryColor.withValues(alpha: 0.8),
      background: const Color(0xFFF8FAFC),
      surface: const Color(0xFFFFFFFF),
      text: const Color(0xFF1E293B),
      textSecondary: const Color(0xFF64748B),
      border: const Color(0xFFE2E8F0),
      error: const Color(0xFFEF4444),
      success: const Color(0xFF10B981),
      warning: const Color(0xFFF59E0B),
    );
  }

  factory AppColors.dark([Color? customPrimary]) {
    final primaryColor = customPrimary ?? const Color(0xFF38BDF8);
    return AppColors(
      primary: primaryColor,
      secondary: primaryColor.withValues(alpha: 0.8),
      background: const Color(0xFF0F172A),
      surface: const Color(0xFF1E293B),
      text: const Color(0xFFF1F5F9),
      textSecondary: const Color(0xFF94A3B8),
      border: const Color(0xFF334155),
      error: const Color(0xFFF87171),
      success: const Color(0xFF34D399),
      warning: const Color(0xFFFBBF24),
    );
  }

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? text,
    Color? textSecondary,
    Color? border,
    Color? error,
    Color? success,
    Color? warning,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
