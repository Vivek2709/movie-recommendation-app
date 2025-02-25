import 'package:flutter/material.dart';
import 'package:frontend/widgets/loaders/circular_progress_indicator.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool isValidating;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.isValidating = false,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: widget.isValidating
            ? CustomCircularProgressIndicator(isPrimary: true)
            : null,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
