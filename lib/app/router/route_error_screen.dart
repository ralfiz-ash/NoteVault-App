import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({required this.location, super.key});

  final Uri location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No page exists at "$location".'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Back to start'),
            ),
          ],
        ),
      ),
    );
  }
}
