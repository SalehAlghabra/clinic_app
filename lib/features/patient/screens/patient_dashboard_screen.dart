import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/app_button.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
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
              const Icon(Icons.person_pin_rounded, size: 80, color: Color(0xFF0077B6)),
              const SizedBox(height: 16),
              const Text(
                'Welcome, Patient!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Your patient area is configured and ready.'),
              const SizedBox(height: 32),
              AppButton(
                text: 'Book an Appointment',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
