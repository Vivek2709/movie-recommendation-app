import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(
      {required BuildContext context,
      required String message,
      bool isError = false}) {
    final theme = Theme.of(context);
    final backgroundColor = isError
        ? theme.colorScheme.error
        : theme.colorScheme.surfaceContainerHigh;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(
            color: isError
                ? theme.colorScheme.onError
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold),
      ),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      duration: const Duration(seconds: 3),
    ));
  }
}
