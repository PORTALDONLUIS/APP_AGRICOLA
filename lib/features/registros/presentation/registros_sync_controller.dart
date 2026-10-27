import 'dart:convert';
import '../../../core/sync/sync_models.dart';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/http_error_handler.dart';
import '../../../core/time/operational_timezone_pe.dart';
import '../data/registros_local_ds.dart';
import '../data/registros_remote_ds.dart';
import '../data/brix_sync_batch.dart';
import '../domain/registro.dart';

class RegistrosSyncState {
  final bool isSyncing;
  final int current;
  final int total;
  final int ok;
  final int fail;
  final int remainingSamples;
  final String? message;
  final String? lastError;

  const RegistrosSyncState({
    required this.isSyncing,
    required this.current,
    required this.total,
    required this.ok,
    required this.fail,
    required this.remainingSamples,
    this.message,
    this.lastError,
  });

  factory RegistrosSyncState.idle() => const RegistrosSyncState(
    isSyncing: false,
    current: 0,
    total: 0,
    ok: 0,
    fail: 0,
    remainingSamples: 0,
    message: null,
    lastError: null,
  );

  RegistrosSyncState copyWith({
    bool? isSyncing,
    int? current,
    int? total,
    int? ok,
    int? fail,
    int? remainingSamples,
    String? message,
    String? lastError,
  }) {
    return RegistrosSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      current: current ?? this.current,
      total: total ?? this.total,
      ok: ok ?? this.ok,
      fail: fail ?? this.fail,
      remainingSamples: remainingSamples ?? this.remainingSamples,
      message: message ?? this.message,
      lastError: lastError,
    );
  }
}

class RegistrosSyncController extends StateNotifier<RegistrosSyncState> {
  RegistrosSyncController(this.ref) : super(RegistrosSyncState.idle());

  final Ref ref;

