import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_packing_recepcion_config.dart';
import '../../domain/cartilla_packing_recepcion_payload.dart';

class CartillaPackingRecepcionFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaPackingRecepcionPayload payload;
  final List<String> errors;

  const CartillaPackingRecepcionFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaPackingRecepcionFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaPackingRecepcionPayload? payload,
    List<String>? errors,
  }) {
    return CartillaPackingRecepcionFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaPackingRecepcionFormProvider =
    StateNotifierProvider.family<
      CartillaPackingRecepcionFormNotifier,
      CartillaPackingRecepcionFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaPackingRecepcionFormNotifier(
        ref: ref,
        localId: localId,
        local: local,
      )..load();
    });

class CartillaPackingRecepcionFormNotifier
    extends StateNotifier<CartillaPackingRecepcionFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaPackingRecepcionFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaPackingRecepcionFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaPackingRecepcionPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('PACKING_RECEPCION load localId=$localId');
      debugPrint('PACKING_RECEPCION dataJsonLen=${reg.dataJson.length}');

      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaPackingRecepcionPayload payload;
      if (isEmptyJson) {
        payload = CartillaPackingRecepcionPayload.empty();

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
          'PACKING_RECEPCION load: dataJson vacio -> inicializado y guardado',
        );
      } else {
        payload = CartillaPackingRecepcionPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('PACKING_RECEPCION load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaPackingRecepcionPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaPackingRecepcionPayload _recompute(
    CartillaPackingRecepcionPayload p,
  ) {
    final body = Map<String, dynamic>.from(p.body);

    int? asNonNegativeIntOrNull(dynamic value) {
      if (value == null || '$value'.trim().isEmpty) return null;
      final parsed = value is num ? value.toInt() : int.tryParse('$value');
      if (parsed == null) return null;
      return parsed < 0 ? 0 : parsed;
    }

    int asNonNegativeInt(dynamic value) {
      return asNonNegativeIntOrNull(value) ?? 0;
    }

    double? asNonNegativeDoubleOrNull(dynamic value) {
      if (value == null || '$value'.trim().isEmpty) return null;
      final parsed = value is num
          ? value.toDouble()
          : double.tryParse('$value'.replaceAll(',', '.'));
      if (parsed == null) return null;
      return parsed < 0 ? 0 : parsed;
    }

    body[CartillaPackingRecepcionConfig.kTotalBinesPorGuia] =
        asNonNegativeIntOrNull(
          body[CartillaPackingRecepcionConfig.kTotalBinesPorGuia],
        );
    body[CartillaPackingRecepcionConfig.kNBines] = asNonNegativeIntOrNull(
      body[CartillaPackingRecepcionConfig.kNBines],
    );
    body[CartillaPackingRecepcionConfig.kPesoTotalBines] =
        asNonNegativeDoubleOrNull(
          body[CartillaPackingRecepcionConfig.kPesoTotalBines],
        );
    body[CartillaPackingRecepcionConfig.kPesoNeto] = asNonNegativeDoubleOrNull(
      body[CartillaPackingRecepcionConfig.kPesoNeto],
    );

    final nBines = body[CartillaPackingRecepcionConfig.kNBines] as int?;
    final pesoNeto = body[CartillaPackingRecepcionConfig.kPesoNeto] as double?;
    body[CartillaPackingRecepcionConfig.kPesoPorBin] =
        nBines == null || nBines == 0 || pesoNeto == null
        ? 0.0
        : double.parse((pesoNeto / nBines).toStringAsFixed(2));

    for (final key in CartillaPackingRecepcionConfig.defectCounterKeys) {
      body[key] = asNonNegativeInt(body[key]);
    }

    body['fotos'] = body['fotos'] is List
        ? body['fotos']
        : <Map<String, dynamic>>[];

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('PACKING_RECEPCION saveLocal START localId=$localId');

    final headerWithGeo = await attachGeo(ref, state.payload.header);
    final payloadWithGeo = state.payload.copyWith(header: headerWithGeo);
    state = state.copyWith(payload: payloadWithGeo);

    final fixed = _recompute(state.payload);

    debugPrint(
      'PACKING_RECEPCION saveLocal payloadBytes=${jsonEncode(fixed.toJson()).length}',
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

      debugPrint('PACKING_RECEPCION saveLocal DONE');
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
    final cfg = CartillaPackingRecepcionConfig();

    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    final payload = CartillaPackingRecepcionPayload(
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
