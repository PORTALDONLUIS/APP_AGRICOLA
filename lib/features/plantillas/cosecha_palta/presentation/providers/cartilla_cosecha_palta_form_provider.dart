import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_cosecha_palta_config.dart';
import '../../domain/cartilla_cosecha_palta_payload.dart';

class CartillaCosechaPaltaFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaCosechaPaltaPayload payload;
  final List<String> errors;

  const CartillaCosechaPaltaFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaCosechaPaltaFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaCosechaPaltaPayload? payload,
    List<String>? errors,
  }) {
    return CartillaCosechaPaltaFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaCosechaPaltaFormProvider =
    StateNotifierProvider.family<
      CartillaCosechaPaltaFormNotifier,
      CartillaCosechaPaltaFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaCosechaPaltaFormNotifier(
        ref: ref,
        localId: localId,
        local: local,
      )..load();
    });

class CartillaCosechaPaltaFormNotifier
    extends StateNotifier<CartillaCosechaPaltaFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaCosechaPaltaFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaCosechaPaltaFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaCosechaPaltaPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('COSECHA_PALTA load localId=$localId');
      debugPrint('COSECHA_PALTA dataJsonLen=${reg.dataJson.length}');

      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaCosechaPaltaPayload payload;
      if (isEmptyJson) {
        payload = CartillaCosechaPaltaPayload.empty();

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
          'COSECHA_PALTA load: dataJson vacio -> inicializado y guardado',
        );
      } else {
        payload = CartillaCosechaPaltaPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('COSECHA_PALTA load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaCosechaPaltaPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaCosechaPaltaPayload _recompute(CartillaCosechaPaltaPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    int asNonNegativeInt(dynamic value) {
      if (value == null) return 0;
      final parsed = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
      return parsed < 0 ? 0 : parsed;
    }

    var conDefectos = 0;
    for (final key in CartillaCosechaPaltaConfig.defectCounterKeys) {
      final normalized = asNonNegativeInt(body[key]);
      body[key] = normalized;
      conDefectos += normalized;
    }

    body[CartillaCosechaPaltaConfig.kNroFrutoEvaluados] = 100;
    body[CartillaCosechaPaltaConfig.kConDefectos] = conDefectos.toDouble();

    final sinDefectos = 100 - conDefectos;
    body[CartillaCosechaPaltaConfig.kSinDefectos] =
        (sinDefectos < 0 ? 0 : sinDefectos).toDouble();

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('COSECHA_PALTA saveLocal START localId=$localId');

    final headerWithGeo = await attachGeo(ref, state.payload.header);
    final payloadWithGeo = state.payload.copyWith(header: headerWithGeo);
    state = state.copyWith(payload: payloadWithGeo);

    final fixed = _recompute(state.payload);

    debugPrint('===== COSECHA_PALTA JSON BEFORE SAVE =====');
    debugPrint(jsonEncode(fixed.toJson()));
    debugPrint('===== END COSECHA_PALTA JSON =====');

    state = state.copyWith(saving: true);
    try {
      state = state.copyWith(payload: fixed);

      await local.saveLocal(
        localId: localId,
        data: fixed.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );

      debugPrint('COSECHA_PALTA saveLocal DONE');
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
    final cfg = CartillaCosechaPaltaConfig();

    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    final payload = CartillaCosechaPaltaPayload(
      payloadVersion:
          (next['payloadVersion'] as int?) ?? state.payload.payloadVersion,
      header:
          (next['header'] as Map?)?.cast<String, dynamic>() ??
          Map<String, dynamic>.from(state.payload.header),
      body:
          (next['body'] as Map?)?.cast<String, dynamic>() ??
          Map<String, dynamic>.from(state.payload.body),
    );

    update(payload);
  }
}
