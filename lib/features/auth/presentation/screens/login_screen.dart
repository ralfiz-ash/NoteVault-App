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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authControllerProvider.notifier)
        .signIn(email: _email.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) showAuthError(context, error);
    });
    final loading = ref.watch(authControllerProvider).isLoading;

    return AuthFormLayout(
      title: 'Welcome back',
      subtitle: 'Sign in to your NoteVault account.',
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
                  key: const Key('login-password'),
                  controller: _password,
                  label: 'Password',
                  enabled: !loading,
                  validator: AuthValidators.loginPassword,
                  onSubmitted: _submit,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: loading
                ? null
                : () => context.go(AppRoutes.forgotPassword),
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: 8),
        SubmitButton(label: 'Sign in', loading: loading, onPressed: _submit),
        const SizedBox(height: 16),
        const _OrDivider(),
        const SizedBox(height: 16),
        GoogleSignInButton(
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
            const Text("Don't have an account?"),
            TextButton(
              onPressed: loading ? null : () => context.go(AppRoutes.register),
              child: const Text('Create one'),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('or'),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}
