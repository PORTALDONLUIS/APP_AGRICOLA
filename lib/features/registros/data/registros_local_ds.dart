import 'package:flutter/cupertino.dart';

import '../../../core/storage/drift/app_database.dart';
import '../domain/registro.dart';
import '../../../core/sync/sync_models.dart';
import '../../../core/storage/drift/daos/registros_dao.dart';

class RegistrosLocalDS {
  final RegistrosDao dao;
  RegistrosLocalDS(this.dao);

  Stream<List<Registro>> watchByPlantilla(int plantillaId, int userId) => dao.watchByPlantilla(plantillaId, userId);

  Stream<List<Registro>> watchRegistrosWithLocation({int? plantillaId, required int userId}) =>
      dao.watchRegistrosWithLocation(plantillaId: plantillaId, userId: userId);

  Future<int> createDraft({required int plantillaId, required String templateKey, required int userId}) =>
      dao.insertDraft(plantillaId: plantillaId, templateKey: templateKey, userId: userId);

  Future<Registro> getByLocalId(int localId) => dao.getByLocalId(localId);

  Future<List<Registro>> listWithServerId({int? plantillaId, String? templateKey, required int userId}) =>
      dao.listWithServerId(plantillaId: plantillaId, templateKey: templateKey, userId: userId);

  Future<void> updateDataJsonPreservingSyncStatus(int localId, String dataJson) async {
    await dao.updateDataJsonPreservingSyncStatus(localId: localId, dataJson: dataJson);
  }

/*  Future<Registro> getByLocalId(int localId) async {
    final r = await dao.getByLocalId(localId);

    // si quieres, persistimos el json estándar (lazy migration)
    final normalized = r.normalizedPayload();
    final normalizedJson = jsonEncode(normalized);

    if (normalizedJson != r.dataJson) {
      await dao.updateDataJson(localId: localId, dataJson: normalizedJson);
      return Registro(
        localId: r.localId,
        serverId: r.serverId,
        plantillaId: r.plantillaId,
        templateKey: r.templateKey,
        userId: r.userId,
        campaniaId: r.campaniaId,
        loteId: r.loteId,
        lat: r.lat,
        lon: r.lon,
        estado: r.estado,
        syncStatus: r.syncStatus,
        syncError: r.syncError,
        syncAttempts: r.syncAttempts,
        dataJson: normalizedJson,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
      );
    }
    return r;
  }*/

  Future<void> saveLocal({
    required int localId,
    required Map<String, dynamic> data,
    required EstadoRegistro estado,
    required SyncStatus syncStatus,
  }) async {
    // Normalizamos el payload a la forma estándar { payloadVersion, header, body }
    Map<String, dynamic> payload;
    if (data.containsKey('payloadVersion')) {
      // Copia defensiva para no mutar el mapa original que viene del notifier
      payload = Map<String, dynamic>.from(data);
    } else {
      payload = {
        'payloadVersion': 1,
        'header': <String, dynamic>{},
        'body': data,
      };
    }

    // Asegurar header y setear fechaEjecucion si no existe (o es null/0)
    final rawHeader = payload['header'];
    final header = (rawHeader is Map)
        ? Map<String, dynamic>.from(rawHeader)
        : <String, dynamic>{};

    final existingFecha = header['fechaEjecucion'];
    final needsFecha = existingFecha == null ||
        (existingFecha is num && existingFecha == 0);
    if (needsFecha) {
      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      header['fechaEjecucion'] = nowMs;
      payload['header'] = header;
      debugPrint('RegistrosLocalDS.saveLocal set header.fechaEjecucion=$nowMs (localId=$localId)');
    } else {
      debugPrint('RegistrosLocalDS.saveLocal keeps existing header.fechaEjecucion=$existingFecha (localId=$localId)');
    }

    debugPrint('RegistrosLocalDS.saveLocal localId=$localId');
    debugPrint('data keys=${data.keys}');
    debugPrint('dataJson=$payload');

    // ✅ Paso B: copiar header → columnas (contexto estructural)
    // (usamos el header ya normalizado/actualizado)

    // final int? campaniaId = (header['campaniaId'] as num?)?.toInt();
    // final int? campaniaId = _toInt(header['campaniaId']); // si es "CAMP2026" => null (ok)
    final String? campaniaId = header['campaniaId']?.toString();
    // final int? loteId = (header['loteId'] as num?)?.toInt();
    final int? loteId = _toInt(header['loteId']);
    final double? lat = (header['lat'] as num?)?.toDouble();
    final double? lon = (header['lon'] as num?)?.toDouble();

    await dao.updateRegistro(
      localId: localId,
      dataJson: payload,
      estado: estado,
      syncStatus: syncStatus,

      campaniaId: campaniaId,
      loteId: loteId,
      lat: lat,
      lon: lon,
    );
  }


