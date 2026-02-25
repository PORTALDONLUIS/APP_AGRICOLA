import 'package:donluis_forms/core/mixins/geo_save_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/sync/sync_models.dart';

import '../../../../../app/providers.dart';
import '../../../cartillas/application/cartilla_form_contract.dart';
import '../../../registros/data/registros_local_ds.dart';
import '../domain/cartilla_floracion_cuaja_config.dart';
import '../domain/cartilla_floracion_cuaja_payload.dart';


class CartillaFloracionCuajaFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaFloracionCuajaPayload payload;
  final List<String> errors;

  const CartillaFloracionCuajaFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaFloracionCuajaFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaFloracionCuajaPayload? payload,
    List<String>? errors,
  }) {
    return CartillaFloracionCuajaFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaFloracionCuajaFormProvider = StateNotifierProvider.family<
    CartillaFloracionCuajaFormNotifier,
    CartillaFloracionCuajaFormState,
    int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaFloracionCuajaFormNotifier(ref:ref, localId: localId, local: local)
    ..load();
});

class CartillaFloracionCuajaFormNotifier
    extends StateNotifier<CartillaFloracionCuajaFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaFloracionCuajaFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(CartillaFloracionCuajaFormState(
    localId: localId,
    loading: true,
    saving: false,
    payload: CartillaFloracionCuajaPayload.empty(),
    errors: const [],
  ));

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);
      final raw = (reg.dataJson).trim();
      final isEmpty = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaFloracionCuajaPayload payload;
      if (isEmpty) {
        payload = CartillaFloracionCuajaPayload.empty().copyWith(
          header: {
            'plantillaId': reg.plantillaId,
            'userId': reg.userId,
            'campaniaId': reg.campaniaId,
            'loteId': reg.loteId,
            'lat': reg.lat,
            'lon': reg.lon,
          },
        );
        await local.updateDataJson(localId, payload.toJsonString());
      } else {
        payload = CartillaFloracionCuajaPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 FLORACION load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaFloracionCuajaPayload payload) {
    state = state.copyWith(payload: _recompute(payload));
  }

  CartillaFloracionCuajaPayload _recompute(
      CartillaFloracionCuajaPayload p) {
    final b = Map<String, dynamic>.from(p.body);

    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final sumFloracion = asInt(b['p10']) +
        asInt(b['p20']) +
        asInt(b['p30']) +
        asInt(b['p40']) +
        asInt(b['p50']) +
        asInt(b['p60']) +
        asInt(b['p70']) +
        asInt(b['p80']) +
        asInt(b['p90']) +
        asInt(b['p100']);

    final totalRacimos =
        asInt(b['caliptraHinchada']) + sumFloracion + asInt(b['cuaja']);

    b['sumFloracion'] = sumFloracion;
    b['totalRacimos'] = totalRacimos;
    b['caliptraPct'] =
    totalRacimos == 0 ? 0.0 : (asInt(b['caliptraHinchada']) / totalRacimos) * 100;
    b['floracionPct'] =
    totalRacimos == 0 ? 0.0 : (sumFloracion / totalRacimos) * 100;
    b['cuajaPct'] =
    totalRacimos == 0 ? 0.0 : (asInt(b['cuaja']) / totalRacimos) * 100;

    return p.copyWith(body: b);
  }

  @override
  Future<void> saveLocal() async {

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
  }

  @override
  Future<void> finalize() async {
    await saveLocal();
    await local.markAsReadyForSync(localId);
  }

  @override
  Future<int> duplicateAsNew() async {
    await saveLocal();
    final cfg = CartillaFloracionCuajaConfig();
    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {}
}
