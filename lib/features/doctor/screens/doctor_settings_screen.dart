import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/dialogs/app_dialogs.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../settings/bloc/theme_cubit.dart';
import '../../settings/bloc/theme_state.dart';
import '../../settings/bloc/locale_cubit.dart';

class DoctorSettingsScreen extends StatelessWidget {
  const DoctorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          final doctorName = state is AuthAuthenticated ? state.user.name : 'Doctor';
          final doctorEmail = state is AuthAuthenticated ? state.user.email : 'doctor@clinic.com';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Profile Header card
                AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.medical_services_rounded, color: colors.primary, size: 32),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctorEmail,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),

                // Settings Options
                Text(
                  l10n.settingsTitle,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),

                // Dark mode toggle
                AppCard(
                  child: BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, themeState) {
                      final isDark = themeState.themeMode == ThemeMode.dark;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.dark_mode_outlined, color: colors.text),
                              const SizedBox(width: 12),
                              Text(
                                l10n.darkMode,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.text,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isDark,
                            onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                            activeThumbColor: colors.primary,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),

                // Language toggle
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.language_rounded, color: colors.text),
                          const SizedBox(width: 12),
                          Text(
                            l10n.language,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.text,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.read<LocaleCubit>().toggleLocale(),
                        child: Text(
                          context.read<LocaleCubit>().isArabic ? 'English' : 'العربية',
                          style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),

                // Logout button
                AppButton(
                  text: l10n.logout,
                  isOutline: true,
                  onPressed: () async {
                    final ok = await AppDialogs.showConfirmation(
                      context: context,
                      title: l10n.logoutConfirmTitle,
                      message: l10n.logoutConfirmMessage,
                    );
                    if (ok == true && context.mounted) {
                      context.read<AuthBloc>().add(const AuthLogoutRequested());
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
