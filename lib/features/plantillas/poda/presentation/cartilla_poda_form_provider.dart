import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/mixins/geo_save_mixin.dart';
import '../../../../core/sync/sync_models.dart';
import '../../../cartillas/application/cartilla_form_contract.dart';
import '../../../registros/data/registros_local_ds.dart';
import '../domain/cartilla_poda_config.dart';
import '../domain/cartilla_poda_payload.dart';

class CartillaPodaFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaPodaPayload payload;
  final List<String> errors;

  const CartillaPodaFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaPodaFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaPodaPayload? payload,
    List<String>? errors,
  }) {
    return CartillaPodaFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaPodaFormProvider =
    StateNotifierProvider.family<
      CartillaPodaFormNotifier,
      CartillaPodaFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaPodaFormNotifier(ref: ref, localId: localId, local: local)
        ..load();
    });

class CartillaPodaFormNotifier extends StateNotifier<CartillaPodaFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaPodaFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaPodaFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaPodaPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);
      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaPodaPayload payload;
      if (isEmptyJson) {
        payload = CartillaPodaPayload.empty().copyWith(
          header: {
            ...CartillaPodaPayload.empty().header,
            'plantillaId': reg.plantillaId,
            'userId': reg.userId,
            'campaniaId': reg.campaniaId,
            'loteId': reg.loteId,
            'lat': reg.lat,
            'lon': reg.lon,
          },
        );
        await local.updateDataJson(localId, payload.toJsonString());
      } else {
        payload = CartillaPodaPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 PODA load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaPodaPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaPodaPayload _recompute(CartillaPodaPayload payload) {
    final body = Map<String, dynamic>.from(payload.body);

    void migrateLegacyKey(String legacyKey, String newKey) {
      final legacyValue = body[legacyKey];
      final newValue = body[newKey];
      final hasLegacy = legacyValue != null && '$legacyValue'.trim().isNotEmpty;
      final hasNew = newValue != null && '$newValue'.trim().isNotEmpty;

      if (hasLegacy && !hasNew) {
        body[newKey] = legacyValue;
      }
      body.remove(legacyKey);
    }

    migrateLegacyKey('podador', CartillaPodaConfig.kPodadorId);
    migrateLegacyKey('supervisor', CartillaPodaConfig.kSupervisorId);

    int asInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    bool hasValue(dynamic value) {
      if (value == null) return false;
      if (value is String) return value.trim().isNotEmpty;
      if (value is Iterable) return value.isNotEmpty;
      if (value is Map) return value.isNotEmpty;
      return true;
    }

    body[CartillaPodaConfig.kPautaCargadores] = asInt(
      body[CartillaPodaConfig.kPautaCargadores],
    );
    body[CartillaPodaConfig.kPautaYemas] = asInt(
      body[CartillaPodaConfig.kPautaYemas],
    );

    final totalCargadores =
        asInt(body[CartillaPodaConfig.kCargDer]) +
        asInt(body[CartillaPodaConfig.kCargIzq]);
    final totalConteo =
        asInt(body[CartillaPodaConfig.kDebil]) +
        asInt(body[CartillaPodaConfig.kNormal]) +
        asInt(body[CartillaPodaConfig.kVigoroso]);
    final totalYemas = List.generate(
      50,
      (index) => 'c${index + 1}',
    ).fold<int>(0, (sum, key) => sum + asInt(body[key]));

    body[CartillaPodaConfig.kTotalCargadores] = totalCargadores;
    body[CartillaPodaConfig.kTotalConteo] = totalConteo;
    body[CartillaPodaConfig.kTotalYemas] = totalYemas;

    final finalCargDer = asInt(
      body[CartillaPodaConfig.finalBodyKey(CartillaPodaConfig.kCargDer)],
    );
    final finalCargIzq = asInt(
      body[CartillaPodaConfig.finalBodyKey(CartillaPodaConfig.kCargIzq)],
    );
    final finalDebil = asInt(
      body[CartillaPodaConfig.finalBodyKey(CartillaPodaConfig.kDebil)],
    );
    final finalNormal = asInt(
      body[CartillaPodaConfig.finalBodyKey(CartillaPodaConfig.kNormal)],
    );
    final finalVigoroso = asInt(
      body[CartillaPodaConfig.finalBodyKey(CartillaPodaConfig.kVigoroso)],
    );
    final finalTotalYemas = List.generate(50, (index) => 'c${index + 1}')
        .fold<int>(
          0,
          (sum, key) => sum + asInt(body[CartillaPodaConfig.finalBodyKey(key)]),
        );

    final hasFinalCargadores =
        hasValue(
          body[CartillaPodaConfig.finalBodyKey(CartillaPodaConfig.kCargDer)],
        ) ||
        hasValue(
          body[CartillaPodaConfig.finalBodyKey(CartillaPodaConfig.kCargIzq)],
        );
    final hasFinalConteo =
        hasValue(
          body[CartillaPodaConfig.finalBodyKey(CartillaPodaConfig.kDebil)],
        ) ||
        hasValue(
          body[CartillaPodaConfig.finalBodyKey(CartillaPodaConfig.kNormal)],
        ) ||
        hasValue(
          body[CartillaPodaConfig.finalBodyKey(CartillaPodaConfig.kVigoroso)],
        );
    final hasFinalYemas = List.generate(
      50,
      (index) => 'c${index + 1}',
    ).any((key) => hasValue(body[CartillaPodaConfig.finalBodyKey(key)]));

    body[CartillaPodaConfig.finalBodyKey(CartillaPodaConfig.kTotalCargadores)] =
        hasFinalCargadores ? finalCargDer + finalCargIzq : null;
    body[CartillaPodaConfig.finalBodyKey(CartillaPodaConfig.kTotalConteo)] =
        hasFinalConteo ? finalDebil + finalNormal + finalVigoroso : null;
    body[CartillaPodaConfig.finalBodyKey(CartillaPodaConfig.kTotalYemas)] =
        hasFinalYemas ? finalTotalYemas : null;

    return payload.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    final headerWithGeo = await attachGeo(
      ref,
      Map<String, dynamic>.from(state.payload.header),
    );
    final fixed = _recompute(state.payload.copyWith(header: headerWithGeo));

    state = state.copyWith(saving: true);
    try {
      state = state.copyWith(payload: fixed);
      await local.saveLocal(
        localId: localId,
        data: fixed.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );
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
    final cfg = CartillaPodaConfig();
    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    final payload = CartillaPodaPayload(
      payloadVersion: (next['payloadVersion'] as int?) ?? 1,
      header: (next['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (next['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
    update(payload);
  }
}
