import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mixins/geo_save_mixin.dart';
import '../../../../core/sync/sync_models.dart';
import '../../../cartillas/application/cartilla_form_contract.dart';
import '../../../registros/data/registros_local_ds.dart';
import '../../../../app/providers.dart';

import '../domain/cartilla_brotacion_config.dart';
import '../domain/cartilla_brotacion_payload.dart';
// si tienes validator propio, puedes importarlo, pero NO es necesario para compilar.

class CartillaBrotacionFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaBrotacionPayload payload;
  final List<String> errors;

  const CartillaBrotacionFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaBrotacionFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaBrotacionPayload? payload,
    List<String>? errors,
  }) {
    return CartillaBrotacionFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaBrotacionFormProvider = StateNotifierProvider.family<
    CartillaBrotacionFormNotifier, CartillaBrotacionFormState, int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  // return CartillaBrotacionFormNotifier(localId: localId, local: local)..load();
  return CartillaBrotacionFormNotifier(
    ref: ref,
    localId: localId,
    local: local,
  )..load();

});

class CartillaBrotacionFormNotifier extends StateNotifier<CartillaBrotacionFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase{
  final int localId;
  final RegistrosLocalDS local;
  final Ref ref; // ✅ ESTE ES EL QUE TE FALTA

  CartillaBrotacionFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(CartillaBrotacionFormState(
    localId: localId,
    loading: true,
    saving: false,
    payload: CartillaBrotacionPayload.empty(),
    errors: const [],
  ));


  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      // 🔎 Logs correctos
      debugPrint('🟦 BROTACION load localId=$localId');
      debugPrint('🟦 BROTACION dataJson=${reg.dataJson}');
      debugPrint('🟦 BROTACION dataJsonLen=${reg.dataJson.length}');

      final raw = (reg.dataJson).trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      // ✅ Si viene {} lo inicializamos con payload vacío estándar
      CartillaBrotacionPayload payload;
      if (isEmptyJson) {
        payload = CartillaBrotacionPayload.empty();

        // IMPORTANTE: le inyectamos header estándar desde el registro si aplica
        // (si tu payload.empty() ya lo trae, igual no hace daño)
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

        // ✅ Persistimos para que deje de ser {} y ya tenga estructura al reabrir
        await local.updateDataJson(localId, payload.toJsonString());

        debugPrint('🟦 BROTACION load: dataJson estaba vacío -> inicializado y guardado');
      } else {
        payload = CartillaBrotacionPayload.fromJsonString(raw);
      }

      debugPrint('🟦 header.campaniaId=${payload.header['campaniaId']}');
      debugPrint('🟦 header.loteId=${payload.header['loteId']}');

      // ✅ recalcula total al cargar (por si venía viejo)
      final fixed = _withTotalYemas(payload);

      state = state.copyWith(
        loading: false,
        payload: fixed,
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 BROTACION load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }


  void update(CartillaBrotacionPayload payload) {
    // ✅ cada update recalcula total de yemas
    final fixed = _withTotalYemas(payload);
    state = state.copyWith(payload: fixed, errors: const []);
  }

  Future<void> saveLocalDraft() async {
    // Guarda el payload actual en DB como borrador
    debugPrint('BROTACION saveLocalDraft localId=$localId');

    // 1) Adjuntar geo en el header (si hay permisos / GPS / fix)
    final headerWithGeo = await attachGeo(ref, state.payload.header);
    final payloadWithGeo = state.payload.copyWith(
      header: headerWithGeo,
    );
    state = state.copyWith(payload: payloadWithGeo);

    debugPrint('payload=${state.payload.toJson()}');

    // 2) Guardar
    await local.saveLocal(
      localId: localId,
      data: state.payload.toJson(), // ✅ payload estándar (ya con geo)
      estado: EstadoRegistro.borrador,
      syncStatus: SyncStatus.local,
    );

    debugPrint('BROTACION saveLocalDraft DONE localId=$localId');
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('✅ BROTACION saveLocal START localId=$localId');

    state = state.copyWith(saving: true);
    try {
      // 1) Adjuntar geo al header ANTES de recalcular y guardar
      final headerWithGeo = await attachGeo(ref, state.payload.header);
      final payloadWithGeo = state.payload.copyWith(
        header: headerWithGeo,
      );
      state = state.copyWith(payload: payloadWithGeo);

      // 2) Recalcular total yemas con el payload ya parcheado
      final fixed = _withTotalYemas(state.payload);
      state = state.copyWith(payload: fixed);

      // 3) Logs del JSON final que se guardará
      final json = fixed.toJson();
      debugPrint('🧾 ===== JSON BEFORE SAVE =====');
      debugPrint(jsonEncode(json));
      debugPrint('🧾 ===== END JSON =====');

      // 4) Guardar
      await local.saveLocal(
        localId: localId,
        data: fixed.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );

      debugPrint('✅ BROTACION saveLocal DONE');
    } finally {
      state = state.copyWith(saving: false);
    }

  }


