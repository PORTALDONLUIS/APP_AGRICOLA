import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../../../../app/providers.dart';

import '../../domain/cartilla_calibre_bayas_config.dart';
import '../../domain/cartilla_calibre_bayas_payload.dart';

class CartillaCalibreBayasFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaCalibreBayasPayload payload;
  final List<String> errors;

  const CartillaCalibreBayasFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaCalibreBayasFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaCalibreBayasPayload? payload,
    List<String>? errors,
  }) {
    return CartillaCalibreBayasFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaCalibreBayasFormProvider = StateNotifierProvider.family<
    CartillaCalibreBayasFormNotifier,
    CartillaCalibreBayasFormState,
    int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaCalibreBayasFormNotifier(ref: ref, localId: localId, local: local)
    ..load();
});

class CartillaCalibreBayasFormNotifier
    extends StateNotifier<CartillaCalibreBayasFormState>
    with  GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaCalibreBayasFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(CartillaCalibreBayasFormState(
    localId: localId,
    loading: true,
    saving: false,
    payload: CartillaCalibreBayasPayload.empty(),
    errors: const [],
  ));

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('🟦 CALIBRE load localId=$localId');
      debugPrint('🟦 CALIBRE dataJsonLen=${reg.dataJson.length}');

      final raw = (reg.dataJson).trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaCalibreBayasPayload payload;
      if (isEmptyJson) {
        payload = CartillaCalibreBayasPayload.empty();

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
        debugPrint('🟦 CALIBRE load: dataJson vacío -> inicializado y guardado');
      } else {
        payload = CartillaCalibreBayasPayload.fromJsonString(raw);
      }

      final fixed = _recompute(payload);

      state = state.copyWith(
        loading: false,
        payload: fixed,
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 CALIBRE load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaCalibreBayasPayload payload) {
    final fixed = _recompute(payload);
    state = state.copyWith(payload: fixed, errors: const []);
  }

  // =====================================================
  // Recompute (fórmulas del PDF)
  // totalBayasEvaluadas = suma(mm0_5 .. mm38)
  // promCalibresPlanta = sum(mmX * X) / totalBayasEvaluadas
  // =====================================================
  CartillaCalibreBayasPayload _recompute(CartillaCalibreBayasPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    // diámetro(mm) -> key en body
    const items = <MapEntry<double, String>>[
      MapEntry(0.5, 'mm0_5'),
      MapEntry(1.0, 'mm1'),
      MapEntry(1.5, 'mm1_5'),
      MapEntry(2.0, 'mm2'),
      MapEntry(2.5, 'mm2_5'),
      MapEntry(3.0, 'mm3'),
      MapEntry(3.5, 'mm3_5'),
      MapEntry(4.0, 'mm4'),
      MapEntry(4.5, 'mm4_5'),
      MapEntry(5.0, 'mm5'),
      MapEntry(5.5, 'mm5_5'),
      MapEntry(6.0, 'mm6'),
      MapEntry(6.5, 'mm6_5'),
      MapEntry(7.0, 'mm7'),
      MapEntry(7.5, 'mm7_5'),
      MapEntry(8.0, 'mm8'),
      MapEntry(8.5, 'mm8_5'),
      MapEntry(9.0, 'mm9'),
      MapEntry(9.5, 'mm9_5'),
      MapEntry(10.0, 'mm10'),
      MapEntry(10.5, 'mm10_5'),
      MapEntry(11.0, 'mm11'),
      MapEntry(11.5, 'mm11_5'),
      MapEntry(12.0, 'mm12'),
      MapEntry(12.5, 'mm12_5'),
      MapEntry(13.0, 'mm13'),
      MapEntry(13.5, 'mm13_5'),
      MapEntry(14.0, 'mm14'),
      MapEntry(14.5, 'mm14_5'),
      MapEntry(15.0, 'mm15'),
      MapEntry(15.5, 'mm15_5'),
      MapEntry(16.0, 'mm16'),
      MapEntry(16.5, 'mm16_5'),
      MapEntry(17.0, 'mm17'),
      MapEntry(17.5, 'mm17_5'),
      MapEntry(18.0, 'mm18'),
      MapEntry(18.5, 'mm18_5'),
      MapEntry(19.0, 'mm19'),
      MapEntry(19.5, 'mm19_5'),
      MapEntry(20.0, 'mm20'),
      MapEntry(20.5, 'mm20_5'),
      MapEntry(21.0, 'mm21'),
      MapEntry(21.5, 'mm21_5'),
      MapEntry(22.0, 'mm22'),
      MapEntry(22.5, 'mm22_5'),
      MapEntry(23.0, 'mm23'),
      MapEntry(23.5, 'mm23_5'),
      MapEntry(24.0, 'mm24'),
      MapEntry(24.5, 'mm24_5'),
      MapEntry(25.0, 'mm25'),
      MapEntry(25.5, 'mm25_5'),
      MapEntry(26.0, 'mm26'),
      MapEntry(26.5, 'mm26_5'),
      MapEntry(27.0, 'mm27'),
      MapEntry(27.5, 'mm27_5'),
      MapEntry(28.0, 'mm28'),
      MapEntry(28.5, 'mm28_5'),
      MapEntry(29.0, 'mm29'),
      MapEntry(29.5, 'mm29_5'),
      MapEntry(30.0, 'mm30'),
      MapEntry(30.5, 'mm30_5'),
      MapEntry(31.0, 'mm31'),
      MapEntry(31.5, 'mm31_5'),
      MapEntry(32.0, 'mm32'),
      MapEntry(32.5, 'mm32_5'),
      MapEntry(33.0, 'mm33'),
      MapEntry(33.5, 'mm33_5'),
      MapEntry(34.0, 'mm34'),
      MapEntry(34.5, 'mm34_5'),
      MapEntry(35.0, 'mm35'),
      MapEntry(35.5, 'mm35_5'),
      MapEntry(36.0, 'mm36'),
      MapEntry(36.5, 'mm36_5'),
      MapEntry(37.0, 'mm37'),
      MapEntry(37.5, 'mm37_5'),
      MapEntry(38.0, 'mm38'),
    ];

    int total = 0;
    double weighted = 0.0;

    for (final it in items) {
      final count = asInt(body[it.value]);
      total += count;
      weighted += (count * it.key);
    }

    body['totalBayasEvaluadas'] = total.toDouble();
    body['promCalibresPlanta'] = total == 0 ? 0.0 : (weighted / total);

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('✅ CALIBRE saveLocal START localId=$localId');

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

      debugPrint('✅ CALIBRE saveLocal DONE');
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
    // ✅ patrón estándar: guardar y duplicar con DS
    await saveLocal();
    final cfg = CartillaCalibreBayasConfig();

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
