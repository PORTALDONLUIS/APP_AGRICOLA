import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_conteo_cargadores_config.dart';
import '../../domain/cartilla_conteo_cargadores_payload.dart';


class CartillaConteoCargadoresFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaConteoCargadoresPayload payload;
  final List<String> errors;

  const CartillaConteoCargadoresFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaConteoCargadoresFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaConteoCargadoresPayload? payload,
    List<String>? errors,
  }) {
    return CartillaConteoCargadoresFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaConteoCargadoresFormProvider = StateNotifierProvider.family<
    CartillaConteoCargadoresFormNotifier,
    CartillaConteoCargadoresFormState,
    int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaConteoCargadoresFormNotifier(ref: ref, localId: localId, local: local)
    ..load();
});

class CartillaConteoCargadoresFormNotifier
    extends StateNotifier<CartillaConteoCargadoresFormState>
    with  GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaConteoCargadoresFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(CartillaConteoCargadoresFormState(
    localId: localId,
    loading: true,
    saving: false,
    payload: CartillaConteoCargadoresPayload.empty(),
    errors: const [],
  ));

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('🟦 CONTEO_CARGADORES load localId=$localId');
      debugPrint('🟦 CONTEO_CARGADORES dataJsonLen=${reg.dataJson.length}');

      final raw = (reg.dataJson).trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaConteoCargadoresPayload payload;
      if (isEmptyJson) {
        payload = CartillaConteoCargadoresPayload.empty();

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
        debugPrint('🟦 CONTEO_CARGADORES load: dataJson vacío -> inicializado');
      } else {
        payload = CartillaConteoCargadoresPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 CONTEO_CARGADORES load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaConteoCargadoresPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  // =====================================================
  // _recompute
  // No hay fórmulas/calculados en el manual.
  // Se deja el hook para mantener el patrón.
  // =====================================================
  CartillaConteoCargadoresPayload _recompute(CartillaConteoCargadoresPayload p) {
    // Normalización mínima (asegurar int no negativo en stepper)
    final body = Map<String, dynamic>.from(p.body);

    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final n = asInt(body['numeroCargadores']);
    body['numeroCargadores'] = n < 0 ? 0 : n;

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('✅ CONTEO_CARGADORES saveLocal START localId=$localId');

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

      debugPrint('✅ CONTEO_CARGADORES saveLocal DONE');
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
    final cfg = CartillaConteoCargadoresConfig();

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
