import 'package:drift/drift.dart';

import '../../app_database.dart';

class TopicoPacientesDao extends DatabaseAccessor<AppDatabase> {
  TopicoPacientesDao(super.db);

  Future<void> upsertMany(List<TopicoPacientesTableCompanion> items) async {
    await batch(
      (b) => b.insertAllOnConflictUpdate(db.topicoPacientesTable, items),
    );
  }

  Stream<List<TopicoPacientesTableData>> watchAll() {
    return (db.select(db.topicoPacientesTable)
          ..where((tbl) => tbl.activo.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombreCompleto)]))
        .watch();
  }

  Future<List<TopicoPacientesTableData>> getAll() {
    return (db.select(db.topicoPacientesTable)
          ..where((tbl) => tbl.activo.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombreCompleto)]))
        .get();
  }

  Future<List<TopicoPacientesTableData>> search(
    String query, {
    int limit = 20,
  }) {
    final normalized = query.trim();
    if (normalized.length < 3) return Future.value(const []);

    final q = normalized.toLowerCase();
    final queryBuilder = db.select(db.topicoPacientesTable)
      ..where(
        (tbl) =>
            tbl.activo.equals(true) &
            (tbl.dni.lower().contains(q) |
                tbl.nombreCompleto.lower().contains(q)),
      )
      ..orderBy([
        (tbl) => OrderingTerm(
          expression: tbl.dni.lower().like('$q%'),
          mode: OrderingMode.desc,
        ),
        (tbl) => OrderingTerm(
          expression: tbl.nombreCompleto.lower().like('$q%'),
          mode: OrderingMode.desc,
        ),
        (tbl) => OrderingTerm.asc(tbl.nombreCompleto),
      ])
      ..limit(limit);

    return queryBuilder.get();
  }
}
