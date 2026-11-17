import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../domain/validation/auth_validators.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_error_snack_bar.dart';
import '../widgets/auth_form_layout.dart';
import '../widgets/email_field.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/password_field.dart';
import '../widgets/submit_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authControllerProvider.notifier)
        .register(email: _email.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) showAuthError(context, error);
    });
    final loading = ref.watch(authControllerProvider).isLoading;

    return AuthFormLayout(
      title: 'Create your account',
      subtitle: 'Your notes stay on this device and sync to your account.',
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EmailField(controller: _email, enabled: !loading),
                const SizedBox(height: 16),
                PasswordField(
                  key: const Key('register-password'),
                  controller: _password,
                  label: 'Password',
                  enabled: !loading,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: AuthValidators.newPassword,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  key: const Key('register-confirm'),
                  controller: _confirm,
                  label: 'Confirm password',
                  enabled: !loading,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) =>
                      AuthValidators.confirmPassword(value, _password.text),
                  onSubmitted: _submit,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SubmitButton(
          label: 'Create account',
          loading: loading,
          onPressed: _submit,
        ),
        const SizedBox(height: 16),
        GoogleSignInButton(
          label: 'Sign up with Google',
          onPressed: loading
              ? null
              : () => ref
                    .read(authControllerProvider.notifier)
                    .signInWithGoogle(),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Already have an account?'),
            TextButton(
              onPressed: loading ? null : () => context.go(AppRoutes.login),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ],
    );
  }
}
