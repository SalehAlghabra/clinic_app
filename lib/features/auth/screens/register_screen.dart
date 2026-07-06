import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        ),
      );
    }
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
          context.go('/patient/dashboard');
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingS,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    l10n.registerTitle,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 8),

                  Text(
                    l10n.registerSubtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // Full Name
                  AppTextField(
                    labelText: l10n.fullNameLabel,
                    hintText: l10n.fullNameHint,
                    controller: _nameController,
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: colors.textSecondary,
                    ),
                    validator: (v) => Validators.required(v, 'Name'),
                  ).animate().slideY(
                    begin: 0.15,
                    delay: 200.ms,
                    duration: 350.ms,
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Email
                  AppTextField(
                    labelText: l10n.emailLabel,
                    hintText: l10n.emailHint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: colors.textSecondary,
                    ),
                    validator: Validators.email,
                  ).animate().slideY(
                    begin: 0.15,
                    delay: 280.ms,
                    duration: 350.ms,
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Phone (optional)
                  AppTextField(
                    labelText: '${l10n.phoneLabel} (optional)',
                    hintText: l10n.phoneHint,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: colors.textSecondary,
                    ),
                    validator: Validators.phone,
                  ).animate().slideY(
                    begin: 0.15,
                    delay: 360.ms,
                    duration: 350.ms,
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Password
                  AppTextField(
                    labelText: l10n.passwordLabel,
                    hintText: l10n.passwordHint,
                    controller: _passwordController,
                    isPassword: true,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: colors.textSecondary,
                    ),
                    validator: Validators.password,
                  ).animate().slideY(
                    begin: 0.15,
                    delay: 440.ms,
                    duration: 350.ms,
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Confirm Password
                  AppTextField(
                    labelText: l10n.confirmPasswordLabel,
                    hintText: l10n.confirmPasswordHint,
                    controller: _confirmPasswordController,
                    isPassword: true,
                    prefixIcon: Icon(
                      Icons.lock_person_outlined,
                      color: colors.textSecondary,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (v != _passwordController.text) {
                        return l10n.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ).animate().slideY(
                    begin: 0.15,
                    delay: 520.ms,
                    duration: 350.ms,
                  ),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // Register button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        text: l10n.registerButton,
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      );
                    },
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: AppDimensions.paddingM),

                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      l10n.alreadyHaveAccount,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
