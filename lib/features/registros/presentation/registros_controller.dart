import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/time/operational_timezone_pe.dart';
import '../domain/registro.dart';
import '../data/registros_local_ds.dart';

/// Stream de registros locales por plantilla
final registrosByPlantillaProvider =
StreamProvider.family.autoDispose<List<Registro>, int>((ref, plantillaId) {
  final RegistrosLocalDS local = ref.watch(registrosLocalDSProvider);
  final userId = ref.watch(currentUserIdProvider);
  return local.watchByPlantilla(plantillaId, userId);
});

class DailySampleNumberRequest {
  final int plantillaId;
  final int userId;
  final int? loteId;
  final int localId;

  const DailySampleNumberRequest({
    required this.plantillaId,
    required this.userId,
    required this.loteId,
    required this.localId,
  });

  @override
  bool operator ==(Object other) =>
      other is DailySampleNumberRequest &&
      other.plantillaId == plantillaId &&
      other.userId == userId &&
      other.loteId == loteId &&
      other.localId == localId;

  @override
  int get hashCode => Object.hash(plantillaId, userId, loteId, localId);
}

/// Contador ligero para cartillas de muestreo masivo.
final dailySampleNumberProvider = FutureProvider.autoDispose.family<
    int, DailySampleNumberRequest>((ref, request) async {
  final nowUtc = DateTime.now().toUtc();
  final dayPeru = operationalYearMonthDayUtc5(nowUtc);
  final startsAtUtc = dayPeru.add(kOperationalUtcOffsetPeru);
  final endsAtUtc = startsAtUtc.add(const Duration(days: 1));
  return ref.read(registrosLocalDSProvider).countForOperationalDayUntil(
    plantillaId: request.plantillaId,
    userId: request.userId,
    loteId: request.loteId,
    localId: request.localId,
    startsAtUtc: startsAtUtc,
    endsAtUtc: endsAtUtc,
  );
});
