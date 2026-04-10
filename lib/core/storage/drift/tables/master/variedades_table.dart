import 'package:drift/drift.dart';

class VariedadesTable extends Table {
  IntColumn get id => integer()(); // ID
  TextColumn get descripcion => text()(); // DESCRIPCION
  TextColumn get fechaCreacion => text().nullable()(); // FECHA_CREACION

  @override
  Set<Column> get primaryKey => {id};
}
