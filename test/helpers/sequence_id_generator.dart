import 'package:notevalult/core/utils/id_generator.dart';

/// Deterministic ids: id-1, id-2, ...
class SequenceIdGenerator implements IdGenerator {
  int _next = 1;

  @override
  String newId() => 'id-${_next++}';
}
