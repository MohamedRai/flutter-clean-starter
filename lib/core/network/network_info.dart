import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports whether the device has a network connection.
///
/// Note: a connection (Wi-Fi, mobile, ...) does not guarantee that the
/// internet is reachable — a captive portal still counts as connected. Treat
/// `true` as "worth trying", and rely on `NetworkException`s for the truth.
abstract interface class NetworkInfo {
  /// Whether any network interface is currently connected.
  Future<bool> get isConnected;

  /// Emits `true` / `false` whenever connectivity changes.
  Stream<bool> get onConnectivityChanged;
}

/// [NetworkInfo] backed by `connectivity_plus`.
class ConnectivityNetworkInfo implements NetworkInfo {
  /// Creates the implementation around a `Connectivity` instance.
  const ConnectivityNetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async =>
      _isConnected(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_isConnected).distinct();

  static bool _isConnected(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
