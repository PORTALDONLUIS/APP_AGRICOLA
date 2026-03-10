import 'package:latlong2/latlong.dart';

/// Parsea WKT a lista de polígonos (cada uno como List de LatLng).
/// WKT usa "lon lat"; LatLng usa (lat, lon) → invertir.
List<List<LatLng>> parseWktToRings(String wkt) {
  final result = <List<LatLng>>[];
  if (wkt.isEmpty) return result;

  final upper = wkt.trim().toUpperCase();
  if (upper.startsWith('MULTIPOLYGON')) {
    final start = upper.indexOf('((');
    if (start < 0) return result;
    var i = start;
    while (i < wkt.length) {
      final open = wkt.indexOf('((', i);
      if (open < 0) break;
      final close = _findMatchingParen(wkt, open + 1);
      if (close == null) break;
      final inner = wkt.substring(open + 2, close);
      final ring = _parseRing(inner);
      if (ring.length >= 3) result.add(ring);
      i = close + 1;
    }
  } else if (upper.startsWith('POLYGON')) {
    final start = upper.indexOf('((');
    final end = upper.lastIndexOf('))');
    if (start == -1 || end == -1 || end <= start + 2) return result;
    final inner = wkt.substring(start + 2, end);
    final ring = _parseRing(inner);
    if (ring.length >= 3) result.add(ring);
  }
  return result;
}

int? _findMatchingParen(String s, int from) {
  var depth = 1;
  for (var i = from; i < s.length; i++) {
    if (s[i] == '(') depth++;
    if (s[i] == ')') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return null;
}

List<LatLng> _parseRing(String inner) {
  final points = <LatLng>[];
  for (final part in inner.split(',')) {
    final tokens = part.trim().split(RegExp(r'\s+'));
    if (tokens.length < 2) continue;
    final lon = double.tryParse(tokens[0]);
    final lat = double.tryParse(tokens[1]);
    if (lon == null || lat == null) continue;
    points.add(LatLng(lat, lon));
  }
  if (points.length >= 3) {
    final first = points.first;
    final last = points.last;
    if (first.latitude != last.latitude || first.longitude != last.longitude) {
      points.add(first);
    }
  }
  return points;
}
