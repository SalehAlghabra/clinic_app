import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'core/api/api_client.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/bloc/locale_cubit.dart';
import 'features/settings/bloc/locale_state.dart';
import 'features/settings/bloc/theme_cubit.dart';
import 'features/settings/bloc/theme_state.dart';

import 'features/auth/data/auth_api_service.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final apiClient = ApiClient(storageService: storageService);

  final authRepository = AuthRepository(
    apiService: AuthApiService(apiClient),
    storageService: storageService,
  );

  final authBloc = AuthBloc(repository: authRepository)
    ..add(const AuthCheckRequested());

  final router = AppRouter.createRouter(
    storageService: storageService,
    apiClient: apiClient,
    authRepository: authRepository,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(storageService)),
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit(storageService)),
        BlocProvider<AuthBloc>(create: (_) => authBloc),
      ],
      child: MyApp(router: router),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, localeState) {
            return MaterialApp.router(
              title: 'Clinic Management',
              debugShowCheckedModeBanner: false,

              // Theme
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,

              // Localization
              locale: localeState.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              // Router
              routerConfig: router,
            );
          },
        );
      },
    );
  }
}
