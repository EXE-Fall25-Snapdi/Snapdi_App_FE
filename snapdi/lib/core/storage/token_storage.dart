import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing and retrieving authentication tokens using Flutter Secure Storage
class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _isLoggedInKey = 'is_logged_in';

  static TokenStorage? _instance;

  // Configure secure storage with encryption options
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(useBackwardCompatibility: true),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static TokenStorage get instance {
    _instance ??= TokenStorage._internal();
    return _instance!;
  }

  TokenStorage._internal();

  /// Store authentication tokens after successful login/signup
  Future<bool> storeTokens({
    required String accessToken,
    required String refreshToken,
    int? userId,
  }) async {
    try {
      await Future.wait([
        _secureStorage.write(key: _accessTokenKey, value: accessToken),
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
        _secureStorage.write(key: _isLoggedInKey, value: 'true'),
        if (userId != null)
          _secureStorage.write(key: _userIdKey, value: userId.toString()),
      ]);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Retrieve the stored access token
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Retrieve the stored refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Retrieve the stored user ID
  Future<int?> getUserId() async {
    try {
      final userIdString = await _secureStorage.read(key: _userIdKey);
      return userIdString != null ? int.tryParse(userIdString) : null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedInString = await _secureStorage.read(key: _isLoggedInKey);
      return isLoggedInString == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Update only the access token (useful for token refresh)
  Future<bool> updateAccessToken(String accessToken) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all stored authentication data (logout)
  Future<bool> clearTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _userIdKey),
        _secureStorage.delete(key: _isLoggedInKey),
      ]);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all stored tokens and user data
  Future<AuthTokens?> getAllTokens() async {
    try {
      final results = await Future.wait([
        _secureStorage.read(key: _accessTokenKey),
        _secureStorage.read(key: _refreshTokenKey),
        _secureStorage.read(key: _userIdKey),
        _secureStorage.read(key: _isLoggedInKey),
      ]);

      final accessToken = results[0];
      final refreshToken = results[1];
      final userIdString = results[2];
      final isLoggedInString = results[3];

      final userId = userIdString != null ? int.tryParse(userIdString) : null;
      final isLoggedIn = isLoggedInString == 'true';

      if (accessToken != null && refreshToken != null && isLoggedIn) {
        return AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: userId,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if tokens exist (without validating expiration)
  Future<bool> hasTokens() async {
    try {
      final results = await Future.wait([
        _secureStorage.read(key: _accessTokenKey),
        _secureStorage.read(key: _refreshTokenKey),
        _secureStorage.read(key: _isLoggedInKey),
      ]);

      final hasAccess = results[0] != null && results[0]!.isNotEmpty;
      final hasRefresh = results[1] != null && results[1]!.isNotEmpty;
      final isLoggedIn = results[2] == 'true';

      return hasAccess && hasRefresh && isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  /// Clear all stored data (including non-auth data)
  Future<bool> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Data class to hold authentication tokens and user data
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final int? userId;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
  });

  @override
  String toString() {
    return 'AuthTokens{userId: $userId, hasAccessToken: ${accessToken.isNotEmpty}, hasRefreshToken: ${refreshToken.isNotEmpty}}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthTokens &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          userId == other.userId;

  @override
  int get hashCode =>
      accessToken.hashCode ^ refreshToken.hashCode ^ userId.hashCode;
}
