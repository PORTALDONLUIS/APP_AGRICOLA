import 'package:drift/drift.dart';

import '../../app_database.dart';

class TopicoEmpresasDao extends DatabaseAccessor<AppDatabase> {
  TopicoEmpresasDao(super.db);

  Future<void> upsertMany(List<TopicoEmpresasTableCompanion> items) async {
    await batch(
      (b) => b.insertAllOnConflictUpdate(db.topicoEmpresasTable, items),
    );
  }

  Stream<List<TopicoEmpresasTableData>> watchAll() {
    return (db.select(db.topicoEmpresasTable)
          ..where((tbl) => tbl.activo.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.idEmpresa)]))
        .watch();
  }

  Future<List<TopicoEmpresasTableData>> getAll() {
    return (db.select(db.topicoEmpresasTable)
          ..where((tbl) => tbl.activo.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.idEmpresa)]))
        .get();
  }
}
