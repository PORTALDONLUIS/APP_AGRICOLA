import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_registro_personal_garita_seguridad_config.dart';
import '../../domain/cartilla_registro_personal_garita_seguridad_payload.dart';

class CartillaRegistroPersonalGaritaSeguridadFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaRegistroPersonalGaritaSeguridadPayload payload;
  final List<String> errors;

  const CartillaRegistroPersonalGaritaSeguridadFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaRegistroPersonalGaritaSeguridadFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaRegistroPersonalGaritaSeguridadPayload? payload,
    List<String>? errors,
  }) {
    return CartillaRegistroPersonalGaritaSeguridadFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaRegistroPersonalGaritaSeguridadFormProvider =
    StateNotifierProvider.family<
      CartillaRegistroPersonalGaritaSeguridadFormNotifier,
      CartillaRegistroPersonalGaritaSeguridadFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaRegistroPersonalGaritaSeguridadFormNotifier(
        ref: ref,
        localId: localId,
        local: local,
      )..load();
    });

class CartillaRegistroPersonalGaritaSeguridadFormNotifier
    extends StateNotifier<CartillaRegistroPersonalGaritaSeguridadFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaRegistroPersonalGaritaSeguridadFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaRegistroPersonalGaritaSeguridadFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaRegistroPersonalGaritaSeguridadPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);
      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaRegistroPersonalGaritaSeguridadPayload payload;
      if (isEmptyJson) {
        payload = CartillaRegistroPersonalGaritaSeguridadPayload.empty();
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
        payload = CartillaRegistroPersonalGaritaSeguridadPayload.fromJsonString(
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

  void update(CartillaRegistroPersonalGaritaSeguridadPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaRegistroPersonalGaritaSeguridadPayload _recompute(
    CartillaRegistroPersonalGaritaSeguridadPayload p,
  ) {
    final body = Map<String, dynamic>.from(p.body);

    for (final key in const [
      CartillaRegistroPersonalGaritaSeguridadConfig.kVisitante,
      CartillaRegistroPersonalGaritaSeguridadConfig.kTransportista,
      CartillaRegistroPersonalGaritaSeguridadConfig.kLicencia,
      CartillaRegistroPersonalGaritaSeguridadConfig.kSoat,
    ]) {
      body[key] = _asSiNo(body[key]);
    }

    if ('${body[CartillaRegistroPersonalGaritaSeguridadConfig.kMotivo] ?? ''}'
            .trim()
            .toUpperCase() ==
        'RETIRO') {
      body[CartillaRegistroPersonalGaritaSeguridadConfig.kFundo] = null;
    }

    body['fotos'] = body['fotos'] is List
        ? body['fotos']
        : <Map<String, dynamic>>[];

    return p.copyWith(body: body);
  }

  String _asSiNo(dynamic value) {
    if (value is bool) return value ? 'SI' : 'NO';
    if (value is num) return value == 0 ? 'NO' : 'SI';
    final text = '${value ?? ''}'.trim().toUpperCase();
    return text == 'SI' || text == 'SÍ' || text == 'TRUE' || text == '1'
        ? 'SI'
        : 'NO';
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
    final cfg = CartillaRegistroPersonalGaritaSeguridadConfig();

    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    final payload = CartillaRegistroPersonalGaritaSeguridadPayload(
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
