import 'dart:math';

/// Creates stable, globally unique ids. Ids are generated on the device so
/// records can be created offline and synced later without id clashes.
abstract interface class IdGenerator {
  String newId();
}

/// Random (version 4) UUIDs.
class UuidV4Generator implements IdGenerator {
  UuidV4Generator([Random? random]) : _random = random ?? Random.secure();

  final Random _random;

  @override
  String newId() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC 4122 variant
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
