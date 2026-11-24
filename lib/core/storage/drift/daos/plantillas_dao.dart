import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/plantillas_table.dart';

part 'plantillas_dao.g.dart';

@DriftAccessor(tables: [PlantillasLocal])
class PlantillasDao extends DatabaseAccessor<AppDatabase>
    with _$PlantillasDaoMixin {
  PlantillasDao(super.db);

  Stream<List<PlantillasLocalData>> watchAssigned(int userId) {
    final q = (select(plantillasLocal)
      ..where((t) => t.userId.equals(userId))
      ..where((t) => t.deletedAt.isNull())
      ..where((t) => t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.nombre)]));
    return q.watch();
  }

  Future<void> upsertMany(
    int userId,
    List<PlantillasLocalCompanion> rows,
  ) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(plantillasLocal, rows);
    });
  }

  Future<int> countByUser(int userId) async {
    final q = selectOnly(plantillasLocal)
      ..addColumns([plantillasLocal.plantillaId.count()])
      ..where(plantillasLocal.userId.equals(userId))
      ..where(plantillasLocal.deletedAt.isNull())
      ..where(plantillasLocal.isActive.equals(true));
    final row = await q.getSingle();
    return row.read(plantillasLocal.plantillaId.count()) ?? 0;
  }

  Future<void> markDeleted(int userId, List<int> ids, DateTime at) async {
    if (ids.isEmpty) return;
    await (update(plantillasLocal)
          ..where((t) => t.userId.equals(userId) & t.plantillaId.isIn(ids)))
        .write(PlantillasLocalCompanion(deletedAt: Value(at)));
  }
}
