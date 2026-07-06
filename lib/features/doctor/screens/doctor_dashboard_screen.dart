import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/app_button.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final storage = StorageService();
              await storage.clearAuthData();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.medical_services_rounded, size: 80, color: Color(0xFF0077B6)),
              const SizedBox(height: 16),
              const Text(
                'Welcome, Doctor!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Your doctor area is configured and ready.'),
              const SizedBox(height: 32),
              AppButton(
                text: 'Manage Appointments',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
