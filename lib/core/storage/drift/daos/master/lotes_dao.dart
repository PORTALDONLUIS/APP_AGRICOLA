import 'package:drift/drift.dart';
import '../../app_database.dart';
import '../../tables/master/lotes_table.dart';

part 'lotes_dao.g.dart';

@DriftAccessor(tables: [LotesTable])
class LotesDao extends DatabaseAccessor<AppDatabase> with _$LotesDaoMixin {
  LotesDao(super.db);

  Future<void> upsertMany(List<LotesTableCompanion> items) async {
    await batch((b) => b.insertAllOnConflictUpdate(lotesTable, items));
  }

  Stream<List<LotesTableData>> watchAll() => select(lotesTable).watch();

  Stream<List<LotesTableData>> watchByFundo(String idFundo) =>
      (select(lotesTable)..where((t) => t.idFundo.equals(idFundo))).watch();

  Future<void> clear() => delete(lotesTable).go();

  /// Lotes con geometría WKT (para mapa).
  Future<List<LotesTableData>> getAllWithGeom() {
    return (select(lotesTable)..where((t) => t.geomWkt.isNotNull())).get();
  }

  /// Lotes candidatos cuyo bounding box contiene el punto (lat, lon).
  Future<List<LotesTableData>> findCandidatesByBbox({
    required double lat,
    required double lon,
  }) {
    final q = select(lotesTable)
      ..where(
        (t) =>
            t.minLat.isSmallerOrEqualValue(lat) &
            t.maxLat.isBiggerOrEqualValue(lat) &
            t.minLon.isSmallerOrEqualValue(lon) &
            t.maxLon.isBiggerOrEqualValue(lon),
      );
    return q.get();
  }
}
