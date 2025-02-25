import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  final bool isPrimary;

  const CustomCircularProgressIndicator({
    Key? key,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 24, // Size of the loader
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              isPrimary
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
            ),
            backgroundColor: isPrimary
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : theme.colorScheme.secondary.withValues(alpha: 0.2),
          ),
          Icon(
            Icons.movie,
            size: 14,
            color: isPrimary
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSecondary,
          ),
        ],
      ),
    );
  }
}
