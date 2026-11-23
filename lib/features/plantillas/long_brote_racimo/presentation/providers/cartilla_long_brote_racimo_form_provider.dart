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

final cartillaLongBroteRacimoFormProvider =
    StateNotifierProvider.autoDispose.family<
      CartillaLongBroteRacimoFormNotifier,
      CartillaLongBroteRacimoFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaLongBroteRacimoFormNotifier(
        ref: ref,
        localId: localId,
        local: local,
      )..load();
    });

class CartillaLongBroteRacimoFormNotifier
    extends StateNotifier<CartillaLongBroteRacimoFormState>
    with GeoSaveMixin {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;
  Future<int>? _pendingPlusOne;
  double _broteTotal = 0;
  double _broteWeightedTotal = 0;
  double _racimoTotal = 0;
  double _racimoWeightedTotal = 0;

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
    if (!mounted) return;
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);

      final raw = (reg.dataJson.isNotEmpty == true) ? reg.dataJson : '{}';
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

      final recomputed = _recompute(payload);

      // Persistir json normalizado para evitar "{}" / missing payloadVersion
      await local.updateDataJson(localId, recomputed.toJsonString());

      if (!mounted) return;
      state = state.copyWith(
        loading: false,
        payload: recomputed,
        errors: const [],
      );
    } catch (_) {
      if (mounted) state = state.copyWith(loading: false);
    }
  }

  /*  void update(CartillaLongBroteRacimoPayload payload) {
    state = state.copyWith(payload: payload);
  }*/

  void update(CartillaLongBroteRacimoPayload payload) {
    if (state.saving) return;
    final fixed = _recompute(payload);
    state = state.copyWith(payload: fixed);
  }

  /// Actualiza una celda sin recorrer todas las mediciones de la cartilla.
  void updateBodyValue(String key, dynamic value) {
    if (state.saving || state.payload.body[key] == value) return;

    final body = Map<String, dynamic>.from(state.payload.body)..[key] = value;
    final broteIndex = _measurementIndex(key, 'long_brote_', 240);
    final racimoIndex = _measurementIndex(key, 'long_racimo_', 25);

    if (broteIndex != null) {
      final delta = _asDouble(value) - _asDouble(state.payload.body[key]);
      _broteTotal += delta;
      _broteWeightedTotal += delta * broteIndex;
      if (_broteTotal.abs() < 0.0000001) _broteTotal = 0;
      if (_broteWeightedTotal.abs() < 0.0000001) _broteWeightedTotal = 0;
      body[CartillaLongBroteRacimoConfig.kTotalBroteEvaluado] = _broteTotal;
      body[CartillaLongBroteRacimoConfig.kPromLongPlantaBrote] =
          _broteTotal > 0 ? _broteWeightedTotal / _broteTotal : 0.0;
    } else if (racimoIndex != null) {
      final delta = _asDouble(value) - _asDouble(state.payload.body[key]);
      _racimoTotal += delta;
      _racimoWeightedTotal += delta * racimoIndex;
      if (_racimoTotal.abs() < 0.0000001) _racimoTotal = 0;
      if (_racimoWeightedTotal.abs() < 0.0000001) _racimoWeightedTotal = 0;
      body[CartillaLongBroteRacimoConfig.kTotalRacimoEvaluado] = _racimoTotal;
      body[CartillaLongBroteRacimoConfig.kPromLongPlantaRacimo] =
          _racimoTotal > 0 ? _racimoWeightedTotal / _racimoTotal : 0.0;
    }

    state = state.copyWith(payload: state.payload.copyWith(body: body));
  }

  void updateHeaderValue(String key, dynamic value) {
    if (state.saving || state.payload.header[key] == value) return;
    final header = Map<String, dynamic>.from(state.payload.header)..[key] = value;
    state = state.copyWith(payload: state.payload.copyWith(header: header));
  }

  void updateBodyValues(Map<String, dynamic> values) {
    if (state.saving) return;
    final changedValues = values.entries
        .where((entry) => state.payload.body[entry.key] != entry.value)
        .toList();
    if (changedValues.isEmpty) return;

    final body = Map<String, dynamic>.from(state.payload.body)
      ..addEntries(changedValues);
    final updatesMeasurements = changedValues.any(
      (entry) =>
          _measurementIndex(entry.key, 'long_brote_', 240) != null ||
          _measurementIndex(entry.key, 'long_racimo_', 25) != null,
    );
    final nextPayload = state.payload.copyWith(body: body);
    state = state.copyWith(
      payload: updatesMeasurements ? _recompute(nextPayload) : nextPayload,
    );
  }

  double _asDouble(dynamic value) {
    if (value is num && value.isFinite) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  int? _measurementIndex(String key, String prefix, int max) {
    if (!key.startsWith(prefix)) return null;
    final index = int.tryParse(key.substring(prefix.length));
    return index != null && index >= 1 && index <= max ? index : null;
  }

  CartillaLongBroteRacimoPayload _recompute(CartillaLongBroteRacimoPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    // ===== BROTE: 241 y 242 =====
    double totalB = 0;
    double weightedB = 0;
    for (var i = 1; i <= 240; i++) {
      final key = 'long_brote_$i';
      final v = body[key];
      final n = (v is num)
          ? v.toDouble()
          : double.tryParse(v?.toString() ?? '') ?? 0.0;
      totalB += n;
      weightedB += n * i;
    }
    final promB = totalB > 0 ? (weightedB / totalB) : 0.0;
    _broteTotal = totalB;
    _broteWeightedTotal = weightedB;
    body['total_brote_evaluado'] = totalB;
    body['prom_long_x_planta_brote'] = promB;

    // ===== RACIMO: 148 y 149 =====
    double totalR = 0;
    double weightedR = 0;

    for (var i = 1; i <= 25; i++) {
      final key = 'long_racimo_$i';
      final v = body[key];
      final n = (v is num)
          ? v.toDouble()
          : double.tryParse(v?.toString() ?? '') ?? 0.0;

      totalR += n;
      weightedR += n * i;
    }

    final promR = totalR > 0 ? (weightedR / totalR) : 0.0;
    _racimoTotal = totalR;
    _racimoWeightedTotal = weightedR;

    body['total_racimo_evaluado'] = totalR; // 148
    body['prom_long_x_planta_racimo'] = promR; // 149

    return p.copyWith(body: body);
  }

  Future<void> saveLocal() async {
    final payloadToSave = state.payload;
    state = state.copyWith(saving: true);
    try {
      final headerWithGeo = await attachGeo(ref, payloadToSave.header);
      final payloadWithGeo = _recompute(
        payloadToSave.copyWith(header: headerWithGeo),
      );
      if (mounted) state = state.copyWith(payload: payloadWithGeo);

      await local.saveLocal(
        localId: localId,
        data: payloadWithGeo.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );
    } finally {
      if (mounted) state = state.copyWith(saving: false);
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
    debugPrint(
      'PLUS1 BEFORE corresponde=${state.payload.getBodyValue("corresponde")}',
    );
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
    final newPayload = CartillaLongBroteRacimoPayload.fromJsonString(
      newReg.dataJson,
    );
    debugPrint(
      'PLUS1 AFTER corresponde=${newPayload.getBodyValue("corresponde")}',
    );

    return newLocalId;
  }

  Future<int> duplicateAsNew() async {
    await saveLocal();
    final cfg = CartillaLongBroteRacimoConfig();
    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  /// Completa la muestra actual y crea la siguiente en una sola transacción.
  /// Reutiliza un GPS reciente y solo busca una lectura nueva si no hay caché.
  Future<int> duplicateAsNewForFastSampling() {
    return _pendingPlusOne ??= _completeSampleAndContinue().whenComplete(() {
      _pendingPlusOne = null;
    });
  }

  Future<int> _completeSampleAndContinue() async {
    final fixed = _recompute(state.payload);
    state = state.copyWith(saving: true);

    try {
      final header = await _headerWithRecentGeo(fixed.header);
      final payloadWithGeo = fixed.copyWith(header: header);
      if (mounted) state = state.copyWith(payload: payloadWithGeo);

      final cfg = CartillaLongBroteRacimoConfig();
      return await local.completeSampleAndCreateNext(
        localId: localId,
        data: payloadWithGeo.toJson(),
        plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
        plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
      );
    } finally {
      if (mounted) state = state.copyWith(saving: false);
    }
  }

  List<String> continuousSamplingValidationErrors() {
    final header = state.payload.header;
    final body = state.payload.body;
    final missing = <String>[];

    void requireValue(dynamic value, String label) {
      if (value == null || (value is String && value.trim().isEmpty)) {
        missing.add(label);
      }
    }

    requireValue(header[CartillaLongBroteRacimoConfig.kLoteId], 'Lote');
    requireValue(
      header[CartillaLongBroteRacimoConfig.kCampaniaId],
      'Campaña',
    );
    requireValue(
      body[CartillaLongBroteRacimoConfig.kCantidadMuestras],
      'Cantidad de muestras',
    );
    requireValue(body[CartillaLongBroteRacimoConfig.kHilera], 'Hilera');
    requireValue(body[CartillaLongBroteRacimoConfig.kPlanta], 'Planta');
    requireValue(body[CartillaLongBroteRacimoConfig.kCorresponde], 'Corresponde');
    return missing;
  }

  Future<Map<String, dynamic>> _headerWithRecentGeo(
    Map<String, dynamic> header,
  ) async {
    final copy = Map<String, dynamic>.from(header);
    if (headerHasSamplingLatLon(copy)) return copy;

    final locationService = ref.read(locationServiceProvider);
    final cachedGeo = locationService.tryGetCachedHeaderGeo(
      maxAge: const Duration(minutes: 5),
    );
    if (cachedGeo != null && headerHasSamplingLatLon(cachedGeo)) {
      return {...copy, ...cachedGeo};
    }

    final freshGeo = await locationService.tryGetHeaderGeo();
    if (freshGeo == null || !headerHasSamplingLatLon(freshGeo)) {
      throw StateError(
        'No hay una ubicación GPS reciente válida. '
        'Espera a que aparezca el GPS y vuelve a tocar +1.',
      );
    }
    return {...copy, ...freshGeo};
  }
}
