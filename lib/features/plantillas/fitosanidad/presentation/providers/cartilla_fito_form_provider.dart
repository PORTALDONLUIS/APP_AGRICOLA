import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../../core/sync/sync_models.dart';
import '../../../../../../features/cartillas/application/cartilla_form_contract.dart';
import '../../../../../../features/registros/data/registros_local_ds.dart';
import '../../../../../../app/providers.dart';

import '../../../../../../features/plantillas/fitosanidad/domain/cartilla_fito_config.dart';
import '../../../../../../features/plantillas/fitosanidad/domain/cartilla_fito_payload.dart';

class CartillaFitoFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaFitoPayload payload;
  final List<String> errors;

  const CartillaFitoFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaFitoFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaFitoPayload? payload,
    List<String>? errors,
  }) {
    return CartillaFitoFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaFitoFormProvider = StateNotifierProvider.family<
    CartillaFitoFormNotifier,
    CartillaFitoFormState,
    int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaFitoFormNotifier(
    ref: ref,
    localId: localId,
    local: local,
  )..load();
});

class CartillaFitoFormNotifier extends StateNotifier<CartillaFitoFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final int localId;
  final RegistrosLocalDS local;
  final Ref ref;

  CartillaFitoFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(CartillaFitoFormState(
          localId: localId,
          loading: true,
          saving: false,
          payload: CartillaFitoPayload.empty(),
          errors: const [],
        ));

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('🟦 FITO load localId=$localId');
      debugPrint('🟦 FITO dataJsonLen=${reg.dataJson.length}');

      final raw = (reg.dataJson).trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaFitoPayload payload;
      if (isEmptyJson) {
        payload = CartillaFitoPayload.empty();

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
        debugPrint('🟦 FITO load: dataJson vacío -> inicializado y guardado');
      } else {
        payload = CartillaFitoPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 FITO load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaFitoPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaFitoPayload _recompute(CartillaFitoPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    void normalizeNonNegative(String key) {
      final n = asInt(body[key]);
      body[key] = n < 0 ? 0 : n;
    }

    const keys = <String>[
      'thripsBrote_nroBrote',
      'thripsBrote_nroIndividuo',
      'pulgonBrote_nroBrote',
      'pulgonBrote_grado',
      'oidiumHojas_nroHojas',
      'oidiumHojas_grado',
      'mildiumHojas_nroHojas',
      'mildiumHojas_grado',
      'aranitaRojaHojas_nroHoja',
      'aranitaRojaHojas_grado',
      'lepidopterosHojas_larvasChicasNroHojas',
      'lepidopterosHojas_larvasChicasIndividuo',
      'lepidopterosHojas_larvasGrandesNroHojas',
      'lepidopterosHojas_larvasGrandesIndividuo',
      'eumorphaHojas_larvasChicasNroHojas',
      'eumorphaHojas_larvasChicasIndividuo',
      'eumorphaHojas_larvasGrandesNroHojas',
      'eumorphaHojas_larvasGrandesIndividuo',
      'acaroHialinoHojas_nroHoja',
      'acaroHialinoHojas_grado',
      'filoxeraHojas_nroHoja',
      'filoxeraHojas_nroAgallas',
      'pseudococusHojas_nroHojas',
      'pseudococusHojas_nroIndividuo',
      'moscaBlancaHojas_nroHoja',
      'moscaBlancaHojas_grado',
      'scolytusTallo_totalZonaPorPlanta',
      'pseudococcusTallo_totalZonaPorPlanta',
      'queresaHojas_nroHojas',
      'queresaHojas_nroIndividuo',
      'thripsFlores_nroRacimos',
      'thripsFlores_nroIndividuo',
      'botrytisFlores_nroRacimos',
      'botrytisFlores_grado',
      'pseudococusFruto_nroRacimos',
      'oidiumFrutos_nroRacimos',
      'oidiumFrutos_grado',
      'mildiuFrutos_nroRacimos',
      'mildiuFrutos_grado',
      'botrytisFrutos_nroRacimos',
      'botrytisFrutos_grado',
      'pudricionAcidasFrutos_nroRacimos',
      'pudricionAcidasFrutos_grado',
      'paloNegroFrutos_nroRacimos',
      'paloNegroFrutos_grado',
      'danoAvesFrutos_nroRacimos',
      'danoAvesFrutos_grado',
      'partidurasFrutos_nroRacimos',
      'partidurasFrutos_grado',
      'carachaFrutos_nroRacimos',
      'carachaFrutos_grado',
      'colapsoFrutos_nroRacimos',
      'colapsoFrutos_grado',
      'empoaskaHojas_nroHojas',
      'empoaskaHojas_nroIndividuo',
    ];

    for (final k in keys) {
      normalizeNonNegative(k);
    }

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('✅ FITO saveLocal START localId=$localId');

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

      debugPrint('✅ FITO saveLocal DONE');
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
    final cfg = CartillaFitoConfig();

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