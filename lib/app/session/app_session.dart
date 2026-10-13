import 'package:flutter/foundation.dart';
import 'package:flutter_clean_starter/core/constants/storage_keys.dart';
import 'package:flutter_clean_starter/core/storage/secure_storage.dart';
import 'package:injectable/injectable.dart';

/// App-level authentication state: whether a session token exists.
///
/// This is deliberately minimal — it powers the router's auth guard and the
/// `AuthTokenInterceptor`. Replace [signIn] with a real `auth` feature
/// (repository + use cases) when your backend has one; keep this class as
/// the single source of truth the router listens to.
@lazySingleton
class AppSession extends ChangeNotifier {
  /// Creates the session backed by [_storage].
  AppSession(this._storage);

  final SecureStorage _storage;

  String? _accessToken;

  /// Whether a user is signed in.
  bool get isAuthenticated => _accessToken != null;

  /// Loads a persisted token at startup.
  @PostConstruct(preResolve: true)
  Future<void> restore() async {
    _accessToken = await _storage.read(StorageKeys.accessToken);
  }

  /// The current access token, read by the HTTP auth interceptor.
  Future<String?> readAccessToken() async => _accessToken;

  /// Stores [accessToken] and notifies listeners (the router).
  Future<void> signIn(String accessToken) async {
    await _storage.write(StorageKeys.accessToken, accessToken);
    _accessToken = accessToken;
    notifyListeners();
  }

  /// Clears the session and notifies listeners.
  Future<void> signOut() async {
    if (_accessToken == null) return;
    await _storage.delete(StorageKeys.accessToken);
    _accessToken = null;
    notifyListeners();
  }
}
