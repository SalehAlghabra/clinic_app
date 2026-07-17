import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';

class PatientMainScreen extends StatelessWidget {
  final Widget child;

  const PatientMainScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/patient/doctors')) return 1;
    if (location.startsWith('/patient/appointments')) return 2;
    if (location.startsWith('/patient/wallet')) return 3;
    if (location.startsWith('/patient/settings')) return 4;
    return 0; // default is dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/patient/dashboard');
        break;
      case 1:
        context.go('/patient/doctors');
        break;
      case 2:
        context.go('/patient/appointments');
        break;
      case 3:
        context.go('/patient/wallet');
        break;
      case 4:
        context.go('/patient/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard_rounded),
            label: l10n.patientDashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_outlined),
            activeIcon: const Icon(Icons.search_rounded),
            label: l10n.doctorsTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today_rounded),
            label: l10n.appointmentsTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            activeIcon: const Icon(Icons.account_balance_wallet_rounded),
            label: l10n.walletTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            activeIcon: const Icon(Icons.person_rounded),
            label: l10n.profileTitle,
          ),
        ],
      ),
    );
  }
}
