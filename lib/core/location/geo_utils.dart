/// Punto en coordenadas lon/lat (SRID 4326).
class LonLat {
  final double lon;
  final double lat;

  const LonLat(this.lon, this.lat);
}

/// Parsea un WKT de tipo "POLYGON ((lon lat, lon lat, ...))" a una lista de puntos.
List<LonLat> parseWktPolygon(String wkt) {
  if (wkt.isEmpty) return const [];

  final upper = wkt.trim().toUpperCase();
  if (!upper.startsWith('POLYGON')) return const [];

  final start = upper.indexOf('((');
  final end = upper.lastIndexOf('))');
  if (start == -1 || end == -1 || end <= start + 2) return const [];

  // Usamos el string original para no perder signos/precisión.
  final inner = wkt.substring(start + 2, end);
  final parts = inner.split(',');
  final points = <LonLat>[];

  for (final part in parts) {
    final tokens = part.trim().split(RegExp(r'\s+'));
    if (tokens.length < 2) continue;
    final lon = double.tryParse(tokens[0]);
    final lat = double.tryParse(tokens[1]);
    if (lon == null || lat == null) continue;
    points.add(LonLat(lon, lat));
  }

  if (points.length < 3) return const [];

  // Asegura que el polígono esté cerrado.
  final first = points.first;
  final last = points.last;
  if (first.lon != last.lon || first.lat != last.lat) {
    points.add(LonLat(first.lon, first.lat));
  }

  return points;
}

/// Algoritmo ray-casting: true si (lon, lat) está dentro del polígono [vertices].
bool pointInPolygon(double lon, double lat, List<LonLat> vertices) {
  if (vertices.length < 3) return false;

  var inside = false;
  for (var i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
    final xi = vertices[i].lon, yi = vertices[i].lat;
    final xj = vertices[j].lon, yj = vertices[j].lat;

    final intersects = ((yi > lat) != (yj > lat)) &&
        (lon <
            (xj - xi) * (lat - yi) / ((yj - yi) + 1e-12) +
                xi); // 1e-12 evita división por cero

    if (intersects) inside = !inside;
  }
  return inside;
}

