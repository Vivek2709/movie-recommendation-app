import 'package:flutter/material.dart';
import 'package:frontend/widgets/loaders/circular_progress_indicator.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isExternallyControlled;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isExternallyControlled = true,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isPrimary
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary,
          foregroundColor: widget.isPrimary
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSecondary,
          textStyle: theme.textTheme.labelLarge,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadowColor: widget.isPrimary
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.secondary.withValues(alpha: 0.3),
          elevation: 6,
        ),
        child: widget.isLoading
            ? CustomCircularProgressIndicator(
                isPrimary: widget.isPrimary,
              )
            : Text(widget.text),
      ),
    );
  }
}
