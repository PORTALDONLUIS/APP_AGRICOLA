import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_clasificacion_cargadores_config.dart';
import '../../domain/cartilla_clasificacion_cargadores_payload.dart';

class CartillaClasificacionCargadoresFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaClasificacionCargadoresPayload payload;
  final List<String> errors;

  const CartillaClasificacionCargadoresFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaClasificacionCargadoresFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaClasificacionCargadoresPayload? payload,
    List<String>? errors,
  }) {
    return CartillaClasificacionCargadoresFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaClasificacionCargadoresFormProvider = StateNotifierProvider.family<
    CartillaClasificacionCargadoresFormNotifier,
    CartillaClasificacionCargadoresFormState,
    int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaClasificacionCargadoresFormNotifier(
    ref: ref,
    localId: localId,
    local: local,
  )..load();
});

class CartillaClasificacionCargadoresFormNotifier
    extends StateNotifier<CartillaClasificacionCargadoresFormState>
    with  GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaClasificacionCargadoresFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(CartillaClasificacionCargadoresFormState(
    localId: localId,
    loading: true,
    saving: false,
    payload: CartillaClasificacionCargadoresPayload.empty(),
    errors: const [],
  ));

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('🟦 CLASIF_CARGADORES load localId=$localId');
      debugPrint('🟦 CLASIF_CARGADORES dataJsonLen=${reg.dataJson.length}');

      final raw = (reg.dataJson).trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaClasificacionCargadoresPayload payload;
      if (isEmptyJson) {
        payload = CartillaClasificacionCargadoresPayload.empty();

        payload = payload.copyWith(
          header: {
            ...payload.header,
            'plantillaId': reg.plantillaId,
            'userId': reg.userId,
            'campaniaId': reg.campaniaId,
            'loteId': reg.loteId,
            'lat': reg.lat,
            'lon': reg.lon,
          },
        );

        await local.updateDataJson(localId, payload.toJsonString());
        debugPrint(
            '🟦 CLASIF_CARGADORES load: dataJson vacío -> inicializado y guardado');
      } else {
        payload = CartillaClasificacionCargadoresPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 CLASIF_CARGADORES load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaClasificacionCargadoresPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  // =====================================================
  // _recompute (Manual)
  // Total = suma de 9 campos:
  // P_debiles + P_normales + P_vigoroso +
  // S_debiles + S_normales + S_vigoroso +
  // T_debiles + T_normales + T_vigoroso
  // :contentReference[oaicite:2]{index=2}
  // =====================================================
  CartillaClasificacionCargadoresPayload _recompute(
      CartillaClasificacionCargadoresPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final total = asInt(body['p_debiles_456']) +
        asInt(body['p_normales_789']) +
        asInt(body['p_vigoroso_10111213']) +
        asInt(body['s_debiles_456']) +
        asInt(body['s_normales_789']) +
        asInt(body['s_vigoroso_10111213']) +
        asInt(body['t_debiles_456']) +
        asInt(body['t_normales_789']) +
        asInt(body['t_vigoroso_10111213']);

    body['total'] = total.toDouble();

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('✅ CLASIF_CARGADORES saveLocal START localId=$localId');

    // 1) Adjuntar geo al header (si hay permiso/GPS/fix)
    final headerWithGeo = await attachGeo(ref, state.payload.header);
    final payloadWithGeo = state.payload.copyWith(header: headerWithGeo);
    state = state.copyWith(payload: payloadWithGeo);

    final fixed = _recompute(state.payload);

    debugPrint('🧾 ===== JSON BEFORE SAVE =====');
    debugPrint(jsonEncode(fixed.toJson()));
    debugPrint('🧾 ===== END JSON =====');

    state = state.copyWith(saving: true);
    try {
      state = state.copyWith(payload: fixed);

      await local.saveLocal(
        localId: localId,
        data: fixed.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );

      debugPrint('✅ CLASIF_CARGADORES saveLocal DONE');
    } finally {
      state = state.copyWith(saving: false);
    }
  }

  @override
  Future<void> finalize() async {
    await saveLocal();
    await local.markAsReadyForSync(localId);
  }

  @override
  Future<int> duplicateAsNew() async {
    await saveLocal();
    final cfg = CartillaClasificacionCargadoresConfig();

    final newLocalId = await local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );

    return newLocalId;
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    // TODO
  }
}
