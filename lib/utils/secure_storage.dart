import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SecureStorage {

  final storage = const FlutterSecureStorage();

  final String _keyAccessToken = 'accessToken';
  final String _keyRefreshToken = 'refreshToken';
  final String _keyFCMToken = 'FCMToken';
  final String _broName = 'broName';
  final String _bromotion = 'bromotion';
  final String _password = 'password';
  final String _email = 'email';

  Future setAccessToken(String accessToken) async {
    await storage.write(key: _keyAccessToken, value: accessToken);
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: _keyAccessToken);
  }

  Future setRefreshToken(String refreshToken) async {
    await storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: _keyRefreshToken);
  }

  Future setFCMToken(String fcmToken) async {
    await storage.write(key: _keyFCMToken, value: fcmToken);
  }

  Future<String?> getFCMToken() async {
    return await storage.read(key: _keyFCMToken);
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

  Future logout() async {
    await storage.write(key: _keyAccessToken, value: null);
    await storage.write(key: _keyRefreshToken, value: null);
    await storage.write(key: _broName, value: null);
    await storage.write(key: _bromotion, value: null);
    await storage.write(key: _password, value: null);
    await storage.write(key: _email, value: null);
  }
}
