import '../../features/registros/data/registros_remote_ds.dart';
import '../../features/registros/data/registros_local_ds.dart';
import '../network/http_error_handler.dart';

class SyncService {
  final RegistrosLocalDS local;
  final RegistrosRemoteDS remote;
  final int userId;

  SyncService({required this.local, required this.remote, required this.userId});

  Future<void> syncAll() async {
    final pending = await local.listPending(userId: userId);
    for (final r in pending) {
      try {
        final serverId = await remote.upsertRegistro(r.toApiPayload());
        await local.markSynced(r.localId, serverId);
      } catch (e) {
        await local.markFailed(r.localId, HttpErrorHandler.toUserMessage(e));
      }
    }
  }

  Future<void> syncPlantilla(int plantillaId) async {
    final pending = await local.listPending(plantillaId: plantillaId, userId: userId);
    for (final r in pending) {
      try {
        final serverId = await remote.upsertRegistro(r.toApiPayload());
        await local.markSynced(r.localId, serverId);
      } catch (e) {
        await local.markFailed(r.localId, HttpErrorHandler.toUserMessage(e));
      }
    }
  }
}
