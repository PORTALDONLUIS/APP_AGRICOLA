import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';

import '../app_database.dart';
import '../tables/registros_table.dart';
import '../../../sync/sync_models.dart';
import '../../../../features/registros/domain/registro.dart';

part 'registros_dao.g.dart';

@DriftAccessor(tables: [RegistrosLocal])
class RegistrosDao extends DatabaseAccessor<AppDatabase> with _$RegistrosDaoMixin {
  RegistrosDao(super.db);

  Stream<List<Registro>> watchByPlantilla(int plantillaId, int userId) {
    final q = (select(registrosLocal)
      ..where((t) => t.plantillaId.equals(plantillaId) & t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]));
    return q.watch().map(_mapRows);
  }

  /// Registros con lat/lon (para mapa). Si plantillaId es null, trae todos del usuario.
  Stream<List<Registro>> watchRegistrosWithLocation({int? plantillaId, required int userId}) {
    final q = (select(registrosLocal)
      ..where((t) {
        var cond = t.userId.equals(userId) & t.lat.isNotNull() & t.lon.isNotNull();
        if (plantillaId != null) cond = cond & t.plantillaId.equals(plantillaId);
        return cond;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]));
    return q.watch().map(_mapRows);
  }

  Future<int> insertDraft({
    required int plantillaId,
    required String templateKey,
    required int userId,
  }) {
    final now = DateTime.now();
    return into(registrosLocal).insert(
      RegistrosLocalCompanion.insert(
        plantillaId: plantillaId,
        templateKey: Value(templateKey),
        userId: userId,
        createdAt: now,
        updatedAt: now,
        dataJson: const Value('{}'),
        estado: const Value('borrador'),
        syncStatus: const Value('local'),
      ),
    );
  }


  Future<Registro> getByLocalId(int localId) async {
    final row = await (select(registrosLocal)..where((t) => t.localId.equals(localId))).getSingle();
    return _mapRow(row);
  }

  Future<void> updateRegistro({
    required int localId,
    required Map<String, dynamic> dataJson,
    required EstadoRegistro estado,
    required SyncStatus syncStatus,
    String? campaniaId,
    int? loteId,
    double? lat,
    double? lon,
  }) async {
    // Leer estado/syncStatus actual para evitar degradar un registro ya "listo/pending"
    final existing = await (select(registrosLocal)
          ..where((t) => t.localId.equals(localId)))
        .getSingle();

    var nextEstado = estado.name;
    var nextSyncStatus = syncStatus.name;

    // Si ya está marcado como listo/pending y nos llega un guardado como borrador/local,
    // preservamos el estado/syncStatus actuales.
    const listoDb = 'listo';
    const pendingDb = 'pending';
    const borradorDb = 'borrador';
    const localDb = 'local';

    if (existing.estado == listoDb &&
        existing.syncStatus == pendingDb &&
        estado.name == borradorDb &&
        syncStatus.name == localDb) {
      nextEstado = existing.estado;
      nextSyncStatus = existing.syncStatus;
    }

    await (update(registrosLocal)..where((t) => t.localId.equals(localId))).write(
      RegistrosLocalCompanion(
        dataJson: Value(jsonEncode(dataJson)),
        estado: Value(nextEstado),
        syncStatus: Value(nextSyncStatus),
        campaniaId: Value(campaniaId),
        loteId: Value(loteId),
        lat: Value(lat),
        lon: Value(lon),
      ),
    );

    debugPrint(
        'DAO.updateRegistro localId=$localId estado=$nextEstado syncStatus=$nextSyncStatus dataJsonLen=${jsonEncode(dataJson).length}');
  }


  /* Future<void> updateRegistro({
    required int localId,
    required Map<String, dynamic> dataJson,
    required EstadoRegistro estado,
    required SyncStatus syncStatus,
  }) async {
    final now = DateTime.now();
    await (update(registrosLocal)..where((t) => t.localId.equals(localId))).write(
      RegistrosLocalCompanion(
        dataJson: Value(jsonEncode(dataJson)),
        estado: Value(estadoToDb(estado)),
        syncStatus: Value(syncStatusToDb(syncStatus)),
        updatedAt: Value(now),
      ),
    );
  }*/

  Future<List<Registro>> listPending({int? plantillaId, required int userId}) async {
    final q = select(registrosLocal)
      ..where((t) => t.syncStatus.equals('pending') & t.userId.equals(userId));

    if (plantillaId != null) {
      q.where((t) => t.plantillaId.equals(plantillaId));
    }

    q.orderBy([(t) => OrderingTerm.asc(t.updatedAt)]);

    final rows = await q.get();
    return _mapRows(rows);
  }

  Future<List<RegistrosLocalData>> listSyncQueue({int? plantillaId, required int userId}) {
    final q = select(registrosLocal)
      ..where((t) =>
      t.userId.equals(userId) &
      t.estado.equals('listo') &
      (t.syncStatus.equals('pending') | t.syncStatus.equals('failed')));

    if (plantillaId != null) {
      q.where((t) => t.plantillaId.equals(plantillaId));
    }

    q.orderBy([(t) => OrderingTerm.asc(t.updatedAt)]);
    return q.get();
  }

    /// Registros por templateKey y usuario (para reportes: luego filtrar por día y estado).
  Future<List<Registro>> listByTemplateKeyAndUser(String templateKey, int userId) async {
    final q = select(registrosLocal)
      ..where((t) => t.templateKey.equals(templateKey) & t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]);
    final rows = await q.get();
    return _mapRows(rows);
  }

  /// Registros ya sincronizados (tienen serverId). Para subir fotos pendientes.
  Future<List<Registro>> listWithServerId({int? plantillaId, String? templateKey, required int userId}) async {
    var q = select(registrosLocal)..where((t) => t.serverId.isNotNull() & t.userId.equals(userId));
    if (plantillaId != null) {
      q = q..where((t) => t.plantillaId.equals(plantillaId));
    }
    if (templateKey != null) {
      q = q..where((t) => t.templateKey.equals(templateKey));
    }
    q.orderBy([(t) => OrderingTerm.asc(t.updatedAt)]);
    final rows = await q.get();
    return _mapRows(rows);
  }


  Future<int> updateDataJson({
    required int localId,
    required String dataJson,
  }) {
    return (update(registrosLocal)
      ..where((t) => t.localId.equals(localId)))
        .write(RegistrosLocalCompanion(
      dataJson: Value(dataJson),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Actualiza solo dataJson sin cambiar syncStatus (para fotos en registros ya synced).
  Future<int> updateDataJsonPreservingSyncStatus({
    required int localId,
    required String dataJson,
  }) {
    return (update(registrosLocal)
      ..where((t) => t.localId.equals(localId)))
        .write(RegistrosLocalCompanion(
      dataJson: Value(dataJson),
      updatedAt: Value(DateTime.now()),
    ));
  }
  
  Future<int> markAsReadyForSync({required int localId}) {
    return (update(registrosLocal)
      ..where((t) => t.localId.equals(localId)))
        .write(
      RegistrosLocalCompanion(
        // Estado que la cola de sync espera para tomar el registro
        estado: const Value('listo'),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }



  Future<void> markSynced(int localId, int serverId) async {
    await (update(registrosLocal)..where((t) => t.localId.equals(localId))).write(
      RegistrosLocalCompanion(
        serverId: Value(serverId),
        syncStatus: const Value('synced'),
        syncError: const Value(null),
      ),
    );
  }

  Future<void> markFailed(int localId, String error) async {
    final now = DateTime.now();
    await (update(registrosLocal)..where((t) => t.localId.equals(localId))).write(
      RegistrosLocalCompanion(
        syncStatus: const Value('failed'),
        syncError: Value(error),
        syncAttempts: const Value.absent(), // lo incrementamos abajo
        updatedAt: Value(now),
      ),
    );

    // incrementar intentos (simple y claro)
    await customUpdate(
      'UPDATE registros_local SET sync_attempts = sync_attempts + 1 WHERE local_id = ?',
      variables: [Variable<int>(localId)],
      updates: {registrosLocal},
    );
  }

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

  /// Observa un registro por localId, útil para refrescar formularios en vivo.
  Stream<Registro> watchByLocalId(int localId) {
    final q = select(registrosLocal)..where((t) => t.localId.equals(localId));
    return q.watchSingle().map(_mapRow);
  }

  /// Elimina un registro local por localId (borrado físico).
  Future<int> deleteByLocalId(int localId) {
    return (delete(registrosLocal)..where((t) => t.localId.equals(localId))).go();
  }
}
