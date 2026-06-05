import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_higiene_config.dart';
import '../../domain/cartilla_higiene_payload.dart';

class CartillaHigieneFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaHigienePayload payload;
  final List<String> errors;

  const CartillaHigieneFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaHigieneFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaHigienePayload? payload,
    List<String>? errors,
  }) {
    return CartillaHigieneFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaHigieneFormProvider =
    StateNotifierProvider.family<
      CartillaHigieneFormNotifier,
      CartillaHigieneFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaHigieneFormNotifier(
        ref: ref,
        localId: localId,
        local: local,
      )..load();
    });

class CartillaHigieneFormNotifier
    extends StateNotifier<CartillaHigieneFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaHigieneFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaHigieneFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaHigienePayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('HIGIENE load localId=$localId');
      debugPrint('HIGIENE dataJsonLen=${reg.dataJson.length}');

      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaHigienePayload payload;
      if (isEmptyJson) {
        payload = CartillaHigienePayload.empty();

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
        debugPrint('HIGIENE load: dataJson vacio -> inicializado y guardado');
      } else {
        payload = CartillaHigienePayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('HIGIENE load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaHigienePayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaHigienePayload _recompute(CartillaHigienePayload p) {
    final body = Map<String, dynamic>.from(p.body);

    String asSiNo(dynamic value) {
      if (value is bool) return value ? 'SI' : 'NO';
      if (value is num) return value == 0 ? 'NO' : 'SI';

      final text = '$value'.trim().toUpperCase();
      if (text == 'SI' || text == 'SÍ' || text == 'TRUE' || text == '1') {
        return 'SI';
      }
      return 'NO';
    }

    List<String> asStringList(dynamic value) {
      if (value is List) {
        return value
            .map((item) => '$item'.trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
      }

      final text = '$value'.trim();
      return text.isEmpty || text == 'null' ? const [] : [text];
    }

    const verificationKeys = [
      CartillaHigieneConfig.kCabelloProtegido,
      CartillaHigieneConfig.kVestimentaAdecuada,
      CartillaHigieneConfig.kPresentaAlhajas,
      CartillaHigieneConfig.kPresenciaMaquillaje,
    ];

    for (final key in verificationKeys) {
      body[key] = asSiNo(body[key]);
    }

    body[CartillaHigieneConfig.kCondicionUnas] = asStringList(
      body[CartillaHigieneConfig.kCondicionUnas],
    );
    body[CartillaHigieneConfig.kCondicionManos] = asStringList(
      body[CartillaHigieneConfig.kCondicionManos],
    );

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('HIGIENE saveLocal START localId=$localId');

    final headerWithGeo = await attachGeo(ref, state.payload.header);
    final payloadWithGeo = state.payload.copyWith(header: headerWithGeo);
    state = state.copyWith(payload: payloadWithGeo);

    final fixed = _recompute(state.payload);

    debugPrint(
      'HIGIENE saveLocal payloadBytes=${jsonEncode(fixed.toJson()).length}',
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

      debugPrint('HIGIENE saveLocal DONE');
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
    final cfg = CartillaHigieneConfig();

    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    final payload = CartillaHigienePayload(
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
