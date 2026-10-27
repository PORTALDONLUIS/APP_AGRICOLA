import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donluis_forms/core/storage/drift/app_database.dart';
import 'package:donluis_forms/core/storage/drift/daos/registros_dao.dart';
import 'package:donluis_forms/core/sync/sync_models.dart';
import 'package:donluis_forms/features/registros/data/registros_local_ds.dart';
import 'package:donluis_forms/features/plantillas/brix_moscatel/domain/cartilla_brix_moscatel_config.dart';
import 'package:donluis_forms/features/plantillas/brix_moscatel/domain/cartilla_brix_moscatel_payload.dart';
import 'package:donluis_forms/features/plantillas/brix_moscatel/presentation/cartilla_brix_moscatel_form_provider.dart';

const template = 'cartilla_brix_moscatel';
final config = CartillaBrixMoscatelConfig();

Map<String, dynamic> sample({double brix = 15.8, int plant = 3}) => {
  'payloadVersion': 1,
  'header': {
    'plantillaId': 9,
    'userId': 7,
    'campaniaId': '2026',
    'loteId': 22,
    'fechaEjecucion': 1793010000000,
    'lat': -14.1234567,
    'lon': -75.9876543,
    'gpsDate': '2026-10-26T09:00:00Z',
    'gpsAccuracy': 4.2,
  },
  'body': {
    'hilera': 2,
    'planta': plant,
    'variedad': 8,
    'corresponde': 'PODA',
    'brixSsc': brix,
    'observaciones': 'Sólo esta muestra',
  },
};

Future<int> next(
  RegistrosLocalDS local,
  int id, {
  double brix = 15.8,
  int plant = 3,
}) => local.completeSampleAndCreateNext(
  localId: id,
  data: sample(brix: brix, plant: plant),
  plusOneReplicableHeaderKeys: config.plusOneReplicableHeaderKeys,
  plusOneReplicableBodyKeys: config.plusOneReplicableBodyKeys,
);

class _SlowSamplingLocal extends RegistrosLocalDS {
  final gate = Completer<void>();
  _SlowSamplingLocal(super.dao);
  @override
  Future<int> completeSampleAndCreateNext({
    required int localId,
    required Map<String, dynamic> data,
    required Set<String> plusOneReplicableHeaderKeys,
    required Set<String> plusOneReplicableBodyKeys,
  }) async {
    await gate.future;
    return super.completeSampleAndCreateNext(
      localId: localId,
      data: data,
      plusOneReplicableHeaderKeys: plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: plusOneReplicableBodyKeys,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Las pruebas abren bases independientes (memoria y disco), nunca un executor compartido.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late RegistrosLocalDS local;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    local = RegistrosLocalDS(RegistrosDao(db));
  });
  tearDown(() => db.close());
  Future<int> draft() =>
      local.createDraft(plantillaId: 9, templateKey: template, userId: 7);

  test(
    'un commit confirma actual y replica sólo el contexto permitido',
    () async {
      final id = await draft();
      final nextId = await next(local, id);
      final completed = await local.getByLocalId(id);
      final current = await local.getByLocalId(nextId);
      final rawCompleted = await (db.select(
        db.registrosLocal,
      )..where((t) => t.localId.equals(id))).getSingle();
      expect(rawCompleted.estado, 'listo');
      expect(completed.syncStatus, SyncStatus.pending);
      expect(current.estado, EstadoRegistro.borrador);
      expect(current.syncStatus, SyncStatus.local);
      expect(current.clientRecordId, isNot(completed.clientRecordId));
      final payload = jsonDecode(current.dataJson) as Map;
      expect(payload['body']['planta'], 3);
      expect(payload['body']['brixSsc'], 0);
      expect(payload['body'].containsKey('observaciones'), isFalse);
      expect(payload['header']['lat'], isNull);
      expect(payload['header']['gpsDate'], isNull);
      expect(jsonDecode(completed.dataJson)['header']['lat'], -14.1234567);
      expect(
        jsonDecode(completed.dataJson)['header']['fechaEjecucion'],
        1793010000000,
      );
    },
  );

  test('fallo al insertar revierte también la muestra actual', () async {
    final id = await draft();
    final before = await local.getByLocalId(id);
    await db.customStatement(
      'CREATE TRIGGER fail_next BEFORE INSERT ON '
      "registros_local BEGIN SELECT RAISE(ABORT, 'disco de prueba'); END",
    );
    await expectLater(next(local, id), throwsA(anything));
    final after = await local.getByLocalId(id);
    expect(after.dataJson, before.dataJson);
    expect(after.syncStatus, SyncStatus.local);
    expect((await db.select(db.registrosLocal).get()).length, 1);
  });

  test(
    'doble toque simultáneo produce una sola muestra y un solo borrador',
    () async {
      final id = await draft();
      final owner = Provider(
        (ref) => CartillaBrixMoscatelFormNotifier(
          ref: ref,
          localId: id,
          local: local,
        ),
      );
      final container = ProviderContainer();
      final notifier = container.read(owner);
      try {
        notifier.update(
          CartillaBrixMoscatelPayload.fromJsonString(jsonEncode(sample())),
        );
        final one = notifier.duplicateAsNewForFastSampling();
        final two = notifier.duplicateAsNewForFastSampling();
        expect(identical(one, two), isTrue);
        expect(await one, await two);
        expect((await db.select(db.registrosLocal).get()).length, 2);
        expect(await local.countSyncQueue(userId: 7, templateKey: template), 1);
      } finally {
        notifier.dispose();
        container.dispose();
      }
    },
  );

