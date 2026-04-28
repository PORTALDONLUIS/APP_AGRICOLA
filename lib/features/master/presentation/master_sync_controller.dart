import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/master_repository.dart';
import '../../../core/network/http_error_handler.dart';
import '../../../core/storage/drift/daos/sync_cursor_dao.dart';

class MasterSyncState {
  final bool loading;
  final String? error;
  final bool done;
  final String? progressMessage;

  const MasterSyncState({
    this.loading = false,
    this.error,
    this.done = false,
    this.progressMessage,
  });

  MasterSyncState copyWith({
    bool? loading,
    String? error,
    bool? done,
    String? progressMessage,
  }) => MasterSyncState(
    loading: loading ?? this.loading,
    error: error,
    done: done ?? this.done,
    progressMessage: progressMessage ?? this.progressMessage,
  );
}

class MasterSyncController extends StateNotifier<MasterSyncState> {
  static const cursorKey = 'MASTER_BOOTSTRAP_LAST_SYNC';

  final MasterRepository repo;
  final SyncCursorDao cursorDao;

  MasterSyncController({required this.repo, required this.cursorDao})
    : super(const MasterSyncState());

  Future<void> runInitialSyncIfNeeded() async {
    final last = await cursorDao.getValue(cursorKey); // DateTime?
    if (last != null) {
      state = state.copyWith(done: true, loading: false);
      return;
    }
    await runForcedSync();
  }

  Future<void> runForcedSync() async {
    state = state.copyWith(
      loading: true,
      error: null,
      done: false,
      progressMessage: 'Sincronizando campañas, lotes y catálogos...',
    );
    try {
      await repo.syncBootstrap(
        onProgress: (message) {
          state = state.copyWith(progressMessage: message);
        },
      );
      await cursorDao.upsertValue(cursorKey, DateTime.now()); // ✅ DateTime
      state = state.copyWith(
        loading: false,
        done: true,
        progressMessage: 'Sincronización completada.',
      );
    } catch (e, st) {
      state = state.copyWith(
        loading: false,
        error: HttpErrorHandler.toUserMessage(e, st),
        done: true,
        progressMessage: 'Se usará la data local disponible.',
      );
    }
  }
}
