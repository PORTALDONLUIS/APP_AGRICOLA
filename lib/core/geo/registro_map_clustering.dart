import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../features/registros/domain/registro.dart';

/// Distancia en metros entre dos puntos WGS84.
double haversineMeters(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const earthRadiusM = 6371000.0;
  final p1 = lat1 * math.pi / 180;
  final p2 = lat2 * math.pi / 180;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLon = (lon2 - lon1) * math.pi / 180;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(p1) * math.cos(p2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusM * c;
}

/// Agrupa registros cuya distancia mutua es ≤ [maxMeters] (enlace transitivo).
///
/// Usado en mapas para unificar marcadores muy cercanos sin coincidencia exacta
/// de coordenadas.
List<List<Registro>> clusterRegistrosByProximityMeters(
  List<Registro> registros,
  double maxMeters,
) {
  final items = registros.where((r) => r.lat != null && r.lon != null).toList();
  final n = items.length;
  if (n == 0) return [];

  final parent = List<int>.generate(n, (i) => i);

  int find(int i) {
    if (parent[i] != i) parent[i] = find(parent[i]);
    return parent[i];
  }

  void union(int a, int b) {
    final ra = find(a);
    final rb = find(b);
    if (ra != rb) parent[rb] = ra;
  }

  for (var i = 0; i < n; i++) {
    for (var j = i + 1; j < n; j++) {
      final a = items[i];
      final b = items[j];
      if (haversineMeters(a.lat!, a.lon!, b.lat!, b.lon!) <= maxMeters) {
        union(i, j);
      }
    }
  }

  final buckets = <int, List<Registro>>{};
  for (var i = 0; i < n; i++) {
    final root = find(i);
    buckets.putIfAbsent(root, () => []).add(items[i]);
  }

  final out = buckets.values.toList();
  out.sort((a, b) {
    final ma = a.map((r) => r.localId).reduce(math.min);
    final mb = b.map((r) => r.localId).reduce(math.min);
    return ma.compareTo(mb);
  });
  return out;
}

/// Centro del grupo para dibujar un único pin (promedio aritmético de lat/lon).
LatLng centroidRegistroGroup(List<Registro> group) {
  if (group.length == 1) {
    final r = group.first;
    return LatLng(r.lat!, r.lon!);
  }
  var slat = 0.0;
  var slon = 0.0;
  for (final r in group) {
    slat += r.lat!;
    slon += r.lon!;
  }
  final n = group.length;
  return LatLng(slat / n, slon / n);
}

/// Umbral por defecto (~12 m): registros más cercanos comparten marker.
const double kMapRegistroClusterMeters = 12.0;

/// Distancia en metros entre dos [LatLng].
double distanceMetersLatLng(LatLng a, LatLng b) =>
    haversineMeters(a.latitude, a.longitude, b.latitude, b.longitude);

/// Texto para UI: distancia de un registro al GPS actual (null si no hay GPS).
String? formatDistanceRegistroVsGps(Registro r, LatLng? gpsNow) {
  if (gpsNow == null || r.lat == null || r.lon == null) return null;
  final m = haversineMeters(r.lat!, r.lon!, gpsNow.latitude, gpsNow.longitude);
  if (m < 1000) {
    // Un decimal: evita "0 m" engañoso cuando hay 0,3–0,4 m reales.
    return 'vs GPS ahora: ${m.toStringAsFixed(1)} m';
  }
  return 'vs GPS ahora: ${(m / 1000).toStringAsFixed(2)} km';
}

/// Mínima distancia del GPS a cualquier registro con coordenadas (para banner).
double? minDistanceMetersGpsToRegistros(LatLng gps, List<Registro> registros) {
  double? best;
  for (final r in registros) {
    if (r.lat == null || r.lon == null) continue;
    final d = haversineMeters(r.lat!, r.lon!, gps.latitude, gps.longitude);
    if (best == null || d < best) best = d;
  }
  return best;
}

/// Color semántico: verde ≤15 m (típ. OK GPS), naranja ≤50 m, rojo si no.
Color gpsDeltaQualityColor(double meters) {
  if (meters <= 15) return const Color(0xFF2E7D32);
  if (meters <= 50) return const Color(0xFFE65100);
  return const Color(0xFFC62828);
}

/// Logs en consola al abrir la lista de un cluster (validar GPS vs coords guardadas).
void debugPrintRegistroClusterVsGps({
  required String mapLabel,
  required List<Registro> group,
  LatLng? gpsNow,
}) {
  debugPrint('════════════════════════════════════════════');
  debugPrint(
    '📍 Mapa: $mapLabel | cluster: ${group.length} registro(s)',
  );
  if (gpsNow != null) {
    debugPrint(
      '   GPS ahora (punto azul): ${gpsNow.latitude}, ${gpsNow.longitude}',
    );
  } else {
    debugPrint('   GPS ahora: null (sin capa / sin fix)');
  }
  if (group.length > 1) {
    final c = centroidRegistroGroup(group);
    debugPrint(
      '   Pin en mapa (centroide del grupo): ${c.latitude}, ${c.longitude}',
    );
    if (gpsNow != null) {
      final dc = distanceMetersLatLng(c, gpsNow);
      debugPrint('   → centroide vs GPS ahora: ${dc.toStringAsFixed(1)} m');
    }
  }
  for (final r in group) {
    final label =
        r.serverId != null ? '#${r.serverId}' : '#${r.localId} (local)';
    debugPrint(
      '   ▪ $label  localId=${r.localId}  guardado: lat=${r.lat}, lon=${r.lon}',
    );
    if (gpsNow != null && r.lat != null && r.lon != null) {
      final d = haversineMeters(
        r.lat!,
        r.lon!,
        gpsNow.latitude,
        gpsNow.longitude,
      );
      debugPrint('     → vs GPS ahora: ${d.toStringAsFixed(1)} m');
    }
  }
  debugPrint('════════════════════════════════════════════');
}
