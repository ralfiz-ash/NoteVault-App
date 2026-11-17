import 'package:flutter/material.dart';

import '../../domain/validation/auth_validators.dart';

class EmailField extends StatelessWidget {
  const EmailField({required this.controller, this.enabled = true, super.key});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.next,
      validator: AuthValidators.email,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
    );
  }
}
