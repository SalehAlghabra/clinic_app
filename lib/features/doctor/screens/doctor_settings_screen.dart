import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/dialogs/app_dialogs.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/models/user_model.dart';
import '../../auth/repository/auth_repository.dart';
import '../../settings/bloc/theme_cubit.dart';
import '../../settings/bloc/theme_state.dart';
import '../../settings/bloc/locale_cubit.dart';

import '../../../shared/widgets/app_top_actions.dart';

class DoctorSettingsScreen extends StatelessWidget {
  const DoctorSettingsScreen({super.key});

  void _showEditProfileDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone ?? '');
    final currentPasswordController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Uint8List? selectedBytes;
    String? selectedFileName;
    bool isSubmitting = false;
    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colors = context.appColors;
            final l10n = AppLocalizations.of(context);
            final isArabic = Localizations.localeOf(context).languageCode == 'ar';

            return AlertDialog(
              backgroundColor: colors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                l10n.editProfile,
                style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: colors.primary.withValues(alpha: 0.15),
                        backgroundImage: selectedBytes != null
                            ? MemoryImage(selectedBytes!)
                            : (user.profilePictureUrl != null
                                ? NetworkImage(user.profilePictureUrl!) as ImageProvider
                                : null),
                        child: (selectedBytes == null && user.profilePictureUrl == null)
                            ? Icon(Icons.person, size: 36, color: colors.primary)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            withData: true,
                          );
                          if (result != null && result.files.isNotEmpty) {
                            final file = result.files.first;
                            if (file.bytes != null) {
                              setDialogState(() {
                                selectedBytes = file.bytes;
                                selectedFileName = file.name;
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: Text(
                          selectedFileName != null
                              ? selectedFileName!
                              : (isArabic ? 'اختر صورة من الجهاز' : 'Choose Photo from Device'),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.primary,
                          side: BorderSide(color: colors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: l10n.fullNameLabel,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: l10n.phoneLabel,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const Divider(height: 32),
                      Text(
                        isArabic ? 'تغيير كلمة المرور' : 'Change Password',
                        style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: currentPasswordController,
                        obscureText: !showCurrentPassword,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'كلمة المرور الحالية' : 'Current Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showCurrentPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setDialogState(() => showCurrentPassword = !showCurrentPassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: !showNewPassword,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'كلمة المرور الجديدة' : 'New Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setDialogState(() => showNewPassword = !showNewPassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: !showConfirmPassword,
                        decoration: InputDecoration(
                          labelText: l10n.confirmPasswordLabel,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setDialogState(() => showConfirmPassword = !showConfirmPassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(l10n.cancel, style: TextStyle(color: colors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final pass = passwordController.text.trim();
                          final confirmPass = confirmPasswordController.text.trim();
                          final currPass = currentPasswordController.text.trim();

                          if (pass.isNotEmpty) {
                            if (currPass.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isArabic
                                        ? 'كلمة المرور الحالية مطلوبة لتعيين كلمة مرور جديدة'
                                        : 'Current password is required to set a new password',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            if (pass != confirmPass) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.passwordsDoNotMatch),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                          }

                          setDialogState(() => isSubmitting = true);
                          try {
                            final authRepo = RepositoryProvider.of<AuthRepository>(context);
                            final res = await authRepo.updateProfile(
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              currentPassword: currPass.isNotEmpty ? currPass : null,
                              password: pass.isNotEmpty ? pass : null,
                              fileBytes: selectedBytes,
                              fileName: selectedFileName,
                            );

                            if (res.isSuccess && dialogCtx.mounted) {
                              final messenger = ScaffoldMessenger.of(context);
                              final authBloc = context.read<AuthBloc>();
                              Navigator.pop(dialogCtx);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(l10n.profileUpdated),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              authBloc.add(AuthProfileUpdated(res.data!));
                            } else {
                              setDialogState(() => isSubmitting = false);
                              if (dialogCtx.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res.failure?.message ?? l10n.errorOccurred),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            if (dialogCtx.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.save, style: const TextStyle(color: Colors.white)),
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

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          AppTopActions(),
          SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;
          final doctorName = user?.name ?? 'Doctor';
          final doctorEmail = user?.email ?? 'doctor@clinic.com';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Profile Header card
                AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          image: user?.profilePictureUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(user!.profilePictureUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user?.profilePictureUrl == null
                            ? Icon(Icons.medical_services_rounded, color: colors.primary, size: 32)
                            : null,
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctorEmail,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (user != null)
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: colors.primary),
                          onPressed: () => _showEditProfileDialog(context, user),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),

                // Settings Options
                Text(
                  l10n.settingsTitle,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),

                // Dark mode toggle
                AppCard(
                  child: BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, themeState) {
                      final isDark = themeState.themeMode == ThemeMode.dark;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.dark_mode_outlined, color: colors.text),
                              const SizedBox(width: 12),
                              Text(
                                l10n.darkMode,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.text,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isDark,
                            onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                            activeThumbColor: colors.primary,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),

                // Language toggle
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.language_rounded, color: colors.text),
                          const SizedBox(width: 12),
                          Text(
                            l10n.language,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.text,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.read<LocaleCubit>().toggleLocale(),
                        child: Text(
                          context.read<LocaleCubit>().isArabic ? 'English' : 'العربية',
                          style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),

                // Logout button
                AppButton(
                  text: l10n.logout,
                  isOutline: true,
                  onPressed: () async {
                    final ok = await AppDialogs.showConfirmation(
                      context: context,
                      title: l10n.logoutConfirmTitle,
                      message: l10n.logoutConfirmMessage,
                    );
                    if (ok == true && context.mounted) {
                      context.read<AuthBloc>().add(const AuthLogoutRequested());
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
