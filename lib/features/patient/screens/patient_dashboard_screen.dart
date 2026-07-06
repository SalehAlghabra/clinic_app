import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_card.dart';
import '../../settings/bloc/locale_cubit.dart';
import '../../settings/bloc/theme_cubit.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final storage = StorageService();
    await storage.clearAuthData();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final isArabic = context.read<LocaleCubit>().isArabic;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.patientDashboard,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          // Theme switch
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: colors.text,
            ),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
          // Language toggle
          TextButton(
            onPressed: () => context.read<LocaleCubit>().toggleLocale(),
            child: Text(
              isArabic ? 'English' : 'العربية',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Logout
          IconButton(
            icon: Icon(Icons.logout_rounded, color: colors.error),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Text(
                '${l10n.loginTitle.split(' ').first}, Patient!',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

              const SizedBox(height: 4),

              Text(
                l10n.splashTagline,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

              const SizedBox(height: AppDimensions.paddingL),

              // Wallet Card (Visual wow card)
              AppCard(
                color: colors.primary,
                borderSide: BorderSide.none,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.walletBalance,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '500.00 SP', // Static sample wallet balance
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '0 Violations', // Static violation sample
                        style: context.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOut),

              const SizedBox(height: AppDimensions.paddingL),

              // Actions Header
              Text(
                'Quick Actions',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Actions grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.25,
                children: [
                  _buildGridItem(
                    context,
                    icon: Icons.person_search_outlined,
                    title: l10n.doctorsTitle,
                    color: colors.secondary,
                    onTap: () => context.go('/patient/doctors'),
                  ),
                  _buildGridItem(
                    context,
                    icon: Icons.calendar_month_outlined,
                    title: l10n.bookAppointment,
                    color: colors.primary,
                    onTap: () => context.go('/patient/doctors'),
                  ),
                  _buildGridItem(
                    context,
                    icon: Icons.medical_information_outlined,
                    title: l10n.medicalRecordsTitle,
                    color: colors.success,
                    onTap: () {},
                  ),
                  _buildGridItem(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: l10n.invoicesTitle,
                    color: colors.warning,
                    onTap: () {},
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;

    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: colors.text,
            ),
          ),
        ],
      ),
    );
  }
}
