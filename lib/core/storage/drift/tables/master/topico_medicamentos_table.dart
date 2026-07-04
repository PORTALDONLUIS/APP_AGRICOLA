import 'package:drift/drift.dart';

class TopicoMedicamentosTable extends Table {
  IntColumn get codigo => integer()();
  TextColumn get medicamento => text()();
  TextColumn get tipoPresentacion => text().nullable()();
  TextColumn get lugar => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {codigo};
}
