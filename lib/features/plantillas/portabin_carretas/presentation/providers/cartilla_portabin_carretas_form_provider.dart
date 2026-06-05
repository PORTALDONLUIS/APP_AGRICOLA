import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_portabin_carretas_payload.dart';

class CartillaPortabinCarretasFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaPortabinCarretasPayload payload;
  final List<String> errors;

  const CartillaPortabinCarretasFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaPortabinCarretasFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaPortabinCarretasPayload? payload,
    List<String>? errors,
  }) {
    return CartillaPortabinCarretasFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaPortabinCarretasFormProvider =
    StateNotifierProvider.family<
      CartillaPortabinCarretasFormNotifier,
      CartillaPortabinCarretasFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaPortabinCarretasFormNotifier(
        ref: ref,
        localId: localId,
        local: local,
      )..load();
    });

class CartillaPortabinCarretasFormNotifier
    extends StateNotifier<CartillaPortabinCarretasFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaPortabinCarretasFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaPortabinCarretasFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaPortabinCarretasPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('PORTABIN_CARRETAS load localId=$localId');
      debugPrint('PORTABIN_CARRETAS dataJsonLen=${reg.dataJson.length}');

      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaPortabinCarretasPayload payload;
      if (isEmptyJson) {
        payload = CartillaPortabinCarretasPayload.empty();

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
          'PORTABIN_CARRETAS load: dataJson vacio -> inicializado y guardado',
        );
      } else {
        payload = CartillaPortabinCarretasPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('PORTABIN_CARRETAS load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaPortabinCarretasPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaPortabinCarretasPayload _recompute(
    CartillaPortabinCarretasPayload p,
  ) {
    final body = Map<String, dynamic>.from(p.body);

    int? asNonNegativeIntOrNull(dynamic value) {
      if (value == null || '$value'.trim().isEmpty) return null;
      final parsed = value is num ? value.toInt() : int.tryParse('$value');
      if (parsed == null) return null;
      return parsed < 0 ? 0 : parsed;
    }

    body['nroBinJabas'] = asNonNegativeIntOrNull(body['nroBinJabas']);
    body['piso'] = _asStringList(body['piso']);
    body['mallaToldo'] = _asStringList(body['mallaToldo']);
    body['insumosLimpieza'] = _asStringList(body['insumosLimpieza']);
    body['fotos'] = body['fotos'] is List
        ? body['fotos']
        : <Map<String, dynamic>>[];

    return p.copyWith(body: body);
  }

  List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList(growable: false);
    }
    return const [];
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('PORTABIN_CARRETAS saveLocal START localId=$localId');

    final headerWithGeo = await attachGeo(ref, state.payload.header);
    final payloadWithGeo = state.payload.copyWith(header: headerWithGeo);
    state = state.copyWith(payload: payloadWithGeo);

    final fixed = _recompute(state.payload);

    debugPrint(
      'PORTABIN_CARRETAS saveLocal payloadBytes=${jsonEncode(fixed.toJson()).length}',
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

      debugPrint('PORTABIN_CARRETAS saveLocal DONE');
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

    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: const {'loteId', 'campaniaId'},
      plusOneReplicableBodyKeys: const {
        'fecha',
        'sector',
        'supervisor',
        'operario',
      },
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    final payload = CartillaPortabinCarretasPayload(
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
