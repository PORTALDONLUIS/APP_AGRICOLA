import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mixins/geo_save_mixin.dart';
import '../../../../core/sync/sync_models.dart';
import '../../../cartillas/application/cartilla_form_contract.dart';
import '../../../registros/data/registros_local_ds.dart';
import '../../../../app/providers.dart';

import '../domain/cartilla_brix_moscatel_config.dart';
import '../domain/cartilla_brix_moscatel_payload.dart';

class CartillaBrixMoscatelFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaBrixMoscatelPayload payload;
  final List<String> errors;

  const CartillaBrixMoscatelFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaBrixMoscatelFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaBrixMoscatelPayload? payload,
    List<String>? errors,
  }) {
    return CartillaBrixMoscatelFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaBrixMoscatelFormProvider = StateNotifierProvider.family<
    CartillaBrixMoscatelFormNotifier,
    CartillaBrixMoscatelFormState,
    int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaBrixMoscatelFormNotifier(
    ref: ref,
    localId: localId,
    local: local,
  )..load();
});

class CartillaBrixMoscatelFormNotifier
    extends StateNotifier<CartillaBrixMoscatelFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final int localId;
  final RegistrosLocalDS local;
  final Ref ref;

  CartillaBrixMoscatelFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(CartillaBrixMoscatelFormState(
          localId: localId,
          loading: true,
          saving: false,
          payload: CartillaBrixMoscatelPayload.empty(),
          errors: const [],
        ));

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('🟦 BRIX_MOSCATEL load localId=$localId');
      debugPrint('🟦 BRIX_MOSCATEL dataJsonLen=${reg.dataJson.length}');

      final raw = (reg.dataJson).trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaBrixMoscatelPayload payload;
      if (isEmptyJson) {
        payload = CartillaBrixMoscatelPayload.empty();

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
          body: {
            ...payload.body,
            'variedad': 'MOSCATEL',
          },
        );

        await local.updateDataJson(localId, payload.toJsonString());
        debugPrint('🟦 BRIX_MOSCATEL load: dataJson vacío -> inicializado y guardado');
      } else {
        payload = CartillaBrixMoscatelPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 BRIX_MOSCATEL load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaBrixMoscatelPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  // =====================================================
  // _recompute
  // No hay fórmulas en el manual.
  // Se mantiene patrón y se normaliza variedad fija.
  // =====================================================
  CartillaBrixMoscatelPayload _recompute(CartillaBrixMoscatelPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    body['variedad'] = 'MOSCATEL';

    double? asDoubleNullable(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      if (v is String) {
        final s = v.trim().replaceAll(',', '.');
        if (s.isEmpty) return null;
        return double.tryParse(s);
      }
      return null;
    }

    final brix = asDoubleNullable(body['brixSsc']);
    body['brixSsc'] = brix;

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('✅ BRIX_MOSCATEL saveLocal START localId=$localId');

    final fixed = _recompute(state.payload);
    final headerWithGeo =
        await attachGeo(ref, Map<String, dynamic>.from(fixed.header));
    final fixedWithGeo = fixed.copyWith(header: headerWithGeo);

    debugPrint('🧾 ===== JSON BEFORE SAVE =====');
    debugPrint(jsonEncode(fixedWithGeo.toJson()));
    debugPrint('🧾 ===== END JSON =====');

    state = state.copyWith(saving: true);
    try {
      state = state.copyWith(payload: fixedWithGeo);

      await local.saveLocal(
        localId: localId,
        data: fixedWithGeo.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );

      debugPrint('✅ BRIX_MOSCATEL saveLocal DONE');
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
    final cfg = CartillaBrixMoscatelConfig();

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