import 'package:drift/drift.dart';
import '../../app_database.dart';
import '../../tables/master/lote_orillas_table.dart';

part 'lote_orillas_dao.g.dart';

@DriftAccessor(tables: [LoteOrillasTable])
class LoteOrillasDao extends DatabaseAccessor<AppDatabase> with _$LoteOrillasDaoMixin {
  LoteOrillasDao(super.db);

  Future<void> upsertMany(List<LoteOrillasTableCompanion> items) async {
    await batch((b) => b.insertAllOnConflictUpdate(loteOrillasTable, items));
  }

  Stream<List<LoteOrillasTableData>> watchAll() =>
      select(loteOrillasTable).watch();

  /// Orillas del lote (para BRIX cuando fenología = ORILLA).
  Future<List<LoteOrillasTableData>> getByLoteId(int idLote) {
    return (select(loteOrillasTable)..where((t) => t.idLote.equals(idLote)))
        .get();
  }

  Stream<List<LoteOrillasTableData>> watchByLoteId(int idLote) {
    return (select(loteOrillasTable)..where((t) => t.idLote.equals(idLote)))
        .watch();
  }

  Future<void> clear() => delete(loteOrillasTable).go();
}
