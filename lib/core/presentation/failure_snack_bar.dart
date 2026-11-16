import 'package:flutter/material.dart';

import '../errors/failure.dart';

/// Shows "`action`. `reason`" once, replacing any SnackBar on screen.
/// [action] is e.g. "Unable to delete note". Validation messages are shown
/// as they are. Raw exceptions and stack traces are never shown.
void showFailureSnackBar(BuildContext context, String action, Object error) {
  final message = switch (error) {
    ValidationFailure(:final message) => message,
    Failure(:final message) => '$action. $message',
    _ => '$action. Please try again.',
  };
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
