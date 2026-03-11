import 'package:drift/drift.dart';

/// Catálogo de orillas por lote (sincronizado en bootstrap).
/// Usado en BRIX cuando fenología = ORILLA.
class LoteOrillasTable extends Table {
  IntColumn get idLoteOrilla => integer()();
  IntColumn get idLote => integer()();
  TextColumn get orillaCodigo => text()();
  TextColumn get orillaLabel => text()();
  TextColumn get perimetralDescripcion => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {idLoteOrilla};
}
