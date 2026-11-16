import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';

/// Shows an auth failure once, replacing any SnackBar already on screen.
///
/// Only the visible (top-most) route reacts, so screens stacked below do not
/// show the same error again. A cancelled sign-in is not reported.
void showAuthError(BuildContext context, Object error) {
  if (error is CancelledFailure) return;
  if (ModalRoute.of(context)?.isCurrent == false) return;
  final message = error is Failure
      ? error.message
      : 'Something went wrong. Please try again.';
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
