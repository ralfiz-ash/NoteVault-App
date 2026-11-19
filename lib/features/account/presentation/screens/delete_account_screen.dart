import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/presentation/confirm_dialog.dart';
import '../../../../core/presentation/content_width.dart';
import '../../../../core/presentation/failure_snack_bar.dart';
import '../../../auth/domain/entities/sign_in_method.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../auth/presentation/state/auth_state.dart';
import '../../../sync/domain/entities/connectivity_status.dart';
import '../../../sync/presentation/providers/connection_status_provider.dart';
import '../../domain/entities/account_deletion_confirmation.dart';
import '../providers/delete_account_controller.dart';

/// Explains what is deleted, confirms the user's identity (password or
/// Google) and deletes the account. Needs a connection.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete({required bool withPassword}) async {
    FocusScope.of(context).unfocus();
    if (withPassword && !_formKey.currentState!.validate()) return;
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete account permanently?',
      message:
          'Your account and all your notes, folders, tags and settings will '
          'be deleted from this device and the cloud. This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    // The app-wide messenger outlives this screen, which closes by itself
    // once the account is gone (the user is signed out).
    final messenger = ScaffoldMessenger.of(context);
    final deleted = await ref
        .read(deleteAccountControllerProvider.notifier)
        .delete(
          withPassword
              ? ConfirmWithPassword(_password.text)
              : const ConfirmWithGoogle(),
        );
    if (deleted) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Your account and notes were deleted.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(deleteAccountControllerProvider, (_, next) {
      if (next case AsyncError(:final error) when error is! CancelledFailure) {
        showFailureSnackBar(context, 'Unable to delete account', error);
      }
    });
    final busy = ref.watch(deleteAccountControllerProvider).isLoading;
    final methods = ref.watch(
      authStateProvider.select(
        (s) => switch (s.value) {
          Authenticated(:final user) => user.signInMethods,
          _ => const <SignInMethod>{},
        },
      ),
    );
    // Password when the account has one; Google-only accounts use Google.
    final withPassword =
        methods.contains(SignInMethod.emailPassword) ||
        !methods.contains(SignInMethod.google);
    final offline = ref.watch(
      connectionStatusProvider.select(
        (s) => s.value == ConnectivityStatus.disconnected,
      ),
    );
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Delete account')),
      body: ContentWidth(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Icon(Icons.warning_amber_rounded, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text(
                'Delete your NoteVault account?',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text('This permanently deletes:'),
              const SizedBox(height: 8),
              const _Bullet('Your NoteVault account'),
              const _Bullet('All your notes, folders and tags'),
              const _Bullet('Your settings'),
              const SizedBox(height: 8),
              const Text(
                'They are removed from this device and from the cloud, so '
                'they disappear from all your devices. This cannot be undone.',
              ),
              const SizedBox(height: 24),
              if (offline) ...[
                const _OfflineNotice(),
                const SizedBox(height: 16),
              ],
              if (withPassword)
                TextFormField(
                  key: const Key('delete-account-password'),
                  controller: _password,
                  enabled: !busy,
                  obscureText: _obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Enter your password to confirm.'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    helperText: 'Enter your password to confirm.',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                )
              else
                const Text(
                  'To confirm, sign in with your Google account again.',
                ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('delete-account-button'),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                ),
                onPressed: busy || offline
                    ? null
                    : () => _delete(withPassword: withPassword),
                child: busy
                    ? SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onError,
                        ),
                      )
                    : Text(
                        withPassword
                            ? 'Delete account'
                            : 'Confirm with Google and delete',
                      ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: busy ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  '),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outline),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off_outlined),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "You're offline. Connect to the internet to delete your "
              'account.',
            ),
          ),
        ],
      ),
    );
  }
}
