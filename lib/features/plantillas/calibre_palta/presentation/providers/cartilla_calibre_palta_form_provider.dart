import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_calibre_palta_config.dart';
import '../../domain/cartilla_calibre_palta_payload.dart';

class CartillaCalibrePaltaFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaCalibrePaltaPayload payload;
  final List<String> errors;

  const CartillaCalibrePaltaFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaCalibrePaltaFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaCalibrePaltaPayload? payload,
    List<String>? errors,
  }) {
    return CartillaCalibrePaltaFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaCalibrePaltaFormProvider =
    StateNotifierProvider.family<
      CartillaCalibrePaltaFormNotifier,
      CartillaCalibrePaltaFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaCalibrePaltaFormNotifier(
        ref: ref,
        localId: localId,
        local: local,
      )..load();
    });

class CartillaCalibrePaltaFormNotifier
    extends StateNotifier<CartillaCalibrePaltaFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaCalibrePaltaFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaCalibrePaltaFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaCalibrePaltaPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('CALIBRE_PALTA load localId=$localId');
      debugPrint('CALIBRE_PALTA dataJsonLen=${reg.dataJson.length}');

      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaCalibrePaltaPayload payload;
      if (isEmptyJson) {
        payload = CartillaCalibrePaltaPayload.empty();

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
          'CALIBRE_PALTA load: dataJson vacio -> inicializado y guardado',
        );
      } else {
        payload = CartillaCalibrePaltaPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('CALIBRE_PALTA load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaCalibrePaltaPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaCalibrePaltaPayload _recompute(CartillaCalibrePaltaPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    int asNonNegativeInt(dynamic value) {
      if (value == null) return 0;
      final parsed = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
      return parsed < 0 ? 0 : parsed;
    }

    for (final key in CartillaCalibrePaltaConfig.calibreKeys) {
      body[key] = asNonNegativeInt(body[key]);
    }

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('CALIBRE_PALTA saveLocal START localId=$localId');

    final headerWithGeo = await attachGeo(ref, state.payload.header);
    final payloadWithGeo = state.payload.copyWith(header: headerWithGeo);
    state = state.copyWith(payload: payloadWithGeo);

    final fixed = _recompute(state.payload);

    debugPrint(
      'CALIBRE_PALTA saveLocal payloadBytes=${jsonEncode(fixed.toJson()).length}',
    );

    state = state.copyWith(saving: true);
    try {
      state = state.copyWith(payload: fixed);

      await local.saveLocal(
        localId: localId,
        data: fixed.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );

      debugPrint('CALIBRE_PALTA saveLocal DONE');
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
    final cfg = CartillaCalibrePaltaConfig();

    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    final payload = CartillaCalibrePaltaPayload(
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
