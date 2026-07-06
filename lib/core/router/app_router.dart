import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/data/auth_api_service.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/doctor/screens/doctor_dashboard_screen.dart';
import '../../features/patient/bloc/doctor_detail_bloc.dart';
import '../../features/patient/bloc/doctor_list_bloc.dart';
import '../../features/patient/data/patient_api_service.dart';
import '../../features/patient/repository/patient_repository.dart';
import '../../features/patient/screens/doctor_detail_screen.dart';
import '../../features/patient/screens/doctor_list_screen.dart';
import '../../features/patient/screens/patient_dashboard_screen.dart';
import '../../features/patient/screens/patient_main_screen.dart';
import '../api/api_client.dart';
import '../services/storage_service.dart';

class AppRouter {
  static GoRouter createRouter({
    required StorageService storageService,
    required ApiClient apiClient,
  }) {
    final authRepository = AuthRepository(
      apiService: AuthApiService(apiClient),
      storageService: storageService,
    );

    final patientRepository = PatientRepository(
      PatientApiService(apiClient),
    );

    return GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => BlocProvider(
            create: (_) => AuthBloc(repository: authRepository)
              ..add(const AuthCheckRequested()),
            child: const SplashScreen(),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => BlocProvider(
            create: (_) => AuthBloc(repository: authRepository),
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => BlocProvider(
            create: (_) => AuthBloc(repository: authRepository),
            child: const RegisterScreen(),
          ),
        ),
        GoRoute(
          path: '/otp-verification',
          builder: (context, state) {
            final email = state.extra as String? ?? '';
            return BlocProvider(
              create: (_) => AuthBloc(repository: authRepository),
              child: OtpVerificationScreen(email: email),
            );
          },
        ),

        // Patient Main Navigation Shell
        ShellRoute(
          builder: (context, state, child) {
            return PatientMainScreen(child: child);
          },
          routes: [
            GoRoute(
              path: '/patient/dashboard',
              builder: (context, state) => const PatientDashboardScreen(),
            ),
            GoRoute(
              path: '/patient/doctors',
              builder: (context, state) => BlocProvider(
                create: (_) => DoctorListBloc(repository: patientRepository),
                child: const DoctorListScreen(),
              ),
            ),
            GoRoute(
              path: '/patient/appointments',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('My Appointments (Coming soon in Phase 4)')),
              ),
            ),
            GoRoute(
              path: '/patient/wallet',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('My Wallet (Coming soon in Phase 7)')),
              ),
            ),
          ],
        ),

        // Doctor details (Not in Shell so it pushes over the bottom navigation bar)
        GoRoute(
          path: '/patient/doctors/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return BlocProvider(
              create: (_) => DoctorDetailBloc(repository: patientRepository),
              child: DoctorDetailScreen(doctorId: id),
            );
          },
        ),

        // Doctor routes
        GoRoute(
          path: '/doctor/dashboard',
          builder: (context, state) => const DoctorDashboardScreen(),
        ),
      ],

      // Redirect guard — verifies token for protected routes
      redirect: (BuildContext context, GoRouterState state) async {
        final token = await storageService.getToken();
        final role = await storageService.getRole();

        final isPublicRoute = state.matchedLocation == '/splash' ||
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/otp-verification';

        // No token — allow only public routes
        if (token == null) {
          return isPublicRoute ? null : '/login';
        }

        // Logged in — prevent going back to login/register
        if (state.matchedLocation == '/login' ||
            state.matchedLocation == '/register') {
          if (role == 'patient') return '/patient/dashboard';
          if (role == 'doctor') return '/doctor/dashboard';
        }

        // Role guard
        if (state.matchedLocation.startsWith('/patient') && role != 'patient') {
          return '/login';
        }
        if (state.matchedLocation.startsWith('/doctor') && role != 'doctor') {
          return '/login';
        }

        return null;
      },
    );
  }
}
