import 'package:drift/drift.dart';

class PersonasTable extends Table {
  IntColumn get id => integer()();
  TextColumn get dni => text()();
  TextColumn get nombreCompleto => text()();
  IntColumn get tipoId => integer()();
  TextColumn get tipoCodigo => text()();
  TextColumn get tipoDescripcion => text()();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
