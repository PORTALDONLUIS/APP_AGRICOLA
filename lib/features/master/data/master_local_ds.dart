import '../../../core/storage/drift/app_database.dart';
import '../../../core/storage/drift/daos/master/campanias_dao.dart';
import '../../../core/storage/drift/daos/master/lote_orillas_dao.dart';
import '../../../core/storage/drift/daos/master/lotes_dao.dart';
import '../../../core/storage/drift/daos/master/variedades_dao.dart';

class MasterLocalDs {
  final CampaniasDao campaniasDao;
  final LotesDao lotesDao;
  final LoteOrillasDao loteOrillasDao;
  final VariedadesDao variedadesDao;

  MasterLocalDs({
    required this.campaniasDao,
    required this.lotesDao,
    required this.loteOrillasDao,
    required this.variedadesDao,
  });

  Future<void> upsertCampanias(List<CampaniasTableCompanion> items) =>
      campaniasDao.upsertMany(items);

  Future<void> upsertLotes(List<LotesTableCompanion> items) =>
      lotesDao.upsertMany(items);

  Future<void> upsertLoteOrillas(List<LoteOrillasTableCompanion> items) =>
      loteOrillasDao.upsertMany(items);

  Future<void> upsertVariedades(List<VariedadesTableCompanion> items) =>
      variedadesDao.upsertMany(items);

  Stream<List<CampaniasTableData>> watchCampanias() => campaniasDao.watchAll();
  Stream<List<LotesTableData>> watchLotes() => lotesDao.watchAll();
  Stream<List<VariedadesTableData>> watchVariedades() => variedadesDao.watchAll();

  Future<List<LoteOrillasTableData>> getOrillasByLoteId(int idLote) =>
      loteOrillasDao.getByLoteId(idLote);

  Stream<List<LoteOrillasTableData>> watchOrillasByLoteId(int idLote) =>
      loteOrillasDao.watchByLoteId(idLote);
}
