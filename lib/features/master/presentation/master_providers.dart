import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/storage/drift/daos/master/campanias_dao.dart';
import '../../../core/storage/drift/daos/master/lote_orillas_dao.dart';
import '../../../core/storage/drift/daos/master/lotes_dao.dart';
import '../../../core/storage/drift/daos/master/variedades_dao.dart';
import '../../../core/storage/drift/daos/sync_cursor_dao.dart';
import '../data/master_local_ds.dart';
import '../data/master_remote_ds.dart';
import '../data/master_repository.dart';
import 'master_sync_controller.dart';

final masterRemoteDsProvider = Provider<MasterRemoteDs>((ref) {
  final dio = ref.read(dioClientProvider);
  return MasterRemoteDs(dio);
});

final masterLocalDsProvider = Provider<MasterLocalDs>((ref) {
  final db = ref.read(appDatabaseProvider);
  return MasterLocalDs(
    campaniasDao: CampaniasDao(db),
    lotesDao: LotesDao(db),
    loteOrillasDao: LoteOrillasDao(db),
    variedadesDao: VariedadesDao(db),
  );
});

final masterRepositoryProvider = Provider<MasterRepository>((ref) {
  return MasterRepository(
    remote: ref.read(masterRemoteDsProvider),
    local: ref.read(masterLocalDsProvider),
  );
});

final masterSyncControllerProvider =
StateNotifierProvider<MasterSyncController, MasterSyncState>((ref) {
  final db = ref.read(appDatabaseProvider);
  return MasterSyncController(
    repo: ref.read(masterRepositoryProvider),
    cursorDao: SyncCursorDao(db),
  );
});

// Streams para combos (offline)
final campaniasStreamProvider = StreamProvider((ref) {
  return ref.read(masterLocalDsProvider).watchCampanias();
});

final lotesStreamProvider = StreamProvider((ref) {
  return ref.read(masterLocalDsProvider).watchLotes();
});

final variedadesStreamProvider = StreamProvider((ref) {
  return ref.read(masterLocalDsProvider).watchVariedades();
});

/// Orillas por lote (para BRIX cuando fenología = ORILLA).
final orillasByLoteProvider = StreamProvider.family<List<dynamic>, int>((ref, idLote) {
  return ref.read(masterLocalDsProvider).watchOrillasByLoteId(idLote);
});
