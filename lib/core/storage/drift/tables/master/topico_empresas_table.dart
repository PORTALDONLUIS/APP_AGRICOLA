import 'package:drift/drift.dart';

class TopicoEmpresasTable extends Table {
  TextColumn get idEmpresa => text()();
  TextColumn get razonSocial => text()();
  TextColumn get ruc => text().nullable()();
  TextColumn get nombreCorto => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {idEmpresa};
}
