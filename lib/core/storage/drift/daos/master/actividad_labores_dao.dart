import 'package:drift/drift.dart';

import '../../app_database.dart';

class ActividadLaboresDao extends DatabaseAccessor<AppDatabase> {
  ActividadLaboresDao(super.db);

  Future<void> upsertMany(List<ActividadLaboresTableCompanion> items) async {
    await batch(
      (b) => b.insertAllOnConflictUpdate(db.actividadLaboresTable, items),
    );
  }

  Stream<List<ActividadLaboresTableData>> watchAll() {
    return (db.select(db.actividadLaboresTable)
          ..where((tbl) => tbl.activo.equals(true))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.actividadNombre),
            (tbl) => OrderingTerm.asc(tbl.laborNombre),
          ]))
        .watch();
  }

  Stream<List<ActividadLaboresTableData>> watchByActividad(String actividadId) {
    return (db.select(db.actividadLaboresTable)
          ..where(
            (tbl) =>
                tbl.activo.equals(true) & tbl.actividadId.equals(actividadId),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.laborNombre)]))
        .watch();
  }

  Future<List<ActividadLaboresTableData>> getAll() {
    return (db.select(db.actividadLaboresTable)
          ..where((tbl) => tbl.activo.equals(true))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.actividadNombre),
            (tbl) => OrderingTerm.asc(tbl.laborNombre),
          ]))
        .get();
  }
}
