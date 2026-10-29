import 'dart:async';
import 'package:dio/dio.dart';

import '../storage/token_store.dart';

enum SessionRefreshStatus { refreshed, unavailable, rejected }

class DioClient {
  final Dio dio;
  final TokenStore tokenStore;
  final Future<void> Function()? onSessionExpired;

  // evita que 10 requests a la vez disparen 10 refresh
  Completer<void>? _refreshCompleter;

  DioClient({
    required String baseUrl,
    required this.tokenStore,
    this.onSessionExpired,
  })
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;

          final isAuthEndpoint =
              path.contains('/api/auth/login') ||
              path.contains('/api/auth/refresh');

          // ✅ Para login/refresh: NO mandes Authorization
          if (isAuthEndpoint) {
            options.headers.remove('Authorization');
            return handler.next(options);
          }

          // ✅ Para el resto: añade token si existe
          final token = await tokenStore.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            options.headers.remove('Authorization');
          }



          return handler.next(options);
        },

        onError: (DioException err, handler) async {
          final status = err.response?.statusCode;
          final req = err.requestOptions;

          final isAuthEndpoint =
              req.path.contains('/api/auth/login') ||
              req.path.contains('/api/auth/refresh');

          // ✅ Si el error es 401 y NO es login/refresh, intenta refrescar
          if (status == 401 &&
              !isAuthEndpoint &&
              req.extra['retried'] != true) {
            try {
              await _refreshTokenIfNeeded();

              // marcar que ya reintentamos 1 vez
              final newReq = _copyRequestOptions(req);
              newReq.extra['retried'] = true;

              // reintentar con el nuevo token
              final access = await tokenStore.getAccessToken();
              if (access != null && access.isNotEmpty) {
                newReq.headers['Authorization'] = 'Bearer $access';
              }

              final response = await dio.fetch(newReq);
              return handler.resolve(response);
            } catch (refreshError) {
              // Un problema de red no invalida la sesión offline. Solo se
              // limpian credenciales si el servidor rechazó el refresh.
              if (_refreshWasRejected(refreshError)) {
                await tokenStore.clear();
                await onSessionExpired?.call();
              }
              return handler.next(err);
            }
          }

          if (status == 401 && !isAuthEndpoint && req.extra['retried'] == true) {
            await tokenStore.clear();
            await onSessionExpired?.call();
          }

          return handler.next(err);
        },
      ),
    );
  }

  Future<void> _refreshTokenIfNeeded() async {
    // si ya hay refresh en progreso, espera
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<void>();

    try {
      final refresh = await tokenStore.getRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        throw Exception('No refresh token');
      }

      // ⚠️ Usa un Dio “limpio” para refresh (sin interceptors)
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: dio.options.connectTimeout,
          receiveTimeout: dio.options.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final r = await refreshDio.post(
        '/api/auth/refresh/',
        data: {'refresh': refresh},
      );

      // Ajusta estas keys según tu backend (simplejwt suele devolver: access, refresh opcional)
      final data = r.data as Map;
      final newAccess = data['access'] as String?;
      final newRefresh = (data['refresh'] as String?) ?? refresh;

      if (newAccess == null || newAccess.isEmpty) {
        throw Exception('Refresh did not return access token');
      }

      await tokenStore.saveTokens(access: newAccess, refresh: newRefresh);

      _refreshCompleter!.complete();
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Renueva la sesión al abrir la app, antes de sincronizar catálogos o
  /// muestras. Si no hay señal se conserva el modo offline; un refresh
  /// rechazado sí requiere un nuevo inicio de sesión.
  Future<SessionRefreshStatus> refreshSessionOnAppStart() async {
    try {
      await _refreshTokenIfNeeded();
      return SessionRefreshStatus.refreshed;
    } catch (error) {
      return _refreshWasRejected(error)
          ? SessionRefreshStatus.rejected
          : SessionRefreshStatus.unavailable;
    }
  }

  bool _refreshWasRejected(Object error) {
    if (error is StateError) return true;
    if (error is DioException) {
      final status = error.response?.statusCode;
      return status == 400 || status == 401;
    }
    return false;
  }

  // copia RequestOptions para poder reintentar
  RequestOptions _copyRequestOptions(RequestOptions r) {
    return RequestOptions(
      path: r.path,
      method: r.method,
      baseUrl: r.baseUrl,
      data: r.data is FormData ? (r.data as FormData).clone() : r.data,
      queryParameters: Map<String, dynamic>.from(r.queryParameters),
      headers: Map<String, dynamic>.from(r.headers),
      extra: Map<String, dynamic>.from(r.extra),
      contentType: r.contentType,
      responseType: r.responseType,
      followRedirects: r.followRedirects,
      receiveDataWhenStatusError: r.receiveDataWhenStatusError,
      validateStatus: r.validateStatus,
      sendTimeout: r.sendTimeout,
      receiveTimeout: r.receiveTimeout,
      connectTimeout: r.connectTimeout,
    );
  }
}
