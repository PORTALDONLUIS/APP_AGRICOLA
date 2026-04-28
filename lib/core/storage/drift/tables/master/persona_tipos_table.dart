import 'package:drift/drift.dart';

class PersonaTiposTable extends Table {
  IntColumn get id => integer()();
  TextColumn get codigo => text()();
  TextColumn get descripcion => text()();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
