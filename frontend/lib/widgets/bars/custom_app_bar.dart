import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = false, // ✅ Default value is fine here
    this.onBack,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
              onPressed: onBack ??
                  () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      debugPrint('No screen to pop');
                    }
                  },
            )
          : null,
      actions: actions, // ✅ Actions will be set from the screen
      backgroundColor: theme.colorScheme.surface,
      elevation: 4,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.2), // ✅ Fixed issue
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
