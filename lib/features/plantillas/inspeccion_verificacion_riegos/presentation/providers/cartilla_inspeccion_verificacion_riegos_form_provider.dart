import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_inspeccion_verificacion_riegos_config.dart';
import '../../domain/cartilla_inspeccion_verificacion_riegos_payload.dart';

class CartillaInspeccionVerificacionRiegosFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaInspeccionVerificacionRiegosPayload payload;
  final List<String> errors;

  const CartillaInspeccionVerificacionRiegosFormState({
    required this.localId, required this.loading, required this.saving,
    required this.payload, required this.errors,
  });

  CartillaInspeccionVerificacionRiegosFormState copyWith({
    bool? loading, bool? saving, CartillaInspeccionVerificacionRiegosPayload? payload,
    List<String>? errors,
  }) => CartillaInspeccionVerificacionRiegosFormState(
    localId: localId, loading: loading ?? this.loading, saving: saving ?? this.saving,
    payload: payload ?? this.payload, errors: errors ?? this.errors,
  );
}

final cartillaInspeccionVerificacionRiegosFormProvider = StateNotifierProvider.family<
    CartillaInspeccionVerificacionRiegosFormNotifier,
    CartillaInspeccionVerificacionRiegosFormState, int>((ref, localId) =>
  CartillaInspeccionVerificacionRiegosFormNotifier(
    ref: ref, localId: localId, local: ref.read(registrosLocalDSProvider),
  )..load());

class CartillaInspeccionVerificacionRiegosFormNotifier
    extends StateNotifier<CartillaInspeccionVerificacionRiegosFormState>
    with GeoSaveMixin implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaInspeccionVerificacionRiegosFormNotifier({
    required this.ref, required this.localId, required this.local,
  }) : super(CartillaInspeccionVerificacionRiegosFormState(
    localId: localId, loading: true, saving: false,
    payload: CartillaInspeccionVerificacionRiegosPayload.empty(), errors: const [],
  ));

  String _today() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  List<String> _selected(dynamic value) {
    if (value is List) return value.map((item) => '$item'.trim()).where((item) => item.isNotEmpty).toList();
    final text = '$value'.trim();
    return text.isEmpty || text == 'null' ? const [] : [text];
  }

  CartillaInspeccionVerificacionRiegosPayload _recompute(
    CartillaInspeccionVerificacionRiegosPayload payload,
  ) {
    final body = Map<String, dynamic>.from(payload.body);
    final verification = <String, dynamic>{};
    for (final group in CartillaInspeccionVerificacionRiegosConfig.allCheckGroups) {
      final selected = _selected(body[group.key]).toSet();
      body[group.key] = selected.toList(growable: false);
      verification[group.key] = {
        for (final option in group.options) option: selected.contains(option) ? 'SI' : 'NO',
      };
    }
    body['verificaciones'] = verification;
    body[CartillaInspeccionVerificacionRiegosConfig.kFecha] ??= _today();
    return payload.copyWith(body: body);
  }

  @override
  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);
      final raw = reg.dataJson.trim();
      var payload = raw.isEmpty || raw == '{}' || raw == 'null'
          ? CartillaInspeccionVerificacionRiegosPayload.empty().copyWith(header: {
              ...CartillaInspeccionVerificacionRiegosPayload.empty().header,
              'plantillaId': reg.plantillaId, 'userId': reg.userId,
              'campaniaId': reg.campaniaId, 'loteId': reg.loteId,
              'lat': reg.lat, 'lon': reg.lon,
            })
          : CartillaInspeccionVerificacionRiegosPayload.fromJsonString(raw);
      payload = _recompute(payload);
      state = state.copyWith(loading: false, payload: payload, errors: const []);
      if (raw.isEmpty || raw == '{}' || raw == 'null') await local.updateDataJson(localId, payload.toJsonString());
    } catch (e) {
      debugPrint('RIEGOS load error: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaInspeccionVerificacionRiegosPayload payload) =>
      state = state.copyWith(payload: _recompute(payload), errors: const []);

  @override
  Future<void> saveLocal() async {
    final withGeo = state.payload.copyWith(header: await attachGeo(ref, state.payload.header));
    final fixed = _recompute(withGeo);
    state = state.copyWith(saving: true, payload: fixed);
    try {
      await local.saveLocal(localId: localId, data: fixed.toJson(), estado: EstadoRegistro.borrador, syncStatus: SyncStatus.local);
    } finally {
      state = state.copyWith(saving: false);
    }
  }

  @override
  Future<void> finalize() async { await saveLocal(); await local.markAsReadyForSync(localId); }

  @override
  Future<int> duplicateAsNew() async {
    await saveLocal();
    final cfg = CartillaInspeccionVerificacionRiegosConfig();
    return local.duplicateAsNew(fromLocalId: localId, plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys, plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys);
  }

  @override
  void updateDataJson(Map<String, dynamic> next) => update(CartillaInspeccionVerificacionRiegosPayload(
    payloadVersion: (next['payloadVersion'] as int?) ?? state.payload.payloadVersion,
    header: (next['header'] as Map?)?.cast<String, dynamic>() ?? Map<String, dynamic>.from(state.payload.header),
    body: (next['body'] as Map?)?.cast<String, dynamic>() ?? Map<String, dynamic>.from(state.payload.body),
  ));
}
