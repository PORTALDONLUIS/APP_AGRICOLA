import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Logger que escribe errores en donluis_errors.log
class FileLogger {
  FileLogger._();

  static File? _logFile;
  static final List<String> _buffer = [];
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/donluis_errors.log');
      _initialized = true;
      for (final line in _buffer) {
        await _append(line);
      }
      _buffer.clear();
    } catch (e) {
      debugPrint('FileLogger init error: $e');
    }
  }

  static Future<void> _append(String line) async {
    try {
      final file = _logFile;
      if (file == null) {
        _buffer.add(line);
        return;
      }
      final timestamp = DateTime.now().toIso8601String();
      final entry = '[$timestamp] $line\n';
      await file.writeAsString(entry, mode: FileMode.append);
    } catch (e) {
      debugPrint('FileLogger _append error: $e');
    }
  }

  static Future<void> error(String message, [Object? error, StackTrace? stackTrace]) async {
    final sb = StringBuffer('ERROR $message');
    if (error != null) sb.write('\n  $error');
    if (stackTrace != null) sb.write('\n$stackTrace');
    await _append(sb.toString());
    debugPrint(sb.toString());
  }

  static Future<void> warning(String message) async {
    await _append('WARNING $message');
    debugPrint('WARNING $message');
  }

  static void logError(String message, [Object? error, StackTrace? stackTrace]) {
    final sb = StringBuffer('ERROR $message');
    if (error != null) sb.write('\n  $error');
    if (stackTrace != null) sb.write('\n$stackTrace');
    _append(sb.toString());
    debugPrint(sb.toString());
  }

  /// Ruta del archivo de log (útil para mostrar al usuario).
  static Future<String?> getLogPath() async {
    await init();
    return _logFile?.path;
  }
}
