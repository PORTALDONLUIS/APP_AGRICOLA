import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/sync/sync_models.dart';
import '../../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_brix_config.dart';
import '../../domain/cartilla_brix_payload.dart';


class CartillaBrixFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaBrixPayload payload;
  final List<String> errors;

  const CartillaBrixFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaBrixFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaBrixPayload? payload,
    List<String>? errors,
  }) {
    return CartillaBrixFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaBrixFormProvider = StateNotifierProvider.family<
    CartillaBrixFormNotifier,
    CartillaBrixFormState,
    int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaBrixFormNotifier(ref: ref, localId: localId, local: local)..load();
});

class CartillaBrixFormNotifier extends StateNotifier<CartillaBrixFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaBrixFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(CartillaBrixFormState(
    localId: localId,
    loading: true,
    saving: false,
    payload: CartillaBrixPayload.empty(),
    errors: const [],
  ));

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('🟦 BRIX load localId=$localId');
      debugPrint('🟦 BRIX dataJsonLen=${reg.dataJson.length}');

      final raw = (reg.dataJson).trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaBrixPayload payload;
      if (isEmptyJson) {
        payload = CartillaBrixPayload.empty();

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
        debugPrint('🟦 BRIX load: dataJson vacío -> inicializado y guardado');
      } else {
        payload = CartillaBrixPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 BRIX load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaBrixPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  // =====================================================
  // _recompute (PDF)
  // totalBayasEvaluadas = (5% + 5.5% + ... + 23.5%)
  // promBrixPlanta = sum(count * brixValue) / totalBayasEvaluadas
  // =====================================================
  CartillaBrixPayload _recompute(CartillaBrixPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    const items = <MapEntry<double, String>>[
      MapEntry(5.0, 'brix5'),
      MapEntry(5.5, 'brix5_5'),
      MapEntry(6.0, 'brix6'),
      MapEntry(6.5, 'brix6_5'),
      MapEntry(7.0, 'brix7'),
      MapEntry(7.5, 'brix7_5'),
      MapEntry(8.0, 'brix8'),
      MapEntry(8.5, 'brix8_5'),
      MapEntry(9.0, 'brix9'),
      MapEntry(9.5, 'brix9_5'),
      MapEntry(10.0, 'brix10'),
      MapEntry(10.5, 'brix10_5'),
      MapEntry(11.0, 'brix11'),
      MapEntry(11.5, 'brix11_5'),
      MapEntry(12.0, 'brix12'),
      MapEntry(12.5, 'brix12_5'),
      MapEntry(13.0, 'brix13'),
      MapEntry(13.5, 'brix13_5'),
      MapEntry(14.0, 'brix14'),
      MapEntry(14.5, 'brix14_5'),
      MapEntry(15.0, 'brix15'),
      MapEntry(15.5, 'brix15_5'),
      MapEntry(16.0, 'brix16'),
      MapEntry(16.5, 'brix16_5'),
      MapEntry(17.0, 'brix17'),
      MapEntry(17.5, 'brix17_5'),
      MapEntry(18.0, 'brix18'),
      MapEntry(18.5, 'brix18_5'),
      MapEntry(19.0, 'brix19'),
      MapEntry(19.5, 'brix19_5'),
      MapEntry(20.0, 'brix20'),
      MapEntry(20.5, 'brix20_5'),
      MapEntry(21.0, 'brix21'),
      MapEntry(21.5, 'brix21_5'),
      MapEntry(22.0, 'brix22'),
      MapEntry(22.5, 'brix22_5'),
      MapEntry(23.0, 'brix23'),
      MapEntry(23.5, 'brix23_5'),
    ];

    int total = 0;
    double weighted = 0.0;

    for (final it in items) {
      final c = asInt(body[it.value]);
      total += c;
      weighted += (c * it.key);
    }

    body['totalBayasEvaluadas'] = total.toDouble();
    body['promBrixPlanta'] = total == 0 ? 0.0 : (weighted / total);

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('✅ BRIX saveLocal START localId=$localId');

    state = state.copyWith(saving: true);
    try {
      // 1) Adjuntar geo al header (si hay permiso/GPS/fix)
      final headerWithGeo = await attachGeo(ref, state.payload.header);
      final payloadWithGeo = state.payload.copyWith(header: headerWithGeo);
      state = state.copyWith(payload: payloadWithGeo);

      // 2) Recompute (solo body)
      final fixed = _recompute(state.payload);
      state = state.copyWith(payload: fixed);

      // 3) Log del JSON FINAL que se guardará (ya con geo)
      debugPrint('🧾 ===== JSON BEFORE SAVE =====');
      debugPrint(jsonEncode(fixed.toJson()));
      debugPrint('🧾 ===== END JSON =====');

      // 4) Guardar
      await local.saveLocal(
        localId: localId,
        data: fixed.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );

      debugPrint('✅ BRIX saveLocal DONE');
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
    final cfg = CartillaBrixConfig();

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
