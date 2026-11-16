import 'package:flutter/material.dart';

/// Temporary start screen so the routing foundation has something to show.
/// Replaced by the real notes screen in a later phase.
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NoteVault')),
      body: const Center(child: Text('Foundation ready')),
    );
  }
}
