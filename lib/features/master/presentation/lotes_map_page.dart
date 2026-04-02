import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/providers.dart';
import '../../../app/theme/donluis_theme.dart';
import '../../../core/network/http_error_handler.dart';
import '../../../core/geo/registro_map_clustering.dart';
import '../../../core/geo/wkt_parser.dart';
import '../../../core/storage/drift/app_database.dart';
import '../../../features/registros/domain/registro.dart';
import '../../../shared/widgets/donluis_app_bar.dart';
import '../../../shared/widgets/registro_map_id_badge.dart';
import '../../../core/sync/sync_models.dart';
import '../../../app/form_registry.dart';

/// (Colores antiguos por fundo ya no se usan para el polígono,
///  pero se pueden reutilizar en el futuro si se quiere diferenciar por fundo.)

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

String _registroMapIdText(int? serverId, int localId) =>
    serverId != null ? '#$serverId' : '#$localId';

String _groupBadgeText(List<Registro> group) {
  if (group.isEmpty) return '';
  if (group.length == 1) {
    final r = group.first;
    return _registroMapIdText(r.serverId, r.localId);
  }
  const maxLen = 36;
  final labels =
      group.map((r) => _registroMapIdText(r.serverId, r.localId)).toList();
  final joined = labels.join(', ');
  if (joined.length <= maxLen) return joined;
  final buf = <String>[];
  var len = 0;
  for (final label in labels) {
    final next = buf.isEmpty ? label : ', $label';
    if (len + next.length > maxLen - 6) {
      final rest = labels.length - buf.length;
      if (rest > 0) {
        if (buf.isEmpty) return '${group.length}';
        return '${buf.join(', ')} +$rest';
      }
    }
    buf.add(label);
    len += next.length;
  }
  return buf.join(', ');
}

String _formatShortRegistroTime(Registro r) {
  final d = r.registrationDateTimeUtc().toLocal();
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour}:$mm';
}

Color _colorForFundo(String idFundo, String descripcion) {
  // Paleta de colores PASTEL claros, todos lejos del verde para que
  // contrasten bien con el mapa satelital.
  const palette = [
    Color(0xFFFFC1CC), // rosa claro
    Color(0xFFFFE0B2), // naranja pastel
    Color(0xFFFFF59D), // amarillo pastel
    Color(0xFFBBDEFB), // azul pastel
    Color(0xFFD1C4E9), // lila pastel
    Color(0xFFFFCCBC), // salmón pastel
    Color(0xFFFFF3E0), // crema claro
    Color(0xFFB3E5FC), // celeste pastel
    Color(0xFFE1BEE7), // violeta pastel
  ];

  // Usamos el idFundo como clave para que TODOS los lotes del mismo fundo
  // compartan exactamente el mismo color claro.
  final key = idFundo;
  var hash = 0;
  for (final codeUnit in key.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7FFFFFFF;
  }
  final index = hash % palette.length;
  return palette[index];
}

IconData _iconForTemplate(String templateKey) {
  switch (templateKey) {
    case 'cartilla_brotacion':
      return Icons.eco; // hoja
    case 'cartilla_brix':
      return Icons.local_drink; // uva / jugo
    case 'cartilla_fito':
    case 'cartilla_fitosanidad':
      return Icons.bug_report; // insecto / alerta
    case 'cartilla_fertilidad':
      return Icons.grass; // fertilidad / suelo
    case 'cartilla_engome':
      return Icons.water_drop; // engorde / agua
    case 'cartilla_calibre_bayas':
      return Icons.straighten; // calibre / medida
    case 'cartilla_conteo_racimos':
      return Icons.filter_9_plus; // conteo
    case 'cartilla_floracion_cuaja':
      return Icons.local_florist; // floración
    case 'cartilla_clasificacion_cargadores':
      return Icons.category; // clasificación
    case 'cartilla_conteo_cargadores':
      return Icons.format_list_numbered; // conteo cargadores
    default:
      return Icons.place;
  }
}

