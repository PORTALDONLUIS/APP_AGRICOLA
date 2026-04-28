import 'package:drift/drift.dart';
import '../../../core/location/geo_utils.dart';
import '../../../core/log/file_logger.dart';
import '../../../core/storage/drift/app_database.dart';
import 'master_local_ds.dart';
import 'master_remote_ds.dart';
import '../../personas/data/personas_remote_ds.dart';

class MasterRepository {
  final MasterRemoteDs remote;
  final MasterLocalDs local;
  final PersonasRemoteDS personasRemote;

  MasterRepository({
    required this.remote,
    required this.local,
    required this.personasRemote,
  });

  Future<void> syncBootstrap({
    void Function(String message)? onProgress,
  }) async {
    onProgress?.call('Sincronizando campañas, lotes y catálogos...');
    final j = await remote.fetchBootstrap();

    final campList = (j['campanias'] as List? ?? const [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();

    final loteList = (j['lotes'] as List? ?? const [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();

    final orillaList = (j['loteOrillas'] as List? ?? const [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();

    final variedadRaw =
        j['variedades'] ?? j['VARIEDADES'] ?? j['variedad'] ?? j['VARIEDAD'];
    final variedadList = (variedadRaw is List ? variedadRaw : const [])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
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
      final codigoLote = (l['codigo_lote'] ?? l['CODIGO_LOTE'])?.toString();
      final lote = (l['lote'] ?? l['LOTE'])?.toString();
      final subLote = (l['sub_lote'] ?? l['SUB_LOTE'])?.toString();
      final cultivo = (l['cultivo'] ?? l['CULTIVO'])?.toString();
      final estadoRaw = l['estado'] ?? l['ESTADO'];
      final estado =
          estadoRaw == true ||
          estadoRaw == 1 ||
          (estadoRaw is String &&
              (estadoRaw.toLowerCase() == 'true' || estadoRaw == '1'));
      final areaRaw = (l['areaTotal'] ?? l['AREA_TOTAL']);
      final area = areaRaw == null ? null : double.tryParse(areaRaw.toString());
      final idFundo = (l['idFundo'] ?? l['ID_FUNDO'])?.toString() ?? '';
      final idVarRaw = l['idVariedad'] ?? l['ID_VARIEDAD'];
      final idVar = idVarRaw != null
          ? (idVarRaw is int
                ? idVarRaw
                : int.tryParse(idVarRaw.toString()) ?? 0)
          : 0;
      final cecoRaw = l['ceco'] ?? l['CECO'];
      final ceco = cecoRaw != null && cecoRaw.toString().isNotEmpty
          ? cecoRaw.toString()
          : '';
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
        codigoLote: Value(codigoLote),
        lote: Value(lote),
        subLote: Value(subLote),
        cultivo: Value(cultivo),
        estado: Value(estado),
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

    final loteOrillas = orillaList.map((o) {
      final idOrillaRaw = o['idLoteOrilla'] ?? o['ID_LOTE_ORILLA'];
      final idOrilla = idOrillaRaw is int
          ? idOrillaRaw
          : int.tryParse(idOrillaRaw.toString()) ?? 0;
      final idLoteRaw = o['idLote'] ?? o['ID_LOTE'];
      final idLote = idLoteRaw is int
          ? idLoteRaw
          : int.tryParse(idLoteRaw.toString()) ?? 0;
      final codigo =
          (o['orillaCodigo'] ?? o['ORILLA_CODIGO'])?.toString() ?? '';
      final label = (o['orillaLabel'] ?? o['ORILLA_LABEL'])?.toString() ?? '';
      final perimetral =
          (o['perimetralDescripcion'] ?? o['PERIMETRAL_DESCRIPCION'])
              ?.toString();
      final activoRaw = o['activo'] ?? o['ACTIVO'];
      final activo =
          activoRaw == true ||
          activoRaw == 1 ||
          (activoRaw is String && activoRaw.toLowerCase() == 'true');

      return LoteOrillasTableCompanion.insert(
        idLoteOrilla: Value(idOrilla),
        idLote: idLote,
        orillaCodigo: codigo,
        orillaLabel: label,
        perimetralDescripcion: Value(perimetral),
        activo: Value(activo),
      );
    }).toList();

    final variedades = variedadList.map((v) {
      final idRaw = v['id'] ?? v['ID'] ?? v['idVariedad'] ?? v['ID_VARIEDAD'];
      final id = idRaw is int ? idRaw : int.tryParse(idRaw.toString()) ?? 0;
      final descripcion =
          (v['descripcion'] ??
                  v['DESCRIPCION'] ??
                  v['variedad'] ??
                  v['VARIEDAD'])
              ?.toString() ??
          '';
      final fechaCreacion =
          (v['fecha_Creacion'] ?? v['FECHA_CREACION'] ?? v['createdAt'])
              ?.toString();
      return VariedadesTableCompanion.insert(
        id: Value(id),
        descripcion: descripcion,
        fechaCreacion: Value(fechaCreacion),
      );
    }).toList();

    await local.upsertCampanias(campanias);
    await local.upsertLotes(lotes);
    await local.upsertLoteOrillas(loteOrillas);
    await local.upsertVariedades(variedades);

    try {
      onProgress?.call('Sincronizando tipos de trabajador...');
      final personaTiposRaw = await personasRemote.fetchPersonaTipos();
      final personaTipos = personaTiposRaw.map((item) {
        final estadoRaw = item['estado'];
        final estado = estadoRaw == null
            ? true
            : estadoRaw == true ||
                  estadoRaw == 1 ||
                  (estadoRaw is String &&
                      (estadoRaw.toLowerCase() == 'true' || estadoRaw == '1'));
        return PersonaTiposTableCompanion.insert(
          id: Value((item['id'] as num).toInt()),
          codigo: (item['codigo'] ?? '').toString(),
          descripcion: (item['descripcion'] ?? '').toString(),
          estado: Value(estado),
        );
      }).toList();
      await local.savePersonaTipos(personaTipos);

      onProgress?.call('Sincronizando trabajadores...');
      final personasRaw = await personasRemote.fetchPersonas(estado: true);
      final personas = personasRaw.map((item) {
        final estadoRaw = item['estado'];
        final estado =
            estadoRaw == true ||
            estadoRaw == 1 ||
            (estadoRaw is String &&
                (estadoRaw.toLowerCase() == 'true' || estadoRaw == '1'));
        return PersonasTableCompanion.insert(
          id: Value((item['id'] as num).toInt()),
          dni: (item['dni'] ?? '').toString(),
          nombreCompleto: (item['nombre_completo'] ?? '').toString(),
          tipoId: (item['tipo_id'] as num).toInt(),
          tipoCodigo: (item['tipo_codigo'] ?? '').toString(),
          tipoDescripcion: (item['tipo_descripcion'] ?? '').toString(),
          estado: Value(estado),
        );
      }).toList();
      await local.savePersonas(personas);
    } catch (e, st) {
      await FileLogger.error(
        'Error sincronizando catálogo de personas. Se continúa con la data local disponible.',
        e,
        st,
      );
    }
  }
}
