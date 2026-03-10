import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/providers.dart';
import '../../../app/theme/donluis_theme.dart';
import '../../../core/network/http_error_handler.dart';
import '../../../core/geo/wkt_parser.dart';
import '../../../core/storage/drift/app_database.dart';
import '../../../features/registros/domain/registro.dart';
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

/// Simplifica un anillo si tiene demasiados puntos para acelerar el render.
List<LatLng> _simplifyRing(List<LatLng> ring, {int maxPoints = 100}) {
  if (ring.length <= maxPoints) return ring;
  final step = (ring.length / maxPoints).floor().clamp(1, ring.length);
  final result = <LatLng>[];
  for (var i = 0; i < ring.length; i += step) result.add(ring[i]);
  if (result.isNotEmpty && result.last != ring.last) result.add(ring.last);
  return result.length >= 3 ? result : ring;
}

/// Extrae el código del lote desde la descripción.
/// Ej: "LOTE CN-3 PALTA --_CERRO NEGRO" -> "CN-3"
///     "LOTE CHAV-1 UVA _CHAVALINA" -> "CHAV-1"
String _extractCodigoLote(String descripcion) {
  if (descripcion.isEmpty) return '';
  final s = descripcion.trim();
  final upper = s.toUpperCase();
  if (!upper.startsWith('LOTE ')) return s;
  final afterLote = s.substring(5).trim();
  final parts = afterLote.split(RegExp(r'\s+'));
  if (parts.isEmpty) return s;
  return parts.first;
}


/// Pantalla con mapa general: lotes + todos los registros del usuario + ubicación en tiempo real.
class LotesMapPage extends ConsumerStatefulWidget {
  const LotesMapPage({super.key});

  @override
  ConsumerState<LotesMapPage> createState() => _LotesMapPageState();
}

class _LotesMapPageState extends ConsumerState<LotesMapPage> {
  List<LotesTableData> _lotes = [];
  List<Registro> _registrosWithLocation = [];
  StreamSubscription<Map<String, dynamic>>? _locationSub;
  StreamSubscription<List<Registro>>? _registrosSub;
  bool _loading = true;
  String? _error;
  late final MapController _mapController;
  late final ValueNotifier<LatLng?> _locationNotifier;
  double _currentZoom = 12;

  static const _labelsZoomThreshold = 15.0;

  /// Cache: polígonos y labels parseados una sola vez. Se recalcula cuando _lotes cambia.
  List<Polygon> _cachedPolygons = [];
  List<Marker> _cachedLabelMarkers = [];
  List<LatLng> _cachedAllPoints = [];
  bool _cacheDirty = true;

