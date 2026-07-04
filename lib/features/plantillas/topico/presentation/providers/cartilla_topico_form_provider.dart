import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../master/presentation/master_providers.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_topico_config.dart';
import '../../domain/cartilla_topico_payload.dart';

class CartillaTopicoFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaTopicoPayload payload;
  final List<String> errors;

  const CartillaTopicoFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaTopicoFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaTopicoPayload? payload,
    List<String>? errors,
  }) {
    return CartillaTopicoFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaTopicoFormProvider =
    StateNotifierProvider.family<
      CartillaTopicoFormNotifier,
      CartillaTopicoFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaTopicoFormNotifier(
        ref: ref,
        localId: localId,
        local: local,
      )..load();
    });

class CartillaTopicoFormNotifier extends StateNotifier<CartillaTopicoFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaTopicoFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaTopicoFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaTopicoPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);
      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaTopicoPayload payload;
      if (isEmptyJson) {
        payload = CartillaTopicoPayload.empty();
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
        payload = await _withDefaultEmpresa(payload);
        await local.updateDataJson(localId, payload.toJsonString());
      } else {
        payload = CartillaTopicoPayload.fromJsonString(raw);
        payload = await _withDefaultEmpresa(payload);
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

  Future<CartillaTopicoPayload> _withDefaultEmpresa(
    CartillaTopicoPayload payload,
  ) async {
    final body = Map<String, dynamic>.from(payload.body);
    final current = body[CartillaTopicoConfig.kEmpresa]?.toString().trim();
    if (current != null && current.isNotEmpty) return payload;

    final empresas = await ref.read(masterLocalDsProvider).getTopicoEmpresas();
    if (empresas.isEmpty) return payload;

    body[CartillaTopicoConfig.kEmpresa] = empresas.first.idEmpresa;
    return payload.copyWith(body: body);
  }

  void update(CartillaTopicoPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaTopicoPayload _recompute(CartillaTopicoPayload p) {
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
    final cfg = CartillaTopicoConfig();

    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    final payload = CartillaTopicoPayload(
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