/// Punto-en-polígono (ray casting). Asume polígono simple, sin agujeros.
bool _pointInPolygon(LatLng p, List<LatLng> poly) {
  var inside = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final xi = poly[i].latitude;
    final yi = poly[i].longitude;
    final xj = poly[j].latitude;
    final yj = poly[j].longitude;
    final intersects = ((yi > p.longitude) != (yj > p.longitude)) &&
        (p.latitude <
            (xj - xi) * (p.longitude - yi) / (yj - yi + 1e-12) + xi);
    if (intersects) inside = !inside;
  }
  return inside;
}

/// Genera un punto aleatorio dentro del polígono (aprox) usando
/// muestreo en el bounding box + _pointInPolygon. Si falla, usa el centroide.
LatLng _randomPointInsideRing(List<LatLng> ring, Random rand) {
  if (ring.isEmpty) return const LatLng(0, 0);
  var minLat = ring.first.latitude;
  var maxLat = ring.first.latitude;
  var minLon = ring.first.longitude;
  var maxLon = ring.first.longitude;
  for (final p in ring) {
    if (p.latitude < minLat) minLat = p.latitude;
    if (p.latitude > maxLat) maxLat = p.latitude;
    if (p.longitude < minLon) minLon = p.longitude;
    if (p.longitude > maxLon) maxLon = p.longitude;
  }

  for (var i = 0; i < 20; i++) {
    final lat = minLat + rand.nextDouble() * (maxLat - minLat);
    final lon = minLon + rand.nextDouble() * (maxLon - minLon);
    final candidate = LatLng(lat, lon);
    if (_pointInPolygon(candidate, ring)) {
      return candidate;
    }
  }

  // Fallback razonable: centroide
  return _centroid(ring);
}

