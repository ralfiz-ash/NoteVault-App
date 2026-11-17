import 'package:flutter/material.dart';

/// Primary action that shows a spinner and is disabled while [loading],
/// which prevents double submission.
class SubmitButton extends StatelessWidget {
  const SubmitButton({
    required this.label,
    required this.loading,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      child: loading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
