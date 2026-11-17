import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../providers/password_reset_controller.dart';
import '../widgets/auth_error_snack_bar.dart';
import '../widgets/auth_form_layout.dart';
import '../widgets/email_field.dart';
import '../widgets/submit_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    ref.read(passwordResetControllerProvider.notifier).send(_email.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(passwordResetControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) showAuthError(context, error);
    });
    final state = ref.watch(passwordResetControllerProvider);
    final loading = state.isLoading;
    final sent = state.value ?? false;

    return AuthFormLayout(
      title: 'Reset your password',
      subtitle: "Enter your account's email and we'll send you a reset link.",
      children: [
        if (sent)
          _SentConfirmation(email: _email.text.trim())
        else ...[
          Form(
            key: _formKey,
            child: EmailField(controller: _email, enabled: !loading),
          ),
          const SizedBox(height: 24),
          SubmitButton(
            label: 'Send reset link',
            loading: loading,
            onPressed: _submit,
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: loading ? null : () => context.go(AppRoutes.login),
          child: const Text('Back to sign in'),
        ),
      ],
    );
  }
}

class _SentConfirmation extends StatelessWidget {
  const _SentConfirmation({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.mark_email_read_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              // Same message whether or not the account exists, so the
              // screen does not reveal which emails are registered.
              child: Text(
                'If an account exists for $email, a password reset link is '
                'on its way. Check your inbox and spam folder.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