Color _colorForTemplate(String templateKey) {
  switch (templateKey) {
    case 'cartilla_brotacion':
      return Colors.green.shade700;
    case 'cartilla_brix':
      return Colors.deepPurple;
    case 'cartilla_fito':
    case 'cartilla_fitosanidad':
      return Colors.redAccent;
    case 'cartilla_fertilidad':
      return Colors.brown;
    case 'cartilla_engome':
      return Colors.teal;
    case 'cartilla_calibre_bayas':
      return Colors.indigo;
    case 'cartilla_conteo_racimos':
      return Colors.orange;
    case 'cartilla_floracion_cuaja':
      return Colors.pinkAccent;
    case 'cartilla_clasificacion_cargadores':
      return Colors.cyan;
    case 'cartilla_conteo_cargadores':
      return Colors.blueGrey;
    default:
      return DonLuisColors.secondary;
  }
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

  // Capas activables
  bool _showLotes = true;
  bool _showRegistros = true;
  bool _showGps = true;

  // Panel de filtros
  bool _showFilters = true;

  // Filtros por tipo de cartilla (templateKey)
  bool _showBrotacion = true;
  bool _showBrix = true;
  bool _showFito = true;
  bool _showFertilidad = true;
  bool _showEngome = true;
  bool _showCalibre = true;
  bool _showConteoRacimos = true;
  bool _showFloracionCuaja = true;
  bool _showClasificacionCargadores = true;
  bool _showConteoCargadores = true;

  // Popup de lote seleccionado
  LotesTableData? _selectedLote;

  // Métricas de muestreo por lote (cacheadas junto con los polígonos)
  Map<int, int> _countsByLote = {};
  Map<int, Set<String>> _cartillasByLote = {};

  /// Cache: polígonos y labels parseados una sola vez. Se recalcula cuando _lotes cambia.
  List<Polygon> _cachedPolygons = [];
  List<Marker> _cachedLabelMarkers = [];
  List<LatLng> _cachedAllPoints = [];
  bool _cacheDirty = true;

  /// Evita centrar solo en onMapReady (cuando aún no hay datos). Se centra cuando llegan lotes/registros.
  bool _hasFittedToData = false;

  bool _isTemplateVisible(String templateKey) {
    switch (templateKey) {
      case 'cartilla_brotacion':
        return _showBrotacion;
      case 'cartilla_brix':
        return _showBrix;
      case 'cartilla_fito':
      case 'cartilla_fitosanidad':
        return _showFito;
      case 'cartilla_fertilidad':
        return _showFertilidad;
      case 'cartilla_engome':
        return _showEngome;
      case 'cartilla_calibre_bayas':
        return _showCalibre;
      case 'cartilla_conteo_racimos':
        return _showConteoRacimos;
      case 'cartilla_floracion_cuaja':
        return _showFloracionCuaja;
      case 'cartilla_clasificacion_cargadores':
        return _showClasificacionCargadores;
      case 'cartilla_conteo_cargadores':
        return _showConteoCargadores;
      default:
        return true;
    }
  }

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
          _registrosWithLocation =
              list.where((r) => r.lat != null && r.lon != null).toList();
          _cacheDirty = true; // recalc counts/cartillas y labels
        });
      }
    });
  }

  void _rebuildPolygonCache() {
    if (!_cacheDirty) return;
    _cacheDirty = false;

    // Construye métricas de muestreo por lote a partir de los registros cargados
    final countsByLote = <int, int>{};
    final cartillasByLote = <int, Set<String>>{};
    for (final r in _registrosWithLocation) {
      final loteId = r.loteId;
      if (loteId == null) continue;
      countsByLote[loteId] = (countsByLote[loteId] ?? 0) + 1;
      final set = cartillasByLote.putIfAbsent(loteId, () => <String>{});
      set.add(r.templateKey);
    }

    final polygons = <Polygon>[];
    final labelMarkers = <Marker>[];
    final allPoints = <LatLng>[];
    for (final lote in _lotes) {
      final wkt = lote.geomWkt;
      if (wkt == null || wkt.isEmpty) continue;
      final rings = parseWktToRings(wkt);
      for (final ring in rings) {
        if (ring.length >= 3) {
          final simplified = _simplifyRing(ring);
          final borderColor =
              _colorForFundo(lote.idFundo, lote.descripcion.trim());

          // 1) Halo negro grueso, sin relleno (debajo)
          polygons.add(
            Polygon(
              points: simplified,
              color: Colors.transparent,
              borderColor: Colors.black,
              borderStrokeWidth: 6,
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
            ),
          );

          // 2) Polígono real con borde por fundo + relleno oscuro transparente
          polygons.add(
            Polygon(
              points: simplified,
              color: Colors.black.withOpacity(0.15),
              borderColor: borderColor,
              borderStrokeWidth: 3,
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
            ),
          );

          allPoints.addAll(simplified);
          final codigo = _extractCodigoLote(lote.descripcion.trim());
          if (codigo.isNotEmpty) {
            final center = _centroid(simplified);
            final count = countsByLote[lote.idLote] ?? 0;
            final labelText = count > 0 ? '$codigo ($count)' : codigo;
            labelMarkers.add(Marker(
              point: center,
              width: 80,
              height: 36,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLote = lote;
                  });
                },
                child: Text(
                  labelText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    shadows: [
                      // Halo/borde negro alrededor del texto
                      Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 0,
                          color: Colors.black),
                      Shadow(
                          offset: Offset(1, 0),
                          blurRadius: 0,
                          color: Colors.black),
                      Shadow(
                          offset: Offset(-1, 0),
                          blurRadius: 0,
                          color: Colors.black),
                      Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 0,
                          color: Colors.black),
                      Shadow(
                          offset: Offset(0, -1),
                          blurRadius: 0,
                          color: Colors.black),
                    ],
                  ),
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
    _countsByLote = countsByLote;
    _cartillasByLote = cartillasByLote;
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

    final visibleRegistros = _registrosWithLocation
        .where((r) => r.lat != null && r.lon != null)
        .where((r) => _isTemplateVisible(r.templateKey))
        .toList();
    final clusters = clusterRegistrosByProximityMeters(
      visibleRegistros,
      kMapRegistroClusterMeters,
    );
    for (final list in clusters) {
      list.sort((a, b) => a.localId.compareTo(b.localId));
    }

    final registroMarkers = clusters
        .map((group) {
          final first = group.first;
          final icon = _iconForTemplate(first.templateKey);
          final color = _colorForTemplate(first.templateKey);
          final point = centroidRegistroGroup(group);
          final badgeText = _groupBadgeText(group);
          return Marker(
            point: point,
            width: 124,
            height: 80,
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showRegistrosGroupSheet(
                      context,
                      group,
                      _locationNotifier.value,
                    ),
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 124,
                  height: 80,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Misma lógica que cartilla_map: badge anclado por abajo encima del círculo.
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 57,
                        child: Center(
                          child: RegistroMapIdBadge(text: badgeText),
                        ),
                      ),
                      Positioned(
                        left: 48,
                        top: 26,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(64),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: group.length > 1
                              ? Center(
                                  child: Text(
                                    '${group.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                )
                              : Icon(icon, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        })
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
            tooltip: _showFilters ? 'Ocultar filtros' : 'Mostrar filtros',
            icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: _loadLotes,
          ),
          IconButton(
            tooltip: 'Generar datos de prueba',
            icon: const Icon(Icons.science),
            onPressed: () async {
              await generateSampleRegistrosForAllLotes(ref);
            },
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
              if (_cachedPolygons.isNotEmpty && _showLotes)
                PolygonLayer(
                  polygons: _cachedPolygons,
                  polygonCulling: true,
                ),
              if (_cachedLabelMarkers.isNotEmpty && showLabels && _showLotes)
                MarkerLayer(markers: _cachedLabelMarkers),
              if (registroMarkers.isNotEmpty && _showRegistros)
                MarkerLayer(markers: registroMarkers),
              ValueListenableBuilder<LatLng?>(
                valueListenable: _locationNotifier,
                builder: (_, myLoc, __) {
                  if (myLoc == null || !_showGps) {
                    return const SizedBox.shrink();
                  }
                  return MarkerLayer(
                    markers: [
                      Marker(
                        point: myLoc,
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
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
          // Panel de filtros (colapsable) de capas y tipos de cartilla
          if (_showFilters)
            Positioned(
              top: 16,
              right: 16,
              child: Card(
                color: Colors.black.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Segmento: filtros generales / capas
                      const Text(
                        'Capas',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showLotes,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              setState(() => _showLotes = v ?? true);
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Lotes',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showRegistros,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              setState(() => _showRegistros = v ?? true);
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Registros',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showGps,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              setState(() => _showGps = v ?? true);
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Ubicación GPS',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Divider(
                        height: 4,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 4),
                      // Segmento: filtros por tipo de cartilla
                      const Text(
                        'Cartillas',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showBrotacion &&
                                _showBrix &&
                                _showFito &&
                                _showFertilidad &&
                                _showEngome &&
                                _showCalibre &&
                                _showConteoRacimos &&
                                _showFloracionCuaja &&
                                _showClasificacionCargadores &&
                                _showConteoCargadores,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              final value = v ?? true;
                              setState(() {
                                _showBrotacion = value;
                                _showBrix = value;
                                _showFito = value;
                                _showFertilidad = value;
                                _showEngome = value;
                                _showCalibre = value;
                                _showConteoRacimos = value;
                                _showFloracionCuaja = value;
                                _showClasificacionCargadores = value;
                                _showConteoCargadores = value;
                              });
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Todas las cartillas',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showFertilidad,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              setState(() => _showFertilidad = v ?? true);
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Fertilidad',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showEngome,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              setState(() => _showEngome = v ?? true);
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Engome',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showCalibre,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              setState(() => _showCalibre = v ?? true);
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Calibre bayas',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showConteoRacimos,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              setState(() => _showConteoRacimos = v ?? true);
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Conteo racimos',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showFloracionCuaja,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              setState(() => _showFloracionCuaja = v ?? true);
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Floración / cuaja',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showClasificacionCargadores,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              setState(() =>
                                  _showClasificacionCargadores = v ?? true);
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Clasificación cargadores',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showConteoCargadores,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              setState(() => _showConteoCargadores = v ?? true);
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Conteo cargadores',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showBrotacion,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              setState(() => _showBrotacion = v ?? true);
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Brotación',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showBrix,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              setState(() => _showBrix = v ?? true);
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Brix',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showFito,
                            activeColor: DonLuisColors.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) {
                              setState(() => _showFito = v ?? true);
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Fitosanidad',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'go_to_my_location',
              backgroundColor: Colors.white,
              foregroundColor: Colors.blueGrey,
              onPressed: () {
                final locNow = _locationNotifier.value;
                if (locNow == null) return;
                _mapController.move(locNow, 17);
              },
              child: const Icon(Icons.my_location),
            ),
          ),
          if (_selectedLote != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 80,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLote = null;
                  });
                },
                child: Card(
                  color: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _extractCodigoLote(
                                    _selectedLote!.descripcion),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 18),
                              onPressed: () {
                                setState(() {
                                  _selectedLote = null;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fundo: ${_selectedLote!.idFundo}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Registros: ${_countsByLote[_selectedLote!.idLote] ?? 0}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Builder(builder: (_) {
                          // Agrupamos registros del lote por templateKey para mostrar
                          // "Nombre cartilla (N)" en varias líneas.
                          final loteId = _selectedLote!.idLote;
                          final regs = _registrosWithLocation
                              .where((r) => r.loteId == loteId)
                              .toList();
                          if (regs.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final counts = <String, int>{};
                          for (final r in regs) {
                            counts[r.templateKey] =
                                (counts[r.templateKey] ?? 0) + 1;
                          }

                          String labelForTemplate(String key) {
                            switch (key) {
                              case 'cartilla_brotacion':
                                return 'Brotación';
                              case 'cartilla_brix':
                                return 'Brix';
                              case 'cartilla_fito':
                              case 'cartilla_fitosanidad':
                                return 'Fitosanidad';
                              case 'cartilla_fertilidad':
                                return 'Fertilidad';
                              case 'cartilla_engome':
                                return 'Engome';
                              case 'cartilla_calibre_bayas':
                                return 'Calibre bayas';
                              case 'cartilla_conteo_racimos':
                                return 'Conteo racimos';
                              case 'cartilla_floracion_cuaja':
                                return 'Floración / cuaja';
                              case 'cartilla_clasificacion_cargadores':
                                return 'Clasificación cargadores';
                              case 'cartilla_conteo_cargadores':
                                return 'Conteo cargadores';
                              default:
                                return key;
                            }
                          }

                          final entries = counts.entries.toList()
                            ..sort((a, b) =>
                                labelForTemplate(a.key)
                                    .compareTo(labelForTemplate(b.key)));

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cartillas:',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 160,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (final e in entries)
                                        Text(
                                          '${labelForTemplate(e.key)} (${e.value})',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ValueListenableBuilder<LatLng?>(
            valueListenable: _locationNotifier,
            builder: (context, myLoc, _) {
              if (myLoc == null || !_showGps || !_showRegistros) {
                return const SizedBox.shrink();
              }
              final vis = _registrosWithLocation
                  .where((r) => r.lat != null && r.lon != null)
                  .where((r) => _isTemplateVisible(r.templateKey))
                  .toList();
              if (vis.isEmpty) return const SizedBox.shrink();
              final minD = minDistanceMetersGpsToRegistros(myLoc, vis);
              if (minD == null) return const SizedBox.shrink();
              return Positioned(
                left: 8,
                right: 8,
                bottom: 10,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withValues(alpha: 0.82),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(
                      'Azul = tu GPS en vivo. Los pins usan la ubicación guardada '
                      'al guardar la cartilla (no se actualiza sola). '
                      'Registro más cercano a tu posición ahora: ${minD.toStringAsFixed(1)} m. '
                      'Diferencias ≤15 m suelen ser normales (precisión GPS).',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              );
            },
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

  void _showRegistrosGroupSheet(
    BuildContext context,
    List<Registro> group,
    LatLng? gpsNow,
  ) {
    debugPrintRegistroClusterVsGps(
      mapLabel: 'lotes',
      group: group,
      gpsNow: gpsNow,
    );
    final title = group.length == 1
        ? 'Registro'
        : '${group.length} registros en este punto';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: DonLuisColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final maxH = MediaQuery.of(ctx).size.height * 0.55;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Text(
                    title,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                  ),
                ),
                if (group.length > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      'El pin en el mapa está en la posición media de este grupo '
                      '(varios registros cercanos). Cada fila muestra las coords '
                      'guardadas de ese registro.',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ),
                if (group.length > 1 && gpsNow != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      'Pin (promedio) vs GPS ahora: '
                      '${distanceMetersLatLng(centroidRegistroGroup(group), gpsNow).toStringAsFixed(1)} m',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: group.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, indent: 16, endIndent: 16, color: cs.outlineVariant),
                    itemBuilder: (_, i) {
                      final r = group[i];
                      final idLabel =
                          _registroMapIdText(r.serverId, r.localId);
                      final route = FormRegistry.routeFor(r.templateKey);
                      final distM = gpsNow != null
                          ? haversineMeters(
                              r.lat!,
                              r.lon!,
                              gpsNow.latitude,
                              gpsNow.longitude,
                            )
                          : null;
                      return ListTile(
                        isThreeLine: true,
                        leading: Icon(
                          _iconForTemplate(r.templateKey),
                          color: cs.primary,
                        ),
                        title: Text(
                          idLabel,
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            letterSpacing: 0.2,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${r.templateKey} · ${_formatShortRegistroTime(r)}',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Guardado: ${r.lat!.toStringAsFixed(5)}, ${r.lon!.toStringAsFixed(5)}',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            if (distM != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                formatDistanceRegistroVsGps(r, gpsNow)!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: gpsDeltaQualityColor(distM),
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: cs.onSurfaceVariant,
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.pushNamed(
                            context,
                            route,
                            arguments: {'localId': r.localId},
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ======= SOLO DEBUG / DESARROLLO =======
/// Genera registros locales de prueba dentro de cada lote con geometría.
Future<void> generateSampleRegistrosForAllLotes(WidgetRef ref) async {
  final daoLotes = ref.read(lotesDaoProvider);
  final local = ref.read(registrosLocalDSProvider);
  final userId = ref.read(currentUserIdProvider);

  final lotes = await daoLotes.getAllWithGeom();
  if (lotes.isEmpty) return;

  final rand = Random();
  // Lista ampliada de tipos de cartilla disponibles en la app.
  const templateKeys = [
    'cartilla_brotacion',
    'cartilla_brix',
    'cartilla_fito',
    'cartilla_fertilidad',
    'cartilla_long_brote_racimo',
    'cartilla_engome',
    'cartilla_calibre_bayas',
    'cartilla_conteo_racimos',
    'cartilla_floracion_cuaja',
    'cartilla_clasificacion_cargadores',
    'cartilla_conteo_cargadores',
  ];

  for (final lote in lotes) {
    if (lote.geomWkt == null || lote.geomWkt!.isEmpty) continue;
    final rings = parseWktToRings(lote.geomWkt!);
    if (rings.isEmpty) continue;

    final ring = _simplifyRing(rings.first);
    if (ring.length < 3) continue;

    // Punto realmente dentro del polígono (o centroide como fallback)
    final p = _randomPointInsideRing(ring, rand);
    final templateKey = templateKeys[rand.nextInt(templateKeys.length)];

    final localId = await local.createDraft(
      plantillaId: 0, // ajusta si quieres ligar a una plantilla específica
      templateKey: templateKey,
      userId: userId,
    );

    final payload = {
      'payloadVersion': 1,
      'header': {
        'plantillaId': 0,
        'userId': userId,
        'campaniaId': null,
        'loteId': lote.idLote,
        'lat': p.latitude,
        'lon': p.longitude,
        'fechaEjecucion': null,
      },
      'body': {
        // Mínimo para diferenciar por tipo de cartilla
        'variedad': 'TEST',
        'observaciones': 'Registro de prueba auto-generado en mapa',
      },
    };

    await local.saveLocal(
      localId: localId,
      data: payload,
      estado: EstadoRegistro.borrador,
      syncStatus: SyncStatus.local,
    );
  }
}
