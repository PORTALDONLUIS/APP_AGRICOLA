import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mixins/geo_save_mixin.dart';
import '../../../../core/sync/sync_models.dart';
import '../../../cartillas/application/cartilla_form_contract.dart';
import '../../../registros/data/registros_local_ds.dart';
import '../../../../app/providers.dart';
import '../../../master/presentation/master_providers.dart';

import '../domain/cartilla_brix_moscatel_config.dart';
import '../domain/cartilla_brix_moscatel_payload.dart';

class CartillaBrixMoscatelFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaBrixMoscatelPayload payload;
  final List<String> errors;

  const CartillaBrixMoscatelFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaBrixMoscatelFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaBrixMoscatelPayload? payload,
    List<String>? errors,
  }) {
    return CartillaBrixMoscatelFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaBrixMoscatelFormProvider = StateNotifierProvider.autoDispose.family<
    CartillaBrixMoscatelFormNotifier,
    CartillaBrixMoscatelFormState,
    int>((ref, localId) {
  final local = ref.read(registrosLocalDSProvider);
  return CartillaBrixMoscatelFormNotifier(
    ref: ref,
    localId: localId,
    local: local,
  )..load();
});

class CartillaBrixMoscatelFormNotifier
    extends StateNotifier<CartillaBrixMoscatelFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final int localId;
  final RegistrosLocalDS local;
  final Ref ref;

  /// Resuelto desde `VARIEDAD` local (descripción MOSCATEL). Null si aún no sincronizó.
  int? _moscatelVariedadId;
  Future<int>? _pendingPlusOne;

  CartillaBrixMoscatelFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(CartillaBrixMoscatelFormState(
          localId: localId,
          loading: true,
          saving: false,
          payload: CartillaBrixMoscatelPayload.empty(),
          errors: const [],
        ));

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final variedades = await ref.read(masterLocalDsProvider).getVariedades();
      _moscatelVariedadId = CartillaBrixMoscatelConfig.resolveVariedadMoscatelId(variedades);

      final reg = await local.getByLocalId(localId);

      final raw = (reg.dataJson).trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaBrixMoscatelPayload payload;
      if (isEmptyJson) {
        payload = CartillaBrixMoscatelPayload.empty();

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
          body: {
            ...payload.body,
            'variedad': _moscatelVariedadId,
          },
        );

        await local.updateDataJson(localId, payload.toJsonString());
      } else {
        payload = CartillaBrixMoscatelPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 BRIX_MOSCATEL load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaBrixMoscatelPayload payload) {
    // El formulario queda de sólo lectura durante el commit. También cubre
    // eventos de teclado que llegaron antes de que Flutter pinte ese estado.
    if (state.saving) return;
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  // =====================================================
  // _recompute
  // No hay fórmulas en el manual.
  // Se mantiene patrón y se normaliza variedad fija.
  // =====================================================
  CartillaBrixMoscatelPayload _recompute(CartillaBrixMoscatelPayload p) {
    final body = Map<String, dynamic>.from(p.body);

    final id = _moscatelVariedadId;
    if (id != null) {
      body['variedad'] = id;
    } else {
      final prev = body['variedad'];
      if (prev is String &&
          prev.trim().toUpperCase() == 'MOSCATEL') {
        body['variedad'] = null;
      } else if (prev is int) {
        body['variedad'] = prev;
      } else {
        body['variedad'] = int.tryParse(prev?.toString() ?? '');
      }
    }

    double? asDoubleNullable(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      if (v is String) {
        final s = v.trim().replaceAll(',', '.');
        if (s.isEmpty) return null;
        return double.tryParse(s);
      }
      return null;
    }

    final brix = asDoubleNullable(body['brixSsc']);
    body['brixSsc'] = brix;

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('✅ BRIX_MOSCATEL saveLocal START localId=$localId');

    final fixed = _recompute(state.payload);
    final headerWithGeo = _headerWithCachedGeo(fixed.header);
    final fixedWithGeo = fixed.copyWith(header: headerWithGeo);

    state = state.copyWith(saving: true);
    try {
      state = state.copyWith(payload: fixedWithGeo);

      await local.saveLocal(
        localId: localId,
        data: fixedWithGeo.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );

      debugPrint('✅ BRIX_MOSCATEL saveLocal DONE');
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
    final cfg = CartillaBrixMoscatelConfig();

    final newLocalId = await local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );

    return newLocalId;
  }

  /// Variante usada exclusivamente por el +1 de Brix Moscatel.
  ///
  /// Primero protege la muestra en SQLite y crea la siguiente sin bloquear al
  /// usuario esperando un fix GPS. Si existe un fix reciente, se incorpora en
  /// esa misma escritura para no actualizar el registro dos veces.
  Future<int> duplicateAsNewForFastSampling() {
    // Dos pulsaciones simultáneas comparten la misma operación durable.
    return _pendingPlusOne ??= _completeAndContinue().whenComplete(() {
      _pendingPlusOne = null;
    });
  }

  Future<int> _completeAndContinue() async {
    final fixed = _recompute(state.payload);
    final fixedWithGeo = fixed.copyWith(
      header: _headerWithCachedGeo(fixed.header),
    );
    state = state.copyWith(saving: true, payload: fixedWithGeo);

    try {
      final cfg = CartillaBrixMoscatelConfig();
      return await local.completeSampleAndCreateNext(
        localId: localId,
        data: fixedWithGeo.toJson(),
        plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
        plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
      );
    } finally {
      state = state.copyWith(saving: false);
    }
  }

  /// Validación ligera para el muestreo continuo. Evita dejar una muestra
  /// incompleta lista para sincronización cuando se presiona +1.
  List<String> continuousSamplingValidationErrors() {
    final header = state.payload.header;
    final body = state.payload.body;
    final missing = <String>[];

    void requireValue(dynamic value, String label) {
      if (!_hasRequiredValue(value)) missing.add(label);
    }

    requireValue(header[CartillaBrixMoscatelConfig.kLoteId], 'Lote');
    requireValue(body[CartillaBrixMoscatelConfig.kHilera], 'Hilera');
    requireValue(body[CartillaBrixMoscatelConfig.kPlanta], 'Planta');
    requireValue(body[CartillaBrixMoscatelConfig.kVariedad], 'Variedad');
    requireValue(body[CartillaBrixMoscatelConfig.kCorresponde], 'Corresponde');
    requireValue(header[CartillaBrixMoscatelConfig.kCampaniaId], 'Campaña');
    if (!_hasMeasuredBrix(body[CartillaBrixMoscatelConfig.kBrixSsc])) {
      missing.add('Brix - SSC');
    }

    return missing;
  }

  bool _hasRequiredValue(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    return true;
  }

  // El formulario muestra 0 como vacío para Brix. Por eso 0 no puede contar
  // como una lectura ingresada al validar el +1.
  bool _hasMeasuredBrix(dynamic value) {
    if (value is num) return value > 0;
    if (value is String) {
      final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
      return parsed != null && parsed > 0;
    }
    return false;
  }

  Map<String, dynamic> _headerWithCachedGeo(Map<String, dynamic> header) {
    final copy = Map<String, dynamic>.from(header);
    if (headerHasSamplingLatLon(copy)) return copy;

    // Brix Moscatel registra cientos de muestras consecutivas. Reutilizar el
    // último fix de la pantalla evita abrir una nueva búsqueda GPS por muestra.
    final cachedGeo = ref.read(locationServiceProvider).tryGetCachedHeaderGeo();
    return cachedGeo == null ? copy : {...copy, ...cachedGeo};
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    // TODO
  }
}
