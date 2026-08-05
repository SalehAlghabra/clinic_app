import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/doctor/screens/doctor_dashboard_screen.dart';
import '../../features/patient/bloc/doctor_detail_bloc.dart';
import '../../features/patient/bloc/doctor_list_bloc.dart';
import '../../features/patient/bloc/appointment_bloc.dart';
import '../../features/patient/data/patient_api_service.dart';
import '../../features/patient/repository/patient_repository.dart';
import '../../features/patient/screens/doctor_detail_screen.dart';
import '../../features/patient/screens/doctor_list_screen.dart';
import '../../features/patient/screens/patient_dashboard_screen.dart';
import '../../features/patient/screens/patient_appointments_screen.dart';
import '../../features/patient/screens/patient_main_screen.dart';
import '../../features/patient/screens/patient_settings_screen.dart';
import '../../features/doctor/data/doctor_api_service.dart';
import '../../features/doctor/repository/doctor_repository.dart';
import '../../features/doctor/bloc/doctor_appointments_bloc.dart';
import '../../features/doctor/screens/doctor_main_screen.dart';
import '../../features/doctor/screens/doctor_appointments_screen.dart';
import '../../features/doctor/screens/doctor_settings_screen.dart';
import '../../features/medical_records/bloc/medical_records_bloc.dart';
import '../../features/medical_records/data/medical_records_api_service.dart';
import '../../features/medical_records/repository/medical_records_repository.dart';
import '../../features/medical_records/screens/patient_records_screen.dart';
import '../../features/medical_records/screens/record_details_screen.dart';
import '../../features/medical_records/screens/create_record_screen.dart';
import '../../features/wallet/bloc/wallet_bloc.dart';
import '../../features/wallet/data/wallet_api_service.dart';
import '../../features/wallet/repository/wallet_repository.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/invoices/bloc/invoices_bloc.dart';
import '../../features/invoices/data/invoices_api_service.dart';
import '../../features/invoices/repository/invoices_repository.dart';
import '../../features/invoices/screens/invoices_list_screen.dart';
import '../../features/invoices/screens/invoice_details_screen.dart';
import '../../features/invoices/models/invoice_model.dart';
import '../api/api_client.dart';
import '../services/storage_service.dart';

class AppRouter {
  static GoRouter createRouter({
    required StorageService storageService,
    required ApiClient apiClient,
    required AuthRepository authRepository,
  }) {
    final patientRepository = PatientRepository(
      PatientApiService(apiClient),
    );

    final doctorRepository = DoctorRepository(
      DoctorApiService(apiClient),
    );

    final medicalRecordsRepository = MedicalRecordsRepository(
      MedicalRecordsApiService(apiClient),
    );

    final walletRepository = WalletRepository(
      WalletApiService(apiClient),
    );

    final invoicesRepository = InvoicesRepository(
      InvoicesApiService(apiClient),
    );

    return GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/otp-verification',
          builder: (context, state) {
            final email = state.extra as String? ?? '';
            return OtpVerificationScreen(email: email);
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
              builder: (context, state) => BlocProvider(
                create: (_) => WalletBloc(repository: walletRepository),
                child: const PatientDashboardScreen(),
              ),
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
              builder: (context, state) => BlocProvider(
                create: (_) => AppointmentBloc(patientRepository),
                child: const PatientAppointmentsScreen(),
              ),
            ),
            GoRoute(
              path: '/patient/wallet',
              builder: (context, state) => BlocProvider(
                create: (_) => WalletBloc(repository: walletRepository),
                child: const WalletScreen(),
              ),
            ),
            GoRoute(
              path: '/patient/settings',
              builder: (context, state) => const PatientSettingsScreen(),
            ),
          ],
        ),

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

        // Patient Medical Records History List
        GoRoute(
          path: '/patient/records',
          builder: (context, state) => BlocProvider(
            create: (_) => MedicalRecordsBloc(repository: medicalRecordsRepository),
            child: const PatientRecordsScreen(),
          ),
        ),

        // Medical Record Details (accessible by both Patient and Doctor)
        GoRoute(
          path: '/medical-records/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return BlocProvider(
              create: (_) => MedicalRecordsBloc(repository: medicalRecordsRepository),
              child: RecordDetailsScreen(recordId: id),
            );
          },
        ),

        // Doctor Create Medical Record Form
        GoRoute(
          path: '/doctor/appointments/:id/create-record',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            final patientName = state.extra as String? ?? 'Patient';
            return BlocProvider(
              create: (_) => MedicalRecordsBloc(repository: medicalRecordsRepository),
              child: CreateRecordScreen(appointmentId: id, patientName: patientName),
            );
          },
        ),

        // Patient Invoices list
        GoRoute(
          path: '/patient/invoices',
          builder: (context, state) => BlocProvider(
            create: (_) => InvoicesBloc(repository: invoicesRepository),
            child: const InvoicesListScreen(),
          ),
        ),

        // Patient Invoice Details Page
        GoRoute(
          path: '/patient/invoices/details',
          builder: (context, state) {
            final invoice = state.extra as InvoiceModel;
            return InvoiceDetailsScreen(invoice: invoice);
          },
        ),

        // Doctor Main Navigation Shell
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => DoctorAppointmentsBloc(repository: doctorRepository),
              child: DoctorMainScreen(child: child),
            );
          },
          routes: [
            GoRoute(
              path: '/doctor/dashboard',
              builder: (context, state) => const DoctorDashboardScreen(),
            ),
            GoRoute(
              path: '/doctor/appointments',
              builder: (context, state) => const DoctorAppointmentsScreen(),
            ),
            GoRoute(
              path: '/doctor/settings',
              builder: (context, state) => const DoctorSettingsScreen(),
            ),
          ],
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
