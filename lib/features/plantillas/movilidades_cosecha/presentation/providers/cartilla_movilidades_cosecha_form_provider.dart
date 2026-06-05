import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_movilidades_cosecha_config.dart';
import '../../domain/cartilla_movilidades_cosecha_payload.dart';

class CartillaMovilidadesCosechaFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaMovilidadesCosechaPayload payload;
  final List<String> errors;

  const CartillaMovilidadesCosechaFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaMovilidadesCosechaFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaMovilidadesCosechaPayload? payload,
    List<String>? errors,
  }) {
    return CartillaMovilidadesCosechaFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaMovilidadesCosechaFormProvider =
    StateNotifierProvider.family<
      CartillaMovilidadesCosechaFormNotifier,
      CartillaMovilidadesCosechaFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaMovilidadesCosechaFormNotifier(
        ref: ref,
        localId: localId,
        local: local,
      )..load();
    });

class CartillaMovilidadesCosechaFormNotifier
    extends StateNotifier<CartillaMovilidadesCosechaFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaMovilidadesCosechaFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaMovilidadesCosechaFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaMovilidadesCosechaPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('MOVILIDADES_COSECHA load localId=$localId');
      debugPrint('MOVILIDADES_COSECHA dataJsonLen=${reg.dataJson.length}');

      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaMovilidadesCosechaPayload payload;
      if (isEmptyJson) {
        payload = CartillaMovilidadesCosechaPayload.empty();

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
          'MOVILIDADES_COSECHA load: dataJson vacio -> inicializado y guardado',
        );
      } else {
        payload = CartillaMovilidadesCosechaPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('MOVILIDADES_COSECHA load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaMovilidadesCosechaPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaMovilidadesCosechaPayload _recompute(
    CartillaMovilidadesCosechaPayload p,
  ) {
    final body = Map<String, dynamic>.from(p.body);

    int? asNonNegativeIntOrNull(dynamic value) {
      if (value == null || '$value'.trim().isEmpty) return null;
      final parsed = value is num ? value.toInt() : int.tryParse('$value');
      if (parsed == null) return null;
      return parsed < 0 ? 0 : parsed;
    }

    body[CartillaMovilidadesCosechaConfig.kCantidadCajas] =
        asNonNegativeIntOrNull(
          body[CartillaMovilidadesCosechaConfig.kCantidadCajas],
        );

    for (final key in const [
      CartillaMovilidadesCosechaConfig.kPiso,
      CartillaMovilidadesCosechaConfig.kTecho,
      CartillaMovilidadesCosechaConfig.kPared,
      CartillaMovilidadesCosechaConfig.kToldo,
      CartillaMovilidadesCosechaConfig.kInsumosLimpieza,
    ]) {
      body[key] = _asStringList(body[key]);
    }

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
    debugPrint('MOVILIDADES_COSECHA saveLocal START localId=$localId');

    final headerWithGeo = await attachGeo(ref, state.payload.header);
    final payloadWithGeo = state.payload.copyWith(header: headerWithGeo);
    state = state.copyWith(payload: payloadWithGeo);

    final fixed = _recompute(state.payload);

    debugPrint(
      'MOVILIDADES_COSECHA saveLocal payloadBytes=${jsonEncode(fixed.toJson()).length}',
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

      debugPrint('MOVILIDADES_COSECHA saveLocal DONE');
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
    final cfg = CartillaMovilidadesCosechaConfig();

    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    final payload = CartillaMovilidadesCosechaPayload(
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
