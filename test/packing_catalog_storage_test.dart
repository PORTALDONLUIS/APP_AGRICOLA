import 'package:donluis_forms/core/storage/drift/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'corrección local y sincronización retiran opciones obsoletas',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await db.upsertPackingQualityCatalog([
        {'tipo': 'ENVASE', 'valor': 'Prueba-musca'},
      ], synced: false);
      final pending = await db.getPackingQualityCatalog('ENVASE');
      await db.updatePendingPackingQualityCatalog(
        pending.single['id'].toString(),
        {'tipo': 'ENVASE', 'valor': 'Envase correcto'},
      );
      expect(
        (await db.getPackingQualityCatalog('ENVASE')).single['valor'],
        'Envase correcto',
      );
      expect(
        (await db.getPendingPackingQualityCatalog())
            .where((row) => row['tipo'] == 'ENVASE')
            .single['valor'],
        'Envase correcto',
      );

      await db.replacePackingQualityCatalog([
        {'tipo': 'ENVASE', 'valor': 'Envase correcto'},
      ]);
      expect(
        (await db.getPendingPackingQualityCatalog()).where(
          (row) => row['tipo'] == 'ENVASE',
        ),
        isEmpty,
      );
      await db.replacePackingQualityCatalog([]);
      expect((await db.getPackingQualityCatalog('ENVASE')), isEmpty);

      await db.upsertPackingQualityCatalog([
        {'tipo': 'ENVASE', 'valor': 'Opción equivocada'},
      ], synced: false);
      final removable = (await db.getPackingQualityCatalog('ENVASE')).single;
      await db.deletePendingPackingQualityCatalog(removable['id'].toString());
      expect((await db.getPackingQualityCatalog('ENVASE')), isEmpty);
    },
  );
}
