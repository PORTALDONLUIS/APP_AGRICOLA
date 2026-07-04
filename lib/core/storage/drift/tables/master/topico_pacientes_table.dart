import 'package:drift/drift.dart';

class TopicoPacientesTable extends Table {
  TextColumn get idCodigoGeneral => text()();
  TextColumn get dni => text()();
  TextColumn get nombreCompleto => text()();
  TextColumn get genero => text().nullable()();
  TextColumn get idEmpresa => text().nullable()();
  TextColumn get empresa => text().nullable()();
  TextColumn get idPlanilla => text().nullable()();
  TextColumn get planilla => text().nullable()();
  TextColumn get idCargo => text().nullable()();
  TextColumn get cargo => text().nullable()();
  TextColumn get idGrupoTrabajo => text().nullable()();
  TextColumn get area => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {idCodigoGeneral};
}