  test('ACK atrasado no marca una muestra editada o de otro usuario', () async {
    final id = await draft();
    await next(local, id);
    final sent = await local.getByLocalId(id);
    await local.updateDataJson(id, jsonEncode(sample(brix: 19)));
    expect(
      await local.markSyncedIfUnchanged(
        localId: id,
        userId: 7,
        serverId: 80,
        dataJson: sent.dataJson,
      ),
      isFalse,
    );
    final edited = await local.getByLocalId(id);
    expect(
      await local.markSyncedIfUnchanged(
        localId: id,
        userId: 8,
        serverId: 80,
        dataJson: edited.dataJson,
      ),
      isFalse,
    );
    expect(
      await local.markSyncedIfUnchanged(
        localId: id,
        userId: 7,
        serverId: 80,
        dataJson: edited.dataJson,
      ),
      isTrue,
    );
    expect((await local.getByLocalId(id)).syncStatus, SyncStatus.synced);
  });

  test(
    'durante commit lento el formulario conserva el snapshot confirmado',
    () async {
      final id = await draft();
      final slow = _SlowSamplingLocal(RegistrosDao(db));
      final owner = Provider(
        (ref) => CartillaBrixMoscatelFormNotifier(
          ref: ref,
          localId: id,
          local: slow,
        ),
      );
      final container = ProviderContainer();
      final notifier = container.read(owner);
      try {
        notifier.update(
          CartillaBrixMoscatelPayload.fromJsonString(jsonEncode(sample())),
        );
        final pending = notifier.duplicateAsNewForFastSampling();
        expect(notifier.state.saving, isTrue);
        notifier.update(
          CartillaBrixMoscatelPayload.fromJsonString(
            jsonEncode(sample(brix: 99)),
          ),
        );
        expect(notifier.state.payload.body['brixSsc'], 15.8);
        slow.gate.complete();
        await pending;
        expect(
          jsonDecode(
            (await local.getByLocalId(id)).dataJson,
          )['body']['brixSsc'],
          15.8,
        );
        expect(notifier.state.saving, isFalse);
      } finally {
        notifier.dispose();
        container.dispose();
      }
    },
  );

  test(
    '+1 desde una muestra enviada clona contexto sin modificar el original',
    () async {
      final id = await draft();
      await next(local, id);
      await local.markSynced(id, 990);
      final before = await local.getByLocalId(id);
      final newId = await next(local, id);
      final after = await local.getByLocalId(id);
      expect(after.dataJson, before.dataJson);
      expect(after.updatedAt, before.updatedAt);
      expect(after.serverId, 990);
      expect(after.syncStatus, SyncStatus.synced);
      final cloned = await local.getByLocalId(newId);
      expect(cloned.serverId, isNull);
      expect(cloned.syncStatus, SyncStatus.local);
      expect(jsonDecode(cloned.dataJson)['body']['planta'], 3);
      expect(await local.countSyncQueue(userId: 7, templateKey: template), 0);
    },
  );

  test(
    'cola paginada incluye días anteriores y excluye borradores/usuarios',
    () async {
      var id = await draft();
      for (var i = 0; i < 105; i++) {
        id = await next(local, id);
      }
      await local.createDraft(plantillaId: 9, templateKey: template, userId: 8);
      expect(await local.countSyncQueue(userId: 7, templateKey: template), 105);
      final first = await local.listSyncQueuePage(
        userId: 7,
        templateKey: template,
        limit: 50,
      );
      final second = await local.listSyncQueuePage(
        userId: 7,
        templateKey: template,
        afterLocalId: first.last.localId,
      );
      final third = await local.listSyncQueuePage(
        userId: 7,
        templateKey: template,
        afterLocalId: second.last.localId,
      );
      expect([first.length, second.length, third.length], [50, 50, 5]);
      expect({...first, ...second, ...third}.length, 105);
      expect(
        first.first.registrationDateTimeUtc().millisecondsSinceEpoch,
        1793010000000,
      );
    },
  );

  test(
    '1500 muestras en SQLite de disco, reinicio conserva todos los datos',
    () async {
      final folder = await Directory.systemTemp.createTemp(
        'brix_offline_test_',
      );
      final file = File('${folder.path}/samples.sqlite');
      final disk = AppDatabase.forTesting(NativeDatabase(file));
      final diskLocal = RegistrosLocalDS(RegistrosDao(disk));
      var id = await diskLocal.createDraft(
        plantillaId: 9,
        templateKey: template,
        userId: 7,
      );
      final times = <int>[];
      try {
        for (var i = 0; i < 1500; i++) {
          final timer = Stopwatch()..start();
          id = await next(
            diskLocal,
            id,
            brix: 10 + i / 100,
            plant: i ~/ 300 + 1,
          );
          times.add(timer.elapsedMicroseconds);
        }
        expect(
          await diskLocal.countSyncQueue(userId: 7, templateKey: template),
          1500,
        );
      } finally {
        await disk.close();
      }
      final reopened = AppDatabase.forTesting(NativeDatabase(file));
      try {
        final rows = await reopened.select(reopened.registrosLocal).get();
        expect(rows.length, 1501);
        expect(rows.map((r) => r.clientRecordId).toSet().length, 1501);
        for (var i = 0; i < 1500; i++) {
          final body = jsonDecode(rows[i].dataJson)['body'];
          expect(body['brixSsc'], 10 + i / 100);
          expect(body['planta'], i ~/ 300 + 1);
          expect(rows[i].syncStatus, 'pending');
        }
        final early = times.sublist(0, 100)..sort();
        final late = times.sublist(1400)..sort();
        // Diagnóstico de escritorio; no se usa como promesa de tiempo en Android.
        // ignore: avoid_print
        print(
          'SQLite disco +1 p95: primeras100=${early[94]}us '
          'ultimas100=${late[94]}us; 1500 muestras verificadas tras reinicio',
        );
      } finally {
        await reopened.close();
        await folder.delete(recursive: true);
      }
    },
  );
}
