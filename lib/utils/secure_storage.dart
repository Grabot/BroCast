import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SecureStorage {

  final storage = const FlutterSecureStorage();

  final String _keyAccessToken = 'accessToken';
  final String _keyRefreshToken = 'refreshToken';
  final String _keyAccessTokenExpiration = 'accessTokenExpiration';
  final String _keyRefreshTokenExpiration = 'refreshTokenExpiration';
  final String _keyFCMToken = 'FCMToken';
  final String _origin = 'origin';
  final String _broId = 'broId';
  final String _broName = 'broName';
  final String _bromotion = 'bromotion';
  final String _password = 'password';
  final String _email = 'email';
  final String _avatar = 'avatar';
  final String _avatarDefault = 'avatarDefault';

  Future setAccessToken(String accessToken) async {
    await storage.write(key: _keyAccessToken, value: accessToken);
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: _keyAccessToken);
  }

  Future setAccessTokenExpiration(int expiration) async {
    await storage.write(key: _keyAccessTokenExpiration, value: expiration.toString());
  }

  Future<int?> getAccessTokenExpiration() async {
    String? expiration = await storage.read(key: _keyAccessTokenExpiration);
    return expiration != null ? int.parse(expiration) : null;
  }

  Future setRefreshToken(String refreshToken) async {
    await storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: _keyRefreshToken);
  }

  Future setRefreshTokenExpiration(int expiration) async {
    await storage.write(key: _keyRefreshTokenExpiration, value: expiration.toString());
  }

  Future<int?> getRefreshTokenExpiration() async {
    String? expiration = await storage.read(key: _keyRefreshTokenExpiration);
    return expiration != null ? int.parse(expiration) : null;
  }

  Future setFCMToken(String fcmToken) async {
    await storage.write(key: _keyFCMToken, value: fcmToken);
  }

  Future<String?> getFCMToken() async {
    return await storage.read(key: _keyFCMToken);
  }

  Future setBroId(String broId) async {
    await storage.write(key: _broId, value: broId);
  }

  Future<String?> getBroId() async {
    return await storage.read(key: _broId);
  }

  Future setOrigin(bool broOrigin) async {
    await storage.write(key: _origin, value: broOrigin.toString());
  }

  Future<bool?> getOrigin() async {
    String? origin = await storage.read(key: _origin);
    return origin != null ? origin == 'true' : null;
  }

  Future setBroName(String broName) async {
    await storage.write(key: _broName, value: broName);
  }

  Future<String?> getBroName() async {
    return await storage.read(key: _broName);
  }

  Future setBromotion(String bromotion) async {
    await storage.write(key: _bromotion, value: bromotion);
  }

  Future<String?> getBromotion() async {
    return await storage.read(key: _bromotion);
  }

  Future setPassword(String password) async {
    await storage.write(key: _password, value: password);
  }

  Future<String?> getPassword() async {
    return await storage.read(key: _password);
  }

  Future setEmail(String email) async {
    await storage.write(key: _email, value: email);
  }

  Future<String?> getEmail() async {
    return await storage.read(key: _email);
  }

  Future setAvatar(String avatar) async {
    await storage.write(key: _avatar, value: avatar);
  }

  Future<String?> getAvatar() async {
    return await storage.read(key: _avatar);
  }

  Future setAvatarDefault(String avatarDefault) async {
    await storage.write(key: _avatarDefault, value: avatarDefault);
  }

  Future<String?> getAvatarDefault() async {
    return await storage.read(key: _avatarDefault);
  }

  Future logout() async {
    await storage.write(key: _broName, value: null);
    await storage.write(key: _bromotion, value: null);
    await storage.write(key: _password, value: null);
    await storage.write(key: _email, value: null);
    await storage.write(key: _avatar, value: null);
    await storage.write(key: _avatarDefault, value: null);
    await storage.write(key: _keyFCMToken, value: null);
    await storage.write(key: _origin, value: null);
    // We exclude the broId because it's used to determine if a different person logged back in.
    // await storage.write(key: _broId, value: null);

    await storage.write(key: _keyAccessToken, value: null);
    await storage.write(key: _keyRefreshToken, value: null);
    await storage.write(key: _keyAccessTokenExpiration, value: null);
    await storage.write(key: _keyRefreshTokenExpiration, value: null);
  }
}
