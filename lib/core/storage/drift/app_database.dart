import 'dart:io';
import 'package:donluis_forms/core/storage/drift/tables/master/campanias_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/master/lotes_table.dart';
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
    LotesTable
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

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
