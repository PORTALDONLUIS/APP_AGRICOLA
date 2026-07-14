import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_inspeccion_herramientas_epp_config.dart';
import '../../domain/cartilla_inspeccion_herramientas_epp_payload.dart';

class CartillaInspeccionHerramientasEppFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaInspeccionHerramientasEppPayload payload;
  final List<String> errors;

  const CartillaInspeccionHerramientasEppFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaInspeccionHerramientasEppFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaInspeccionHerramientasEppPayload? payload,
    List<String>? errors,
  }) {
    return CartillaInspeccionHerramientasEppFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaInspeccionHerramientasEppFormProvider =
    StateNotifierProvider.family<
      CartillaInspeccionHerramientasEppFormNotifier,
      CartillaInspeccionHerramientasEppFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaInspeccionHerramientasEppFormNotifier(
        ref: ref,
        localId: localId,
        local: local,
      )..load();
    });

class CartillaInspeccionHerramientasEppFormNotifier
    extends StateNotifier<CartillaInspeccionHerramientasEppFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaInspeccionHerramientasEppFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaInspeccionHerramientasEppFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaInspeccionHerramientasEppPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);
      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaInspeccionHerramientasEppPayload payload;
      if (isEmptyJson) {
        payload = CartillaInspeccionHerramientasEppPayload.empty();
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
      } else {
        payload = CartillaInspeccionHerramientasEppPayload.fromJsonString(raw);
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

  void update(CartillaInspeccionHerramientasEppPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaInspeccionHerramientasEppPayload _recompute(
    CartillaInspeccionHerramientasEppPayload p,
  ) {
    final body = Map<String, dynamic>.from(p.body);
    body['fotos'] = body['fotos'] is List
        ? body['fotos']
        : <Map<String, dynamic>>[];
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
    final cfg = CartillaInspeccionHerramientasEppConfig();

    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    final payload = CartillaInspeccionHerramientasEppPayload(
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
