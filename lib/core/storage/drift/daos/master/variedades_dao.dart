import 'package:drift/drift.dart';
import '../../app_database.dart';

class VariedadesDao extends DatabaseAccessor<AppDatabase> {
  VariedadesDao(super.db);

  Future<void> upsertMany(List<VariedadesTableCompanion> items) async {
    await batch(
      (b) => b.insertAllOnConflictUpdate(db.variedadesTable, items),
    );
  }

  Stream<List<VariedadesTableData>> watchAll() =>
      db.select(db.variedadesTable).watch();

  Future<List<VariedadesTableData>> getAll() =>
      db.select(db.variedadesTable).get();
}
