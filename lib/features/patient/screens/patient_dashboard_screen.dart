import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../wallet/bloc/wallet_bloc.dart';
import '../../wallet/bloc/wallet_event.dart';
import '../../wallet/bloc/wallet_state.dart';

import '../../../shared/widgets/app_top_actions.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    context.read<WalletBloc>().add(const FetchWalletDataEvent());
  }



  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    // Get user name from AuthBloc
    final authState = context.read<AuthBloc>().state;
    final userName = authState is AuthAuthenticated ? authState.user.name : 'Patient';

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
        actions: const [
          AppTopActions(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                Text(
                  'Welcome, $userName!',
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

                // Real-time Wallet Card
                BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, state) {
                    if (state is WalletLoading) {
                      return SizedBox(
                        height: 160,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(AppDimensions.paddingM),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const AppLoadingIndicator(),
                          ),
                        ),
                      );
                    }

                    double balance = 0.0;
                    int violations = 0;

                    if (state is WalletLoadSuccess) {
                      balance = state.balance.walletBalance;
                      violations = state.balance.violationCount;
                    }

                    return AppCard(
                      onTap: () => context.push('/patient/wallet'),
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
                                  color: Colors.white.withValues(alpha: 0.85),
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
                            '${balance.toStringAsFixed(2)} SP',
                            style: context.textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$violations Violations',
                                  style: context.textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                'Tap to view statement',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOut);
                  },
                ),

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
                      onTap: () => context.push('/patient/records'),
                    ),
                    _buildGridItem(
                      context,
                      icon: Icons.receipt_long_outlined,
                      title: l10n.invoicesTitle,
                      color: colors.warning,
                      onTap: () => context.push('/patient/invoices'),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              ],
            ),
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
              color: color.withValues(alpha: 0.12),
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
