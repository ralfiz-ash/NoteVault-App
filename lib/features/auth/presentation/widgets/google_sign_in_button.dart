import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.onPressed,
    this.label = 'Continue with Google',
    super.key,
  });

  /// `null` disables the button (while another request runs).
  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      icon: const Text(
        'G',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      label: Text(label),
    );
  }
}