  /// Evita centrar solo en onMapReady (cuando aún no hay datos). Se centra cuando llegan lotes/registros.
  bool _hasFittedToData = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _locationNotifier = ValueNotifier<LatLng?>(null);
    _loadLotes();
    _startLocationStream();
    _subscribeRegistros();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _registrosSub?.cancel();
    _locationNotifier.dispose();
    super.dispose();
  }

  void _startLocationStream() {
    final loc = ref.read(locationServiceProvider);
    _locationSub?.cancel();
    _locationSub = loc.watchPositionStream(distanceFilter: 5).listen((geo) {
      if (mounted) {
        final newLoc = LatLng(
          (geo['lat'] as num).toDouble(),
          (geo['lon'] as num).toDouble(),
        );
        _locationNotifier.value = newLoc;
      }
    });
    loc.tryGetHeaderGeo().then((geo) {
      if (mounted && geo != null) {
        _locationNotifier.value = LatLng(
          (geo['lat'] as num).toDouble(),
          (geo['lon'] as num).toDouble(),
        );
      }
    });
  }

  void _subscribeRegistros() {
    final local = ref.read(registrosLocalDSProvider);
    final userId = ref.read(currentUserIdProvider);
    _registrosSub?.cancel();
    _registrosSub = local
        .watchRegistrosWithLocation(plantillaId: null, userId: userId)
        .listen((list) {
      if (mounted) {
        setState(() {
          _registrosWithLocation = list
              .where((r) => r.lat != null && r.lon != null)
              .toList();
        });
      }
    });
  }

  void _rebuildPolygonCache() {
    if (!_cacheDirty) return;
    _cacheDirty = false;
    final polygons = <Polygon>[];
    final labelMarkers = <Marker>[];
    final allPoints = <LatLng>[];
    for (final lote in _lotes) {
      final wkt = lote.geomWkt;
      if (wkt == null || wkt.isEmpty) continue;
      final rings = parseWktToRings(wkt);
      final baseColor = _colorForFundo(lote.idFundo);
      for (final ring in rings) {
        if (ring.length >= 3) {
          final simplified = _simplifyRing(ring);
          polygons.add(Polygon(
            points: simplified,
            color: baseColor.withAlpha(128),
            borderColor: baseColor,
            borderStrokeWidth: 3,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ));
          allPoints.addAll(simplified);
          final codigo = _extractCodigoLote(lote.descripcion.trim());
          if (codigo.isNotEmpty) {
            final center = _centroid(simplified);
            labelMarkers.add(Marker(
              point: center,
              width: 80,
              height: 36,
              alignment: Alignment.center,
              child: Text(
                codigo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: baseColor.withOpacity(0.35),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  shadows: const [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.white70,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ));
          }
        }
      }
    }
    _cachedPolygons = polygons;
    _cachedLabelMarkers = labelMarkers;
    _cachedAllPoints = allPoints;
    _cacheDirty = false;
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
          _cacheDirty = true;
          _hasFittedToData = false;
        });
      }
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _error = HttpErrorHandler.toUserMessage(e, st);
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: DonLuisAppBar(title: const Text('Mapa de Lotes')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: _loadLotes, child: const Text('Reintentar')),
              ],
            ),
          ),
        ),
      );
    }

    // Mapa visible de inmediato (con o sin lotes) para que los tiles carguen rápido
    _rebuildPolygonCache();
    final pointsForBounds = [..._cachedAllPoints];
    for (final r in _registrosWithLocation) {
      if (r.lat != null && r.lon != null) {
        pointsForBounds.add(LatLng(r.lat!, r.lon!));
      }
    }
    final loc = _locationNotifier.value;
    if (loc != null) pointsForBounds.add(loc);

    final registroMarkers = _registrosWithLocation
        .where((r) => r.lat != null && r.lon != null)
        .map((r) => Marker(
              point: LatLng(r.lat!, r.lon!),
              width: 28,
              height: 28,
              child: Container(
                decoration: BoxDecoration(
                  color: DonLuisColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(64),
                        blurRadius: 4,
                        spreadRadius: 1),
                  ],
                ),
                child: const Icon(Icons.place, color: Colors.white, size: 16),
              ),
            ))
        .toList();

    final showLabels = _currentZoom >= _labelsZoomThreshold;

    if (pointsForBounds.isNotEmpty && !_hasFittedToData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitCameraIfNeeded(pointsForBounds);
      });
    }

    return Scaffold(
      appBar: DonLuisAppBar(
        title: Text(
            'Mapa (${_lotes.length} lotes, ${_registrosWithLocation.length} registros)'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: _loadLotes,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: pointsForBounds.isEmpty
                  ? const LatLng(-33.5, -70.6)
                  : _center(pointsForBounds),
              initialZoom: pointsForBounds.isEmpty ? 10 : 12,
              minZoom: 3,
              maxZoom: 19,
              onPositionChanged: (position, _) {
                final z = position.zoom;
                if (mounted && z != null) {
                  final wasAbove = _currentZoom >= _labelsZoomThreshold;
                  final isAbove = z >= _labelsZoomThreshold;
                  _currentZoom = z;
                  if (wasAbove != isAbove) setState(() {});
                }
              },
              onMapReady: () => _fitCameraIfNeeded(pointsForBounds),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.donluis_forms',
                maxNativeZoom: 17,
                maxZoom: 19,
                fallbackUrl:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                panBuffer: 2,
                keepBuffer: 4,
              ),
              if (_cachedPolygons.isNotEmpty)
                PolygonLayer(
                  polygons: _cachedPolygons,
                  polygonCulling: true,
                ),
              if (_cachedLabelMarkers.isNotEmpty && showLabels)
                MarkerLayer(markers: _cachedLabelMarkers),
              if (registroMarkers.isNotEmpty)
                MarkerLayer(markers: registroMarkers),
              ValueListenableBuilder<LatLng?>(
                valueListenable: _locationNotifier,
                builder: (_, myLoc, __) {
                  if (myLoc == null) return const SizedBox.shrink();
                  return MarkerLayer(
                    markers: [
                      Marker(
                        point: myLoc,
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
                  );
                },
              ),
            ],
          ),
          if (_loading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  void _fitCameraIfNeeded(List<LatLng> pointsForBounds) {
    if (pointsForBounds.isEmpty || _hasFittedToData || !mounted) return;
    _hasFittedToData = true;
    final bounds = LatLngBounds.fromPoints(pointsForBounds);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
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
