import 'package:drift/drift.dart';

import '../../../core/storage/drift/app_database.dart';
import '../../../core/storage/drift/daos/plantillas_dao.dart';
import '../../../core/storage/drift/daos/sync_cursor_dao.dart';
import 'templates_remote_ds.dart';

class TemplatesRepository {
  TemplatesRepository({
    required this.remote,
    required this.plantillasDao,
    required this.syncCursorDao,
  });

  final TemplatesRemoteDS remote;
  final PlantillasDao plantillasDao;
  final SyncCursorDao syncCursorDao;

  // UI siempre lee de local (offline-first)
  Stream<List<PlantillasLocalData>> watchAssigned(int userId) {
    return plantillasDao.watchAssigned(userId);
  }

  Future<void> syncAssigned(int userId) async {
    // La lista de plantillas asignadas es pequeña y debe reflejar IsActive
    // incluso si se cambió sin actualizar UpdatedAt en SQL Server.
    final cursorKey = 'templates_assigned_$userId';
    final data = await remote.fetchAssigned();

    final serverTime = DateTime.parse(data['serverTime'] as String).toUtc();
    final items = (data['items'] as List).cast<Map<String, dynamic>>();
    final deleted = (data['deleted'] as Map?)?.cast<String, dynamic>() ?? {};

    final companions = <PlantillasLocalCompanion>[];
    final activeIds = <int>{};

    for (final it in items) {
      final plantillaId = it['plantillaId'] as int;
      final assignment = it['assignment'] as Map?;
      final assignmentActive =
          assignment == null ||
          ('${assignment['estado'] ?? 'Activo'}'.trim().toLowerCase() ==
                  'activo' &&
              assignment['deletedAt'] == null);
      final plantillaActive = (it['isActive'] as bool?) ?? true;
      final plantillaDeletedAt = it['deletedAt'] == null
          ? null
          : DateTime.parse(it['deletedAt'] as String).toUtc();
      final effectiveActive = plantillaActive && assignmentActive;
      final effectiveDeletedAt =
          plantillaDeletedAt ?? (assignmentActive ? null : serverTime);
      if (effectiveActive && effectiveDeletedAt == null) {
        activeIds.add(plantillaId);
      }

      companions.add(
        PlantillasLocalCompanion(
          plantillaId: Value(plantillaId),
          userId: Value(userId),
          codigo: Value(it['codigo'] as String?),
          nombre: Value(it['nombre'] as String?),
          descripcion: Value(it['descripcion'] as String?),
          version: Value((it['version'] as int?) ?? 1),
          isActive: Value(effectiveActive),
          updatedAt: Value(DateTime.parse(it['updatedAt'] as String).toUtc()),
          deletedAt: Value(effectiveDeletedAt),
        ),
      );
    }

    final deletedPlantillas =
        (deleted['plantillas'] as List?)?.cast<int>() ?? <int>[];

    // Transacción local
    await plantillasDao.db.transaction(() async {
      if (companions.isNotEmpty) {
        await plantillasDao.upsertMany(userId, companions);
      }

      if (deletedPlantillas.isNotEmpty) {
        await plantillasDao.markDeleted(userId, deletedPlantillas, serverTime);
      }

      await plantillasDao.markMissingAsDeleted(userId, activeIds, serverTime);
      await syncCursorDao.setCursor(cursorKey, serverTime);
    });
  }
}
