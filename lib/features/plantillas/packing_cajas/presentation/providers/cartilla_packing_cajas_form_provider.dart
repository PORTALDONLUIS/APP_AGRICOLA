import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_packing_cajas_config.dart';
import '../../domain/cartilla_packing_cajas_payload.dart';

class CartillaPackingCajasFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaPackingCajasPayload payload;
  final List<String> errors;

  const CartillaPackingCajasFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaPackingCajasFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaPackingCajasPayload? payload,
    List<String>? errors,
  }) {
    return CartillaPackingCajasFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaPackingCajasFormProvider =
    StateNotifierProvider.family<
      CartillaPackingCajasFormNotifier,
      CartillaPackingCajasFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaPackingCajasFormNotifier(
        ref: ref,
        localId: localId,
        local: local,
      )..load();
    });

class CartillaPackingCajasFormNotifier
    extends StateNotifier<CartillaPackingCajasFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaPackingCajasFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaPackingCajasFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaPackingCajasPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);
      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaPackingCajasPayload payload;
      if (isEmptyJson) {
        final emptyPayload = CartillaPackingCajasPayload.empty();
        payload = emptyPayload.copyWith(
          header: {
            ...emptyPayload.header,
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
        payload = CartillaPackingCajasPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaPackingCajasPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaPackingCajasPayload _recompute(CartillaPackingCajasPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    int asNonNegativeInt(dynamic value) {
      final parsed = value is num ? value.toInt() : int.tryParse('$value');
      if (parsed == null) return 0;
      return parsed < 0 ? 0 : parsed;
    }

    for (final key in CartillaPackingCajasConfig.palletCounterKeys) {
      body[key] = asNonNegativeInt(body[key]);
    }

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    final headerWithGeo = await attachGeo(ref, state.payload.header);
    final fixed = _recompute(state.payload.copyWith(header: headerWithGeo));

    state = state.copyWith(saving: true, payload: fixed);
    try {
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
    final cfg = CartillaPackingCajasConfig();
    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    final payload = CartillaPackingCajasPayload(
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
