import 'dart:io';
import 'package:donluis_forms/core/storage/drift/tables/master/campanias_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/master/lote_orillas_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/master/lotes_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/master/variedades_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/plantillas_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/registros_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/sync_cursor_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    RegistrosLocal,
    PlantillasLocal,
    SyncCursorLocal,
    CampaniasTable,
    LotesTable,
    LoteOrillasTable,
    VariedadesTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Si estás en DEV y no te importa perder registros locales,
      // recreamos la tabla para corregir campaniaId (int -> text)
      if (from < 3) {
        await m.deleteTable('registros_local');
        await m.createTable(registrosLocal);
      }

      // Master data (lotes): nueva columna geomWkt
      if (from < 4) {
        await m.addColumn(lotesTable, lotesTable.geomWkt);
        // Forzar re-sync del bootstrap (campañas/lotes) para poblar `geomWkt`
        // sin borrar registros locales.
        await customStatement(
          'DELETE FROM sync_cursor_local WHERE "key" = ?',
          ['MASTER_BOOTSTRAP_LAST_SYNC'],
        );
      }

      // Master data (lotes): columnas de bounding box (min/max lat/lon)
      if (from < 5) {
        await m.addColumn(lotesTable, lotesTable.minLat);
        await m.addColumn(lotesTable, lotesTable.minLon);
        await m.addColumn(lotesTable, lotesTable.maxLat);
        await m.addColumn(lotesTable, lotesTable.maxLon);
        // Forzar nuevamente el bootstrap para rellenar bbox.
        await customStatement(
          'DELETE FROM sync_cursor_local WHERE "key" = ?',
          ['MASTER_BOOTSTRAP_LAST_SYNC'],
        );
      }

      // Catálogo de orillas por lote (BRIX).
      if (from < 6) {
        await m.createTable(loteOrillasTable);
        await customStatement(
          'DELETE FROM sync_cursor_local WHERE "key" = ?',
          ['MASTER_BOOTSTRAP_LAST_SYNC'],
        );
      }

      // Catálogo de variedades.
      if (from < 7) {
        await m.createTable(variedadesTable);
        await customStatement(
          'DELETE FROM sync_cursor_local WHERE "key" = ?',
          ['MASTER_BOOTSTRAP_LAST_SYNC'],
        );
      }

      // LOTE: columnas adicionales (codigo_lote, lote, sub_lote, cultivo, estado).
      if (from < 9) {
        await m.addColumn(lotesTable, lotesTable.codigoLote);
        await m.addColumn(lotesTable, lotesTable.lote);
        await m.addColumn(lotesTable, lotesTable.subLote);
        await m.addColumn(lotesTable, lotesTable.cultivo);
        await m.addColumn(lotesTable, lotesTable.estado);
        await customStatement(
          'DELETE FROM sync_cursor_local WHERE "key" = ?',
          ['MASTER_BOOTSTRAP_LAST_SYNC'],
        );
      }
    },
  );

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'donluis_offline.sqlite'));
    return NativeDatabase.createInBackground(file);
  });

}
