import 'package:flutter/material.dart';

/// Formats a stored (UTC) timestamp for display in the device's time zone and
/// locale, e.g. "Nov 16, 2026, 2:05 PM". The only place UTC becomes local.
String formatDateTime(BuildContext context, DateTime utc) {
  final local = utc.toLocal();
  final l10n = MaterialLocalizations.of(context);
  return '${l10n.formatMediumDate(local)}, '
      '${l10n.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
}
