import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

enum GeoLookupFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  reducedAccuracy,
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
      case GeoLookupFailure.reducedAccuracy:
        return 'Activa la ubicación precisa para obtener un GPS confiable.';
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
  StreamSubscription<Position>? _warmupSub;
  bool _warmupStarting = false;
  int _warmupClients = 0;
  String? _lastAccuracyStatusName;

  void dispose() {
    _warmupSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _lastResumeAt = DateTime.now();
      _ensureWarmupRunning();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _warmupSub?.cancel();
      _warmupSub = null;
      _warmupStarting = false;
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
      if (_lastAccuracyStatusName != null)
        'gpsAccuracyStatus': _lastAccuracyStatusName,
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

  Future<GeoLookupFailure?> _ensurePreciseLocationReady() async {
    final readinessFailure = await _ensureLocationReady();
    if (readinessFailure != null) return readinessFailure;

    try {
      final status = await Geolocator.getLocationAccuracy();
      _lastAccuracyStatusName = status.name;
      if (status == LocationAccuracyStatus.reduced) {
        return GeoLookupFailure.reducedAccuracy;
      }
    } catch (_) {
      _lastAccuracyStatusName = null;
    }

    return null;
  }

  void startForegroundWarmup() {
    _warmupClients += 1;
    _ensureWarmupRunning();
  }

  void stopForegroundWarmup() {
    if (_warmupClients > 0) {
      _warmupClients -= 1;
    }
    if (_warmupClients == 0) {
      _warmupSub?.cancel();
      _warmupSub = null;
      _warmupStarting = false;
    }
  }

  Future<void> _ensureWarmupRunning() async {
    if (_warmupClients <= 0 || _warmupSub != null || _warmupStarting) return;

    _warmupStarting = true;
    try {
      final readinessFailure = await _ensurePreciseLocationReady();
      if (readinessFailure != null || _warmupClients <= 0) return;

      _warmupSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 0,
            ),
          ).listen(
            (pos) {
              final sample = _GeoSample(pos, DateTime.now(), 'warmup_stream');
              _rememberAccurate(sample, maxAccuracyMeters: 50);
            },
            onError: (_) {
              _warmupSub?.cancel();
              _warmupSub = null;
            },
            cancelOnError: false,
          );
    } finally {
      _warmupStarting = false;
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
    Duration timeout = const Duration(seconds: 4),
    Duration streamTimeout = const Duration(seconds: 4),
    Duration maxAge = const Duration(seconds: 75),
    double maxAccuracyMeters = 35,
  }) async {
    final result = await _tryGetReliableGeo(
      currentTimeout: timeout,
      streamTimeout: streamTimeout,
      maxAge: maxAge,
      maxAccuracyMeters: maxAccuracyMeters,
      allowLastKnown: false,
      preferCached: true,
    );
    return result.geo;
  }

  Future<GeoLookupResult> _tryGetReliableGeo({
    required Duration currentTimeout,
    required Duration streamTimeout,
    required Duration maxAge,
    required double maxAccuracyMeters,
    required bool allowLastKnown,
    required bool preferCached,
  }) async {
    final readinessFailure = await _ensurePreciseLocationReady();
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

    GeoLookupResult? acceptSample(_GeoSample sample, String source) {
      final now = DateTime.now();
      if (_isAcceptableSample(
        sample,
        now,
        maxAccuracyMeters: maxAccuracyMeters,
        maxAge: maxAge,
        freshSince: freshSince,
      )) {
        _rememberAccurate(sample, maxAccuracyMeters: maxAccuracyMeters);
        return GeoLookupResult(
          geo: _toGeoMap(sample),
          failure: null,
          source: source,
          accuracyMeters: sample.position.accuracy,
          age: _sampleAge(sample, now),
        );
      }

      lastFailure = _failureForSample(
        sample,
        now,
        maxAccuracyMeters: maxAccuracyMeters,
        maxAge: maxAge,
        freshSince: freshSince,
      );
      lastRejectedSample = sample;
      return null;
    }

    if (preferCached) {
      final cached = _lastAccurateSample;
      if (cached != null) {
        final accepted = acceptSample(cached, 'cached_${cached.source}');
        if (accepted != null) return accepted;
      }
    }

    final current = await _tryCurrentPosition(currentTimeout);
    if (current != null) {
      final accepted = acceptSample(current, current.source);
      if (accepted != null) return accepted;
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
      final accepted = acceptSample(streamed, streamed.source);
      if (accepted != null) return accepted;
    }

    final cached = _lastAccurateSample;
    if (!preferCached && cached != null) {
      final accepted = acceptSample(cached, 'cached_${cached.source}');
      if (accepted != null) return accepted;
    }

    if (allowLastKnown) {
      final lastKnown = await _tryLastKnownPosition();
      if (lastKnown != null) {
        final accepted = acceptSample(lastKnown, lastKnown.source);
        if (accepted != null) return accepted;
      }
    }

    final rejectedNow = DateTime.now();
    final rejectedSample = lastRejectedSample;
    return GeoLookupResult(
      geo: null,
      failure: lastFailure,
      source: rejectedSample?.source ?? 'unknown',
      accuracyMeters: rejectedSample?.position.accuracy,
      age: rejectedSample == null
          ? null
          : _sampleAge(rejectedSample, rejectedNow),
    );
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
    return _tryGetReliableGeo(
      currentTimeout: currentTimeout,
      streamTimeout: streamTimeout,
      maxAge: maxAge,
      maxAccuracyMeters: maxAccuracyMeters,
      allowLastKnown: true,
      preferCached: true,
    );
  }

  /// Stream de ubicación en tiempo real (para mapa).
  /// distanceFilter: metros mínimos para emitir (5 = cada ~5m).
  Stream<Map<String, dynamic>> watchPositionStream({
    double distanceFilter = 5,
  }) async* {
    final readinessFailure = await _ensurePreciseLocationReady();
    if (readinessFailure != null) return;

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
