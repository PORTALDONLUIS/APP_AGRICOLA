import 'package:drift/drift.dart';

class LotesTable extends Table {
  IntColumn get idLote => integer()(); // ID_LOTE
  TextColumn get descripcion => text()(); // DESCRIPCION
  TextColumn get codigoLote => text().nullable()(); // CODIGO_LOTE
  TextColumn get lote => text().nullable()(); // LOTE
  TextColumn get subLote => text().nullable()(); // SUB_LOTE
  TextColumn get cultivo => text().nullable()(); // CULTIVO
  BoolColumn get estado => boolean().withDefault(const Constant(true))(); // ESTADO
  RealColumn get areaTotal => real().nullable()(); // AREA_TOTAL decimal
  TextColumn get idFundo => text()(); // ID_FUNDO
  IntColumn get idVariedad => integer()(); // ID_VARIEDAD (bigint) -> en Dart int
  TextColumn get ceco => text()(); // CECO
  TextColumn get geomWkt => text().nullable()(); // GEOM_WKT (WKT lon/lat)

  /// Bounding box del polígono (en grados, SRID 4326).
  /// Se usa para filtrar candidatos antes de hacer punto-en-polígono.
  RealColumn get minLat => real().nullable()();
  RealColumn get minLon => real().nullable()();
  RealColumn get maxLat => real().nullable()();
  RealColumn get maxLon => real().nullable()();

  IntColumn get updatedAt => integer().nullable()(); // opcional

  @override
  Set<Column> get primaryKey => {idLote};
}
