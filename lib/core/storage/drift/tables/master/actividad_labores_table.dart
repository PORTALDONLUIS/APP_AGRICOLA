import 'package:drift/drift.dart';

class ActividadLaboresTable extends Table {
  TextColumn get actividadId => text()();
  TextColumn get actividadNombre => text()();
  TextColumn get laborId => text()();
  TextColumn get laborNombre => text()();
  RealColumn get costo => real().nullable()();
  RealColumn get rendimiento => real().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {actividadId, laborId};
}
