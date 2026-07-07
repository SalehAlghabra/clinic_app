import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutline;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutline = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutline ? colors.primary : colors.surface,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: isOutline ? colors.primary : colors.surface),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isOutline ? colors.primary : colors.surface,
                ),
              ),
            ],
          );

    final style = ElevatedButton.styleFrom(
      backgroundColor: isOutline ? Colors.transparent : colors.primary,
      elevation: isOutline ? 0 : 2,
      shadowColor: colors.primary.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOutline ? BorderSide(color: colors.primary, width: 1.5) : BorderSide.none,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      minimumSize: const Size(double.infinity, 50),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: child,
    );
  }
}
