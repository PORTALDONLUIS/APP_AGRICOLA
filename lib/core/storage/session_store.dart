import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  static const _kUserId = 'session.userId';
  static const _kOfflineExp = 'session.offlineExpiresAt';
  static const _kIsSuperadmin = 'session.isSuperadmin';

  static const int offlineDays = 30;

  final FlutterSecureStorage storage;
  const SessionStore(this.storage);

  Future<void> saveOfflineSession({
    required int userId,
    required bool isSuperadmin,
  }) async {
    final exp = DateTime.now().add(const Duration(days: offlineDays));
    await storage.write(key: _kUserId, value: userId.toString());
    await storage.write(key: _kOfflineExp, value: exp.toIso8601String());
    await storage.write(
      key: _kIsSuperadmin,
      value: isSuperadmin ? 'true' : 'false',
    );
  }

  Future<bool> isOfflineSessionValid() async {
    final expStr = await storage.read(key: _kOfflineExp);
    if (expStr == null) return false;
    final exp = DateTime.tryParse(expStr);
    if (exp == null) return false;
    return DateTime.now().isBefore(exp);
  }

  Future<int?> getUserId() async {
    final s = await storage.read(key: _kUserId);
    return s == null ? null : int.tryParse(s);
  }

  Future<bool> getIsSuperadmin() async {
    final value = await storage.read(key: _kIsSuperadmin);
    return value == 'true';
  }

  Future<void> extendOfflineSession() async {
    final exp = DateTime.now().add(const Duration(days: offlineDays));
    await storage.write(key: _kOfflineExp, value: exp.toIso8601String());
  }

  Future<void> clear() async {
    await storage.delete(key: _kUserId);
    await storage.delete(key: _kOfflineExp);
    await storage.delete(key: _kIsSuperadmin);
  }
}
