import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Retorna un map listo para meter en header:
  /// {lat, lon, gpsAccuracy, gpsDate}
  /// Si no se pudo obtener (sin permisos / gps apagado / timeout), retorna null.
  Future<Map<String, dynamic>?> tryGetHeaderGeo({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    // 1) GPS activo?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // 2) Permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    // 3) Obtener fix (con timeout)
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(timeout);

      return {
        'lat': pos.latitude,
        'lon': pos.longitude,
        'gpsAccuracy': pos.accuracy,
        'gpsDate': DateTime.now().toIso8601String(),
      };
    } catch (_) {
      // fallback opcional: last known
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last == null) return null;
        return {
          'lat': last.latitude,
          'lon': last.longitude,
          'gpsAccuracy': last.accuracy,
          'gpsDate': DateTime.now().toIso8601String(),
        };
      } catch (_) {
        return null;
      }
    }
  }

  /// Stream de ubicación en tiempo real (para mapa).
  /// distanceFilter: metros mínimos para emitir (5 = cada ~5m).
  Stream<Map<String, dynamic>> watchPositionStream({double distanceFilter = 5}) async* {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final p = await Geolocator.requestPermission();
      if (p != LocationPermission.whileInUse && p != LocationPermission.always) return;
    } else if (permission == LocationPermission.deniedForever) return;

    await for (final pos in Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter.toInt(),
      ),
    )) {
      yield {
        'lat': pos.latitude,
        'lon': pos.longitude,
        'gpsAccuracy': pos.accuracy,
      };
    }
  }
}
