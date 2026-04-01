/*
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/sync_models.dart';
import '../../../cartillas/application/cartilla_validator.dart';
import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../registros/data/registros_local_ds.dart';
import '../../../../app/providers.dart';

import '../../domain/cartilla_fito_payload.dart';
import '../../domain/cartilla_fito_validator.dart';
import '../../../cartillas/domain/cartilla_header_v1.dart';

class CartillaFitoFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaFitoPayload payload;
  final List<String> errors;

  const CartillaFitoFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaFitoFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaFitoPayload? payload,
    List<String>? errors,
  }) {
    return CartillaFitoFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaFitoFormProvider = StateNotifierProvider.family<
    CartillaFitoFormNotifier, CartillaFitoFormState, int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaFitoFormNotifier(localId: localId, local: local)..load();
});

class CartillaFitoFormNotifier extends StateNotifier<CartillaFitoFormState> {
  final int localId;
  final RegistrosLocalDS local;

  CartillaFitoFormNotifier({
    required this.localId,
    required this.local,
  }) : super(
    CartillaFitoFormState(
      localId: localId,
      loading: true,
      saving: false,
      // ✅ payload inicial “dummy” (se reemplaza en load())
      payload: CartillaFitoPayload(
        header: const CartillaHeaderV1(plantillaId: 0, userId: 0),
        body: const <String, dynamic>{},
      ),
      errors: const [],
    ),
  );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      // ✅ dataJson es String -> parse Map
      final raw = (reg.dataJson?.isNotEmpty == true) ? reg.dataJson! : '{}';
      final map = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};

      // ✅ normaliza a estándar: {payloadVersion, header, body}
      final Map<String, dynamic> body;
      final Map<String, dynamic> headerMap;
      if (map['payloadVersion'] != null && map['body'] is Map) {
        body = Map<String, dynamic>.from(map['body'] as Map);
        headerMap = Map<String, dynamic>.from(map['header'] as Map? ?? {});
      } else {
        // legacy: todo era body
        body = map;
        headerMap = {};
      }

      // ✅ header: SIEMPRE desde columnas BD (fuente de verdad)
      final header = CartillaHeaderV1(
        plantillaId: reg.plantillaId,
        userId: reg.userId,
        campaniaId: reg.campaniaId,
        loteId: reg.loteId,
        lat: reg.lat?.toDouble(),
        lon: reg.lon?.toDouble(),
        fechaEjecucion: null,
      );

      final payload = CartillaFitoPayload(header: header, body: body);

      final errors = const CartillaFitoValidator().validate(payload);

      state = state.copyWith(
        loading: false,
        payload: payload,
        errors: errors,
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaFitoPayload payload) {
    state = state.copyWith(
      payload: payload,
      errors: const CartillaFitoValidator().validate(payload),
    );
  }

  // 1) Guardar (motor genérico llama esto)
  Future<void> saveLocal() => saveLocalDraft();

  Future<void> saveLocalDraft() async {
    state = state.copyWith(saving: true);
    try {
      // ✅ guarda payload estándar

      final j = state.payload.toJson();
      debugPrint('🧾 FITO BEFORE SAVE header.keys=${(j["header"] as Map).keys.toList()}');
      debugPrint('🧾 FITO BEFORE SAVE body.keys=${(j["body"] as Map).keys.toList()}');
      debugPrint('🧾 FITO BEFORE SAVE JSON=${jsonEncode(j)}');
      await local.saveLocal(
        localId: localId,
        data: state.payload.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );

      final reg2 = await local.getByLocalId(localId);
      debugPrint('🧾 FITO AFTER SAVE dataJson=${reg2.dataJson}');

    } finally {
      state = state.copyWith(saving: false);
    }
  }

  Future<void> finalize({
    required BuildContext context,
    required CartillaFormConfig config,
  }) async {
    final payload = state.payload;

    final issues = validateRequired(
      config: config,
      // ✅ header/body vía contrato (Base A implementa accessors)
      getHeaderValue: (k) => payload.getHeaderValue(k),
      getBodyValue: (k) => payload.getBodyValue(k),
    );

    if (issues.isNotEmpty) {
      final msgs =
      issues.map((i) => '${i.sectionTitle}: ${i.fieldLabel}').toList();
      await _showValidationDialog(context, msgs);
      return;
    }

    await saveLocalDraft();
    await local.markAsReadyForSync(localId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro marcado como LISTO para sincronizar')),
      );
    }
  }

  /// ✅ Duplicación +1: se define por config (sets existentes)
  /// IMPORTANTE: este método ahora requiere config (igual que finalize)
  Future<int> duplicateAsNew({
    required CartillaFormConfig config,
  }) async {
    final currentReg = await local.getByLocalId(localId);

    final newLocalId = await local.createDraft(
      plantillaId: currentReg.plantillaId,
      templateKey: currentReg.templateKey,
      userId: currentReg.userId,
    );

    final original = state.payload.toJson();
    final originalHeader =
    Map<String, dynamic>.from(original['header'] as Map? ?? {});
    final originalBody =
    Map<String, dynamic>.from(original['body'] as Map? ?? {});

    // ✅ header nuevo desde columnas BD
    final headerFromColumns = <String, dynamic>{
      'plantillaId': currentReg.plantillaId,
      'userId': currentReg.userId,
      'campaniaId': currentReg.campaniaId,
      'loteId': currentReg.loteId,
      'lat': currentReg.lat,
      'lon': currentReg.lon,
      'fechaEjecucion': null,
    };

    // ✅ copiar header keys según config (si está vacío, se queda solo con BD si tú lo pones en el set)
    final newHeader = <String, dynamic>{};
    for (final k in config.plusOneReplicableHeaderKeys) {
      newHeader[k] = headerFromColumns.containsKey(k)
          ? headerFromColumns[k]
          : originalHeader[k];
    }

    // ✅ copiar body keys según config
    final newBody = <String, dynamic>{};
    for (final k in config.plusOneReplicableBodyKeys) {
      if (originalBody.containsKey(k)) newBody[k] = originalBody[k];
    }

    final plusPayload = <String, dynamic>{
      'payloadVersion': 1,
      'header': newHeader,
      'body': newBody,
    };

    await local.saveLocal(
      localId: newLocalId,
      data: plusPayload,
      estado: EstadoRegistro.borrador,
      syncStatus: SyncStatus.local,
    );

    return newLocalId;
  }

  Future<void> _showValidationDialog(
      BuildContext context, List<String> issues) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Campos obligatorios'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: issues.map((e) => Text('• $e')).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
*/


