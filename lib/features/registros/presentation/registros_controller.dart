import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/registro.dart';
import '../data/registros_local_ds.dart';

/// Stream de registros locales por plantilla
final registrosByPlantillaProvider =
StreamProvider.family.autoDispose<List<Registro>, int>((ref, plantillaId) {
  final RegistrosLocalDS local = ref.watch(registrosLocalDSProvider);
  final userId = ref.watch(currentUserIdProvider);
  return local.watchByPlantilla(plantillaId, userId);
});
