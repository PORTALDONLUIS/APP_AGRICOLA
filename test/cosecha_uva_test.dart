import 'package:flutter/material.dart';
import 'package:donluis_forms/app/form_registry.dart';
import 'package:donluis_forms/app/router/app_router.dart';
import 'package:donluis_forms/features/cartillas/presentation/cartilla_form_page.dart';
import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donluis_forms/app/providers.dart';
import 'package:donluis_forms/core/storage/drift/app_database.dart';
import 'package:donluis_forms/core/storage/drift/daos/registros_dao.dart';
import 'package:donluis_forms/features/registros/data/registros_local_ds.dart';
import 'package:donluis_forms/features/registros/data/registros_remote_ds.dart';
import 'package:donluis_forms/features/registros/data/brix_sync_batch.dart';
import 'package:donluis_forms/features/registros/presentation/registros_sync_controller.dart';
import 'package:donluis_forms/features/plantillas/cosecha_uva/domain/cartilla_cosecha_uva_config.dart';
import 'package:donluis_forms/features/plantillas/cosecha_uva/domain/cartilla_cosecha_uva_payload.dart';
import 'package:donluis_forms/features/plantillas/cosecha_uva/domain/cosecha_uva_metrics.dart';
import 'package:donluis_forms/features/plantillas/cosecha_uva/presentation/cartilla_cosecha_uva_form_provider.dart';

const key = 'cartilla_cosecha_uva';
final config = CartillaCosechaUvaConfig();
Map<String, dynamic> sample({
  int count = 14,
  List<Map<String, dynamic>> photos = const [],
}) {
  final body = <String, dynamic>{
    'conformados': count,
    'paloNegro': 2,
    'pudricion': 1,
    'operario': '11',
    'supervisor': '12',
    'variedad': 5,
    'codigoLimpiador': 'L-01',
    'fecha': '27/10/2026',
    'hora': '09:15',
    'restosVegetales': ['HOJAS'],
    'fotos': photos,
  };
  return {
    'payloadVersion': 1,
    'header': {
      'plantillaId': 9,
      'userId': 7,
      'loteId': '22',
      'campaniaId': '2026',
      'fechaEjecucion': 1793109600000,
      'lat': -14.01959,
      'lon': -75.75971,
    },
    'body': {...body, ...cosechaUvaMetrics(body)},
  };
}

class Remote implements RegistrosRemoteDS {
  int calls = 0, photos = 0, maxBlock = 0;
  @override
  Future<List<BrixSyncAcknowledgement>> syncBrixBatch(
    BrixSyncBatch block,
  ) async {
    calls++;
    if (block.items.length > maxBlock) maxBlock = block.items.length;
    final contexts = block.request['contexts'] as List;
    for (final r in block.request['records'] as List) {
      final record = r as Map;
      final ctx = contexts[record['context']] as Map;
      final data = <String, dynamic>{
        'payloadVersion': 1,
        'header': {...ctx['header'] as Map, ...record['header'] as Map},
        'body': {...ctx['body'] as Map, ...record['body'] as Map},
      };
      expect(brixSnapshotRevision(key, data), record['revision']);
    }
    return [
      for (final item in block.items)
        BrixSyncAcknowledgement(
          clientRecordId: item.registro.clientRecordId,
          revision: item.revision,
          status: 'synced',
          serverRegistroId: 10000 + item.registro.localId,
        ),
    ];
  }

