import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_registro_motorizado_seguridad_config.dart';
import '../../domain/cartilla_registro_motorizado_seguridad_payload.dart';

class CartillaRegistroMotorizadoSeguridadFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaRegistroMotorizadoSeguridadPayload payload;
  final List<String> errors;

  const CartillaRegistroMotorizadoSeguridadFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaRegistroMotorizadoSeguridadFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaRegistroMotorizadoSeguridadPayload? payload,
    List<String>? errors,
  }) {
    return CartillaRegistroMotorizadoSeguridadFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaRegistroMotorizadoSeguridadFormProvider =
    StateNotifierProvider.family<
      CartillaRegistroMotorizadoSeguridadFormNotifier,
      CartillaRegistroMotorizadoSeguridadFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaRegistroMotorizadoSeguridadFormNotifier(
        ref: ref,
        localId: localId,
        local: local,
      )..load();
    });

class CartillaRegistroMotorizadoSeguridadFormNotifier
    extends StateNotifier<CartillaRegistroMotorizadoSeguridadFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaRegistroMotorizadoSeguridadFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaRegistroMotorizadoSeguridadFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaRegistroMotorizadoSeguridadPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);
      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaRegistroMotorizadoSeguridadPayload payload;
      if (isEmptyJson) {
        payload = CartillaRegistroMotorizadoSeguridadPayload.empty();
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
        payload = CartillaRegistroMotorizadoSeguridadPayload.fromJsonString(
          raw,
        );
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

  void update(CartillaRegistroMotorizadoSeguridadPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaRegistroMotorizadoSeguridadPayload _recompute(
    CartillaRegistroMotorizadoSeguridadPayload p,
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
    final cfg = CartillaRegistroMotorizadoSeguridadConfig();

    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    final payload = CartillaRegistroMotorizadoSeguridadPayload(
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
