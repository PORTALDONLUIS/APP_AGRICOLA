import 'package:drift/drift.dart';

import '../../app_database.dart';

class TopicoMedicamentosDao extends DatabaseAccessor<AppDatabase> {
  TopicoMedicamentosDao(super.db);

  Future<void> upsertMany(List<TopicoMedicamentosTableCompanion> items) async {
    await batch(
      (b) => b.insertAllOnConflictUpdate(db.topicoMedicamentosTable, items),
    );
  }

  Stream<List<TopicoMedicamentosTableData>> watchAll() {
    return (db.select(db.topicoMedicamentosTable)
          ..where((tbl) => tbl.activo.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.medicamento)]))
        .watch();
  }

  Future<List<TopicoMedicamentosTableData>> getAll() {
    return (db.select(db.topicoMedicamentosTable)
          ..where((tbl) => tbl.activo.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.medicamento)]))
        .get();
  }
}
