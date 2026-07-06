import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../extensions/context_extensions.dart';

class AppLoadingIndicator extends StatelessWidget {
  final bool isShimmer;
  final double height;
  final double width;
  final double borderRadius;

  const AppLoadingIndicator({
    super.key,
    this.isShimmer = false,
    this.height = 100,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (isShimmer) {
      return Shimmer.fromColors(
        baseColor: colors.border,
        highlightColor: colors.surface,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      );
    }

    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
      ),
    );
  }
}
