import 'dart:io';
import 'package:donluis_forms/core/storage/drift/tables/master/actividad_labores_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/master/campanias_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/master/lote_orillas_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/master/lotes_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/master/persona_tipos_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/master/personas_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/master/topico_consultas_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/master/topico_empresas_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/master/topico_medicamentos_table.dart';
import 'package:donluis_forms/core/storage/drift/tables/master/topico_pacientes_table.dart';
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
    PersonaTiposTable,
    PersonasTable,
    ActividadLaboresTable,
    TopicoEmpresasTable,
    TopicoPacientesTable,
    TopicoConsultasTable,
    TopicoMedicamentosTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Permite verificar transacciones con SQLite aislado, sin abrir la BD del equipo.
  AppDatabase.forTesting(super.executor);

  /// Evita `duplicate column name` si la migración se ejecutó de forma parcial o la
  /// columna ya existía (p. ej. builds intermedios / datos locales inconsistentes).
  Future<bool> _sqliteTableHasColumn(
    String tableName,
    String columnName,
  ) async {
    final rows = await customSelect(
      'PRAGMA table_info($tableName)',
      readsFrom: {lotesTable},
    ).get();
    for (final row in rows) {
      if (row.read<String>('name') == columnName) {
        return true;
      }
    }
    return false;
  }

  Future<void> _ensureTopicoPacienteSearchIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_topico_pacientes_dni '
      'ON topico_pacientes_table(dni)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_topico_pacientes_nombre '
      'ON topico_pacientes_table(nombre_completo)',
    );
  }

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('''
        CREATE TABLE IF NOT EXISTS packing_quality_catalog_local (
          id TEXT PRIMARY KEY NOT NULL,
          tipo TEXT NOT NULL,
          valor TEXT NOT NULL DEFAULT '',
          fundo TEXT NOT NULL DEFAULT '',
          codigo_lugar_produccion TEXT NOT NULL DEFAULT '',
          synced INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await customStatement('''
        UPDATE OR IGNORE packing_quality_catalog_local
        SET id='PLANTA|SUN FRUITS', valor='SUN FRUITS', synced=0
        WHERE tipo='PLANTA' AND UPPER(TRIM(valor))='ZOOMFLIX'
      ''');
      await customStatement('''
        DELETE FROM packing_quality_catalog_local
        WHERE tipo='PLANTA' AND UPPER(TRIM(valor))='ZOOMFLIX'
      ''');
      await customStatement('''
        INSERT OR IGNORE INTO packing_quality_catalog_local
          (id,tipo,valor,synced) VALUES ('PLANTA|SUN FRUITS','PLANTA','SUN FRUITS',0)
      ''');
      await _ensureTopicoPacienteSearchIndexes();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_registros_muestreo_dia '
        'ON registros_local(plantilla_id, user_id, lote_id, created_at, local_id) '
        'WHERE deleted_at IS NULL',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_registros_cola '
        'ON registros_local(user_id, template_key, estado, sync_status, local_id)',
      );
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
        await customStatement('DELETE FROM sync_cursor_local WHERE "key" = ?', [
          'MASTER_BOOTSTRAP_LAST_SYNC',
        ]);
      }

      // Master data (lotes): columnas de bounding box (min/max lat/lon)
      if (from < 5) {
        await m.addColumn(lotesTable, lotesTable.minLat);
        await m.addColumn(lotesTable, lotesTable.minLon);
        await m.addColumn(lotesTable, lotesTable.maxLat);
        await m.addColumn(lotesTable, lotesTable.maxLon);
        // Forzar nuevamente el bootstrap para rellenar bbox.
        await customStatement('DELETE FROM sync_cursor_local WHERE "key" = ?', [
          'MASTER_BOOTSTRAP_LAST_SYNC',
        ]);
      }

      // Catálogo de orillas por lote (BRIX).
      if (from < 6) {
        await m.createTable(loteOrillasTable);
        await customStatement('DELETE FROM sync_cursor_local WHERE "key" = ?', [
          'MASTER_BOOTSTRAP_LAST_SYNC',
        ]);
      }

      // Catálogo de variedades.
      if (from < 7) {
        await m.createTable(variedadesTable);
        await customStatement('DELETE FROM sync_cursor_local WHERE "key" = ?', [
          'MASTER_BOOTSTRAP_LAST_SYNC',
        ]);
      }

      // LOTE: columnas adicionales (codigo_lote, lote, sub_lote, cultivo, estado).
      if (from < 9) {
        final lotesSqlName = lotesTable.actualTableName;
        if (!await _sqliteTableHasColumn(lotesSqlName, 'codigo_lote')) {
          await m.addColumn(lotesTable, lotesTable.codigoLote);
        }
        if (!await _sqliteTableHasColumn(lotesSqlName, 'lote')) {
          await m.addColumn(lotesTable, lotesTable.lote);
        }
        if (!await _sqliteTableHasColumn(lotesSqlName, 'sub_lote')) {
          await m.addColumn(lotesTable, lotesTable.subLote);
        }
        if (!await _sqliteTableHasColumn(lotesSqlName, 'cultivo')) {
          await m.addColumn(lotesTable, lotesTable.cultivo);
        }
        if (!await _sqliteTableHasColumn(lotesSqlName, 'estado')) {
          await m.addColumn(lotesTable, lotesTable.estado);
        }
        await customStatement('DELETE FROM sync_cursor_local WHERE "key" = ?', [
          'MASTER_BOOTSTRAP_LAST_SYNC',
        ]);
      }

      if (from < 10) {
        await m.createTable(personaTiposTable);
        await m.createTable(personasTable);
        await customStatement('DELETE FROM sync_cursor_local WHERE "key" = ?', [
          'MASTER_BOOTSTRAP_LAST_SYNC',
        ]);
      }

      if (from < 11) {
        await customStatement(
          "ALTER TABLE registros_local "
          "ADD COLUMN client_record_id TEXT NOT NULL DEFAULT ''",
        );
        await customStatement(
          "UPDATE registros_local "
          "SET client_record_id = "
          "'legacy-' || local_id || '-' || abs(random()) "
          "WHERE client_record_id = ''",
        );
      }

      if (from < 12) {
        await m.createTable(actividadLaboresTable);
        await customStatement('DELETE FROM sync_cursor_local WHERE "key" = ?', [
          'MASTER_BOOTSTRAP_LAST_SYNC',
        ]);
      }

      if (from < 13) {
        await m.createTable(topicoEmpresasTable);
        await m.createTable(topicoPacientesTable);
        await m.createTable(topicoConsultasTable);
        await m.createTable(topicoMedicamentosTable);
        await customStatement('DELETE FROM sync_cursor_local WHERE "key" = ?', [
          'MASTER_BOOTSTRAP_LAST_SYNC',
        ]);
      }

      if (from < 14) {
        await m.addColumn(lotesTable, lotesTable.fundoDescripcion);
        await customStatement('DELETE FROM sync_cursor_local WHERE "key" = ?', [
          'MASTER_BOOTSTRAP_LAST_SYNC',
        ]);
      }
    },
  );

  Future<List<Map<String, dynamic>>> getPackingQualityCatalog(
    String tipo,
  ) async {
    final rows = await customSelect(
      'SELECT id,tipo,valor,fundo,codigo_lugar_produccion,synced '
      'FROM packing_quality_catalog_local WHERE tipo=? ORDER BY valor,fundo,codigo_lugar_produccion',
      variables: [Variable.withString(tipo)],
    ).get();
    return rows
        .map(
          (row) => <String, dynamic>{
            'id': row.read<String>('id'),
            'tipo': row.read<String>('tipo'),
            'valor': row.read<String>('valor'),
            'fundo': row.read<String>('fundo'),
            'codigoLugarProduccion': row.read<String>(
              'codigo_lugar_produccion',
            ),
            'synced': row.read<int>('synced') == 1,
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getPendingPackingQualityCatalog() async {
    final rows = await customSelect(
      'SELECT id,tipo,valor,fundo,codigo_lugar_produccion '
      'FROM packing_quality_catalog_local WHERE synced=0',
    ).get();
    return rows
        .map(
          (row) => <String, dynamic>{
            'id': row.read<String>('id'),
            'tipo': row.read<String>('tipo'),
            'valor': row.read<String>('valor'),
            'fundo': row.read<String>('fundo'),
            'codigoLugarProduccion': row.read<String>(
              'codigo_lugar_produccion',
            ),
          },
        )
        .toList();
  }

  Future<void> upsertPackingQualityCatalog(
    List<Map<String, dynamic>> items, {
    bool synced = true,
  }) async {
    await transaction(() async {
      for (final item in items) {
        final tipo = (item['tipo'] ?? '').toString().trim().toUpperCase();
        final valor = (item['valor'] ?? '').toString().trim();
        final fundo = (item['fundo'] ?? '').toString().trim();
        final codigo = (item['codigoLugarProduccion'] ?? '').toString().trim();
        final id = tipo == 'LUGAR_PRODUCCION'
            ? '$tipo|${fundo.toUpperCase()}|${codigo.toUpperCase()}'
            : '$tipo|${valor.toUpperCase()}';
        await customStatement(
          'INSERT INTO packing_quality_catalog_local '
          '(id,tipo,valor,fundo,codigo_lugar_produccion,synced) VALUES (?,?,?,?,?,?) '
          'ON CONFLICT(id) DO UPDATE SET valor=excluded.valor,fundo=excluded.fundo,'
          'codigo_lugar_produccion=excluded.codigo_lugar_produccion,'
          'synced=MAX(packing_quality_catalog_local.synced,excluded.synced)',
          [id, tipo, valor, fundo, codigo, synced ? 1 : 0],
        );
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'donluis_offline.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
