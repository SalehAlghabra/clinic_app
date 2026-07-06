import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'An Error Occurred',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 150,
                child: AppButton(
                  text: 'Retry',
                  onPressed: onRetry,
                  isOutline: true,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
