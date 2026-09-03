import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_descarga_racimos_config.dart';
import '../../domain/cartilla_descarga_racimos_payload.dart';

class CartillaDescargaRacimosFormState implements CartillaFormStateBase {
  final int localId;
  @override
  final bool loading;
  @override
  final bool saving;
  final CartillaDescargaRacimosPayload payload;
  @override
  final List<String> errors;

  const CartillaDescargaRacimosFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  @override
  Map<String, dynamic> get dataJson => payload.toJson();

  CartillaDescargaRacimosFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaDescargaRacimosPayload? payload,
    List<String>? errors,
  }) => CartillaDescargaRacimosFormState(
    localId: localId,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    payload: payload ?? this.payload,
    errors: errors ?? this.errors,
  );
}

final cartillaDescargaRacimosFormProvider =
    StateNotifierProvider.family<
      CartillaDescargaRacimosFormNotifier,
      CartillaDescargaRacimosFormState,
      int
    >(
      (ref, localId) => CartillaDescargaRacimosFormNotifier(
        ref: ref,
        localId: localId,
        local: ref.read(registrosLocalDSProvider),
      )..load(),
    );

class CartillaDescargaRacimosFormNotifier
    extends StateNotifier<CartillaDescargaRacimosFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaDescargaRacimosFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaDescargaRacimosFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaDescargaRacimosPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);
      final raw = reg.dataJson.trim();
      final isEmpty = raw.isEmpty || raw == '{}' || raw == 'null';
      var payload = isEmpty
          ? CartillaDescargaRacimosPayload.empty().copyWith(
              header: {
                ...CartillaDescargaRacimosPayload.empty().header,
                'plantillaId': reg.plantillaId,
                'userId': reg.userId,
                'loteId': reg.loteId,
                'lat': reg.lat,
                'lon': reg.lon,
              },
            )
          : CartillaDescargaRacimosPayload.fromJsonString(raw);
      payload = _recompute(payload);
      if (isEmpty) await local.updateDataJson(localId, payload.toJsonString());
      state = state.copyWith(
        loading: false,
        payload: payload,
        errors: const [],
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  CartillaDescargaRacimosPayload _recompute(
    CartillaDescargaRacimosPayload payload,
  ) {
    final body = Map<String, dynamic>.from(payload.body);
    final value = body[CartillaDescargaRacimosConfig.kTotalRacimo];
    final total = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    body[CartillaDescargaRacimosConfig.kTotalRacimo] = total < 0 ? 0 : total;
    body['fotos'] = body['fotos'] is List
        ? body['fotos']
        : <Map<String, dynamic>>[];
    return payload.copyWith(
      payloadVersion: CartillaDescargaRacimosConfig.payloadVersionStatic,
      body: body,
    );
  }

  void update(CartillaDescargaRacimosPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    update(
      CartillaDescargaRacimosPayload(
        payloadVersion:
            (next['payloadVersion'] as int?) ?? state.payload.payloadVersion,
        header:
            (next['header'] as Map?)?.cast<String, dynamic>() ??
            state.payload.header,
        body:
            (next['body'] as Map?)?.cast<String, dynamic>() ??
            state.payload.body,
      ),
    );
  }

  @override
  Future<void> saveLocal() async {
    final fixed = _recompute(
      state.payload.copyWith(
        header: await attachGeo(ref, state.payload.header),
      ),
    );
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
    final config = CartillaDescargaRacimosConfig();
    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: config.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: config.plusOneReplicableBodyKeys,
    );
  }
}
