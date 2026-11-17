/// Source of "now". Inject it instead of calling `DateTime.now()` directly so
/// timestamp behaviour can be tested deterministically.
typedef Clock = DateTime Function();
