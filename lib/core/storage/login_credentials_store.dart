import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SavedCredentials {
  final String username;
  final String password;

  const SavedCredentials({
    required this.username,
    required this.password,
  });
}

class LoginCredentialsStore {
  static const _kUsername = 'login.username';
  static const _kPassword = 'login.password';

  final FlutterSecureStorage storage;
  const LoginCredentialsStore(this.storage);

  Future<void> save({
    required String username,
    required String password,
  }) async {
    await storage.write(key: _kUsername, value: username);
    await storage.write(key: _kPassword, value: password);
  }

  Future<SavedCredentials?> getSavedCredentials() async {
    final username = await storage.read(key: _kUsername);
    final password = await storage.read(key: _kPassword);
    if (username == null || password == null) return null;
    return SavedCredentials(username: username, password: password);
  }

  Future<void> clear() async {
    await storage.delete(key: _kUsername);
    await storage.delete(key: _kPassword);
  }
}
