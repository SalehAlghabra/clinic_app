import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../extensions/context_extensions.dart';

class AppDialogs {
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colors = context.appColors;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: Icon(Icons.check_circle_outline_rounded, color: colors.success, size: 48),
          title: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: context.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          actions: [
            AppButton(
              text: buttonText,
              onPressed: () {
                Navigator.of(context).pop();
                onPressed?.call();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        final colors = context.appColors;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: Icon(Icons.error_outline_rounded, color: colors.error, size: 48),
          title: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: context.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          actions: [
            AppButton(
              text: buttonText,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = context.appColors;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: context.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: cancelText,
                    onPressed: () => Navigator.of(context).pop(false),
                    isOutline: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: confirmText,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
