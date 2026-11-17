import 'package:flutter/material.dart';

/// Keeps page content at a readable width on wide screens (web, tablets),
/// centred at the top; no effect on phones.
class ContentWidth extends StatelessWidget {
  const ContentWidth({required this.child, this.maxWidth = 760, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
