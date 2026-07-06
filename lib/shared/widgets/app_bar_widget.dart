import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const AppBarWidget({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppBar(
      title: Text(
        title,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colors.text,
        ),
      ),
      centerTitle: true,
      leading: leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
