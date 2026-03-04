import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/providers.dart';
import '../../../core/storage/drift/app_database.dart';
import '../../../shared/widgets/donluis_app_bar.dart';

/// Paleta que contrasta sobre fondo verde (zona agrícola).
/// Evita verdes; usa tonos cálidos y fríos que destacan en vegetación.
const _fundoColors = [
  Color(0xFFFDD835), // amarillo
  Color(0xFFFB8C00), // naranja
  Color(0xFFE53935), // rojo
  Color(0xFFD81B60), // magenta
  Color(0xFF8E24AA), // morado
  Color(0xFF1E88E5), // azul
  Color(0xFF00ACC1), // cyan
  Color(0xFF7CB342), // lima (verde amarillento, distinto a vegetación)
];

Color _colorForFundo(String idFundo) {
  final i = idFundo.hashCode.abs() % _fundoColors.length;
  return _fundoColors[i];
}

LatLng _centroid(List<LatLng> points) {
  if (points.isEmpty) return const LatLng(0, 0);
  var lat = 0.0, lon = 0.0;
  for (final p in points) {
    lat += p.latitude;
    lon += p.longitude;
  }
  return LatLng(lat / points.length, lon / points.length);
}


/// Parsea WKT a lista de polígonos (cada uno como List de LatLng).
/// WKT usa "lon lat"; LatLng usa (lat, lon) → invertir.
List<List<LatLng>> _parseWkt(String wkt) {
  final result = <List<LatLng>>[];
  if (wkt.isEmpty) return result;

  final upper = wkt.trim().toUpperCase();
  if (upper.startsWith('MULTIPOLYGON')) {
    // MULTIPOLYGON(((lon lat,...)),((lon lat,...)))
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
    // POLYGON((lon lat, lon lat, ...))
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
    points.add(LatLng(lat, lon)); // WKT: lon lat → LatLng(lat, lon)
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

/// Pantalla con mapa de lotes (polígonos WKT).
class LotesMapPage extends ConsumerStatefulWidget {
  const LotesMapPage({super.key});

  @override
  ConsumerState<LotesMapPage> createState() => _LotesMapPageState();
}

class _LotesMapPageState extends ConsumerState<LotesMapPage> {
  List<LotesTableData> _lotes = [];
  LatLng? _myLocation;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLotes();
    _loadMyLocation();
  }

  Future<void> _loadMyLocation() async {
    final loc = ref.read(locationServiceProvider);
    final geo = await loc.tryGetHeaderGeo();
    if (mounted && geo != null) {
      setState(() {
        _myLocation = LatLng(
          (geo['lat'] as num).toDouble(),
          (geo['lon'] as num).toDouble(),
        );
      });
    }
  }

  Future<void> _loadLotes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dao = ref.read(lotesDaoProvider);
      final list = await dao.getAllWithGeom();
      if (mounted) {
        setState(() {
          _lotes = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: DonLuisAppBar(title: const Text('Mapa de Lotes')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: DonLuisAppBar(title: const Text('Mapa de Lotes')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _loadLotes, child: const Text('Reintentar')),
              ],
            ),
          ),
        ),
      );
    }

    final polygons = <Polygon>[];
    final labelMarkers = <Marker>[];
    final allPoints = <LatLng>[];

    for (final lote in _lotes) {
      final wkt = lote.geomWkt;
      if (wkt == null || wkt.isEmpty) continue;
      final rings = _parseWkt(wkt);
      final baseColor = _colorForFundo(lote.idFundo);
      for (final ring in rings) {
        if (ring.length >= 3) {
          polygons.add(Polygon(
            points: ring,
            color: baseColor.withAlpha(128),
            borderColor: baseColor,
            borderStrokeWidth: 3,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ));
          allPoints.addAll(ring);
          final desc = lote.descripcion.trim();
          if (desc.isNotEmpty) {
            final center = _centroid(ring);
            labelMarkers.add(Marker(
              point: center,
              width: 100,
              height: 36,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: baseColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(64),
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: baseColor,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ));
          }
        }
      }
    }

    final mapController = MapController();
    final pointsForBounds = [...allPoints];
    if (_myLocation != null) pointsForBounds.add(_myLocation!);

    return Scaffold(
      appBar: DonLuisAppBar(
        title: Text('Mapa de Lotes (${_lotes.length})'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: _loadLotes,
          ),
        ],
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: pointsForBounds.isEmpty
              ? const LatLng(-33.5, -70.6)
              : _center(pointsForBounds),
          initialZoom: pointsForBounds.isEmpty ? 10 : 12,
          minZoom: 3,
          maxZoom: 19,
          onMapReady: () {
            if (pointsForBounds.isNotEmpty) {
              final bounds = LatLngBounds.fromPoints(pointsForBounds);
              mapController.fitCamera(
                CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
              );
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: 'com.example.donluis_forms',
            maxNativeZoom: 17,
            maxZoom: 19,
            fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            panBuffer: 2,
            keepBuffer: 3,
          ),
          if (polygons.isNotEmpty)
            PolygonLayer(
              polygons: polygons,
              polygonCulling: true,
            ),
          if (labelMarkers.isNotEmpty)
            MarkerLayer(markers: labelMarkers),
          if (_myLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _myLocation!,
                  width: 24,
                  height: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(64),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  LatLng _center(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(-33.5, -70.6);
    var sumLat = 0.0, sumLon = 0.0;
    for (final p in points) {
      sumLat += p.latitude;
      sumLon += p.longitude;
    }
    return LatLng(sumLat / points.length, sumLon / points.length);
  }
}
