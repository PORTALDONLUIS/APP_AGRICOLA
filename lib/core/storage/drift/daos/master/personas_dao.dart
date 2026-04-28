import 'package:drift/drift.dart';

import '../../app_database.dart';

class PersonasDao extends DatabaseAccessor<AppDatabase> {
  PersonasDao(super.db);

  Future<void> upsertMany(List<PersonasTableCompanion> items) async {
    await batch((b) => b.insertAllOnConflictUpdate(db.personasTable, items));
  }

  Stream<List<PersonasTableData>> watchAll() => (db.select(
    db.personasTable,
  )..orderBy([(tbl) => OrderingTerm.asc(tbl.nombreCompleto)])).watch();

  Stream<List<PersonasTableData>> watchActivas() {
    return (db.select(db.personasTable)
          ..where((tbl) => tbl.estado.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombreCompleto)]))
        .watch();
  }

  Stream<List<PersonasTableData>> watchActivasByTipoCodigo(String tipoCodigo) {
    final normalized = tipoCodigo.trim().toUpperCase();
    return (db.select(db.personasTable)
          ..where(
            (tbl) =>
                tbl.estado.equals(true) &
                tbl.tipoCodigo.upper().equals(normalized),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombreCompleto)]))
        .watch();
  }

  Stream<List<PersonasTableData>> watchActivasByTipoId(int tipoId) {
    return (db.select(db.personasTable)
          ..where((tbl) => tbl.estado.equals(true) & tbl.tipoId.equals(tipoId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombreCompleto)]))
        .watch();
  }

  Future<List<PersonasTableData>> getActivas() {
    return (db.select(db.personasTable)
          ..where((tbl) => tbl.estado.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombreCompleto)]))
        .get();
  }

  Future<List<PersonasTableData>> getActivasByTipoCodigo(String tipoCodigo) {
    final normalized = tipoCodigo.trim().toUpperCase();
    return (db.select(db.personasTable)
          ..where(
            (tbl) =>
                tbl.estado.equals(true) &
                tbl.tipoCodigo.upper().equals(normalized),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombreCompleto)]))
        .get();
  }

  Future<List<PersonasTableData>> getActivasByTipoId(int tipoId) {
    return (db.select(db.personasTable)
          ..where((tbl) => tbl.estado.equals(true) & tbl.tipoId.equals(tipoId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombreCompleto)]))
        .get();
  }
}
