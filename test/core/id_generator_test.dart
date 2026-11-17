import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/utils/id_generator.dart';

void main() {
  test('UuidV4Generator makes unique, well-formed v4 UUIDs', () {
    final generator = UuidV4Generator();
    final ids = {for (var i = 0; i < 500; i++) generator.newId()};

    expect(ids, hasLength(500));
    final pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    expect(ids.every(pattern.hasMatch), isTrue);
  });
}
