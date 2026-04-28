import 'package:drift/drift.dart';

import '../../app_database.dart';

class PersonaTiposDao extends DatabaseAccessor<AppDatabase> {
  PersonaTiposDao(super.db);

  Future<void> upsertMany(List<PersonaTiposTableCompanion> items) async {
    await batch(
      (b) => b.insertAllOnConflictUpdate(db.personaTiposTable, items),
    );
  }

  Stream<List<PersonaTiposTableData>> watchAll() =>
      db.select(db.personaTiposTable).watch();

  Stream<List<PersonaTiposTableData>> watchActivos() {
    return (db.select(db.personaTiposTable)
          ..where((tbl) => tbl.estado.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.descripcion)]))
        .watch();
  }

  Future<List<PersonaTiposTableData>> getActivos() {
    return (db.select(db.personaTiposTable)
          ..where((tbl) => tbl.estado.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.descripcion)]))
        .get();
  }
}
