import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/http_error_handler.dart';
import '../data/registros_local_ds.dart';
import '../data/registros_remote_ds.dart';
import '../domain/registro.dart';


class RegistrosSyncState {
  final bool isSyncing;
  final int current;
  final int total;
  final int ok;
  final int fail;
  final String? message;
  final String? lastError;

  const RegistrosSyncState({
    required this.isSyncing,
    required this.current,
    required this.total,
    required this.ok,
    required this.fail,
    this.message,
    this.lastError,
  });

  factory RegistrosSyncState.idle() => const RegistrosSyncState(
    isSyncing: false,
    current: 0,
    total: 0,
    ok: 0,
    fail: 0,
    message: null,
    lastError: null,
  );

  RegistrosSyncState copyWith({
    bool? isSyncing,
    int? current,
    int? total,
    int? ok,
    int? fail,
    String? message,
    String? lastError,
  }) {
    return RegistrosSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      current: current ?? this.current,
      total: total ?? this.total,
      ok: ok ?? this.ok,
      fail: fail ?? this.fail,
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
        final Map<String, dynamic> dataMap =
            (jsonDecode(r.dataJson) as Map).cast<String, dynamic>();

        final payload = <String, dynamic>{
          'templateKey': r.templateKey,
          'payloadVersion': 1,
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

        state = state.copyWith(
          fail: state.fail + 1,
          lastError: msg,
        );

        debugPrint('Sync registro #${r.localId} FAILED: $e');
      }
    }

    state = state.copyWith(
      isSyncing: false,
      message: 'Sync terminado: ${state.ok} OK, ${state.fail} con error',
    );
  }

  Future<void> sync({String? templateKey}) async {
    if (state.isSyncing) return;

    final local = ref.read(registrosLocalDSProvider);
    final remote = ref.read(registrosRemoteDSProvider);
    final userId = ref.read(currentUserIdProvider);

    final allPendientes = await local.listSyncQueue(userId: userId);
    final pendientes = templateKey == null
        ? allPendientes
        : allPendientes.where((r) => r.templateKey == templateKey).toList();

    final syncedWithFotosPendientes = await local.listWithServerId(templateKey: templateKey, userId: userId);
    final conFotosPendientes = <Registro>[];
    for (final r in syncedWithFotosPendientes) {
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
        final Map<String, dynamic> dataMap =
            (jsonDecode(r.dataJson) as Map).cast<String, dynamic>();

        final payload = <String, dynamic>{
          'templateKey': r.templateKey,
          'payloadVersion': 1,
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

        state = state.copyWith(
          fail: state.fail + 1,
          lastError: msg,
        );

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
        final Map<String, dynamic> dataMap =
            (jsonDecode(r.dataJson) as Map).cast<String, dynamic>();

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

    state = state.copyWith(
      isSyncing: false,
      message: 'Sync terminado: ${state.ok} OK, ${state.fail} con error',
    );
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
  }) async {
    final pendientes = _getFotosPendientes(dataMap);
    if (pendientes.isEmpty) return;

    debugPrint('Upload fotos: $pendientes para registro $localId (server $serverId)');

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
          debugPrint('Upload foto slot $slot intento ${attempt + 1}/$_maxFotoRetries: $e');
          if (attempt < _maxFotoRetries - 1) {
            await Future<void>.delayed(_backoffDelays[attempt]);
          } else {
            debugPrint('Foto slot $slot dejada pendiente para próximo sync');
          }
        }
      }

      if (serverUrl != null && serverUrl.isNotEmpty) {
        _mergeServerUrlInDataMap(dataMap, slot, serverUrl);
        if (preserveSyncStatus) {
          await local.updateDataJsonPreservingSyncStatus(localId, jsonEncode(dataMap));
        } else {
          await local.updateDataJson(localId, jsonEncode(dataMap));
        }
        debugPrint('Foto slot $slot subida OK: $serverUrl');
      }
    }
  }

  void _mergeServerUrlInDataMap(Map<String, dynamic> dataMap, int slot, String serverUrl) {
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