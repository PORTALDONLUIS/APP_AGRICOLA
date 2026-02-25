// lib/features/conteo_racimos/application/cartilla_conteo_racimos_form_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../../../../app/providers.dart';

import '../../domain/cartilla_conteo_racimos_config.dart';
import 'cartilla_conteo_racimos_payload.dart';


class CartillaConteoRacimosFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaConteoRacimosPayload payload;
  final List<String> errors;

  const CartillaConteoRacimosFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaConteoRacimosFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaConteoRacimosPayload? payload,
    List<String>? errors,
  }) {
    return CartillaConteoRacimosFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaConteoRacimosFormProvider = StateNotifierProvider.family<
    CartillaConteoRacimosFormNotifier, CartillaConteoRacimosFormState, int>(
      (ref, localId) {
    final local = ref.read(registrosLocalDSProvider);
    return CartillaConteoRacimosFormNotifier(ref:ref, localId: localId, local: local)..load();
  },
);

class CartillaConteoRacimosFormNotifier
    extends StateNotifier<CartillaConteoRacimosFormState> with  GeoSaveMixin {

  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaConteoRacimosFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
    CartillaConteoRacimosFormState(
      localId: localId,
      loading: true,
      saving: false,
      payload: CartillaConteoRacimosPayload.empty(),
      errors: const [],
    ),
  );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      final raw = (reg.dataJson?.isNotEmpty == true) ? reg.dataJson! : '{}';
      final map = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};

      final body = (map['payloadVersion'] != null && map['body'] is Map)
          ? Map<String, dynamic>.from(map['body'] as Map)
          : Map<String, dynamic>.from(map);

      final header = <String, dynamic>{
        'plantillaId': reg.plantillaId,
        'userId': reg.userId,
        'campaniaId': reg.campaniaId,
        'loteId': reg.loteId,
        'lat': reg.lat?.toDouble(),
        'lon': reg.lon?.toDouble(),
        'fechaEjecucion': null,
      };

      final payload = _recompute(
        CartillaConteoRacimosPayload(
          payloadVersion: 1,
          header: header,
          body: body,
        ),
      );

      // Persistir normalizado
      await local.updateDataJson(localId, payload.toJsonString());

      state = state.copyWith(loading: false, payload: payload);
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  // ✅ recalcula en vivo cada vez que el motor hace nt.update(nextPayload)
  void update(CartillaConteoRacimosPayload payload) {
    state = state.copyWith(payload: _recompute(payload));
  }

  CartillaConteoRacimosPayload _recompute(CartillaConteoRacimosPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    double asDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    // Total S+D = (racimo simple + racimo doble) :contentReference[oaicite:21]{index=21}
    // Interpretación: suma ambos pares (6-7 y 8-9) porque el manual lista 2 veces simple/doble.
    final rs1 = asDouble(body[CartillaConteoRacimosConfig.kRacimoSimple1]);
    final rd1 = asDouble(body[CartillaConteoRacimosConfig.kRacimoDoble1]);
    final rs2 = asDouble(body[CartillaConteoRacimosConfig.kRacimoSimple2]);
    final rd2 = asDouble(body[CartillaConteoRacimosConfig.kRacimoDoble2]);

    final totalSD = rs1 + rd1 + rs2 + rd2;
    body[CartillaConteoRacimosConfig.kTotalSD] = totalSD;

    final indef = asDouble(body[CartillaConteoRacimosConfig.kRacimoIndefinido]);
    final corr = asDouble(body[CartillaConteoRacimosConfig.kRacimoCorrido]);

    // Total = (Total S+D + Indefinido + Corrido) :contentReference[oaicite:22]{index=22}
    final total = totalSD + indef + corr;
    body[CartillaConteoRacimosConfig.kTotal] = total;

    return p.copyWith(body: body);
  }

  Future<void> saveLocal() async {
    state = state.copyWith(saving: true);
    try {

      // 1) Adjuntar geo al header (si hay permiso/GPS/fix)
      final headerWithGeo = await attachGeo(ref, state.payload.header);
      final payloadWithGeo = state.payload.copyWith(header: headerWithGeo);
      state = state.copyWith(payload: payloadWithGeo);

      final fixed = _recompute(state.payload);

      await local.saveLocal(
        localId: localId,
        data: fixed.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );

      state = state.copyWith(payload: fixed);
    } finally {
      state = state.copyWith(saving: false);
    }
  }

  Future<void> finalize() async {
    await saveLocal();
    await local.markAsReadyForSync(localId);
  }

  // ✅ +1 genérico: copia lo marcado en config (+1)
  Future<int> duplicateAsNew() async {
    await saveLocal();
    final cfg = CartillaConteoRacimosConfig();

    // Requiere que ya tengas arreglado local.duplicateAsNew para copiar body/header bien.
    final newLocalId = await local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );

    return newLocalId;
  }
}
