import 'dart:convert';

import 'package:donluis_forms/core/mixins/geo_save_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../../app/providers.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_fertilidad_config.dart';
import '../../domain/cartilla_fertilidad_payload.dart';

class CartillaFertilidadFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaFertilidadPayload payload;
  final List<String> errors;

  const CartillaFertilidadFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaFertilidadFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaFertilidadPayload? payload,
    List<String>? errors,
  }) {
    return CartillaFertilidadFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaFertilidadFormProvider = StateNotifierProvider.family<
    CartillaFertilidadFormNotifier,
    CartillaFertilidadFormState,
    int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaFertilidadFormNotifier(ref:ref, localId: localId, local: local)..load();
});

class CartillaFertilidadFormNotifier
    extends StateNotifier<CartillaFertilidadFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaFertilidadFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(CartillaFertilidadFormState(
    localId: localId,
    loading: true,
    saving: false,
    payload: CartillaFertilidadPayload.empty(),
    errors: const [],
  ));

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('🟦 FERTILIDAD load localId=$localId');
      debugPrint('🟦 FERTILIDAD dataJsonLen=${reg.dataJson.length}');

      final raw = (reg.dataJson).trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaFertilidadPayload payload;
      if (isEmptyJson) {
        payload = CartillaFertilidadPayload.empty();

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
        debugPrint('🟦 FERTILIDAD load: dataJson vacío -> inicializado y guardado');
      } else {
        payload = CartillaFertilidadPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 FERTILIDAD load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaFertilidadPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  // =====================================================
  // _recompute (reglas del manual)
  // CAT/YEMA depende de Evaluación:
  // - I ACARO-FERTILIDAD => no hay opciones => limpiar cat/yema en todas las yemas
  // - II / III => permite M/I (si hay otro valor, se limpia)
  // =====================================================
  CartillaFertilidadPayload _recompute(CartillaFertilidadPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    final eval = (body['evaluacion'] ?? '').toString().trim();

    final allowed = (eval.startsWith('II') || eval.startsWith('III'))
        ? const {'M', 'I'}
        : const <String>{}; // I => ninguna opción

    void normalizeCat(String key) {
      final v = body[key];
      if (allowed.isEmpty) {
        body[key] = null;
        return;
      }
      if (v == null) return;
      final s = v.toString().trim();
      body[key] = allowed.contains(s) ? s : null;
    }

    normalizeCat('yema1_catYema');
    normalizeCat('yema2_catYema');
    normalizeCat('yema3_catYema');
    normalizeCat('yema4_catYema');
    normalizeCat('yema5_catYema');
    normalizeCat('yema6_catYema');
    normalizeCat('yema7_catYema');

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('✅ FERTILIDAD saveLocal START localId=$localId');

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

      debugPrint('✅ FERTILIDAD saveLocal DONE');
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
    final cfg = CartillaFertilidadConfig();

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
