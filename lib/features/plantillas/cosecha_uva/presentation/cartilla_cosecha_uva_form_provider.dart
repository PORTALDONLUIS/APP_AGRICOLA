import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../../../core/mixins/geo_save_mixin.dart';
import '../../../../core/sync/sync_models.dart';
import '../../../cartillas/application/cartilla_form_contract.dart';
import '../../../cartillas/application/cartilla_validator.dart';
import '../../../cartillas/domain/evaluation_defaults.dart';
import '../../../registros/data/registros_local_ds.dart';
import '../domain/cartilla_cosecha_uva_config.dart';
import '../domain/cartilla_cosecha_uva_payload.dart';
import '../domain/cosecha_uva_metrics.dart';

class CartillaCosechaUvaFormState {
  final int localId;
  final bool loading, saving;
  final CartillaCosechaUvaPayload payload;
  final List<String> errors;
  const CartillaCosechaUvaFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    this.errors = const [],
  });
  CartillaCosechaUvaFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaCosechaUvaPayload? payload,
    List<String>? errors,
  }) => CartillaCosechaUvaFormState(
    localId: localId,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    payload: payload ?? this.payload,
    errors: errors ?? this.errors,
  );
}

final cartillaCosechaUvaFormProvider = StateNotifierProvider.autoDispose
    .family<CartillaCosechaUvaFormNotifier, CartillaCosechaUvaFormState, int>(
      (ref, id) => CartillaCosechaUvaFormNotifier(
        ref: ref,
        localId: id,
        local: ref.read(registrosLocalDSProvider),
      )..load(),
    );

class CartillaCosechaUvaFormNotifier
    extends StateNotifier<CartillaCosechaUvaFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;
  Future<int>? _pendingPlusOne;
  CartillaCosechaUvaFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaCosechaUvaFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaCosechaUvaPayload.empty(),
         ),
       );

  CartillaCosechaUvaPayload _recompute(CartillaCosechaUvaPayload p) =>
      p.copyWith(body: {...p.body, ...cosechaUvaMetrics(p.body)});

  Future<void> load() async {
    try {
      final row = await local.getByLocalId(localId);
      final raw = row.dataJson.trim();
      var p = raw.isEmpty || raw == '{}' || raw == 'null'
          ? CartillaCosechaUvaPayload.empty().copyWith(
              header: {
                'plantillaId': row.plantillaId,
                'userId': row.userId,
                'loteId': row.loteId,
                'campaniaId': row.campaniaId,
                'lat': row.lat,
                'lon': row.lon,
              },
            )
          : CartillaCosechaUvaPayload.fromJsonString(raw);
      if (row.serverId == null) {
        var b = evaluationDefaults(p.body, p.header);
        final pe = DateTime.now().toUtc().subtract(const Duration(hours: 5));
        String two(int n) => n.toString().padLeft(2, '0');
        if (b['hora'] == null || '${b['hora']}'.trim().isEmpty) {
          b = {...b, 'hora': '${two(pe.hour)}:${two(pe.minute)}'};
        }
        // Variety is lot metadata, not a copied answer. Resolve it by primary
        // key only when absent on the new draft; no full catalog or network read.
        final loteId = int.tryParse('${p.header['loteId']}');
        if (loteId != null && (b['variedad'] == null || '${b['variedad']}'.isEmpty)) {
          final db = local.dao.attachedDatabase;
          final lote = await (db.select(db.lotesTable)
                ..where((t) => t.idLote.equals(loteId)))
              .getSingleOrNull();
          if (lote != null && lote.estado) b = {...b, 'variedad': '${lote.idVariedad}'};
        }
        p = p.copyWith(body: b);
      }
      if (mounted) {
        state = state.copyWith(loading: false, payload: _recompute(p));
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          loading: false,
          errors: ['No se pudo abrir la muestra: $e'],
        );
      }
    }
  }

  void update(CartillaCosechaUvaPayload p) {
    if (!state.saving) {
      state = state.copyWith(payload: _recompute(p), errors: []);
    }
  }

  @override
  void updateDataJson(Map<String, dynamic> next) => update(
    CartillaCosechaUvaPayload(
      payloadVersion: 1,
      header: Map<String, dynamic>.from(next['header'] as Map),
      body: Map<String, dynamic>.from(next['body'] as Map),
    ),
  );

  Map<String, dynamic> _cachedGeo(Map<String, dynamic> header) {
    if (headerHasSamplingLatLon(header)) return header;
    return {
      ...header,
      ...?ref.read(locationServiceProvider).tryGetCachedHeaderGeo(),
    };
  }

  List<String> continuousSamplingValidationErrors() {
    final p = state.payload;
    final errors = validateRequired(
      config: CartillaCosechaUvaConfig(),
      getHeaderValue: (k) => p.header[k],
      getBodyValue: (k) => p.body[k],
    ).map((e) => e.fieldLabel).toList();
    if ((cosechaUvaMetrics(p.body)['totalRacimos'] as num) <= 0) {
      errors.add('Ingrese al menos un racimo en la clasificación');
    }
    return errors;
  }

  @override
  Future<void> saveLocal() async {
    if (state.saving) return;
    final p = _recompute(state.payload);
    final next = p.copyWith(header: _cachedGeo(p.header));
    state = state.copyWith(saving: true, payload: next);
    try {
      await local.saveLocal(
        localId: localId,
        data: next.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );
    } finally {
      if (mounted) state = state.copyWith(saving: false);
    }
  }

  @override
  Future<void> finalize() async {
    final issues = continuousSamplingValidationErrors();
    if (issues.isNotEmpty) throw StateError(issues.join(', '));
    await saveLocal();
    await local.markAsReadyForSync(localId);
  }

  @override
  Future<int> duplicateAsNew() => duplicateAsNewForFastSampling();
  Future<int> duplicateAsNewForFastSampling() =>
      _pendingPlusOne ??= _complete().whenComplete(() {
        _pendingPlusOne = null;
      });
  Future<int> _complete() async {
    final issues = continuousSamplingValidationErrors();
    if (issues.isNotEmpty) throw StateError(issues.join(', '));
    final p = _recompute(state.payload);
    final next = p.copyWith(header: _cachedGeo(p.header));
    state = state.copyWith(saving: true, payload: next);
    try {
      final cfg = CartillaCosechaUvaConfig();
      return await local.completeSampleAndCreateNext(
        localId: localId,
        data: next.toJson(),
        plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
        plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
      );
    } finally {
      if (mounted) state = state.copyWith(saving: false);
    }
  }
}
