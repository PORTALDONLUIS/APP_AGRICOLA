import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  final FlutterSecureStorage storage;

  const TokenStore(this.storage);

  // =========================
  // Keys (todas juntas arriba)
  // =========================
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';

  // 👉 NUEVAS keys para sesión offline
  static const _kOfflineUntil = 'offline_session_until';
  static const _kUserId = 'user_id';

  // =========================
  // Tokens JWT
  // =========================
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await storage.write(key: _kAccessToken, value: access);
    await storage.write(key: _kRefreshToken, value: refresh);
  }

  Future<String?> getAccessToken() async {
    return storage.read(key: _kAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return storage.read(key: _kRefreshToken);
  }

  // =========================
  // Sesión OFFLINE (login persistente)
  // =========================

  /// Guarda hasta cuándo es válida la sesión offline
  Future<void> saveOfflineSessionUntil(DateTime until) async {
    await storage.write(key: _kOfflineUntil, value: until.toIso8601String());
  }

  /// Obtiene la fecha de expiración de la sesión offline
  Future<DateTime?> getOfflineSessionUntil() async {
    final value = await storage.read(key: _kOfflineUntil);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Indica si la sesión offline sigue siendo válida
  Future<bool> hasValidOfflineSession() async {
    final userId = await getUserId();
    final refresh = await getRefreshToken();
    return userId != null &&
        userId > 0 &&
        refresh != null &&
        refresh.isNotEmpty;
  }

  // =========================
  // Usuario
  // =========================
  Future<void> saveUserId(int userId) async {
    await storage.write(key: _kUserId, value: userId.toString());
  }

  Future<int?> getUserId() async {
    final value = await storage.read(key: _kUserId);
    if (value == null) return null;
    return int.tryParse(value);
  }

  // =========================
  // Limpieza total (logout)
  // =========================
  Future<void> clear() async {
    await storage.delete(key: _kAccessToken);
    await storage.delete(key: _kRefreshToken);
    await storage.delete(key: _kOfflineUntil);
    await storage.delete(key: _kUserId);
  }
}