  @override
  Future<void> finalize() async {
    // 1) Guardar primero
    await saveLocal();

    // 2) Marcar listo para sync
    await local.markAsReadyForSync(localId);
  }

  // =====================================================
  // Helpers
  // =====================================================

  CartillaBrotacionPayload _withTotalYemas(CartillaBrotacionPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final total =
        asInt(body['yemaHinchada']) +
            asInt(body['botonAlgodonoso']) +
            asInt(body['puntaVerde']) +
            asInt(body['hojasExtendidas']) +
            asInt(body['yemasNecroticas']);

    body['totalYemas'] = total;

    return p.copyWith(body: body);
  }

  @override
  Future<int> duplicateAsNew() async {
    // 0) Asegura que el payload actual esté persistido
    await saveLocal();

    // 1) Metadata del registro actual
    final currentReg = await local.getByLocalId(localId);

    // 2) Crear nuevo draft (nuevo localId)
    final newLocalId = await local.createDraft(
      plantillaId: currentReg.plantillaId,
      templateKey: currentReg.templateKey,
      userId: currentReg.userId,
    );

    // 3) Payload actual
    final p = state.payload;

    // 4) Nuevo HEADER: solo lo estructural + lo replicable (campaniaId/loteId)
    final newHeader = <String, dynamic>{
      // estructural base (siempre)
      'plantillaId': currentReg.plantillaId,
      'userId': currentReg.userId,

      // ✅ replicar (según tu decisión)
      'campaniaId': p.getHeaderValue('campaniaId'),
      'loteId': p.getHeaderValue('loteId'),

      // mantener geo si quieres (si NO, pon null)
      'lat': p.getHeaderValue('lat'),
      'lon': p.getHeaderValue('lon'),

      // fecha nueva (si quieres mantener, cambia)
      'fechaEjecucion': null,
    };

    // 5) Nuevo BODY: replicar lo marcado +1, resetear hilera/planta, resetear contadores
    final newBody = <String, dynamic>{
      // ✅ replicar (+1)
      'variedad': p.getBodyValue('variedad'),
      'cantidadMuestras': p.getBodyValue('cantidadMuestras'),
      'corresponde': p.getBodyValue('corresponde'),

      // ❌ NO replicar
      'hilera': null,
      'planta': null,

      // reset contadores
      'yemaHinchada': 0,
      'botonAlgodonoso': 0,
      'puntaVerde': 0,
      'hojasExtendidas': 0,
      'yemasNecroticas': 0,
      'totalYemas': 0,

      // observaciones vacías
      'observaciones': null,
    };

    // 6) Armar payload +1
    final plusPayload = CartillaBrotacionPayload(
      payloadVersion: p.payloadVersion,
      header: newHeader,
      body: newBody,
    );

    // 7) Guardar payload en el registro recién creado
    await local.saveLocal(
      localId: newLocalId,
      data: plusPayload.toJson(), // ✅ usa toJson, no toMap si ya lo tienes
      estado: EstadoRegistro.borrador,
      syncStatus: SyncStatus.local,
    );

    return newLocalId;
  }


  Future<int> duplicateAsNew2() async {
    // 1) Guardar lo actual (para copiar lo último editado)
    await saveLocalDraft();

    // 2) Config de Brotación (qué keys copiar)
    final cfg = CartillaBrotacionConfig();

    // 3) Duplicar usando DS (él conoce templateKey/userId desde BD)
    final newLocalId = await local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );

    return newLocalId;

  /*  // ✅ 1) GUARDAR lo que el usuario acaba de editar
    await saveLocalDraft();

    // ✅ 2) Config real de Brotación (define qué se copia)
    final config = CartillaBrotacionConfig();

    // ✅ 3) Duplicar leyendo desde DB (payload normalizado)
    final newLocalId = await local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: config.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: config.plusOneReplicableBodyKeys,
    );

    return newLocalId;*/
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    // TODO: implement updateDataJson
  }


}


