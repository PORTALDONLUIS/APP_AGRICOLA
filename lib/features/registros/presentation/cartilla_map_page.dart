import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/providers.dart';
import '../domain/registro.dart';
import '../../../app/theme/donluis_theme.dart';
import '../../../core/geo/wkt_parser.dart';
import '../../../core/storage/drift/app_database.dart';
import '../../../shared/widgets/donluis_app_bar.dart';

const _fundoColors = [
  Color(0xFFFDD835),
  Color(0xFFFB8C00),
  Color(0xFFE53935),
  Color(0xFF8E24AA),
  Color(0xFF1E88E5),
  Color(0xFF00ACC1),
];

Color _colorForFundo(String idFundo) {
  final i = idFundo.hashCode.abs() % _fundoColors.length;
  return _fundoColors[i];
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
  List<_RegistroPoint> _registros = [];
  LatLng? _myLocation;
  StreamSubscription<Map<String, dynamic>>? _locationSub;
  bool _loading = true;
  StreamSubscription<List<Registro>>? _registrosSub;

  @override
  void initState() {
    super.initState();
    _loadLotes();
    _startLocationStream();
    _subscribeRegistros();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _registrosSub?.cancel();
    super.dispose();
  }

  Future<void> _loadLotes() async {
    setState(() => _loading = true);
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
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startLocationStream() {
    final loc = ref.read(locationServiceProvider);
    _locationSub?.cancel();
    _locationSub = loc.watchPositionStream(distanceFilter: 5).listen((geo) {
      if (mounted) {
        setState(() {
          _myLocation = LatLng(
            (geo['lat'] as num).toDouble(),
            (geo['lon'] as num).toDouble(),
          );
        });
      }
    });
    // Obtener posición inicial
    loc.tryGetHeaderGeo().then((geo) {
      if (mounted && geo != null) {
        setState(() {
          _myLocation = LatLng(
            (geo['lat'] as num).toDouble(),
            (geo['lon'] as num).toDouble(),
          );
        });
      }
    });
  }

  void _subscribeRegistros() {
    final local = ref.read(registrosLocalDSProvider);
    final userId = ref.read(currentUserIdProvider);
    _registrosSub?.cancel();
    _registrosSub = local
        .watchRegistrosWithLocation(plantillaId: widget.plantillaId, userId: userId)
        .listen((list) {
      if (mounted) {
        setState(() {
          _registros = list
              .where((r) => r.lat != null && r.lon != null)
              .map((r) => _RegistroPoint(
                    LatLng(r.lat!, r.lon!),
                    'Registro #${r.localId}',
                  ))
              .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: DonLuisAppBar(title: Text('Mapa: ${widget.plantillaNombre}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
          polygons.add(Polygon(
            points: ring,
            color: baseColor.withAlpha(128),
            borderColor: baseColor,
            borderStrokeWidth: 2,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ));
          allPoints.addAll(ring);
          final desc = lote.descripcion.trim();
          if (desc.isNotEmpty) {
            final center = _centroid(ring);
            labelMarkers.add(Marker(
              point: center,
              width: 80,
              height: 28,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: baseColor, width: 1),
                ),
                child: Text(
                  desc,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: baseColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ));
          }
        }
      }
    }

    final registroMarkers = _registros
        .map((r) => Marker(
              point: r.point,
              width: 32,
              height: 32,
              child: Container(
                decoration: BoxDecoration(
                  color: DonLuisColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(64), blurRadius: 4, spreadRadius: 1),
                  ],
                ),
                child: const Icon(Icons.place, color: Colors.white, size: 18),
              ),
            ))
        .toList();

    for (final r in _registros) allPoints.add(r.point);
    if (_myLocation != null) allPoints.add(_myLocation!);

    final mapController = MapController();

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
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: allPoints.isEmpty ? const LatLng(-33.5, -70.6) : _center(allPoints),
          initialZoom: allPoints.isEmpty ? 10 : 13,
          minZoom: 3,
          maxZoom: 19,
          onMapReady: () {
            if (allPoints.isNotEmpty) {
              final bounds = LatLngBounds.fromPoints(allPoints);
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
          if (polygons.isNotEmpty) PolygonLayer(polygons: polygons, polygonCulling: true),
          if (labelMarkers.isNotEmpty) MarkerLayer(markers: labelMarkers),
          if (registroMarkers.isNotEmpty) MarkerLayer(markers: registroMarkers),
          if (_myLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _myLocation!,
                  width: 28,
                  height: 28,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(64), blurRadius: 6, spreadRadius: 1),
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
    var lat = 0.0, lon = 0.0;
    for (final p in points) {
      lat += p.latitude;
      lon += p.longitude;
    }
    return LatLng(lat / points.length, lon / points.length);
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
}

class _RegistroPoint {
  final LatLng point;
  final String label;
  _RegistroPoint(this.point, this.label);
}
