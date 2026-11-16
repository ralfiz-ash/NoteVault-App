/// A single application action. Pure Dart: no Flutter, Firebase or Riverpod.
abstract interface class UseCase<Output, Input> {
  Output call(Input input);
}

/// Marker for use cases that take no input.
class NoParams {
  const NoParams();
}
