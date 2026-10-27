import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:donluis_forms/app/providers.dart';
import 'package:donluis_forms/core/network/dio_client.dart';
import 'package:donluis_forms/core/storage/token_store.dart';
import 'package:donluis_forms/core/sync/sync_models.dart';
import 'package:donluis_forms/features/registros/data/brix_sync_batch.dart';
import 'package:donluis_forms/features/registros/data/registros_local_ds.dart';
import 'package:donluis_forms/features/registros/data/registros_remote_ds.dart';
import 'package:donluis_forms/features/registros/domain/registro.dart';
import 'package:donluis_forms/features/registros/presentation/registros_sync_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _key = 'cartilla_brix_moscatel';

Registro _sample(
  int id, {
  int userId = 7,
  int plantillaId = 3,
  SyncStatus status = SyncStatus.pending,
  double brix = 18.5,
  String? note,
  int payloadVersion = 1,
  bool includeIdentity = true,
  int? headerUserId,
}) {
  final captured = DateTime.utc(2020, 1, 1).millisecondsSinceEpoch + id * 1000;
  return Registro(
    localId: id,
    clientRecordId: '00000000-0000-4000-8000-${id.toString().padLeft(12, '0')}',
    serverId: status == SyncStatus.synced ? id + 10000 : null,
    plantillaId: plantillaId,
    templateKey: _key,
    userId: userId,
    campaniaId: 'C2026',
    loteId: 123,
    lat: -14.012345,
    lon: -75.123456,
    estado: EstadoRegistro.pendienteSync,
    syncStatus: status,
    syncError: null,
    syncAttempts: 0,
    dataJson: jsonEncode({
      'payloadVersion': payloadVersion,
      'header': {
        if (includeIdentity) 'userId': headerUserId ?? userId,
        if (includeIdentity) 'plantillaId': plantillaId,
        'campaniaId': 'C2026',
        'loteId': 123,
        'fechaEjecucion': captured,
        'lat': -14.012345,
        'lon': -75.123456,
        'gpsDate': '2020-01-01T00:00:00Z',
      },
      'body': {
        'hilera': 3,
        'planta': 10,
        'variedad': 5,
        'corresponde': 'RACIMO',
        'brixSsc': brix,
        if (note != null) 'observaciones': note,
      },
    }),
    createdAt: DateTime.utc(2020, 1, 1),
    updatedAt: DateTime.utc(2020, 1, 1),
    deletedAt: null,
  );
}

class _MemoryLocal implements RegistrosLocalDS {
  final Map<int, Registro> rows;
  int maxPageSize = 0;
  int transactions = 0;
  final Set<int> confirmed = {};
  final Set<int> errors = {};
  _MemoryLocal(Iterable<Registro> rows)
    : rows = {for (final row in rows) row.localId: row};

  Iterable<Registro> _queue({
    required int userId,
    required String templateKey,
    int? plantillaId,
    List<int>? localIds,
  }) => rows.values.where(
    (row) =>
        row.userId == userId &&
        row.templateKey == templateKey &&
        (plantillaId == null || row.plantillaId == plantillaId) &&
        (localIds == null || localIds.contains(row.localId)) &&
        row.syncStatus != SyncStatus.synced &&
        !confirmed.contains(row.localId),
  );

  @override
  Future<int> countSyncQueue({
    required int userId,
    required String templateKey,
    int? plantillaId,
    List<int>? localIds,
  }) async => _queue(
    userId: userId,
    templateKey: templateKey,
    plantillaId: plantillaId,
    localIds: localIds,
  ).length;

  @override
  Future<List<Registro>> listSyncQueuePage({
    required int userId,
    required String templateKey,
    int? plantillaId,
    int afterLocalId = 0,
    int limit = 50,
    List<int>? localIds,
  }) async {
    final result =
        _queue(
            userId: userId,
            templateKey: templateKey,
            plantillaId: plantillaId,
            localIds: localIds,
          ).where((row) => row.localId > afterLocalId).toList()
          ..sort((a, b) => a.localId.compareTo(b.localId));
    final page = result.take(limit).toList();
    if (page.length > maxPageSize) maxPageSize = page.length;
    return page;
  }