  static const int _maxFotoRetries = 3;
  static const List<Duration> _backoffDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];

  /// La subida de campo es diaria: nunca se reenvían registros de días previos.
  /// Se usa el mismo día operativo Perú (UTC−5) de los reportes y la lista.
  bool _isFromToday(Registro registro) => isSameOperationalCalendarDayUtc5(
    registro.registrationDateTimeUtc(),
    DateTime.now(),
  );

  bool _isInScope(
    Registro registro, {
    required String? templateKey,
    required Set<int>? localIds,
  }) {
    return _isFromToday(registro) &&
        (templateKey == null || registro.templateKey == templateKey) &&
        (localIds == null || localIds.contains(registro.localId));
  }

  Future<int> _countRemainingSamples({
    required RegistrosLocalDS local,
    required int userId,
    required String? templateKey,
    required Set<int>? localIds,
  }) async {
    final incompleteIds = <int>{};

    final queue = await local.listSyncQueue(userId: userId);
    for (final registro in queue) {
      if (_isInScope(registro, templateKey: templateKey, localIds: localIds)) {
        incompleteIds.add(registro.localId);
      }
    }

    final withServerId = await local.listWithServerId(
      templateKey: templateKey,
      userId: userId,
    );
    for (final registro in withServerId) {
      if (!_isInScope(registro, templateKey: templateKey, localIds: localIds)) {
        continue;
      }
      try {
        final dataMap = (jsonDecode(registro.dataJson) as Map)
            .cast<String, dynamic>();
        if (_getFotosPendientes(dataMap).isNotEmpty) {
          incompleteIds.add(registro.localId);
        }
      } catch (_) {
        // Si no se puede leer su payload, no puede verificarse como completo.
        incompleteIds.add(registro.localId);
      }
    }

    return incompleteIds.length;
  }

  int _payloadVersionForSync({
    required String templateKey,
    required Map<String, dynamic> data,
  }) {
    final normalizedTemplate = templateKey.trim().toLowerCase().replaceAll(
      '-',
      '_',
    );
    // Conteo de Bayas cambió su estructura a versión 2. Las muestras que se
    // guardaron antes de la actualización también son compatibles y deben
    // enviarse con la versión que el backend tiene publicada.
    if (normalizedTemplate == 'cartilla_conteo_bayas') return 2;

    final raw = data['payloadVersion'];
    if (raw is num) return raw.toInt();
    return int.tryParse('$raw') ?? 1;
  }

  Future<void> sync2({String? templateKey}) async {
    if (state.isSyncing) return;

    final local = ref.read(registrosLocalDSProvider);
    final remote = ref.read(registrosRemoteDSProvider);
    final userId = ref.read(currentUserIdProvider);

    final allPendientes = await local.listSyncQueue(userId: userId);
    final pendientes = templateKey == null
        ? allPendientes
        : allPendientes.where((r) => r.templateKey == templateKey).toList();

    if (pendientes.isEmpty) {
      state = state.copyWith(
        isSyncing: false,
        current: 0,
        total: 0,
        ok: 0,
        fail: 0,
        message: 'No hay pendientes para sincronizar',
        lastError: null,
      );
      return;
    }

    state = state.copyWith(
      isSyncing: true,
      current: 0,
      total: pendientes.length,
      ok: 0,
      fail: 0,
      message: 'Sincronizando...',
      lastError: null,
    );

    for (var i = 0; i < pendientes.length; i++) {
      final r = pendientes[i];

      state = state.copyWith(
        current: i + 1,
        message: '${r.templateKey} (#${r.localId})',
      );

      try {
        final Map<String, dynamic> dataMap = (jsonDecode(r.dataJson) as Map)
            .cast<String, dynamic>();

        final payload = <String, dynamic>{
          'clientRecordId': r.clientRecordId,
          'templateKey': r.templateKey,
          'payloadVersion': _payloadVersionForSync(
            templateKey: r.templateKey,
            data: dataMap,
          ),
          'dataJson': dataMap,
          if (r.campaniaId != null) 'campaniaId': r.campaniaId,
          if (r.loteId != null) 'loteId': r.loteId,
          if (r.lat != null) 'lat': r.lat,
          if (r.lon != null) 'lon': r.lon,
        };

        final serverId = await remote.upsertRegistro(payload);
        await local.markSynced(r.localId, serverId);

        await _uploadFotosPendientes(
          local: local,
          remote: remote,
          localId: r.localId,
          serverId: serverId,
          dataMap: dataMap,
        );

        state = state.copyWith(ok: state.ok + 1);
      } catch (e, st) {
        final msg = HttpErrorHandler.toUserMessage(e, st);
        await local.markFailed(r.localId, msg);

        state = state.copyWith(fail: state.fail + 1, lastError: msg);

        debugPrint('Sync registro #${r.localId} FAILED: $e');
      }
    }

    state = state.copyWith(
      isSyncing: false,
      message: 'Sync terminado: ${state.ok} OK, ${state.fail} con error',
    );
  }

  /// Descarga únicamente las muestras del usuario autenticado para la cartilla
  /// piloto BRIX MOSCATEL. La subida normal continúa usando [sync].
  Future<void> downloadBrixMoscatel({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      current: 0,
      total: 0,
      ok: 0,
      fail: 0,
      message: 'Descargando muestras...',
      lastError: null,
    );

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId <= 0) {
        throw Exception('No se pudo identificar al usuario actual');
      }
      final remote = ref.read(registrosRemoteDSProvider);
      final local = ref.read(registrosLocalDSProvider);
      final cloud = await remote.downloadBrixMoscatel(
        startDate: startDate,
        endDate: endDate,
      );
      final result = await local.dao.applyCloudDownload(
        userId: userId,
        templateKey: 'cartilla_brix_moscatel',
        records: cloud.records,
        deletedClientRecordIds: cloud.deletedClientRecordIds,
      );
      final skipped = result.skippedPending > 0
          ? ' Se conservaron ${result.skippedPending} pendientes locales.'
          : '';
      state = state.copyWith(
        isSyncing: false,
        current: cloud.records.length,
        total: cloud.records.length,
        ok: result.inserted + result.updated,
        fail: 0,
        message:
            'Descarga terminada: ${result.inserted} nuevas, ${result.updated} actualizadas y ${result.removed} eliminadas.$skipped',
        lastError: null,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        isSyncing: false,
        fail: 1,
        message: 'No se pudo descargar las muestras',
        lastError: HttpErrorHandler.toUserMessage(error, stackTrace),
      );
      debugPrint('Download BRIX MOSCATEL FAILED: $error');
    }
  }

  Future<void> sync({
    String? templateKey,
    Set<int>? localIds,
    int? plantillaId,
  }) async {
    if (state.isSyncing) return;

    if (templateKey != null && supportsCompactSync(templateKey)) {
      await _syncBrixMoscatel(
        templateKey: templateKey,
        localIds: localIds,
        plantillaId: plantillaId,
      );
      return;
    }

    final local = ref.read(registrosLocalDSProvider);
    final remote = ref.read(registrosRemoteDSProvider);
    final userId = ref.read(currentUserIdProvider);

    final allPendientes = await local.listSyncQueue(userId: userId);
    final pendientesPorCartilla = templateKey == null
        ? allPendientes
        : allPendientes.where((r) => r.templateKey == templateKey).toList();
    final pendientes =
        (localIds == null
                ? pendientesPorCartilla
                : pendientesPorCartilla
                      .where((registro) => localIds.contains(registro.localId))
                      .toList())
            .where(_isFromToday)
            .toList();

    final syncedWithFotosPendientes = await local.listWithServerId(
      templateKey: templateKey,
      userId: userId,
    );
    final conFotosPendientes = <Registro>[];
    for (final r in syncedWithFotosPendientes) {
      if (!_isInScope(r, templateKey: templateKey, localIds: localIds)) {
        continue;
      }
      final dataMap = (jsonDecode(r.dataJson) as Map).cast<String, dynamic>();
      if (_getFotosPendientes(dataMap).isNotEmpty) {
        conFotosPendientes.add(r);
      }
    }

    final totalWork = pendientes.length + conFotosPendientes.length;
    if (totalWork == 0) {
      state = state.copyWith(
        isSyncing: false,
        current: 0,
        total: 0,
        ok: 0,
        fail: 0,
        message: 'No hay pendientes para sincronizar',
        lastError: null,
      );
      return;
    }

    state = state.copyWith(
      isSyncing: true,
      current: 0,
      total: totalWork,
      ok: 0,
      fail: 0,
      remainingSamples: 0,
      message: 'Sincronizando...',
      lastError: null,
    );

    int currentIdx = 0;

    for (final r in pendientes) {
      currentIdx++;
      state = state.copyWith(
        current: currentIdx,
        message: '${r.templateKey} (#${r.localId})',
      );

      try {
        final Map<String, dynamic> dataMap = (jsonDecode(r.dataJson) as Map)
            .cast<String, dynamic>();

        final payload = <String, dynamic>{
          'clientRecordId': r.clientRecordId,
          'templateKey': r.templateKey,
          'payloadVersion': _payloadVersionForSync(
            templateKey: r.templateKey,
            data: dataMap,
          ),
          'dataJson': dataMap,
          if (r.campaniaId != null) 'campaniaId': r.campaniaId,
          if (r.loteId != null) 'loteId': r.loteId,
          if (r.lat != null) 'lat': r.lat,
          if (r.lon != null) 'lon': r.lon,
        };

        final serverId = await remote.upsertRegistro(payload);
        await local.markSynced(r.localId, serverId);

        await _uploadFotosPendientes(
          local: local,
          remote: remote,
          localId: r.localId,
          serverId: serverId,
          dataMap: dataMap,
          preserveSyncStatus: false,
        );

        state = state.copyWith(ok: state.ok + 1);
      } catch (e, st) {
        final msg = HttpErrorHandler.toUserMessage(e, st);
        await local.markFailed(r.localId, msg);

        state = state.copyWith(fail: state.fail + 1, lastError: msg);

        debugPrint('Sync registro #${r.localId} FAILED: $e');
      }
    }

    for (final r in conFotosPendientes) {
      currentIdx++;
      final serverId = r.serverId!;
      state = state.copyWith(
        current: currentIdx,
        message: 'Fotos pendientes ${r.templateKey} (#${r.localId})',
      );

      try {
        final Map<String, dynamic> dataMap = (jsonDecode(r.dataJson) as Map)
            .cast<String, dynamic>();

        await _uploadFotosPendientes(
          local: local,
          remote: remote,
          localId: r.localId,
          serverId: serverId,
          dataMap: dataMap,
          preserveSyncStatus: true,
        );

        state = state.copyWith(ok: state.ok + 1);
      } catch (e, st) {
        debugPrint('Upload fotos pendientes #${r.localId} error: $e');
        state = state.copyWith(
          fail: state.fail + 1,
          lastError: HttpErrorHandler.toUserMessage(e, st),
        );
      }
    }

    final remainingSamples = await _countRemainingSamples(
      local: local,
      userId: userId,
      templateKey: templateKey,
      localIds: localIds,
    );
    state = state.copyWith(
      isSyncing: false,
      remainingSamples: remainingSamples,
      message: remainingSamples > 0
          ? '$remainingSamples muestra(s) no se llegaron a subir. Intenta nuevamente.'
          : 'Subida completada: todas las muestras se subieron correctamente.',
    );
  }

  /// Cola duradera de Brix: la fecha de la lista no limita los pendientes.
  /// Solo se carga un bloque a la vez y cada ACK confirma el JSON enviado.
  Future<void> _syncBrixMoscatel({
    required String templateKey,
    required Set<int>? localIds,
    required int? plantillaId,
  }) async {
    final local = ref.read(registrosLocalDSProvider);
    final remote = ref.read(registrosRemoteDSProvider);
    final userId = ref.read(currentUserIdProvider);
    final scopedIds = localIds?.toList(growable: false);
    state = RegistrosSyncState.idle().copyWith(
      isSyncing: true,
      message: 'Preparando muestras pendientes...',
    );
    var paused = false;
    var pendingPhotos = 0;
    var photoPaused = false;
    try {
      if (userId <= 0) {
        throw StateError('No se pudo identificar al usuario actual.');
      }
      final total = await local.countSyncQueue(
        userId: userId,
        templateKey: templateKey,
        plantillaId: plantillaId,
        localIds: scopedIds,
      );
      state = state.copyWith(total: total, remainingSamples: total);
      var afterLocalId = 0;
      while (true) {
        // Si cambió la sesión durante una subida, no se envía la cola anterior
        // con las credenciales del nuevo usuario.
        if (ref.read(currentUserIdProvider) != userId) {
          throw StateError('La sesión cambió. Vuelve a iniciar la subida.');
        }
        final page = await local.listSyncQueuePage(
          userId: userId,
          templateKey: templateKey,
          plantillaId: plantillaId,
          localIds: scopedIds,
          afterLocalId: afterLocalId,
          limit: BrixSyncBatch.maxRecords,
        );
        if (page.isEmpty) break;

        // La versión de plantilla es común por bloque. Al no especificar
        // plantillaId se separan también plantillas con la misma clave.
        final firstPlantillaId = page.first.plantillaId;
        var candidates = <BrixSyncItem>[];
        for (final registro in page) {
          if (registro.plantillaId != firstPlantillaId) break;
          BrixSyncItem item;
          try {
            item = BrixSyncItem.fromRegistro(registro);
          } catch (error) {
            // Envía primero el prefijo válido; así ningún cursor salta una
            // muestra que todavía no se ha incluido en un bloque.
            if (candidates.isNotEmpty) break;
            // Se conserva su JSON para revisión; no bloquea otras muestras.
            await local.markFailedIfUnchanged(
              localId: registro.localId,
              userId: userId,
              dataJson: registro.dataJson,
              error: error.toString(),
            );
            afterLocalId = registro.localId;
            state = state.copyWith(
              current: state.current + 1,
              fail: state.fail + 1,
              lastError: error.toString(),
            );
            continue;
          }
          candidates.add(item);
        }
        if (candidates.isEmpty) continue;

        // El bloque normal se construye y serializa una sola vez. Solo si
        // excede el límite se reduce por mitades; no se vuelve a codificar el
        // mismo bloque por cada muestra añadida.
        var batch = BrixSyncBatch(candidates);
        while (batch.byteLength > BrixSyncBatch.maxBytes &&
            candidates.length > 1) {
          candidates = candidates.take((candidates.length / 2).ceil()).toList();
          batch = BrixSyncBatch(candidates);
        }
        if (batch.byteLength > BrixSyncBatch.maxBytes) {
          final registro = candidates.single.registro;
          const message = 'La muestra supera el tamaño permitido por bloque.';
          await local.markFailedIfUnchanged(
            localId: registro.localId,
            userId: userId,
            dataJson: registro.dataJson,
            error: message,
          );
          afterLocalId = registro.localId;
          state = state.copyWith(
            current: state.current + 1,
            fail: state.fail + 1,
            lastError: message,
          );
          continue;
        }
        afterLocalId = candidates.last.registro.localId;
        final results = await _sendBrixBatchWithRetry(remote, batch, userId);
        final byClientId = <String, BrixSyncAcknowledgement>{};
        final sent = {
          for (final item in candidates)
            item.registro.clientRecordId.toLowerCase(): item,
        };
        for (final result in results) {
          final clientId = result.clientRecordId.toLowerCase();
          final item = sent[clientId];
          if (item == null ||
              item.revision != result.revision ||
              byClientId.containsKey(clientId) ||
              !const {
                'synced',
                'deleted',
                'error',
                'conflict',
              }.contains(result.status) ||
              (result.status == 'synced' &&
                  (result.serverRegistroId == null ||
                      result.serverRegistroId! <= 0))) {
            throw const FormatException(
              'La confirmación del bloque no coincide con las muestras enviadas.',
            );
          }
          byClientId[clientId] = result;
        }
        if (byClientId.length != candidates.length) {
          throw const FormatException(
            'Faltan confirmaciones del servidor. Las muestras siguen pendientes.',
          );
        }

        var confirmed = 0;
        var failed = 0;
        String? lastError;
        await local.runSyncTransaction(() async {
          for (final item in candidates) {
            final registro = item.registro;
            final result = byClientId[registro.clientRecordId.toLowerCase()]!;
            if (result.status == 'synced') {
              if (await local.markSyncedIfUnchanged(
                localId: registro.localId,
                userId: userId,
                serverId: result.serverRegistroId!,
                dataJson: registro.dataJson,
              )) {
                confirmed++;
              }
            } else {
              lastError =
                  result.error ??
                  (result.status == 'deleted'
                      ? 'La muestra fue retirada en la nube y no se volverá a crear.'
                      : 'La muestra requiere revisión antes de enviarse nuevamente.');
              if (await local.markFailedIfUnchanged(
                localId: registro.localId,
                userId: userId,
                dataJson: registro.dataJson,
                error: lastError!,
              )) {
                failed++;
              }
            }
          }
        });
        state = state.copyWith(
          current: state.current + candidates.length,
          ok: state.ok + confirmed,
          fail: state.fail + failed,
          remainingSamples: max(0, total - state.ok - confirmed),
          message: '${state.ok + confirmed} de $total muestras confirmadas',
          lastError: lastError,
        );
        if (results.any((result) => result.error == 'database_unavailable')) {
          // La API conserva los ACK previos al fallo. No se insiste con el
          // resto de la cola mientras la base de datos está indisponible.
          paused = true;
          state = state.copyWith(
            lastError:
                'El servidor no está disponible. Las muestras siguen guardadas en el equipo.',
          );
          break;
        }
      }
      if (!paused &&
          normalizeBrixTemplateKey(templateKey) == 'cartilla_cosecha_uva') {
        var afterPhotoId = 0;
        while (!photoPaused) {
          final synced = await local.listSyncedPhotoCandidatesPage(
            templateKey: templateKey,
            userId: userId,
            plantillaId: plantillaId,
            afterLocalId: afterPhotoId,
          );
          if (synced.isEmpty) break;
          afterPhotoId = synced.last.localId;
          for (final row in synced) {
            if (scopedIds != null && !scopedIds.contains(row.localId)) continue;
            if (ref.read(currentUserIdProvider) != userId) {
              throw StateError('La sesión cambió');
            }
            if (row.syncStatus != SyncStatus.synced ||
                !row.dataJson.contains('localPath')) {
              continue;
            }
            final body = Map<String, dynamic>.from(
              jsonDecode(row.dataJson) as Map,
            );
            if (_getFotosPendientes(body).isEmpty) continue;
            await _uploadFotosPendientes(
              local: local,
              remote: remote,
              localId: row.localId,
              serverId: row.serverId!,
              dataMap: body,
              preserveSyncStatus: true,
              expectedDataJson: row.dataJson,
            );
            final fresh = await local.getByLocalId(row.localId);
            if (fresh.syncStatus == SyncStatus.synced &&
                _getFotosPendientes(
                  Map<String, dynamic>.from(jsonDecode(fresh.dataJson) as Map),
                ).isNotEmpty) {
              pendingPhotos++;
              photoPaused = true;
              paused = true;
              break;
            }
          }
        }
      }
    } catch (error, stackTrace) {
      paused = true;
      final message =
          error is DioException &&
              const {404, 405}.contains(error.response?.statusCode)
          ? 'El servidor necesita la actualización para subir estas muestras por bloques.'
          : HttpErrorHandler.toUserMessage(error, stackTrace);
      state = state.copyWith(lastError: message);
    } finally {
      var remaining = state.remainingSamples;
      try {
        if (userId > 0) {
          remaining = await local.countSyncQueue(
            userId: userId,
            templateKey: templateKey,
            plantillaId: plantillaId,
            localIds: scopedIds,
          );
        }
      } catch (error, stackTrace) {
        paused = true;
        state = state.copyWith(
          lastError: HttpErrorHandler.toUserMessage(error, stackTrace),
        );
      }
      remaining += pendingPhotos;
      state = state.copyWith(
        isSyncing: false,
        remainingSamples: remaining,
        message: photoPaused
            ? 'Subida de fotos pausada. Las evidencias pendientes siguen en el equipo; vuelve a intentar cuando haya conexión.'
            : remaining == 0 && !paused
            ? 'Subida completada: todas las muestras se subieron correctamente.'
            : 'Subida ${paused ? 'pausada' : 'incompleta'}: $remaining muestra(s) siguen guardadas en el equipo.',
        lastError: state.lastError,
      );
    }
  }

  Future<List<BrixSyncAcknowledgement>> _sendBrixBatchWithRetry(
    RegistrosRemoteDS remote,
    BrixSyncBatch batch,
    int expectedUserId,
  ) async {
    try {
      return await remote.syncBrixBatch(batch);
    } on DioException catch (error) {
      final retryable =
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          const {408, 429, 502, 503, 504}.contains(error.response?.statusCode);
      if (!retryable) rethrow;
      // Un único reintento del mismo bloque con espera breve. Si no vuelve la
      // señal, se pausa la cola completa en vez de agotar un timeout por muestra.
      await Future<void>.delayed(
        Duration(milliseconds: 1000 + Random().nextInt(500)),
      );
      if (ref.read(currentUserIdProvider) != expectedUserId) {
        throw StateError('La sesión cambió. Vuelve a iniciar la subida.');
      }
      return remote.syncBrixBatch(batch);
    }
  }

  List<Map<String, dynamic>> _getFotosPendientes(Map<String, dynamic> dataMap) {
    final body = dataMap['body'];
    List<dynamic> raw = const [];
    if (body is Map && body['fotos'] is List) {
      raw = body['fotos'] as List;
    } else if (dataMap['fotos'] is List) {
      raw = dataMap['fotos'] as List;
    }
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e.cast<String, dynamic>()))
        .where((f) {
          final localPath = f['localPath'] as String?;
          final serverUrl = f['serverUrl'] as String?;
          return localPath != null &&
              localPath.isNotEmpty &&
              (serverUrl == null || serverUrl.isEmpty);
        })
        .toList();
  }

  Future<void> _uploadFotosPendientes({
    required RegistrosLocalDS local,
    required RegistrosRemoteDS remote,
    required int localId,
    required int serverId,
    required Map<String, dynamic> dataMap,
    bool preserveSyncStatus = false,
    String? expectedDataJson,
  }) async {
    final pendientes = _getFotosPendientes(dataMap);
    if (pendientes.isEmpty) return;

    debugPrint(
      'Upload fotos: $pendientes para registro $localId (server $serverId)',
    );

    for (final foto in pendientes) {
      final slot = (foto['slot'] as num?)?.toInt() ?? 0;
      final localPath = foto['localPath'] as String? ?? '';
      if (slot < 1 || localPath.isEmpty) continue;

      final file = File(localPath);
      if (!await file.exists()) {
        debugPrint('Foto slot $slot no existe: $localPath');
        continue;
      }

      String? serverUrl;
      for (var attempt = 0; attempt < _maxFotoRetries; attempt++) {
        try {
          serverUrl = await remote.uploadFoto(
            serverRegistroId: serverId,
            slot: slot,
            file: file,
          );
          break;
        } catch (e) {
          debugPrint(
            'Upload foto slot $slot intento ${attempt + 1}/$_maxFotoRetries: $e',
          );
          if (attempt < _maxFotoRetries - 1) {
            await Future<void>.delayed(_backoffDelays[attempt]);
          } else {
            debugPrint('Foto slot $slot dejada pendiente para próximo sync');
          }
        }
      }

      if (serverUrl != null && serverUrl.isNotEmpty) {
        if (expectedDataJson != null &&
            (await local.getByLocalId(localId)).dataJson != expectedDataJson) {
          return;
        }
        _mergeServerUrlInDataMap(dataMap, slot, serverUrl);
        if (preserveSyncStatus) {
          await local.updateDataJsonPreservingSyncStatus(
            localId,
            jsonEncode(dataMap),
          );
        } else {
          await local.updateDataJson(localId, jsonEncode(dataMap));
        }
        if (expectedDataJson != null) expectedDataJson = jsonEncode(dataMap);
        debugPrint('Foto slot $slot subida OK: $serverUrl');
      }
    }
  }

  void _mergeServerUrlInDataMap(
    Map<String, dynamic> dataMap,
    int slot,
    String serverUrl,
  ) {
    final body = dataMap['body'];
    List<dynamic> fotos;
    if (body is Map && body['fotos'] is List) {
      fotos = body['fotos'] as List;
    } else if (dataMap['fotos'] is List) {
      fotos = dataMap['fotos'] as List;
      dataMap['fotos'] = fotos;
    } else {
      fotos = [];
      if (body is Map) {
        body['fotos'] = fotos;
        dataMap['body'] = body;
      } else {
        dataMap['body'] = {'fotos': fotos};
      }
    }

    var found = false;
    for (var i = 0; i < fotos.length; i++) {
      final f = fotos[i];
      if (f is Map && (f['slot'] as num?)?.toInt() == slot) {
        final m = Map<String, dynamic>.from(f.cast<String, dynamic>());
        m['serverUrl'] = serverUrl;
        fotos[i] = m;
        found = true;
        break;
      }
    }
    if (!found) {
      fotos.add({'slot': slot, 'localPath': null, 'serverUrl': serverUrl});
    }
  }
}

final registrosSyncControllerProvider =
    StateNotifierProvider<RegistrosSyncController, RegistrosSyncState>(
      (ref) => RegistrosSyncController(ref),
    );
