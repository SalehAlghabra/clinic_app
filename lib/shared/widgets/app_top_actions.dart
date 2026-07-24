import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/extensions/context_extensions.dart';
import '../../features/settings/bloc/locale_cubit.dart';
import '../../features/settings/bloc/theme_cubit.dart';
import '../../features/settings/bloc/theme_state.dart';

class AppTopActions extends StatelessWidget {
  const AppTopActions({super.key});

  static const List<Map<String, dynamic>> _themeColors = [
    {'name': 'Ocean Blue', 'color': Color(0xFF0077B6)},
    {'name': 'Teal Green', 'color': Color(0xFF0D9488)},
    {'name': 'Rose Pink', 'color': Color(0xFFE11D48)},
    {'name': 'Indigo Blue', 'color': Color(0xFF4F46E5)},
    {'name': 'Warm Amber', 'color': Color(0xFFD97706)},
  ];

  void _showColorPicker(BuildContext context) {
    final colors = context.appColors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            final activeColor = themeState.primaryColor ?? const Color(0xFF0077B6);

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Localizations.localeOf(context).languageCode == 'ar'
                            ? 'اختر لون التطبيق الرئيسية'
                            : 'Select Primary Accent Color',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(modalContext),
                        icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _themeColors.map((item) {
                      final color = item['color'] as Color;
                      final isSelected = activeColor == color;

                      return GestureDetector(
                        onTap: () {
                          context.read<ThemeCubit>().setPrimaryColor(color);
                          Navigator.pop(modalContext);
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? colors.text : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary Theme Color Selector
        IconButton(
          onPressed: () => _showColorPicker(context),
          icon: Icon(Icons.palette_outlined, color: colors.primary, size: 22),
          tooltip: 'Theme Color',
        ),

        // Dark / Light Theme Toggle
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            final isDark = state.themeMode == ThemeMode.dark;
            return IconButton(
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                color: isDark ? Colors.amber : colors.textSecondary,
                size: 22,
              ),
              tooltip: 'Toggle Theme',
            );
          },
        ),

        // Language Switcher Toggle
        InkWell(
          onTap: () => context.read<LocaleCubit>().toggleLocale(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language_rounded, color: colors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  Localizations.localeOf(context).languageCode == 'ar' ? 'EN' : 'عربي',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
