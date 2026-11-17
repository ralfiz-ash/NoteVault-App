/// Network state as the app understands it.
///
/// `connected` means the device has a network interface (Wi-Fi, mobile,
/// ethernet, ...). It does not prove the internet or Firebase is reachable;
/// the sync phase treats failed requests as offline too.
enum ConnectivityStatus {
  connected,
  disconnected,

  /// Not determined yet (startup) or the platform could not tell.
  unknown;

  bool get isConnected => this == ConnectivityStatus.connected;
}
