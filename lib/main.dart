import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'core/api/api_client.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/bloc/locale_cubit.dart';
import 'features/settings/bloc/locale_state.dart';
import 'features/settings/bloc/theme_cubit.dart';
import 'features/settings/bloc/theme_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final apiClient = ApiClient(storageService: storageService);
  final router = AppRouter.createRouter(
    storageService: storageService,
    apiClient: apiClient,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(storageService),
        ),
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit(storageService),
        ),
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
