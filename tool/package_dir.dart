// Prints the root directory of a resolved package: dart run tool/package_dir.dart drift
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final config = jsonDecode(
    File('.dart_tool/package_config.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final packages = (config['packages']! as List).cast<Map<String, Object?>>();
  final pkg = packages.firstWhere((p) => p['name'] == args.single);
  final root = Uri.parse(pkg['rootUri']! as String);
  stdout.write(
    Directory.fromUri(
      File('.dart_tool/package_config.json').uri.resolve(root.toString()),
    ).path,
  );
}
