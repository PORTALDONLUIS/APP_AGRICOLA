import 'dart:convert';

import 'package:donluis_forms/core/mixins/geo_save_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/sync/sync_models.dart';
import '../../../../../app/providers.dart';
import '../../../../registros/data/registros_local_ds.dart';

import '../../domain/cartilla_long_brote_racimo_config.dart';
import '../../domain/cartilla_long_brote_racimo_payload.dart';


class CartillaLongBroteRacimoFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaLongBroteRacimoPayload payload;
  final List<String> errors;

  const CartillaLongBroteRacimoFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaLongBroteRacimoFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaLongBroteRacimoPayload? payload,
    List<String>? errors,
  }) {
    return CartillaLongBroteRacimoFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaLongBroteRacimoFormProvider = StateNotifierProvider.family<
    CartillaLongBroteRacimoFormNotifier,
    CartillaLongBroteRacimoFormState,
    int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaLongBroteRacimoFormNotifier(ref: ref, localId: localId, local: local)..load();
});

class CartillaLongBroteRacimoFormNotifier
    extends StateNotifier<CartillaLongBroteRacimoFormState>  with GeoSaveMixin {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaLongBroteRacimoFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
    CartillaLongBroteRacimoFormState(
      localId: localId,
      loading: true,
      saving: false,
      payload: CartillaLongBroteRacimoPayload.empty(),
      errors: const [],
    ),
  );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      final raw = (reg.dataJson?.isNotEmpty == true) ? reg.dataJson! : '{}';
      final map = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};

      // Normaliza: si ya viene con payloadVersion/body, úsalo;
      // si viene legacy (map plano), trátalo como body.
      final body = (map['payloadVersion'] != null && map['body'] is Map)
          ? Map<String, dynamic>.from(map['body'] as Map)
          : Map<String, dynamic>.from(map);

      // Header SIEMPRE desde columnas BD (fuente de verdad)
      final header = <String, dynamic>{
        'plantillaId': reg.plantillaId,
        'userId': reg.userId,
        'campaniaId': reg.campaniaId,
        'loteId': reg.loteId,
        'lat': reg.lat?.toDouble(),
        'lon': reg.lon?.toDouble(),
        'fechaEjecucion': null,
      };

      final payload = CartillaLongBroteRacimoPayload(
        payloadVersion: 1,
        header: header,
        body: body,
      );

      // Persistir json normalizado para evitar "{}" / missing payloadVersion
      await local.updateDataJson(localId, payload.toJsonString());

      state = state.copyWith(
        loading: false,
        payload: payload,
        errors: const [],
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

/*  void update(CartillaLongBroteRacimoPayload payload) {
    state = state.copyWith(payload: payload);
  }*/

  void update(CartillaLongBroteRacimoPayload payload) {
    final fixed = _recompute(payload);
    state = state.copyWith(payload: fixed);
  }

  CartillaLongBroteRacimoPayload _recompute(CartillaLongBroteRacimoPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    // ===== RACIMO: 148 y 149 =====
    double totalR = 0;
    double weightedR = 0;

    for (var i = 1; i <= 25; i++) {
      final key = 'long_racimo_$i';
      final v = body[key];
      final n = (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

      totalR += n;
      weightedR += n * i;
    }

    final promR = totalR > 0 ? (weightedR / totalR) : 0.0;

    body['total_racimo_evaluado'] = totalR;           // 148
    body['prom_long_x_planta_racimo'] = promR;        // 149

    return p.copyWith(body: body);
  }



  Future<void> saveLocal() async {
    state = state.copyWith(saving: true);
    try {
      final headerWithGeo = await attachGeo(ref, state.payload.header);
      final payloadWithGeo = state.payload.copyWith(header: headerWithGeo);
      state = state.copyWith(payload: payloadWithGeo);

      await local.saveLocal(
        localId: localId,
        data: state.payload.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );
    } finally {
      state = state.copyWith(saving: false);
    }
  }

  Future<void> finalize() async {
    // Si ya tienes validación requerida en UI, aquí solo marcamos listo
    await saveLocal();
    await local.markAsReadyForSync(localId);
  }

  /// ✅ +1 SIN argumentos (CartillaFormPage lo llama así)
  Future<int> duplicateAsNew2() async {


    await saveLocal();

    final cfg = CartillaLongBroteRacimoConfig();

 /*   debugPrint('PLUS1 bodyKeys=${cfg.plusOneReplicableBodyKeys}');
    debugPrint('ORIG corresponde=${ originalBody["corresponde"]}');
    debugPrint('NEW  corresponde=${newBody["corresponde"]}');*/


    // Usa duplicado genérico en DS (como en Brotación duplicateAsNew2)
    final newLocalId = await local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );

    return newLocalId;
  }

  Future<int> duplicateAsNew3() async {
    // 1) Guarda lo último
    await saveLocal();

    final cfg = CartillaLongBroteRacimoConfig();

    // ✅ LOG: qué valor tienes antes del +1 (desde el payload actual)
    debugPrint('PLUS1 BEFORE corresponde=${state.payload.getBodyValue("corresponde")}');
    debugPrint('PLUS1 BODY KEYS=${cfg.plusOneReplicableBodyKeys}');

    // 2) Duplica (genérico)
    final newLocalId = await local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );

    // 3) ✅ LOG: leer lo que realmente quedó guardado en el nuevo registro
    final newReg = await local.getByLocalId(newLocalId);
    debugPrint('PLUS1 NEW dataJson=${newReg.dataJson}');

    // 4) ✅ LOG: parsear el nuevo payload y ver corresponde
    final newPayload = CartillaLongBroteRacimoPayload.fromJsonString(newReg.dataJson ?? '{}');
    debugPrint('PLUS1 AFTER corresponde=${newPayload.getBodyValue("corresponde")}');

    return newLocalId;
  }

  Future<int> duplicateAsNew() async {
    // 0) guarda lo último
    await saveLocal();

    // 1) registro actual desde DB local
    final currentReg = await local.getByLocalId(localId);

    // 2) crear nuevo draft
    final newLocalId = await local.createDraft(
      plantillaId: currentReg.plantillaId,
      templateKey: currentReg.templateKey,
      userId: currentReg.userId,
    );

    // 3) payload actual
    final p = state.payload;

    // 4) header nuevo (mínimo estándar + replicables)
    final newHeader = <String, dynamic>{
      'plantillaId': currentReg.plantillaId,
      'userId': currentReg.userId,
      'campaniaId': p.getHeaderValue('campaniaId'),
      'loteId': p.getHeaderValue('loteId'),
      'lat': p.getHeaderValue('lat'),
      'lon': p.getHeaderValue('lon'),
      'fechaEjecucion': null,
    };

    // 5) body nuevo: copiar SOLO lo copiables (+1)
    // ✅ aquí está el fix: incluir "corresponde"
    final newBody = <String, dynamic>{
      'cantidadMuestras': null,
      'corresponde': p.getBodyValue('corresponde'),

      // NO copiar: que el usuario lo vuelva a llenar
      'hilera': null,
      'planta': null,

      // resetea calculados (se recalculan solos por update/save)
      'total_racimo_evaluado': 0.0,
      'prom_long_x_planta_racimo': 0.0,
    };

    // 6) armar payload +1 (usa TU clase de Long Brote/Racimo)
    final plusPayload = CartillaLongBroteRacimoPayload(
      payloadVersion: p.payloadVersion,
      header: newHeader,
      body: newBody,
    );

    // 7) guardar en el nuevo registro (OJO: es local.saveLocal, no saveLocal)
    await local.saveLocal(
      localId: newLocalId,
      data: plusPayload.toJson(),
      estado: EstadoRegistro.borrador,
      syncStatus: SyncStatus.local,
    );

    return newLocalId;
  }

}
