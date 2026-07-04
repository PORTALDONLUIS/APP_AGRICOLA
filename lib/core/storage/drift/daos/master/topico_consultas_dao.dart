import 'package:drift/drift.dart';

import '../../app_database.dart';

class TopicoConsultasDao extends DatabaseAccessor<AppDatabase> {
  TopicoConsultasDao(super.db);

  Future<void> upsertMany(List<TopicoConsultasTableCompanion> items) async {
    await batch(
      (b) => b.insertAllOnConflictUpdate(db.topicoConsultasTable, items),
    );
  }

  Stream<List<TopicoConsultasTableData>> watchAll() {
    return (db.select(db.topicoConsultasTable)
          ..where((tbl) => tbl.activo.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.descripcion)]))
        .watch();
  }

  Future<List<TopicoConsultasTableData>> getAll() {
    return (db.select(db.topicoConsultasTable)
          ..where((tbl) => tbl.activo.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.descripcion)]))
        .get();
  }
}
