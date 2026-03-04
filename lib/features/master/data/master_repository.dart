import 'package:drift/drift.dart';
import '../../../core/location/geo_utils.dart';
import '../../../core/storage/drift/app_database.dart';
import 'master_local_ds.dart';
import 'master_remote_ds.dart';

class MasterRepository {
  final MasterRemoteDs remote;
  final MasterLocalDs local;

  MasterRepository({required this.remote, required this.local});

  Future<void> syncBootstrap() async {
    final j = await remote.fetchBootstrap();

    final campList = (j['campanias'] as List? ?? const [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();

    final loteList = (j['lotes'] as List? ?? const [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();

    final campanias = campList.map((c) {
      final id = (c['idCampania'] ?? c['ID_CAMPANIA']).toString();
      final desc = (c['descripcion'] ?? c['DESCRIPCION']).toString();
      return CampaniasTableCompanion.insert(
        idCampania: id,
        descripcion: desc,
        updatedAt: const Value(null),
      );
    }).toList();

    final lotes = loteList.map((l) {
      final idLote = (l['idLote'] ?? l['ID_LOTE']) as int;
      final desc = (l['descripcion'] ?? l['DESCRIPCION']).toString();
      final areaRaw = (l['areaTotal'] ?? l['AREA_TOTAL']);
      final area = areaRaw == null ? null : double.tryParse(areaRaw.toString());
      final idFundo = (l['idFundo'] ?? l['ID_FUNDO'])?.toString() ?? '';
      final idVarRaw = l['idVariedad'] ?? l['ID_VARIEDAD'];
      final idVar = idVarRaw != null ? (idVarRaw is int ? idVarRaw : int.tryParse(idVarRaw.toString()) ?? 0) : 0;
      final cecoRaw = l['ceco'] ?? l['CECO'];
      final ceco = cecoRaw != null && cecoRaw.toString().isNotEmpty ? cecoRaw.toString() : '';
      final geomWkt = (l['geomWkt'] ?? l['GEOM_WKT'])?.toString();

      double? minLat, minLon, maxLat, maxLon;
      if (geomWkt != null && geomWkt.isNotEmpty) {
        final vertices = parseWktPolygon(geomWkt);
        if (vertices.isNotEmpty) {
          minLat = vertices.map((p) => p.lat).reduce((a, b) => a < b ? a : b);
          maxLat = vertices.map((p) => p.lat).reduce((a, b) => a > b ? a : b);
          minLon = vertices.map((p) => p.lon).reduce((a, b) => a < b ? a : b);
          maxLon = vertices.map((p) => p.lon).reduce((a, b) => a > b ? a : b);
        }
      }

      return LotesTableCompanion.insert(
        idLote: Value(idLote),
        descripcion: desc,
        areaTotal: Value(area),
        idFundo: idFundo,
        idVariedad: idVar,
        ceco: ceco,
        geomWkt: Value(geomWkt),
        minLat: Value(minLat),
        minLon: Value(minLon),
        maxLat: Value(maxLat),
        maxLon: Value(maxLon),
        updatedAt: const Value(null),
      );
    }).toList();

    await local.upsertCampanias(campanias);
    await local.upsertLotes(lotes);
  }
}
