import 'package:dio/dio.dart';

import '../log/file_logger.dart';

/// Mapeo de errores HTTP técnicos a mensajes amigables para el usuario.
class HttpErrorHandler {
  HttpErrorHandler._();

  /// Convierte un error en mensaje amigable, logueando el detalle técnico.
  /// Usar en catch (e, st) para mostrar solo mensaje amigable en la UI.
  static String toUserMessage(Object error, [StackTrace? stackTrace]) {
    final friendly = _mapToFriendly(error);
    _logTechnical(error, stackTrace);
    return friendly;
  }

  /// Solo mapea a mensaje amigable (sin loguear). Útil si ya se logueó en otro sitio.
  static String toUserMessageOnly(Object error) => _mapToFriendly(error);

  static String _mapToFriendly(Object error) {
    if (error is DioException) {
      return _mapDioException(error);
    }
    // Errores genéricos (Exception, etc.)
    final msg = error.toString().toLowerCase();
    if (msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('network') ||
        msg.contains('host')) {
      return 'Problemas de conexión. Revisa tu internet.';
    }
    if (msg.contains('timeout')) {
      return 'Tardó demasiado. Revisa tu conexión e intenta de nuevo.';
    }
    return 'Ocurrió un error inesperado.';
  }

  static String _mapDioException(DioException err) {
    // Timeout y problemas de conexión
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tardó demasiado. Revisa tu conexión e intenta de nuevo.';
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return 'Problemas de conexión. Revisa tu internet.';
      case DioExceptionType.badResponse:
        return _mapStatusCode(err.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Solicitud cancelada.';
      case DioExceptionType.badCertificate:
        return 'Problema de seguridad en la conexión.';
    }
  }

  static String _mapStatusCode(int? status) {
    switch (status) {
      case 400:
        return 'No se pudo procesar la solicitud.';
      case 401:
        return 'Usuario o contraseña incorrectos.';
      case 403:
        return 'No tienes permisos para esta acción.';
      case 404:
        return 'No se encontró la información solicitada.';
      case 408:
        return 'Tardó demasiado. Intenta de nuevo.';
      case 500:
      case 502:
      case 503:
        return 'Ocurrió un problema interno. Intenta más tarde.';
      default:
        if (status != null && status >= 400 && status < 500) {
          return 'No se pudo completar la solicitud.';
        }
        if (status != null && status >= 500) {
          return 'Ocurrió un problema interno. Intenta más tarde.';
        }
        return 'Ocurrió un error inesperado.';
    }
  }

  static void _logTechnical(Object error, [StackTrace? stackTrace]) {
    String endpoint = '';
    int? status;
    String? body;

    if (error is DioException) {
      endpoint = '${error.requestOptions.method} ${error.requestOptions.uri}';
      status = error.response?.statusCode;
      try {
        body = error.response?.data?.toString();
      } catch (_) {}
    }

    final sb = StringBuffer('HTTP_ERROR');
    sb.write(' | endpoint: $endpoint');
    if (status != null) sb.write(' | status: $status');
    if (body != null && body.isNotEmpty) {
      final truncated = body.length > 500 ? '${body.substring(0, 500)}...' : body;
      sb.write(' | body: $truncated');
    }
    sb.write(' | exception: $error');
    if (stackTrace != null) sb.write('\n$stackTrace');

    FileLogger.logError(sb.toString());
  }
}
