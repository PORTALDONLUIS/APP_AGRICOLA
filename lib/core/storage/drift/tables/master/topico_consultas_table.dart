import 'package:drift/drift.dart';

class TopicoConsultasTable extends Table {
  IntColumn get codigo => integer()();
  TextColumn get descripcion => text()();
  TextColumn get tipoAtencion => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {codigo};
}
