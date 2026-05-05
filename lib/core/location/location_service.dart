import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

enum GeoLookupFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  lowAccuracy,
  staleLocation,
  unavailable,
}

class GeoLookupResult {
  final Map<String, dynamic>? geo;
  final GeoLookupFailure? failure;
  final String source;
  final double? accuracyMeters;
  final Duration? age;

  const GeoLookupResult({
    required this.geo,
    required this.failure,
    required this.source,
    this.accuracyMeters,
    this.age,
  });

  bool get isSuccess => geo != null;

  String get userMessage {
    switch (failure) {
      case GeoLookupFailure.serviceDisabled:
        return 'Activa el GPS para ubicar el lote.';
      case GeoLookupFailure.permissionDenied:
      case GeoLookupFailure.permissionDeniedForever:
        return 'La app no tiene permiso de ubicación para ubicar el lote.';
      case GeoLookupFailure.timeout:
        return 'El GPS aún no responde. Espera unos segundos y vuelve a intentar.';
      case GeoLookupFailure.lowAccuracy:
        return 'El GPS aún no tiene precisión suficiente para ubicar el lote.';
      case GeoLookupFailure.staleLocation:
        return 'La ubicación disponible es antigua. Espera a que el GPS se actualice.';
      case GeoLookupFailure.unavailable:
      case null:
        return 'No se pudo obtener una ubicación confiable.';
    }
  }
}

class _GeoSample {
  final Position position;
  final DateTime acquiredAt;
  final String source;

  const _GeoSample(this.position, this.acquiredAt, this.source);
}

class LocationService with WidgetsBindingObserver {
  LocationService() {
    WidgetsBinding.instance.addObserver(this);
  }

