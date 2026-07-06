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
import '../../features/patient/screens/patient_dashboard_screen.dart';
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

        // Patient routes
        GoRoute(
          path: '/patient/dashboard',
          builder: (context, state) => const PatientDashboardScreen(),
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
