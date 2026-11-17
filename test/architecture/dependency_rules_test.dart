import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the dependency direction described in docs/architecture.md:
///
///   presentation -> domain <- data        (core is usable by everyone)
///
/// Runs against the source files, so a bad import fails `flutter test`.
void main() {
  final libDir = Directory('lib');
  final files = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  final importPattern = RegExp(
    r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );

  /// Imports of [file] as normalized `lib/...` paths, or the raw
  /// `package:`/`dart:` URI for external ones.
  List<String> importsOf(File file) {
    final result = <String>[];
    for (final m in importPattern.allMatches(file.readAsStringSync())) {
      final uri = m.group(1)!;
      if (uri.startsWith('package:notevalult/')) {
        result.add('lib/${uri.substring('package:notevalult/'.length)}');
      } else if (uri.contains(':')) {
        result.add(uri);
      } else {
        final resolved = file.uri.resolve(uri).toFilePath();
        final idx = resolved.lastIndexOf('lib/');
        result.add(idx >= 0 ? resolved.substring(idx) : resolved);
      }
    }
    return result;
  }

  // lib/features/<feature>/<layer>/...
  ({String feature, String layer})? place(String path) {
    final parts = path.split('/');
    if (parts.length >= 4 && parts[0] == 'lib' && parts[1] == 'features') {
      return (feature: parts[2], layer: parts[3]);
    }
    return null;
  }

  bool isFlutter(String i) =>
      i.startsWith('package:flutter/') || i == 'dart:ui';
  bool isRiverpod(String i) =>
      i.startsWith('package:flutter_riverpod') ||
      i.startsWith('package:riverpod') ||
      i.startsWith('package:hooks_riverpod');
  bool isFirebase(String i) =>
      i.startsWith('package:firebase_') ||
      i.startsWith('package:cloud_firestore') ||
      i.startsWith('package:google_sign_in');
  bool isInfra(String i) =>
      isFirebase(i) ||
      i.startsWith('package:sqflite') ||
      i.startsWith('package:drift') ||
      i.startsWith('package:isar') ||
      i.startsWith('package:hive') ||
      i.startsWith('package:shared_preferences') ||
      i.startsWith('package:connectivity_plus');

  final violations = <String>[];
  void report(File f, String imp, String rule) =>
      violations.add('${f.path} imports $imp  ($rule)');

  for (final file in files) {
    final path = file.path;
    final p = place(path);
    final isCore = path.startsWith('lib/core/');

    for (final imp in importsOf(file)) {
      final target = imp.startsWith('lib/') ? place(imp) : null;

      if (isCore) {
        if (imp.startsWith('lib/features/') || imp.startsWith('lib/app/')) {
          report(file, imp, 'core must not depend on features or app');
        }
        continue;
      }
      if (p == null) continue;
      // Feature presentation may read the DI providers in lib/app/di (typed
      // by domain abstractions) and the route path constants; nothing else
      // in a feature may touch app/.
      final allowedFromPresentation =
          imp.startsWith('lib/app/di/') ||
          imp == 'lib/app/router/app_routes.dart';
      if (imp.startsWith('lib/app/') &&
          !(allowedFromPresentation && p.layer == 'presentation')) {
        report(
          file,
          imp,
          'features may only use app/di and app_routes, from presentation',
        );
      }

      switch (p.layer) {
        case 'domain':
          if (imp.startsWith('lib/core/database/') ||
              imp.startsWith('lib/core/firebase/') ||
              imp == 'lib/firebase_options.dart') {
            report(file, imp, 'domain must not use the database or Firebase');
          }
          if (isFlutter(imp) || isRiverpod(imp) || isInfra(imp)) {
            report(file, imp, 'domain must be pure Dart');
          }
          if (target != null && target.layer != 'domain') {
            report(file, imp, 'domain may only import domain');
          }
        case 'data':
          if (isFlutter(imp) || isRiverpod(imp)) {
            report(file, imp, 'data must not use Flutter or Riverpod');
          }
          if (target != null) {
            if (target.layer == 'presentation') {
              report(file, imp, 'data must not import presentation');
            }
            if (target.layer == 'data' && target.feature != p.feature) {
              report(file, imp, 'data must not import another feature\'s data');
            }
          }
        case 'presentation':
          if (imp.startsWith('lib/core/database/') ||
              imp.startsWith('lib/core/firebase/') ||
              imp == 'lib/firebase_options.dart') {
            report(
              file,
              imp,
              'presentation must not use the database or Firebase',
            );
          }
          if (isInfra(imp)) {
            report(file, imp, 'presentation must not use infrastructure SDKs');
          }
          if (target != null) {
            if (target.layer == 'data') {
              report(file, imp, 'presentation must not import data');
            }
            // Another feature's providers/state are its public presentation
            // API (e.g. the notes editor uses the folders list); its screens
            // and widgets are not.
            final isProviderApi =
                imp.contains('/presentation/providers/') ||
                imp.contains('/presentation/state/');
            if (target.layer == 'presentation' &&
                target.feature != p.feature &&
                !isProviderApi) {
              report(
                file,
                imp,
                'presentation must not import another feature\'s screens/widgets',
              );
            }
          }
      }
    }
  }

  test('layers respect the dependency direction', () {
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('every feature has data, domain and presentation layers', () {
    final features = Directory('lib/features')
        .listSync()
        .whereType<Directory>();
    expect(features, isNotEmpty);
    for (final feature in features) {
      for (final layer in ['data', 'domain', 'presentation']) {
        expect(
          Directory('${feature.path}/$layer').existsSync(),
          isTrue,
          reason: '${feature.path} is missing $layer/',
        );
      }
    }
  });
}
