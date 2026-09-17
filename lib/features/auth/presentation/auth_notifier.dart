import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/network/http_error_handler.dart';
import '../../../core/storage/login_credentials_store.dart';
import '../../../core/storage/session_store.dart';

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SessionStore(const FlutterSecureStorage());
});

final loginCredentialsStoreProvider = Provider<LoginCredentialsStore>((ref) {
  return LoginCredentialsStore(const FlutterSecureStorage());
});

class AuthState {
  final bool loading;
  final bool loggedIn;
  final String? error;
  final int? userId; // ✅ Agregado para aislar datos por usuario
  final bool isSuperadmin;
  final String? username;
  final String? fullName;
  final String? dni;

  const AuthState({
    this.loading = false,
    this.loggedIn = false,
    this.error,
    this.userId,
    this.isSuperadmin = false,
    this.username,
    this.fullName,
    this.dni,
  });

  AuthState copyWith({
    bool? loading,
    bool? loggedIn,
    String? error,
    int? userId,
    bool? isSuperadmin,
    String? username,
    String? fullName,
    String? dni,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      loggedIn: loggedIn ?? this.loggedIn,
      error: error,
      userId: userId ?? this.userId,
      isSuperadmin: isSuperadmin ?? this.isSuperadmin,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      dni: dni ?? this.dni,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // ✅ al arrancar, intenta entrar sin login si la sesión offline sigue válida
    _bootstrap();
    return const AuthState(loading: true);
  }

  Future<void> _bootstrap() async {
    try {
      final sessionStore = ref.read(sessionStoreProvider);
      final ok = await sessionStore.isOfflineSessionValid();
      final userId = ok ? await sessionStore.getUserId() : null;
      final isSuperadmin = ok ? await sessionStore.getIsSuperadmin() : false;
      var username = ok ? await sessionStore.getUsername() : null;
      final fullName = ok ? await sessionStore.getFullName() : null;
      final dni = ok ? await sessionStore.getDni() : null;
      if (ok && (username == null || username.trim().isEmpty)) {
        username =
            (await ref
                    .read(loginCredentialsStoreProvider)
                    .getSavedCredentials())
                ?.username;
      }
      state = state.copyWith(
        loading: false,
        loggedIn: ok,
        error: null,
        userId: userId,
        isSuperadmin: isSuperadmin,
        username: username,
        fullName: fullName,
        dni: dni,
      );
    } catch (e, st) {
      state = state.copyWith(
        loading: false,
        loggedIn: false,
        error: HttpErrorHandler.toUserMessage(e, st),
      );
    }
  }

  Future<void> login(
    String username,
    String password, {
    bool rememberCredentials = false,
  }) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final repo = ref.read(authRepoProvider);
      final result = await repo.login(username, password);

      // ✅ PASO 7: guardar “sesión offline” (30 días)
      await ref
          .read(sessionStoreProvider)
          .saveOfflineSession(
            userId: result.userId,
            isSuperadmin: result.isSuperadmin,
            username: result.username ?? username,
            fullName: result.fullName,
            dni: result.dni,
          );
      final credentialsStore = ref.read(loginCredentialsStoreProvider);
      if (rememberCredentials) {
        await credentialsStore.save(username: username, password: password);
      } else {
        await credentialsStore.clear();
      }

      state = state.copyWith(
        loading: false,
        loggedIn: true,
        userId: result.userId,
        isSuperadmin: result.isSuperadmin,
        username: result.username ?? username,
        fullName: result.fullName,
        dni: result.dni,
      );
    } catch (e, st) {
      state = state.copyWith(
        loading: false,
        error: HttpErrorHandler.toUserMessage(e, st),
      );
    }
  }

  Future<void> logout() async {
    await ref.read(authRepoProvider).logout();
    await ref.read(sessionStoreProvider).clear(); // ✅ limpia sesión offline
    state = const AuthState(); // ✅ se limpia el userId automáticamente
  }
}
