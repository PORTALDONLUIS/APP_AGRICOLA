import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_engome_config.dart';
import '../../domain/cartilla_engome_payload.dart';


class CartillaEngomeFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaEngomePayload payload;
  final List<String> errors;

  const CartillaEngomeFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaEngomeFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaEngomePayload? payload,
    List<String>? errors,
  }) {
    return CartillaEngomeFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaEngomeFormProvider = StateNotifierProvider.family<
    CartillaEngomeFormNotifier,
    CartillaEngomeFormState,
    int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaEngomeFormNotifier(ref:ref, localId: localId, local: local)..load();
});

class CartillaEngomeFormNotifier extends StateNotifier<CartillaEngomeFormState>
    with  GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaEngomeFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(CartillaEngomeFormState(
    localId: localId,
    loading: true,
    saving: false,
    payload: CartillaEngomePayload.empty(),
    errors: const [],
  ));

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('🟦 ENGOME load localId=$localId');
      debugPrint('🟦 ENGOME dataJsonLen=${reg.dataJson.length}');

      final raw = (reg.dataJson).trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaEngomePayload payload;
      if (isEmptyJson) {
        payload = CartillaEngomePayload.empty();

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
        debugPrint('🟦 ENGOME load: dataJson vacío -> inicializado y guardado');
      } else {
        payload = CartillaEngomePayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 ENGOME load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaEngomePayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  // =====================================================
  // _recompute (PDF)
  // 9. Pinta total rac/planta = VERDE + ENGOME
  // =====================================================
  CartillaEngomePayload _recompute(CartillaEngomePayload p) {
    final body = Map<String, dynamic>.from(p.body);

    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final verde = asInt(body['verdeNRacPlanta']);
    final engome = asInt(body['engomeNRacPlanta']);

    body['pintaTotalRacPlanta'] = (verde + engome).toDouble();

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('✅ ENGOME saveLocal START localId=$localId');

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

      debugPrint('✅ ENGOME saveLocal DONE');
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
    final cfg = CartillaEngomeConfig();

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