import 'dart:convert';

import 'package:donluis_forms/core/mixins/geo_save_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/domain/cartilla_form_config.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_fito_config.dart';
import '../../domain/cartilla_fito_payload.dart';
import '../../domain/cartilla_fito_validator.dart';

class CartillaFitoFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaFitoPayload payload;
  final List<String> errors;

  const CartillaFitoFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaFitoFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaFitoPayload? payload,
    List<String>? errors,
  }) {
    return CartillaFitoFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaFitoFormProvider = StateNotifierProvider.family<
    CartillaFitoFormNotifier, CartillaFitoFormState, int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaFitoFormNotifier(ref: ref, localId: localId, local: local)..load();
});

class CartillaFitoFormNotifier extends StateNotifier<CartillaFitoFormState>
    with GeoSaveMixin {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaFitoFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
    CartillaFitoFormState(
      localId: localId,
      loading: true,
      saving: false,
      // ✅ payload inicial estándar (igual Brotación)
      payload: CartillaFitoPayload.empty(),
      errors: const [],
    ),
  );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      // ✅ dataJson es String -> parse Map
      final raw = (reg.dataJson?.isNotEmpty == true) ? reg.dataJson! : '{}';
      final map = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};

      // ✅ normaliza a estándar: {payloadVersion, header, body}
      Map<String, dynamic> body;
      if (map['payloadVersion'] != null && map['body'] is Map) {
        body = Map<String, dynamic>.from(map['body'] as Map);
      } else {
        // legacy: todo era body (si existe)
        body = Map<String, dynamic>.from(map);
      }

      // ✅ header: SIEMPRE desde columnas BD (fuente de verdad)
      final header = <String, dynamic>{
        'plantillaId': reg.plantillaId,
        'userId': reg.userId,
        'campaniaId': reg.campaniaId,
        'loteId': reg.loteId,
        'lat': reg.lat?.toDouble(),
        'lon': reg.lon?.toDouble(),
        'fechaEjecucion': null,
      };

      final payload = CartillaFitoPayload(
        payloadVersion: 1,
        header: header,
        body: body,
      );

      // ✅ IMPORTANTÍSIMO: guardar inmediatamente el JSON normalizado
      // para que NUNCA quede en '{}' y evitar bugs de payloadVersion
      await local.updateDataJson(localId, payload.toJsonString());

      final errors = const CartillaFitoValidator().validate(payload);

      state = state.copyWith(
        loading: false,
        payload: payload,
        errors: errors,
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaFitoPayload payload) {
    state = state.copyWith(
      payload: payload,
      errors: const CartillaFitoValidator().validate(payload),
    );
  }

  // 1) Guardar (motor genérico llama esto)
  Future<void> saveLocal() => saveLocalDraft();

  Future<void> saveLocalDraft() async {
    state = state.copyWith(saving: true);
    try {
      final j = state.payload.toJson();

      debugPrint('🧾 FITO BEFORE SAVE header.keys=${(j["header"] as Map).keys.toList()}');
      debugPrint('🧾 FITO BEFORE SAVE body.keys=${(j["body"] as Map).keys.toList()}');
      debugPrint('🧾 FITO BEFORE SAVE JSON=${jsonEncode(j)}');

      final headerWithGeo = await attachGeo(ref, state.payload.header);
      final payloadWithGeo = state.payload.copyWith(header: headerWithGeo);
      state = state.copyWith(payload: payloadWithGeo);

      await local.saveLocal(
        localId: localId,
        data: j,
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );

      final reg2 = await local.getByLocalId(localId);
      debugPrint('🧾 FITO AFTER SAVE dataJson=${reg2.dataJson}');
    } finally {
      state = state.copyWith(saving: false);
    }
  }

  Future<void> finalize() async {
    // 1) Guardar primero
    await saveLocal();

    // 2) Marcar listo para sync
    await local.markAsReadyForSync(localId);
  }

 /* Future<void> finalize({
    required BuildContext context,
    required CartillaFormConfig config,
  }) async {
    final payload = state.payload;

    final issues = validateRequired(
      config: config,
      getHeaderValue: (k) => payload.getHeaderValue(k),
      getBodyValue: (k) => payload.getBodyValue(k),
    );

    if (issues.isNotEmpty) {
      final msgs = issues.map((i) => '${i.sectionTitle}: ${i.fieldLabel}').toList();
      await _showValidationDialog(context, msgs);
      return;
    }

    await saveLocalDraft();
    await local.markAsReadyForSync(localId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro marcado como LISTO para sincronizar')),
      );
    }
  }*/

  /// ✅ Duplicación +1: usa sets del config
  Future<int> duplicateAsNew2({
    required CartillaFormConfig config,
  }) async {
    // 1) Guardar primero lo último
    await saveLocalDraft();

    final currentReg = await local.getByLocalId(localId);

    // 2) Crear nuevo draft
    final newLocalId = await local.createDraft(
      plantillaId: currentReg.plantillaId,
      templateKey: currentReg.templateKey,
      userId: currentReg.userId,
    );

    final original = state.payload.toJson();
    final originalHeader = Map<String, dynamic>.from(original['header'] as Map? ?? {});
    final originalBody = Map<String, dynamic>.from(original['body'] as Map? ?? {});

    // 3) Header base desde columnas
    final headerFromColumns = <String, dynamic>{
      'plantillaId': currentReg.plantillaId,
      'userId': currentReg.userId,
      'campaniaId': currentReg.campaniaId,
      'loteId': currentReg.loteId,
      'lat': currentReg.lat?.toDouble(),
      'lon': currentReg.lon?.toDouble(),
      'fechaEjecucion': null,
    };

    // 4) Copiar header keys (según config)
    final newHeader = <String, dynamic>{};
    for (final k in config.plusOneReplicableHeaderKeys) {
      newHeader[k] = headerFromColumns.containsKey(k)
          ? headerFromColumns[k]
          : originalHeader[k];
    }

    // 5) Copiar body keys (según config)
    final newBody = <String, dynamic>{};
    for (final k in config.plusOneReplicableBodyKeys) {
      if (originalBody.containsKey(k)) newBody[k] = originalBody[k];
    }

    // 6) Guardar payload nuevo
    final plusPayload = <String, dynamic>{
      'payloadVersion': 1,
      'header': newHeader,
      'body': newBody,
    };

    await local.saveLocal(
      localId: newLocalId,
      data: plusPayload,
      estado: EstadoRegistro.borrador,
      syncStatus: SyncStatus.local,
    );

    return newLocalId;
  }

  /// ✅ +1: copia SOLO keys marcadas en config y crea nuevo registro
  Future<int> duplicateAsNew() async {
    // 1) Guardar lo último editado

    debugPrint('🧾 FITO duplicateAsNew');
    await saveLocalDraft();

    // 2) Config (define qué se copia)
    final cfg = CartillaFitoConfig();

    // 3) Duplicar usando el DS (mismo patrón que Brotación duplicateAsNew2)
    final newLocalId = await local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );

    return newLocalId;
  }

  Future<void> _showValidationDialog(BuildContext context, List<String> issues) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Campos obligatorios'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: issues.map((e) => Text('• $e')).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