  DateTime? _lastResumeAt;
  _GeoSample? _lastAccurateSample;

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _lastResumeAt = DateTime.now();
    }
  }

  DateTime _sampleMoment(_GeoSample sample) => sample.position.timestamp;

  Duration _sampleAge(_GeoSample sample, DateTime now) =>
      now.difference(_sampleMoment(sample));

  void _rememberAccurate(_GeoSample sample, {double maxAccuracyMeters = 30}) {
    final accuracy = sample.position.accuracy;
    if (accuracy.isFinite && accuracy >= 0 && accuracy <= maxAccuracyMeters) {
      _lastAccurateSample = sample;
    }
  }

  Map<String, dynamic> _toGeoMap(_GeoSample sample) {
    final moment = _sampleMoment(sample);
    return {
      'lat': sample.position.latitude,
      'lon': sample.position.longitude,
      'gpsAccuracy': sample.position.accuracy,
      'gpsDate': moment.toIso8601String(),
      'gpsSource': sample.source,
    };
  }

  GeoLookupFailure _failureForSample(
    _GeoSample sample,
    DateTime now, {
    required double maxAccuracyMeters,
    required Duration maxAge,
    DateTime? freshSince,
  }) {
    final accuracy = sample.position.accuracy;
    if (!accuracy.isFinite || accuracy < 0 || accuracy > maxAccuracyMeters) {
      return GeoLookupFailure.lowAccuracy;
    }

    final age = _sampleAge(sample, now);
    if (age > maxAge) {
      return GeoLookupFailure.staleLocation;
    }

    if (freshSince != null && _sampleMoment(sample).isBefore(freshSince)) {
      return GeoLookupFailure.staleLocation;
    }

    return GeoLookupFailure.unavailable;
  }

  bool _isAcceptableSample(
    _GeoSample sample,
    DateTime now, {
    required double maxAccuracyMeters,
    required Duration maxAge,
    DateTime? freshSince,
  }) {
    final failure = _failureForSample(
      sample,
      now,
      maxAccuracyMeters: maxAccuracyMeters,
      maxAge: maxAge,
      freshSince: freshSince,
    );
    return failure != GeoLookupFailure.lowAccuracy &&
        failure != GeoLookupFailure.staleLocation;
  }

  Future<GeoLookupFailure?> _ensureLocationReady() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return GeoLookupFailure.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return GeoLookupFailure.permissionDeniedForever;
      }
      if (permission == LocationPermission.denied) {
        return GeoLookupFailure.permissionDenied;
      }
      return null;
    } catch (_) {
      return GeoLookupFailure.unavailable;
    }
  }

  Future<_GeoSample?> _tryCurrentPosition(Duration timeout) async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(timeout);
      return _GeoSample(pos, DateTime.now(), 'current');
    } catch (_) {
      return null;
    }
  }

  Future<_GeoSample?> _tryLastKnownPosition() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos == null) return null;
      return _GeoSample(pos, DateTime.now(), 'last_known');
    } catch (_) {
      return null;
    }
  }

  Future<_GeoSample?> _waitForStreamFix(
    Duration timeout, {
    required double maxAccuracyMeters,
    required Duration maxAge,
    DateTime? freshSince,
  }) async {
    try {
      return await Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 0,
            ),
          )
          .map((pos) => _GeoSample(pos, DateTime.now(), 'stream'))
          .firstWhere((sample) {
            return _isAcceptableSample(
              sample,
              DateTime.now(),
              maxAccuracyMeters: maxAccuracyMeters,
              maxAge: maxAge,
              freshSince: freshSince,
            );
          })
          .timeout(timeout);
    } catch (_) {
      return null;
    }
  }

  /// Retorna un map listo para meter en header:
  /// {lat, lon, gpsAccuracy, gpsDate}
  /// Si no se pudo obtener (sin permisos / gps apagado / timeout), retorna null.
  ///
  /// **Importante (mapas / trazabilidad):** este método usa
  /// [Geolocator.getCurrentPosition] en el **momento del guardado** de la cartilla.
  /// [watchPositionStream] usa otro flujo de actualizaciones en tiempo real para el
  /// punto azul en el mapa. No hay garantía de igualdad exacta entre ambos: el
  /// usuario puede moverse entre guardados, el GPS oscila (típ. 3–15 m en campo
  /// abierto), y tras el primer guardado la ubicación de la muestra ya no se
  /// sobrescribe al guardar de nuevo ([attachGeo] “pegajoso”).
  Future<Map<String, dynamic>?> tryGetHeaderGeo({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final readinessFailure = await _ensureLocationReady();
    if (readinessFailure != null) {
      return null;
    }

    final current = await _tryCurrentPosition(timeout);
    if (current != null) {
      _rememberAccurate(current);
      return _toGeoMap(current);
    }

    final last = await _tryLastKnownPosition();
    if (last != null) {
      _rememberAccurate(last);
      return _toGeoMap(last);
    }

    return null;
  }

  /// Obtiene una ubicación confiable para detección de lote.
  ///
  /// A diferencia de [tryGetHeaderGeo], aquí sí validamos precisión,
  /// antigüedad y, si la app acaba de volver al foreground, exigimos
  /// un fix más fresco para evitar usar una ubicación vieja.
  Future<GeoLookupResult> tryGetGeoForLoteDetection({
    Duration currentTimeout = const Duration(seconds: 6),
    Duration streamTimeout = const Duration(seconds: 8),
    Duration maxAge = const Duration(minutes: 2),
    double maxAccuracyMeters = 30,
  }) async {
    final readinessFailure = await _ensureLocationReady();
    if (readinessFailure != null) {
      return GeoLookupResult(
        geo: null,
        failure: readinessFailure,
        source: 'permission_check',
      );
    }

    final freshSince = _lastResumeAt;
    GeoLookupFailure? lastFailure;
    _GeoSample? lastRejectedSample;

    final current = await _tryCurrentPosition(currentTimeout);
    if (current != null) {
      final now = DateTime.now();
      if (_isAcceptableSample(
        current,
        now,
        maxAccuracyMeters: maxAccuracyMeters,
        maxAge: maxAge,
        freshSince: freshSince,
      )) {
        _rememberAccurate(current, maxAccuracyMeters: maxAccuracyMeters);
        return GeoLookupResult(
          geo: _toGeoMap(current),
          failure: null,
          source: current.source,
          accuracyMeters: current.position.accuracy,
          age: _sampleAge(current, now),
        );
      }
      lastFailure = _failureForSample(
        current,
        now,
        maxAccuracyMeters: maxAccuracyMeters,
        maxAge: maxAge,
        freshSince: freshSince,
      );
      lastRejectedSample = current;
    } else {
      lastFailure = GeoLookupFailure.timeout;
    }

    final streamed = await _waitForStreamFix(
      streamTimeout,
      maxAccuracyMeters: maxAccuracyMeters,
      maxAge: maxAge,
      freshSince: freshSince,
    );
    if (streamed != null) {
      final now = DateTime.now();
      _rememberAccurate(streamed, maxAccuracyMeters: maxAccuracyMeters);
      return GeoLookupResult(
        geo: _toGeoMap(streamed),
        failure: null,
        source: streamed.source,
        accuracyMeters: streamed.position.accuracy,
        age: _sampleAge(streamed, now),
      );
    }

    final cached = _lastAccurateSample;
    if (cached != null) {
      final now = DateTime.now();
      if (_isAcceptableSample(
        cached,
        now,
        maxAccuracyMeters: maxAccuracyMeters,
        maxAge: maxAge,
        freshSince: freshSince,
      )) {
        return GeoLookupResult(
          geo: _toGeoMap(cached),
          failure: null,
          source: 'cached_${cached.source}',
          accuracyMeters: cached.position.accuracy,
          age: _sampleAge(cached, now),
        );
      }
      lastFailure = _failureForSample(
        cached,
        now,
        maxAccuracyMeters: maxAccuracyMeters,
        maxAge: maxAge,
        freshSince: freshSince,
      );
      lastRejectedSample = cached;
    }

    final lastKnown = await _tryLastKnownPosition();
    if (lastKnown != null) {
      final now = DateTime.now();
      if (_isAcceptableSample(
        lastKnown,
        now,
        maxAccuracyMeters: maxAccuracyMeters,
        maxAge: maxAge,
        freshSince: freshSince,
      )) {
        _rememberAccurate(lastKnown, maxAccuracyMeters: maxAccuracyMeters);
        return GeoLookupResult(
          geo: _toGeoMap(lastKnown),
          failure: null,
          source: lastKnown.source,
          accuracyMeters: lastKnown.position.accuracy,
          age: _sampleAge(lastKnown, now),
        );
      }
      lastFailure = _failureForSample(
        lastKnown,
        now,
        maxAccuracyMeters: maxAccuracyMeters,
        maxAge: maxAge,
        freshSince: freshSince,
      );
      lastRejectedSample = lastKnown;
    }

    final rejectedNow = DateTime.now();
    return GeoLookupResult(
      geo: null,
      failure: lastFailure,
      source: lastRejectedSample?.source ?? 'unknown',
      accuracyMeters: lastRejectedSample?.position.accuracy,
      age: lastRejectedSample == null
          ? null
          : _sampleAge(lastRejectedSample, rejectedNow),
    );
  }

  /// Stream de ubicación en tiempo real (para mapa).
  /// distanceFilter: metros mínimos para emitir (5 = cada ~5m).
  Stream<Map<String, dynamic>> watchPositionStream({
    double distanceFilter = 5,
  }) async* {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final p = await Geolocator.requestPermission();
      if (p != LocationPermission.whileInUse &&
          p != LocationPermission.always) {
        return;
      }
    } else if (permission == LocationPermission.deniedForever) {
      return;
    }

    await for (final pos in Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter.toInt(),
      ),
    )) {
      final sample = _GeoSample(pos, DateTime.now(), 'stream');
      _rememberAccurate(sample);
      yield _toGeoMap(sample);
    }
  }
}
