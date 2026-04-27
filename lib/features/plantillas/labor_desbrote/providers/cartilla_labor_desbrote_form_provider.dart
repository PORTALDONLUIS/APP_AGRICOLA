import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/sync_models.dart';
import '../../../cartillas/application/cartilla_form_contract.dart';
import '../../../registros/data/registros_local_ds.dart';
import '../../../../app/providers.dart';

import '../domain/cartilla_labor_desbrote_config.dart';
import '../domain/cartilla_labor_desbrote_payload.dart';

class CartillaLaborDesbroteFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaLaborDesbrotePayload payload;
  final List<String> errors;

  const CartillaLaborDesbroteFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaLaborDesbroteFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaLaborDesbrotePayload? payload,
    List<String>? errors,
  }) {
    return CartillaLaborDesbroteFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaLaborDesbroteFormProvider = StateNotifierProvider.family<
    CartillaLaborDesbroteFormNotifier,
    CartillaLaborDesbroteFormState,
    int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaLaborDesbroteFormNotifier(localId: localId, local: local)
    ..load();
});

class CartillaLaborDesbroteFormNotifier
    extends StateNotifier<CartillaLaborDesbroteFormState>
    implements CartillaFormNotifierBase {
  final int localId;
  final RegistrosLocalDS local;

  CartillaLaborDesbroteFormNotifier({
    required this.localId,
    required this.local,
  }) : super(CartillaLaborDesbroteFormState(
          localId: localId,
          loading: true,
          saving: false,
          payload: CartillaLaborDesbrotePayload.empty(),
          errors: const [],
        ));

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('🟦 LABOR_DESBROTE load localId=$localId');
      debugPrint('🟦 LABOR_DESBROTE dataJsonLen=${reg.dataJson.length}');

      final raw = (reg.dataJson).trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaLaborDesbrotePayload payload;
      if (isEmptyJson) {
        payload = CartillaLaborDesbrotePayload.empty();

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
        debugPrint('🟦 LABOR_DESBROTE load: dataJson vacío -> inicializado');
      } else {
        payload = CartillaLaborDesbrotePayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 LABOR_DESBROTE load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaLaborDesbrotePayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  // =====================================================
  // _recompute
  // Total Brotes = Piton en brote + Cargadores + Material Viejo
  // Total S+D = Racimo Simple + Racimo Doble
  // =====================================================
  CartillaLaborDesbrotePayload _recompute(CartillaLaborDesbrotePayload p) {
    final body = Map<String, dynamic>.from(p.body);

    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    int clampInt(dynamic v, int min, int? max) {
      var n = asInt(v);
      if (n < min) n = min;
      if (max != null && n > max) n = max;
      return n;
    }

    body['pitonBrote'] = clampInt(body['pitonBrote'], 0, 50);
    body['cargadores'] = clampInt(body['cargadores'], 0, 150);
    body['materialViejo'] = clampInt(body['materialViejo'], 0, 50);

    body['piton'] = clampInt(body['piton'], 0, 50);
    body['racimoSimple'] = clampInt(body['racimoSimple'], 0, null);
    body['racimoDoble'] = clampInt(body['racimoDoble'], 0, 100);
    body['racimoIndefinido'] = clampInt(body['racimoIndefinido'], 0, null);

    final totalBrotes = asInt(body['pitonBrote']) +
        asInt(body['cargadores']) +
        asInt(body['materialViejo']);

    final totalSimpleDoble =
        asInt(body['racimoSimple']) + asInt(body['racimoDoble']);

    body['totalBrotes'] = totalBrotes.toDouble();
    body['totalSimpleDoble'] = totalSimpleDoble.toDouble();

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('✅ LABOR_DESBROTE saveLocal START localId=$localId');

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

      debugPrint('✅ LABOR_DESBROTE saveLocal DONE');
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
    final cfg = CartillaLaborDesbroteConfig();

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
