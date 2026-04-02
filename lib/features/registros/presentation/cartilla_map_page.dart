import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/providers.dart';
import '../../../core/network/http_error_handler.dart';
import '../domain/registro.dart';
import '../../../app/theme/donluis_theme.dart';
import '../../../core/geo/wkt_parser.dart';
import '../../../core/storage/drift/app_database.dart';
import '../../../shared/widgets/donluis_app_bar.dart';
import '../../../app/form_registry.dart';

/// Paleta que contrasta sobre fondo verde (zona agrícola).
const _fundoColors = [
  Color(0xFFFDD835), // amarillo
  Color(0xFFFB8C00), // naranja
  Color(0xFFE53935), // rojo
  Color(0xFFD81B60), // magenta
  Color(0xFF8E24AA), // morado
  Color(0xFF1E88E5), // azul
  Color(0xFF00ACC1), // cyan
  Color(0xFF7CB342), // lima
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

/// Id visible en mapa: mismo formato `#n` (servidor si existe, si no id local).
String _registroMapIdText(int? serverId, int localId) =>
    serverId != null ? '#$serverId' : '#$localId';

String _latLonKey(double lat, double lon) =>
    '${lat.toStringAsFixed(6)}_${lon.toStringAsFixed(6)}';

/// Un registro: id único. Varios: lista truncada o `n` si no cabe.
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

Widget _registroMapIdBadge(String text) {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 118),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.15,
        ),
      ),
    ),
  );
}

/// Mapa de una cartilla: lotes + registros de esa cartilla + ubicación actual en tiempo real.
class CartillaMapPage extends ConsumerStatefulWidget {
  final int plantillaId;
  final String templateKey;
  final String plantillaNombre;

  const CartillaMapPage({
    super.key,
    required this.plantillaId,
    required this.templateKey,
    required this.plantillaNombre,
  });

  @override
  ConsumerState<CartillaMapPage> createState() => _CartillaMapPageState();
}

class _CartillaMapPageState extends ConsumerState<CartillaMapPage> {
  List<LotesTableData> _lotes = [];
  List<Registro> _registros = [];
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
        .watchRegistrosWithLocation(
            plantillaId: widget.plantillaId, userId: userId)
        .listen((list) {
      if (mounted) {
        setState(() {
          _registros =
              list.where((r) => r.lat != null && r.lon != null).toList();
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
      for (final ring in rings) {
        if (ring.length >= 3) {
          final simplified = _simplifyRing(ring);
          polygons.add(Polygon(
            points: simplified,
            // Mismo estilo que en LotesMapPage para mejor contraste
            color: const Color(0xFF2ECC71).withOpacity(0.35),
            borderColor: const Color(0xFFFF8C00),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  shadows: [
                    // Halo/borde negro alrededor del texto (igual que en LotesMapPage)
                    Shadow(offset: Offset(0, 0), blurRadius: 0, color: Colors.black),
                    Shadow(offset: Offset(1, 0), blurRadius: 0, color: Colors.black),
                    Shadow(offset: Offset(-1, 0), blurRadius: 0, color: Colors.black),
                    Shadow(offset: Offset(0, 1), blurRadius: 0, color: Colors.black),
                    Shadow(offset: Offset(0, -1), blurRadius: 0, color: Colors.black),
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
        appBar: DonLuisAppBar(title: Text('Mapa: ${widget.plantillaNombre}')),
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
    for (final r in _registros) {
      if (r.lat != null && r.lon != null) {
        pointsForBounds.add(LatLng(r.lat!, r.lon!));
      }
    }
    final loc = _locationNotifier.value;
    if (loc != null) pointsForBounds.add(loc);

    final grouped = <String, List<Registro>>{};
    for (final r in _registros) {
      if (r.lat == null || r.lon == null) continue;
      final k = _latLonKey(r.lat!, r.lon!);
      grouped.putIfAbsent(k, () => []).add(r);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => a.localId.compareTo(b.localId));
    }

    final registroMarkers = grouped.entries
        .map((e) {
          final group = e.value;
          final first = group.first;
          final point = LatLng(first.lat!, first.lon!);
          final badgeText = _groupBadgeText(group);
          return Marker(
            point: point,
            width: 124,
            height: 72,
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showRegistrosGroupSheet(context, group),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _registroMapIdBadge(badgeText),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: DonLuisColors.secondary,
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          : const Icon(Icons.place,
                              color: Colors.white, size: 18),
                    ),
                  ],
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
        title: Text('Mapa: ${widget.plantillaNombre}'),
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
              initialZoom: pointsForBounds.isEmpty ? 10 : 13,
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
                        width: 28,
                        height: 28,
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

  void _showRegistrosGroupSheet(BuildContext context, List<Registro> group) {
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
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    title,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
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
                      return ListTile(
                        leading: Icon(
                          Icons.edit_note_outlined,
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
                        subtitle: Text(
                          _formatShortRegistroTime(r),
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                          ),
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
