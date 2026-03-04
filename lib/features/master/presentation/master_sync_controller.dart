import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/master_repository.dart';
import '../../../core/log/file_logger.dart';
import '../../../core/storage/drift/daos/sync_cursor_dao.dart';

class MasterSyncState {
  final bool loading;
  final String? error;
  final bool done;

  const MasterSyncState({this.loading = false, this.error, this.done = false});

  MasterSyncState copyWith({bool? loading, String? error, bool? done}) =>
      MasterSyncState(
        loading: loading ?? this.loading,
        error: error,
        done: done ?? this.done,
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
    state = state.copyWith(loading: true, error: null, done: false);
    try {
      await repo.syncBootstrap();
      await cursorDao.upsertValue(cursorKey, DateTime.now()); // ✅ DateTime
      state = state.copyWith(loading: false, done: true);
    } catch (e, st) {
      final err = e.toString();
      state = state.copyWith(loading: false, error: err, done: true);
      try {
        await FileLogger.error('MasterSync runForcedSync', e, st);
      } catch (_) {}
    }
  }
}
