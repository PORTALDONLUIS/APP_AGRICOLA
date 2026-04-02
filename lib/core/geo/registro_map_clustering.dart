import 'dart:math' as math;

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