  @override
  Future<bool> markSyncedIfUnchanged({
    required int localId,
    required int userId,
    required int serverId,
    required String dataJson,
  }) async {
    final row = rows[localId]!;
    if (row.userId != userId || row.dataJson != dataJson) return false;
    confirmed.add(localId);
    return true;
  }

  @override
  Future<bool> markFailedIfUnchanged({
    required int localId,
    required int userId,
    required String dataJson,
    required String error,
  }) async {
    final row = rows[localId]!;
    if (row.userId != userId || row.dataJson != dataJson) return false;
    errors.add(localId);
    return true;
  }

  @override
  Future<T> runSyncTransaction<T>(Future<T> Function() action) {
    transactions++;
    return action();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryRemote implements RegistrosRemoteDS {
  int calls = 0;
  int maxBlockSize = 0;
  int maxBytes = 0;
  final Set<String> serverIds = {};
  bool failConnection = false;
  bool loseFirstAck = false;
  bool wrongRevision = false;
  bool databaseOutage = false;
  String status = 'synced';
  void Function()? duringRequest;

  @override
  Future<List<BrixSyncAcknowledgement>> syncBrixBatch(
    BrixSyncBatch batch,
  ) async {
    calls++;
    if (batch.items.length > maxBlockSize) maxBlockSize = batch.items.length;
    if (batch.byteLength > maxBytes) maxBytes = batch.byteLength;
    if (!failConnection) {
      serverIds.addAll(batch.items.map((item) => item.registro.clientRecordId));
    }
    if (failConnection || (loseFirstAck && calls == 1)) {
      throw DioException(
        requestOptions: RequestOptions(path: '/batch'),
        type: DioExceptionType.connectionError,
      );
    }
    duringRequest?.call();
    return [
      for (final item in batch.items)
        BrixSyncAcknowledgement(
          clientRecordId: item.registro.clientRecordId,
          revision: wrongRevision ? 'incorrecta' : item.revision,
          status: databaseOutage && item != batch.items.first
              ? 'error'
              : status,
          serverRegistroId: status == 'synced'
              ? item.registro.localId + 10000
              : null,
          error: databaseOutage && item != batch.items.first
              ? 'database_unavailable'
              : null,
        ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoTokens implements TokenStore {
  @override
  Future<String?> getAccessToken() async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _JsonAdapter implements HttpClientAdapter {
  final Map<String, dynamic> Function(RequestOptions) respond;
  _JsonAdapter(this.respond);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(respond(options)),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
  @override
  void close({bool force = false}) {}
}

ProviderContainer _container(_MemoryLocal local, _MemoryRemote remote) =>
    ProviderContainer(
      overrides: [
        registrosLocalDSProvider.overrideWithValue(local),
        registrosRemoteDSProvider.overrideWithValue(remote),
        currentUserIdProvider.overrideWithValue(7),
      ],
    );

void main() {
  test(
    'revision iguala el fixture Python con Unicode, enteros y cero negativo',
    () {
      final payload = <String, dynamic>{
        'payloadVersion': 1,
        'header': {'fechaEjecucion': 1793048400000, 'lat': -0.0, 'userId': 7},
        'body': {'brixSsc': 18.5, 'observaciones': 'Muestra ñ 🍇', 'planta': 1},
      };
      expect(
        brixSnapshotRevision(_key, payload),
        '37feea892c65d361bd430932630dc4b6a998db2a1998136cf6c6510c4a90a654',
      );
      final equivalent =
          jsonDecode(jsonEncode(payload)) as Map<String, dynamic>;
      (equivalent['body'] as Map)['planta'] = 1.0;
      (equivalent['header'] as Map)['lat'] = 0;
      expect(
        brixSnapshotRevision('cartilla-brix-moscatel', equivalent),
        brixSnapshotRevision(_key, payload),
      );
      expect(
        () => brixSnapshotRevision(_key, {
          'payloadVersion': 1,
          'header': {},
          'body': {'valor': 9007199254740993},
        }),
        throwsFormatException,
      );
    },
  );

  test(
    'contexto compacto reconstruye exactamente cada muestra independiente',
    () {
      final items = [
        for (var i = 1; i <= 50; i++) BrixSyncItem.fromRegistro(_sample(i)),
      ];
      final batch = BrixSyncBatch(items);
      final contexts = batch.request['contexts'] as List;
      final records = batch.request['records'] as List;
      expect(contexts.length, 1);
      expect((records.first as Map).containsKey('lat'), false);
      for (var i = 0; i < items.length; i++) {
        final record = records[i] as Map;
        final context = contexts[record['context'] as int] as Map;
        final rebuilt = {
          'payloadVersion': record['payloadVersion'],
          'header': {...context['header'] as Map, ...record['header'] as Map},
          'body': {...context['body'] as Map, ...record['body'] as Map},
        };
        expect(rebuilt, items[i].payload);
        expect(brixSnapshotRevision(_key, rebuilt), items[i].revision);
      }
      final individualBytes = utf8
          .encode(
            jsonEncode(
              items
                  .map(
                    (item) => {
                      'clientRecordId': item.registro.clientRecordId,
                      'templateKey': _key,
                      'dataJson': item.payload,
                    },
                  )
                  .toList(),
            ),
          )
          .length;
      expect(batch.byteLength, lessThan(individualBytes));
    },
  );

  test(
    'snapshot antiguo añade identidad solo al envío y rechaza otra identidad',
    () {
      final registro = _sample(1, includeIdentity: false);
      final item = BrixSyncItem.fromRegistro(registro);
      expect((item.payload['header'] as Map)['userId'], 7);
      expect((item.payload['header'] as Map)['plantillaId'], 3);
      expect(
        (jsonDecode(registro.dataJson) as Map)['header'],
        isNot(contains('userId')),
      );
      expect(
        () => BrixSyncItem.fromRegistro(_sample(2, headerUserId: 99)),
        throwsFormatException,
      );
    },
  );

  test(
    'muestra antigua sin identidad se confirma contra su JSON local original',
    () async {
      final local = _MemoryLocal([_sample(1, includeIdentity: false)]);
      final remote = _MemoryRemote();
      final container = _container(local, remote);
      addTearDown(container.dispose);
      await container
          .read(registrosSyncControllerProvider.notifier)
          .sync(templateKey: _key);
      expect(local.confirmed, {1});
      expect(
        container.read(registrosSyncControllerProvider).remainingSamples,
        0,
      );
    },
  );

  test('remote usa el endpoint y contrato batch reales sin red', () async {
    final batch = BrixSyncBatch([BrixSyncItem.fromRegistro(_sample(1))]);
    final client = DioClient(
      baseUrl: 'https://example.invalid',
      tokenStore: _NoTokens(),
    );
    client.dio.httpClientAdapter = _JsonAdapter((options) {
      expect(options.path, '/api/registros/sync-batch/');
      expect(options.method, 'POST');
      expect(options.data, batch.request);
      expect((options.data as Map)['key'], _key);
      expect((options.data as Map)['plantillaVersion'], 1);
      return {
        'protocolVersion': 1,
        'results': [
          {
            'clientRecordId': batch.items.first.registro.clientRecordId,
            'revision': batch.items.first.revision,
            'status': 'synced',
            'serverRegistroId': 10001,
          },
        ],
      };
    });
    addTearDown(() => client.dio.close(force: true));
    final results = await RegistrosRemoteDS(client).syncBrixBatch(batch);
    expect(results.single.serverRegistroId, 10001);
    expect(results.single.revision, batch.items.single.revision);
  });

  test('remote rechaza respuesta incompleta sin confirmar muestras', () async {
    final client = DioClient(
      baseUrl: 'https://example.invalid',
      tokenStore: _NoTokens(),
    );
    client.dio.httpClientAdapter = _JsonAdapter((_) => {'protocolVersion': 1});
    addTearDown(() => client.dio.close(force: true));
    final batch = BrixSyncBatch([BrixSyncItem.fromRegistro(_sample(1))]);
    await expectLater(
      RegistrosRemoteDS(client).syncBrixBatch(batch),
      throwsFormatException,
    );
    expect(
      brixSnapshotRevision(_key, {
        'payloadVersion': 1,
        'header': {},
        'body': {'valor': 9007199254740992},
      }),
      brixSnapshotRevision(_key, {
        'payloadVersion': 1,
        'header': {},
        'body': {'valor': 9007199254740992.0},
      }),
    );
  });

  test(
    '1500 muestras antiguas usan 30 bloques y memoria de 50, con scope estricto',
    () async {
      final local = _MemoryLocal([
        for (var i = 1; i <= 1500; i++) _sample(i),
        _sample(1501, userId: 99),
        _sample(1502, plantillaId: 44),
      ]);
      final remote = _MemoryRemote();
      final container = _container(local, remote);
      addTearDown(container.dispose);
      await container
          .read(registrosSyncControllerProvider.notifier)
          .sync(templateKey: _key, plantillaId: 3);
      final state = container.read(registrosSyncControllerProvider);
      expect(state.ok, 1500);
      expect(state.remainingSamples, 0);
      expect(state.isSyncing, false);
      expect(remote.calls, 30);
      expect(remote.maxBlockSize, 50);
      expect(local.maxPageSize, 50);
      expect(local.transactions, 30);
      expect(local.confirmed, isNot(contains(1501)));
      expect(local.confirmed, isNot(contains(1502)));
    },
  );

  test(
    'sin señal pausa tras un reintento y conserva las 1500 muestras',
    () async {
      final local = _MemoryLocal([for (var i = 1; i <= 1500; i++) _sample(i)]);
      final remote = _MemoryRemote()..failConnection = true;
      final container = _container(local, remote);
      addTearDown(container.dispose);
      await container
          .read(registrosSyncControllerProvider.notifier)
          .sync(templateKey: _key);
      final state = container.read(registrosSyncControllerProvider);
      expect(remote.calls, 2);
      expect(local.confirmed, isEmpty);
      expect(local.rows.length, 1500);
      expect(state.remainingSamples, 1500);
      expect(state.isSyncing, false);
    },
  );

  test('ACK perdido repite el mismo bloque sin crear duplicados', () async {
    final local = _MemoryLocal([for (var i = 1; i <= 51; i++) _sample(i)]);
    final remote = _MemoryRemote()..loseFirstAck = true;
    final container = _container(local, remote);
    addTearDown(container.dispose);
    await container
        .read(registrosSyncControllerProvider.notifier)
        .sync(templateKey: _key);
    expect(remote.calls, 3);
    expect(remote.serverIds.length, 51);
    expect(local.confirmed.length, 51);
    expect(container.read(registrosSyncControllerProvider).remainingSamples, 0);
  });

  test(
    'un cambio local durante la petición no se marca como sincronizado',
    () async {
      final local = _MemoryLocal([_sample(1)]);
      final remote = _MemoryRemote()
        ..duringRequest = () => local.rows[1] = _sample(1, brix: 19.9);
      final container = _container(local, remote);
      addTearDown(container.dispose);
      await container
          .read(registrosSyncControllerProvider.notifier)
          .sync(templateKey: _key);
      expect(local.confirmed, isEmpty);
      expect(
        container.read(registrosSyncControllerProvider).remainingSamples,
        1,
      );
      expect(local.rows[1]!.dataJson, contains('19.9'));
    },
  );

  test(
    'ACK de otra revision conserva toda la cola sin confirmaciones falsas',
    () async {
      final local = _MemoryLocal([_sample(1), _sample(2)]);
      final remote = _MemoryRemote()..wrongRevision = true;
      final container = _container(local, remote);
      addTearDown(container.dispose);
      await container
          .read(registrosSyncControllerProvider.notifier)
          .sync(templateKey: _key);
      expect(local.confirmed, isEmpty);
      expect(
        container.read(registrosSyncControllerProvider).remainingSamples,
        2,
      );
    },
  );

  test(
    'tombstone en servidor conserva el original local y avisa el error',
    () async {
      final local = _MemoryLocal([_sample(1)]);
      final remote = _MemoryRemote()..status = 'deleted';
      final container = _container(local, remote);
      addTearDown(container.dispose);
      await container
          .read(registrosSyncControllerProvider.notifier)
          .sync(templateKey: _key);
      expect(local.rows.length, 1);
      expect(local.confirmed, isEmpty);
      expect(local.errors, contains(1));
      expect(
        container.read(registrosSyncControllerProvider).remainingSamples,
        1,
      );
    },
  );

  test('caída parcial de base conserva ACK previos y pausa la cola', () async {
    final local = _MemoryLocal([for (var i = 1; i <= 1500; i++) _sample(i)]);
    final remote = _MemoryRemote()..databaseOutage = true;
    final container = _container(local, remote);
    addTearDown(container.dispose);
    await container
        .read(registrosSyncControllerProvider.notifier)
        .sync(templateKey: _key);
    expect(remote.calls, 1);
    expect(local.confirmed, {1});
    expect(
      container.read(registrosSyncControllerProvider).remainingSamples,
      1499,
    );
    expect(container.read(registrosSyncControllerProvider).isSyncing, false);
  });

  test(
    'bloques grandes se dividen por bytes sin saltar muestras del cursor',
    () async {
      final local = _MemoryLocal([
        for (var i = 1; i <= 51; i++) _sample(i, note: '$i${'x' * 24000}'),
      ]);
      final remote = _MemoryRemote();
      final container = _container(local, remote);
      addTearDown(container.dispose);
      await container
          .read(registrosSyncControllerProvider.notifier)
          .sync(templateKey: _key);
      expect(local.confirmed.length, 51);
      expect(remote.calls, greaterThan(2));
      expect(remote.maxBytes, lessThanOrEqualTo(BrixSyncBatch.maxBytes));
      expect(
        container.read(registrosSyncControllerProvider).remainingSamples,
        0,
      );
    },
  );

  test(
    'muestra inválida y muestra sobredimensionada no ocultan las siguientes',
    () async {
      final local = _MemoryLocal([
        _sample(1),
        _sample(2, payloadVersion: 999),
        _sample(3),
        _sample(4, note: 'x' * (BrixSyncBatch.maxBytes + 1)),
        _sample(5),
      ]);
      final remote = _MemoryRemote();
      final container = _container(local, remote);
      addTearDown(container.dispose);
      await container
          .read(registrosSyncControllerProvider.notifier)
          .sync(templateKey: _key);
      expect(local.confirmed, {1, 3, 5});
      expect(local.errors, {2, 4});
      expect(local.rows.length, 5);
      expect(
        container.read(registrosSyncControllerProvider).remainingSamples,
        2,
      );
    },
  );

  test(
    'subida concurrente no duplica llamadas y respeta selección explícita',
    () async {
      final local = _MemoryLocal([_sample(1), _sample(2)]);
      final remote = _MemoryRemote();
      final container = _container(local, remote);
      addTearDown(container.dispose);
      final controller = container.read(
        registrosSyncControllerProvider.notifier,
      );
      await Future.wait([
        controller.sync(templateKey: _key, localIds: {2}),
        controller.sync(templateKey: _key, localIds: {2}),
      ]);
      expect(remote.calls, 1);
      expect(local.confirmed, {2});
    },
  );
}
