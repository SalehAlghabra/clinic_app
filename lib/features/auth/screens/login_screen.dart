import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../repository/auth_repository.dart';
import '../../settings/bloc/theme_cubit.dart';
import '../../settings/bloc/locale_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    final otpCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    int step = 1;
    bool isLoading = false;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colors = context.appColors;

            return AlertDialog(
              backgroundColor: colors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Forgot Password',
                style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 340,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      step == 1
                          ? 'Step 1: Enter your registered email to receive an OTP code.'
                          : (step == 2
                              ? 'Step 2: Enter the 6-digit OTP sent to ${emailCtrl.text.trim()}'
                              : 'Step 3: Set your new password.'),
                      style: TextStyle(color: colors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    if (errorMsg != null) ...[
                      Text(errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                      const SizedBox(height: 8),
                    ],
                    if (step == 1)
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    else if (step == 2)
                      TextField(
                        controller: otpCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: '6-Digit OTP',
                          prefixIcon: const Icon(Icons.security_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    else ...[
                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmPassCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          setDialogState(() {
                            isLoading = true;
                            errorMsg = null;
                          });

                          try {
                            final authRepo = RepositoryProvider.of<AuthRepository>(context);

                            if (step == 1) {
                              final email = emailCtrl.text.trim();
                              if (email.isEmpty) throw 'Please enter a valid email';
                              final res = await authRepo.forgotPassword(email);
                              if (res.isSuccess) {
                                setDialogState(() {
                                  step = 2;
                                  isLoading = false;
                                });
                              } else {
                                throw res.failure?.message ?? 'Failed to send OTP';
                              }
                            } else if (step == 2) {
                              final otp = otpCtrl.text.trim();
                              if (otp.length != 6) throw 'Please enter a valid 6-digit OTP';
                              final res = await authRepo.verifyResetOtp(emailCtrl.text.trim(), otp);
                              if (res.isSuccess) {
                                setDialogState(() {
                                  step = 3;
                                  isLoading = false;
                                });
                              } else {
                                throw res.failure?.message ?? 'Invalid OTP code';
                              }
                            } else {
                              final newPass = passCtrl.text.trim();
                              final confirmPass = confirmPassCtrl.text.trim();
                              if (newPass.length < 6) throw 'Password must be at least 6 characters';
                              if (newPass != confirmPass) throw 'Passwords do not match';

                              final res = await authRepo.resetPassword(
                                email: emailCtrl.text.trim(),
                                otp: otpCtrl.text.trim(),
                                password: newPass,
                                passwordConfirmation: confirmPass,
                              );

                              if (res.isSuccess) {
                                Navigator.pop(dialogCtx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password reset successfully! Please log in.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                throw res.failure?.message ?? 'Failed to reset password';
                              }
                            }
                          } catch (e) {
                            setDialogState(() {
                              isLoading = false;
                              errorMsg = e.toString();
                            });
                          }
                        },
                  child: isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          step == 1 ? 'Send OTP' : (step == 2 ? 'Verify' : 'Reset Password'),
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showServerSettingsDialog() {
    final urlController = TextEditingController(text: AppConfig.baseUrl);
    bool isTesting = false;
    String? testResultMsg;
    bool? testSuccess;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colors = context.appColors;

            return AlertDialog(
              backgroundColor: colors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.developer_mode_rounded, color: colors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Developer Server Settings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 340,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change the backend API base URL below. Long-press logo anytime to return here.',
                      style: TextStyle(color: colors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: urlController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: 'API Base URL',
                        hintText: 'http://10.0.0.5:8000',
                        prefixIcon: const Icon(Icons.dns_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (testResultMsg != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: testSuccess == true
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: testSuccess == true ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              testSuccess == true
                                  ? Icons.check_circle_rounded
                                  : Icons.error_rounded,
                              color: testSuccess == true ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                testResultMsg!,
                                style: TextStyle(
                                  color: testSuccess == true ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: isTesting
                                ? null
                                : () async {
                                    setDialogState(() {
                                      isTesting = true;
                                      testResultMsg = null;
                                      testSuccess = null;
                                    });

                                    String inputUrl = urlController.text.trim();
                                    if (!inputUrl.startsWith('http://') && !inputUrl.startsWith('https://')) {
                                      inputUrl = 'http://$inputUrl';
                                    }
                                    if (inputUrl.endsWith('/')) {
                                      inputUrl = inputUrl.substring(0, inputUrl.length - 1);
                                    }

                                    try {
                                      final testDio = dio.Dio(dio.BaseOptions(
                                        connectTimeout: const Duration(seconds: 5),
                                        receiveTimeout: const Duration(seconds: 5),
                                      ));
                                      final resp = await testDio.get('$inputUrl/api/doctors');
                                      setDialogState(() {
                                        isTesting = false;
                                        testSuccess = true;
                                        testResultMsg = 'Connected! Server reachable (Status ${resp.statusCode})';
                                      });
                                    } catch (e) {
                                      setDialogState(() {
                                        isTesting = false;
                                        testSuccess = false;
                                        testResultMsg = 'Connection failed: ${e.toString().replaceAll('DioException ', '')}';
                                      });
                                    }
                                  },
                            icon: isTesting
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.wifi_find_rounded, size: 18),
                            label: const Text('Test Connection'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final storage = StorageService();
                    await storage.delete(StorageKeys.customBaseUrl);
                    AppConfig.currentBaseUrl = AppConfig.defaultBaseUrl;
                    urlController.text = AppConfig.defaultBaseUrl;
                    if (dialogCtx.mounted) {
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reset to default base URL')),
                      );
                    }
                  },
                  child: const Text('Reset', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    String newUrl = urlController.text.trim();
                    if (newUrl.isEmpty) return;

                    if (!newUrl.startsWith('http://') && !newUrl.startsWith('https://')) {
                      newUrl = 'http://$newUrl';
                    }
                    if (newUrl.endsWith('/')) {
                      newUrl = newUrl.substring(0, newUrl.length - 1);
                    }

                    final storage = StorageService();
                    await storage.write(StorageKeys.customBaseUrl, newUrl);
                    AppConfig.currentBaseUrl = newUrl;

                    if (dialogCtx.mounted) {
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Server URL updated to: $newUrl'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Save & Apply', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          context.push('/otp-verification', extra: state.email);
        } else if (state is AuthAuthenticated) {
          final role = state.user.role;
          if (role == 'patient') {
            context.go('/patient/dashboard');
          } else if (role == 'doctor') {
            context.go('/doctor/dashboard');
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (state is AuthValidationError) {
          final firstError = state.errors.values.isNotEmpty
              ? (state.errors.values.first is List
                    ? state.errors.values.first[0]
                    : state.errors.values.first)
              : state.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(firstError.toString()),
              backgroundColor: colors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: colors.text,
              ),
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            ),
            TextButton(
              onPressed: () => context.read<LocaleCubit>().toggleLocale(),
              child: Text(
                context.read<LocaleCubit>().isArabic ? 'English' : 'العربية',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingS),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  GestureDetector(
                    onLongPress: _showServerSettingsDialog,
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ).animate().scale(
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),

                  const SizedBox(height: AppDimensions.paddingL),

                  // Title
                  Text(
                    l10n.loginTitle,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 8),

                  Text(
                    l10n.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // Email field
                  AppTextField(
                    labelText: l10n.emailLabel,
                    hintText: l10n.emailHint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: colors.textSecondary,
                    ),
                    validator: (v) => Validators.email(
                      v,
                      l10n.validatorEmailRequired,
                      l10n.validatorEmailInvalid,
                    ),
                  ).animate().slideY(
                    begin: 0.2,
                    delay: 400.ms,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Password field
                  AppTextField(
                    labelText: l10n.passwordLabel,
                    hintText: l10n.passwordHint,
                    controller: _passwordController,
                    isPassword: true,
                    textDirection: TextDirection.ltr,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: colors.textSecondary,
                    ),
                    validator: (v) => Validators.password(
                      v,
                      l10n.validatorPasswordRequired,
                      l10n.validatorPasswordMinLength,
                    ),
                  ).animate().slideY(
                    begin: 0.2,
                    delay: 500.ms,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Login button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        text: l10n.loginButton,
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      );
                    },
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Register link
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text(
                      l10n.noAccountPrompt,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
