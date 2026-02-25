import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/auth/jwt_utils.dart';
import '../core/storage/drift/app_database.dart';
import '../core/storage/drift/daos/plantillas_dao.dart';
import '../core/storage/drift/daos/registros_dao.dart';
import '../core/storage/drift/daos/sync_cursor_dao.dart';
import '../core/storage/token_store.dart';
import '../core/network/dio_client.dart';
import '../core/location/location_service.dart';


import '../core/sync/sync_service.dart';
import '../features/auth/data/auth_remote_ds.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_notifier.dart';
import '../features/master/presentation/master_providers.dart';
import '../features/registros/data/registros_local_ds.dart';
import '../features/registros/data/registros_remote_ds.dart';
import '../features/templates/data/templates_remote_ds.dart';
import '../features/templates/data/templates_repository.dart';
import '../features/templates/presentation/templates_notifier.dart';


// ✅ Cambia esto según tu device:
// Emulator Android: http://10.0.2.2:8000
// PC/Web: http://localhost:8000  (si el backend está en la misma PC)
// Celular real: http://192.168.x.x:8000
// const baseUrl = 'http://127.0.0.1:8000';//local
const baseUrl = 'http://192.168.0.130:8000';//tablet
// const baseUrl = 'http://10.0.2.2:8000';

// final tokenStoreProvider = Provider<TokenStore>((ref) => createTokenStore());

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore(ref.read(secureStorageProvider));
});

final dioClientProvider = Provider<DioClient>((ref) {
  final store = ref.read(tokenStoreProvider);

  return DioClient(baseUrl: baseUrl, tokenStore: store);
});

final authRemoteProvider = Provider<AuthRemoteDS>((ref) {
  final dio = ref.read(dioClientProvider).dio;
  return AuthRemoteDS(dio);
});

final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    remote: ref.read(authRemoteProvider),
    tokenStore: ref.read(tokenStoreProvider),
  );
});

final appDbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});



final authUserIdProvider = FutureProvider<int?>((ref) async {
  final tokenStore = ref.read(tokenStoreProvider);

  final token = await tokenStore.getAccessToken();
  return tryGetUserIdFromJwt(token);
});


final templatesRemoteProvider = Provider<TemplatesRemoteDS>((ref) {
  final dio = ref.read(dioClientProvider).dio;
  return TemplatesRemoteDS(dio);
});

final templatesRepoProvider = Provider<TemplatesRepository>((ref) {
  return TemplatesRepository(
    remote: ref.read(templatesRemoteProvider),
    plantillasDao: ref.read(plantillasDaoProvider),
    syncCursorDao: ref.read(syncCursorDaoProvider),
  );
});

final templatesNotifierProvider =
StateNotifierProvider<TemplatesNotifier, TemplatesUiState>((ref) {
  return TemplatesNotifier(ref.read(templatesRepoProvider));
});


// userId actual (léelo del token o del user guardado)
final currentUserIdProvider = Provider<int>((ref) {
  return 6066; // TODO: sacar del login real
});

// Sync (lo dejamos con stub por ahora)
final syncControllerProvider = StateNotifierProvider<SyncController, AsyncValue<void>>((ref) {
  return SyncController();
});

class SyncController extends StateNotifier<AsyncValue<void>> {
  SyncController() : super(const AsyncData(null));

  Future<void> syncAll() async {
    // TODO: implementar luego
  }

  Future<void> syncPlantilla(int plantillaId) async {
    // TODO: implementar luego
  }
}


final registrosRemoteDSProvider = Provider<RegistrosRemoteDS>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return RegistrosRemoteDS(dioClient);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final local = ref.read(registrosLocalDSProvider);
  final remote = ref.read(registrosRemoteDSProvider);
  return SyncService(local: local, remote: remote);
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final plantillasDaoProvider = Provider<PlantillasDao>((ref) {
  final db = ref.read(appDatabaseProvider);
  return PlantillasDao(db);
});

final registrosDaoProvider = Provider<RegistrosDao>((ref) {
  final db = ref.read(appDatabaseProvider);
  return RegistrosDao(db);
});

final registrosLocalDSProvider = Provider<RegistrosLocalDS>((ref) {
  final dao = ref.read(registrosDaoProvider);
  return RegistrosLocalDS(dao);
});

final syncCursorDaoProvider = Provider<SyncCursorDao>((ref) {
  final db = ref.read(appDatabaseProvider);
  return SyncCursorDao(db);
});

// Campañas
final catalogCampaniasProvider =
StreamProvider<List<CampaniasTableData>>((ref) {
  return ref.watch(campaniasStreamProvider.stream);
});

// Lotes
final catalogLotesProvider =
StreamProvider<List<LotesTableData>>((ref) {
  return ref.watch(lotesStreamProvider.stream);
});

// ✅ ESTE ES EL QUE TE FALTABA EN APP/LOGIN
final authProvider =
NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
