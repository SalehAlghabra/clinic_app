import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.border, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        selectedLabelStyle: context.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: context.textTheme.labelMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
