import 'dart:convert';
import '../../../core/storage/token_store.dart';
import 'auth_remote_ds.dart';

class LoginResult {
  final String access;
  final String refresh;
  final int userId;
  final bool isSuperadmin;

  const LoginResult({
    required this.access,
    required this.refresh,
    required this.userId,
    required this.isSuperadmin,
  });
}

class AuthRepository {
  final AuthRemoteDS remote;
  final TokenStore tokenStore;

  AuthRepository({required this.remote, required this.tokenStore});

  Future<LoginResult> login(String u, String p) async {
    final data = await remote.login(u, p);

    final access = data['access_token'] as String;
    final refresh = data['refresh_token'] as String;

    await tokenStore.saveTokens(access: access, refresh: refresh);

    // ✅ sacamos el userId del JWT access_token (sin backend extra)
    final userId = _extractUserIdFromAccessToken(access);

    await tokenStore.saveUserId(userId);
    await tokenStore.saveOfflineSessionUntil(
      DateTime.now().add(const Duration(days: 7)),
    );

    final userMap = Map<String, dynamic>.from(data['user'] as Map? ?? const {});
    final isSuperadmin = userMap['is_superadmin'] == true;

    return LoginResult(
      access: access,
      refresh: refresh,
      userId: userId,
      isSuperadmin: isSuperadmin,
    );
  }

  Future<void> extendOfflineSession({int days = 7}) async {
    final until = DateTime.now().add(Duration(days: days));
    await tokenStore.saveOfflineSessionUntil(
      until,
    ); // 👈 lo implementas en TokenStore
  }

  Future<void> logout() => tokenStore.clear();
}

// -------- helpers --------

int _extractUserIdFromAccessToken(String jwt) {
  final parts = jwt.split('.');
  if (parts.length != 3) {
    throw Exception('Access token inválido (no es JWT)');
  }

  final payload = parts[1];
  final normalized = base64Url.normalize(payload);
  final decoded = utf8.decode(base64Url.decode(normalized));
  final Map<String, dynamic> json = jsonDecode(decoded);

  // intenta varias claves comunes
  final dynamic v =
      json['user_id'] ?? json['userId'] ?? json['id'] ?? json['sub'];

  if (v is int) return v;
  if (v is String) {
    final n = int.tryParse(v);
    if (n != null) return n;
  }

  throw Exception(
    'No se encontró userId en el JWT (payload: ${json.keys.toList()})',
  );
}