  /*Future<void> saveLocal({
    required int localId,
    required Map<String, dynamic> data,
    required EstadoRegistro estado,
    required SyncStatus syncStatus,
  }) =>
      dao.updateRegistro(localId: localId, dataJson: data, estado: estado, syncStatus: syncStatus);*/

  Future<List<Registro>> listPending({int? plantillaId, required int userId}) => dao.listPending(plantillaId: plantillaId, userId: userId);

  Future<List<Registro>> listSyncQueue({int? plantillaId, required int userId}) async {
    final rows = await dao.listSyncQueue(plantillaId: plantillaId, userId: userId);
    return _mapRows(rows);
  }

  Future<void> updateDataJson(int localId, String dataJson) async {
    await dao.updateDataJson(localId: localId, dataJson: dataJson);
  }
  Future<void> markAsReadyForSync(int localId) async {
    await dao.markAsReadyForSync(localId: localId);
  }

  Future<void> markSynced(int localId, int serverId) => dao.markSynced(localId, serverId);

  Future<void> markFailed(int localId, String error) => dao.markFailed(localId, error);

  Stream<Registro> watchByLocalId(int localId) => dao.watchByLocalId(localId);

  List<Registro> _mapRows(List<RegistrosLocalData> rows) => rows.map(_mapRow).toList();

  Registro _mapRow(RegistrosLocalData r) {
    return Registro(
      localId: r.localId,
      serverId: r.serverId,
      plantillaId: r.plantillaId,
      templateKey: r.templateKey,
      userId: r.userId,
      campaniaId: r.campaniaId,
      loteId: r.loteId,
      lat: r.lat,
      lon: r.lon,
      estado: estadoFromDb(r.estado),
      syncStatus: syncStatusFromDb(r.syncStatus),
      syncError: r.syncError,
      syncAttempts: r.syncAttempts,
      dataJson: r.dataJson,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
    );
  }

  Future<int> duplicateAsNew({
    required int fromLocalId,
    required Set<String> plusOneReplicableHeaderKeys,
    required Set<String> plusOneReplicableBodyKeys,
  }) async {
    final currentReg = await getByLocalId(fromLocalId);

    final newLocalId = await createDraft(
      plantillaId: currentReg.plantillaId,
      templateKey: currentReg.templateKey,
      userId: currentReg.userId,
    );

    final original = currentReg.normalizedPayload(); // (tu método en Registro)
    final originalHeader = Map<String, dynamic>.from(original['header'] ?? {});
    final originalBody = Map<String, dynamic>.from(original['body'] ?? {});

    // ✅ header nuevo desde columnas BD (fuente de verdad)
    final headerFromColumns = <String, dynamic>{
      'plantillaId': currentReg.plantillaId,
      'userId': currentReg.userId,
      'campaniaId': currentReg.campaniaId,
      'loteId': currentReg.loteId,
      'lat': currentReg.lat,
      'lon': currentReg.lon,
      'fechaEjecucion': null,
    };

    // ✅ copiamos SOLO las keys permitidas del header (si decides permitirlo)
    final newHeader = <String, dynamic>{};
    for (final k in plusOneReplicableHeaderKeys) {
      // si es key estándar BD, usa columnas; si no, copia del header original
      newHeader[k] = headerFromColumns.containsKey(k) ? headerFromColumns[k] : originalHeader[k];
    }

    // ✅ copiamos SOLO las keys permitidas del body
    final newBody = <String, dynamic>{};
    for (final k in plusOneReplicableBodyKeys) {
      if (originalBody.containsKey(k)) newBody[k] = originalBody[k];
    }

    final payload = {
      'payloadVersion': 1,
      'header': newHeader,
      'body': newBody,
    };

    await saveLocal(
      localId: newLocalId,
      data: payload,
      estado: EstadoRegistro.borrador,
      syncStatus: SyncStatus.local,
    );

    return newLocalId;
  }


}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}