  @override
  Future<String> uploadFoto({
    required int serverRegistroId,
    required int slot,
    required File file,
  }) async {
    photos++;
    return 'https://example.invalid/$serverRegistroId/$slot.jpg';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProviderContainer container(RegistrosLocalDS local, Remote remote) =>
    ProviderContainer(
      overrides: [
        registrosLocalDSProvider.overrideWithValue(local),
        registrosRemoteDSProvider.overrideWithValue(remote),
        currentUserIdProvider.overrideWithValue(7),
      ],
    );
void main() {
  test('el payload conserva contexto, medidas y evidencias al reabrirse', () {
    final original = sample();
    expect(
      CartillaCosechaUvaPayload.fromJsonString(jsonEncode(original)).toJson(),
      original,
    );
  });

  testWidgets('la ruta real abre Cosecha Uva en Calidad', (tester) async {
    final name = FormRegistry.routeFor('cartilla-cosecha-uva');
    expect(name, '/calidad/cartilla-cosecha-uva');
    final route = onGenerateAppRoute(
      RouteSettings(name: name, arguments: {'localId': 123}),
    );
    expect(route, isA<MaterialPageRoute>());
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final widget = (route as MaterialPageRoute).builder(context);
            expect(widget, isA<CartillaFormPage>());
            expect((widget as CartillaFormPage).config.templateKey, key);
            expect(widget.localId, 123);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  test('manual: cero, defectos superpuestos y bayas separadas de racimos', () {
    expect(cosechaUvaMetrics({})['porcentajeConDefectos'], 0);
    final m = cosechaUvaMetrics({
      'conformados': 2,
      'paloNegro': 3,
      'colapso': 2,
      'pudricion': 99,
    });
    expect(m['racimosSinDefectos'], 0);
    expect(m['porcentajeConDefectos'], 250);
    expect(m['totalBayasDefectuosas'], 99);
  });
  test('1500 capturas durables, 30 bloques y reapertura sin pérdida', () async {
    final dir = await Directory.systemTemp.createTemp('cosecha_uva_');
    final file = File('${dir.path}/samples.sqlite');
    var db = AppDatabase.forTesting(NativeDatabase(file));
    var local = RegistrosLocalDS(RegistrosDao(db));
    var id = await local.createDraft(
      plantillaId: 9,
      templateKey: key,
      userId: 7,
    );
    final times = <int>[];
    try {
      for (var i = 0; i < 1500; i++) {
        final watch = Stopwatch()..start();
        id = await local.completeSampleAndCreateNext(
          localId: id,
          data: sample(count: i % 7 + 1),
          plusOneReplicableHeaderKeys: config.plusOneReplicableHeaderKeys,
          plusOneReplicableBodyKeys: config.plusOneReplicableBodyKeys,
        );
        times.add(watch.elapsedMicroseconds);
      }
      expect(await local.countSyncQueue(userId: 7, templateKey: key), 1500);
      final next = jsonDecode((await local.getByLocalId(id)).dataJson) as Map;
      expect(next['body']['operario'], '11');
      expect(next['body']['conformados'] ?? 0, 0);
      expect(next['body']['fotos'], isNull);
      await db.close();
      db = AppDatabase.forTesting(NativeDatabase(file));
      local = RegistrosLocalDS(RegistrosDao(db));
      expect(await local.countSyncQueue(userId: 7, templateKey: key), 1500);
      final remote = Remote();
      final scope = container(local, remote);
      try {
        await scope
            .read(registrosSyncControllerProvider.notifier)
            .sync(templateKey: key);
        expect(remote.calls, 30);
        expect(remote.maxBlock, 50);
        expect(await local.countSyncQueue(userId: 7, templateKey: key), 0);
        final stored = await local.listWithServerId(
          templateKey: key,
          userId: 7,
        );
        expect(stored.length, 1500);
        expect(stored.map((r) => r.clientRecordId).toSet().length, 1500);
        expect(scope.read(registrosSyncControllerProvider).remainingSamples, 0);
      } finally {
        scope.dispose();
      }
      times.sort();
      debugPrint(
        'Cosecha Uva SQLite desktop: 1500 capturas, p95=${times[1424]}us',
      );
    } finally {
      await db.close();
      await dir.delete(recursive: true);
    }
  });
  test(
    'tres fotos se suben después del bloque sin volver a encolar la muestra',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final local = RegistrosLocalDS(RegistrosDao(db));
      final dir = await Directory.systemTemp.createTemp('cosecha_photos_');
      final photos = <Map<String, dynamic>>[];
      for (var slot = 1; slot <= 3; slot++) {
        final photo = File('${dir.path}/$slot.jpg');
        await photo.writeAsBytes([1, 2, 3]);
        photos.add({'slot': slot, 'localPath': photo.path, 'serverUrl': null});
      }
      final id = await local.createDraft(
        plantillaId: 9,
        templateKey: key,
        userId: 7,
      );
      await local.completeSampleAndCreateNext(
        localId: id,
        data: sample(photos: photos),
        plusOneReplicableHeaderKeys: config.plusOneReplicableHeaderKeys,
        plusOneReplicableBodyKeys: config.plusOneReplicableBodyKeys,
      );
      final remote = Remote();
      final scope = container(local, remote);
      try {
        await scope
            .read(registrosSyncControllerProvider.notifier)
            .sync(templateKey: key);
        expect(remote.calls, 1);
        expect(remote.photos, 3);
        expect(await local.countSyncQueue(userId: 7, templateKey: key), 0);
        final saved = jsonDecode((await local.getByLocalId(id)).dataJson);
        expect(
          (saved['body']['fotos'] as List).every((p) => p['serverUrl'] != null),
          true,
        );
        await scope
            .read(registrosSyncControllerProvider.notifier)
            .sync(templateKey: key);
        expect(remote.calls, 1);
        expect(remote.photos, 3);
      } finally {
        scope.dispose();
        await db.close();
        await dir.delete(recursive: true);
      }
    },
  );
  test(
    'foto pendiente se retoma sin reenviar la muestra ya confirmada',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final local = RegistrosLocalDS(RegistrosDao(db));
      final dir = await Directory.systemTemp.createTemp('cosecha_retry_');
      final photo = File('${dir.path}/later.jpg');
      final id = await local.createDraft(
        plantillaId: 9,
        templateKey: key,
        userId: 7,
      );
      await local.completeSampleAndCreateNext(
        localId: id,
        data: sample(
          photos: [
            {'slot': 1, 'localPath': photo.path, 'serverUrl': null},
          ],
        ),
        plusOneReplicableHeaderKeys: config.plusOneReplicableHeaderKeys,
        plusOneReplicableBodyKeys: config.plusOneReplicableBodyKeys,
      );
      final remote = Remote();
      final scope = container(local, remote);
      try {
        await scope
            .read(registrosSyncControllerProvider.notifier)
            .sync(templateKey: key);
        expect(remote.calls, 1);
        expect(remote.photos, 0);
        expect(scope.read(registrosSyncControllerProvider).remainingSamples, 1);
        await photo.writeAsBytes([1, 2, 3]);
        await scope
            .read(registrosSyncControllerProvider.notifier)
            .sync(templateKey: key);
        expect(remote.calls, 1);
        expect(remote.photos, 1);
        expect(scope.read(registrosSyncControllerProvider).remainingSamples, 0);
      } finally {
        scope.dispose();
        await db.close();
        await dir.delete(recursive: true);
      }
    },
  );
  test('65 muestras con fotos recorren páginas acotadas y terminan completas', () async {
    final db=AppDatabase.forTesting(NativeDatabase.memory());
    final local=RegistrosLocalDS(RegistrosDao(db));
    final dir=await Directory.systemTemp.createTemp('cosecha_photo_pages_');
    final file=File('${dir.path}/photo.jpg');await file.writeAsBytes([1,2,3]);
    final photos=[{'slot':1,'localPath':file.path,'serverUrl':null}];
    for(var i=0;i<65;i++) {
      final id=await local.createDraft(plantillaId:9,templateKey:key,userId:7);
      await local.completeSampleAndCreateNext(localId:id,data:sample(photos:photos),
        plusOneReplicableHeaderKeys:config.plusOneReplicableHeaderKeys,
        plusOneReplicableBodyKeys:config.plusOneReplicableBodyKeys);
    }
    final remote=Remote();final scope=container(local,remote);
    try {
      await scope.read(registrosSyncControllerProvider.notifier).sync(templateKey:key);
      expect(remote.calls,2);expect(remote.photos,65);
      expect(scope.read(registrosSyncControllerProvider).message,contains('Subida completada'));
      final first=await local.listSyncedPhotoCandidatesPage(templateKey:key,userId:7);
      expect(first.length,50);
      expect((await local.listSyncedPhotoCandidatesPage(templateKey:key,userId:7,afterLocalId:first.last.localId)).length,15);
    }finally{scope.dispose();await db.close();await dir.delete(recursive:true);}
  });
  test(
    'notifier protege doble toque y limpia evidencias al continuar',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final local = RegistrosLocalDS(RegistrosDao(db));
      final id = await local.createDraft(
        plantillaId: 9,
        templateKey: key,
        userId: 7,
      );
      await local.updateDataJson(id, jsonEncode(sample()));
      final scope = ProviderContainer();
      final owner = Provider(
        (ref) =>
            CartillaCosechaUvaFormNotifier(ref: ref, localId: id, local: local),
      );
      final notifier = scope.read(owner);
      await notifier.load();
      try {
        final both = await Future.wait([
          notifier.duplicateAsNewForFastSampling(),
          notifier.duplicateAsNewForFastSampling(),
        ]);
        expect(both[0], both[1]);
        expect(await local.countSyncQueue(userId: 7, templateKey: key), 1);
      } finally {
        notifier.dispose();
        scope.dispose();
        await db.close();
      }
    },
  );
}
