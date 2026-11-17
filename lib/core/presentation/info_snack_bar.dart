import 'package:flutter/material.dart';

/// A short confirmation ("Folder created"), replacing any SnackBar shown.
void showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
