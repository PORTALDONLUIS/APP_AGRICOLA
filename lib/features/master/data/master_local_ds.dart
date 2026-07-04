import '../../../core/storage/drift/app_database.dart';
import '../../../core/storage/drift/daos/master/actividad_labores_dao.dart';
import '../../../core/storage/drift/daos/master/campanias_dao.dart';
import '../../../core/storage/drift/daos/master/lote_orillas_dao.dart';
import '../../../core/storage/drift/daos/master/lotes_dao.dart';
import '../../../core/storage/drift/daos/master/persona_tipos_dao.dart';
import '../../../core/storage/drift/daos/master/personas_dao.dart';
import '../../../core/storage/drift/daos/master/topico_consultas_dao.dart';
import '../../../core/storage/drift/daos/master/topico_empresas_dao.dart';
import '../../../core/storage/drift/daos/master/topico_medicamentos_dao.dart';
import '../../../core/storage/drift/daos/master/topico_pacientes_dao.dart';
import '../../../core/storage/drift/daos/master/variedades_dao.dart';

class MasterLocalDs {
  final CampaniasDao campaniasDao;
  final LotesDao lotesDao;
  final LoteOrillasDao loteOrillasDao;
  final VariedadesDao variedadesDao;
  final PersonaTiposDao personaTiposDao;
  final PersonasDao personasDao;
  final ActividadLaboresDao actividadLaboresDao;
  final TopicoEmpresasDao topicoEmpresasDao;
  final TopicoPacientesDao topicoPacientesDao;
  final TopicoConsultasDao topicoConsultasDao;
  final TopicoMedicamentosDao topicoMedicamentosDao;

  MasterLocalDs({
    required this.campaniasDao,
    required this.lotesDao,
    required this.loteOrillasDao,
    required this.variedadesDao,
    required this.personaTiposDao,
    required this.personasDao,
    required this.actividadLaboresDao,
    required this.topicoEmpresasDao,
    required this.topicoPacientesDao,
    required this.topicoConsultasDao,
    required this.topicoMedicamentosDao,
  });

  Future<void> upsertCampanias(List<CampaniasTableCompanion> items) =>
      campaniasDao.upsertMany(items);

  Future<void> upsertLotes(List<LotesTableCompanion> items) =>
      lotesDao.upsertMany(items);

  Future<void> upsertLoteOrillas(List<LoteOrillasTableCompanion> items) =>
      loteOrillasDao.upsertMany(items);

  Future<void> upsertVariedades(List<VariedadesTableCompanion> items) =>
      variedadesDao.upsertMany(items);

  Future<void> savePersonaTipos(List<PersonaTiposTableCompanion> items) =>
      personaTiposDao.upsertMany(items);

  Future<void> savePersonas(List<PersonasTableCompanion> items) =>
      personasDao.upsertMany(items);

  Future<void> saveActividadLabores(
    List<ActividadLaboresTableCompanion> items,
  ) => actividadLaboresDao.upsertMany(items);

  Future<void> saveTopicoEmpresas(List<TopicoEmpresasTableCompanion> items) =>
      topicoEmpresasDao.upsertMany(items);

  Future<void> saveTopicoPacientes(List<TopicoPacientesTableCompanion> items) =>
      topicoPacientesDao.upsertMany(items);

  Future<void> saveTopicoConsultas(List<TopicoConsultasTableCompanion> items) =>
      topicoConsultasDao.upsertMany(items);

  Future<void> saveTopicoMedicamentos(
    List<TopicoMedicamentosTableCompanion> items,
  ) => topicoMedicamentosDao.upsertMany(items);

  Stream<List<CampaniasTableData>> watchCampanias() => campaniasDao.watchAll();
  Stream<List<LotesTableData>> watchLotes() => lotesDao.watchAll();
  Stream<List<VariedadesTableData>> watchVariedades() =>
      variedadesDao.watchAll();
  Stream<List<PersonaTiposTableData>> watchPersonaTiposActivos() =>
      personaTiposDao.watchActivos();
  Stream<List<PersonasTableData>> watchPersonasActivas() =>
      personasDao.watchActivas();
  Stream<List<ActividadLaboresTableData>> watchActividadLaboresActivas() =>
      actividadLaboresDao.watchAll();
  Stream<List<ActividadLaboresTableData>> watchLaboresByActividad(
    String actividadId,
  ) => actividadLaboresDao.watchByActividad(actividadId);
  Stream<List<TopicoEmpresasTableData>> watchTopicoEmpresas() =>
      topicoEmpresasDao.watchAll();
  Stream<List<TopicoPacientesTableData>> watchTopicoPacientes() =>
      topicoPacientesDao.watchAll();
  Stream<List<TopicoConsultasTableData>> watchTopicoConsultas() =>
      topicoConsultasDao.watchAll();
  Stream<List<TopicoMedicamentosTableData>> watchTopicoMedicamentos() =>
      topicoMedicamentosDao.watchAll();
  Stream<List<PersonasTableData>> watchPersonasActivasByTipoCodigo(
    String codigo,
  ) => personasDao.watchActivasByTipoCodigo(codigo);
  Stream<List<PersonasTableData>> watchPersonasActivasByTipoId(int tipoId) =>
      personasDao.watchActivasByTipoId(tipoId);

  Future<List<VariedadesTableData>> getVariedades() => variedadesDao.getAll();
  Future<List<PersonaTiposTableData>> getPersonaTiposActivos() =>
      personaTiposDao.getActivos();
  Future<List<PersonasTableData>> getPersonasActivas() =>
      personasDao.getActivas();
  Future<List<ActividadLaboresTableData>> getActividadLaboresActivas() =>
      actividadLaboresDao.getAll();
  Future<List<TopicoEmpresasTableData>> getTopicoEmpresas() =>
      topicoEmpresasDao.getAll();
  Future<List<TopicoPacientesTableData>> getTopicoPacientes() =>
      topicoPacientesDao.getAll();
  Future<List<TopicoPacientesTableData>> searchTopicoPacientes(
    String query, {
    int limit = 20,
  }) => topicoPacientesDao.search(query, limit: limit);
  Future<List<TopicoConsultasTableData>> getTopicoConsultas() =>
      topicoConsultasDao.getAll();
  Future<List<TopicoMedicamentosTableData>> getTopicoMedicamentos() =>
      topicoMedicamentosDao.getAll();
  Future<List<PersonasTableData>> getPersonasActivasByTipoCodigo(
    String codigo,
  ) => personasDao.getActivasByTipoCodigo(codigo);
  Future<List<PersonasTableData>> getPersonasActivasByTipoId(int tipoId) =>
      personasDao.getActivasByTipoId(tipoId);

  Future<List<LoteOrillasTableData>> getOrillasByLoteId(int idLote) =>
      loteOrillasDao.getByLoteId(idLote);

  Stream<List<LoteOrillasTableData>> watchOrillasByLoteId(int idLote) =>
      loteOrillasDao.watchByLoteId(idLote);
}
