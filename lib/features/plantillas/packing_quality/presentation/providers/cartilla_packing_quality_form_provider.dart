import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../cartillas/domain/cartilla_form_models.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_packing_quality_config.dart';
import '../../domain/cartilla_packing_quality_payload.dart';

class CartillaPackingQualityArgs {
  final String templateKey;
  final int localId;
  const CartillaPackingQualityArgs(this.templateKey, this.localId);

  // Riverpod identifica cada provider family por igualdad de argumentos.
  // Usar igualdad por valor evita recrear el formulario en cada rebuild.
  @override
  bool operator ==(Object other) =>
      other is CartillaPackingQualityArgs &&
      other.templateKey == templateKey &&
      other.localId == localId;

  @override
  int get hashCode => Object.hash(templateKey, localId);
}

class CartillaPackingQualityState {
  final bool loading, saving;
  final CartillaPackingQualityPayload payload;
  final List<String> errors;
  const CartillaPackingQualityState({
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });
  CartillaPackingQualityState copyWith({
    bool? loading,
    bool? saving,
    CartillaPackingQualityPayload? payload,
    List<String>? errors,
  }) => CartillaPackingQualityState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    payload: payload ?? this.payload,
    errors: errors ?? this.errors,
  );
}

final cartillaPackingQualityFormProvider =
    StateNotifierProvider.family<
      CartillaPackingQualityNotifier,
      CartillaPackingQualityState,
      CartillaPackingQualityArgs
    >(
      (ref, args) => CartillaPackingQualityNotifier(
        ref: ref,
        args: args,
        local: ref.read(registrosLocalDSProvider),
      )..load(),
    );

class CartillaPackingQualityNotifier
    extends StateNotifier<CartillaPackingQualityState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final CartillaPackingQualityArgs args;
  final RegistrosLocalDS local;
  CartillaPackingQualityNotifier({
    required this.ref,
    required this.args,
    required this.local,
  }) : super(
         CartillaPackingQualityState(
           loading: true,
           saving: false,
           payload: CartillaPackingQualityPayload(header: {}, body: {}),
           errors: const [],
         ),
       );
  CartillaPackingQualityConfig get config =>
      CartillaPackingQualityConfig(args.templateKey);
  Map<String, dynamic> _emptyBody() {
    final out = <String, dynamic>{'fotos': <Map<String, dynamic>>[]};
    for (final s in config.sections) {
      for (final f in s.fields) {
        if (f.type == CartillaFieldType.photo) continue;
        out[f.key] = f.type == CartillaFieldType.stepperInt ? 0 : null;
      }
    }
    if (args.templateKey == 'cartilla_packing_recepcion_uva_calidad') {
      out['pesoPorJaba'] = 0.0;
    }
    if (args.templateKey == 'cartilla_packing_recepcion_uva_calidad' ||
        args.templateKey == 'cartilla_packing_linea_uva_calidad' ||
        args.templateKey == 'cartilla_packing_abastecimiento_uva_calidad') {
      out['fecha'] = _today();
    }
    return out;
  }

  String _today() {
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> load() async {
    try {
      final r = await local.getByLocalId(args.localId);
      final raw = r.dataJson.trim();
      final blank = raw.isEmpty || raw == '{}' || raw == 'null';
      final header = {
        'plantillaId': r.plantillaId,
        'userId': r.userId,
        'campaniaId': r.campaniaId,
        'loteId': r.loteId,
        'lat': r.lat,
        'lon': r.lon,
        'fechaEjecucion': null,
      };
      final p = blank
          ? CartillaPackingQualityPayload(header: header, body: _emptyBody())
          : CartillaPackingQualityPayload.fromJsonString(raw);
      if (blank) await local.updateDataJson(args.localId, p.toJsonString());
      state = state.copyWith(
        loading: false,
        payload: _recompute(p),
        errors: const [],
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  CartillaPackingQualityPayload _recompute(CartillaPackingQualityPayload p) {
    if (args.templateKey != 'cartilla_packing_recepcion_uva_calidad') return p;
    final b = Map<String, dynamic>.from(p.body);
    double n(dynamic x) => x is num
        ? x.toDouble()
        : double.tryParse('${x ?? ''}'.replaceAll(',', '.')) ?? 0;
    final j = int.tryParse('${b['numeroJabas'] ?? ''}') ?? 0;
    b['pesoPorJaba'] = j > 0
        ? double.parse((n(b['pesoNeto']) / j).toStringAsFixed(2))
        : 0.0;
    return p.copyWith(body: b);
  }

  void update(CartillaPackingQualityPayload p) =>
      state = state.copyWith(payload: _recompute(p), errors: const []);
  @override
  Future<void> saveLocal() async {
    final h = await attachGeo(ref, state.payload.header);
    final p = _recompute(state.payload.copyWith(header: h));
    state = state.copyWith(saving: true, payload: p);
    try {
      await local.saveLocal(
        localId: args.localId,
        data: p.toJson(),
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
    await local.markAsReadyForSync(args.localId);
  }

  @override
  Future<int> duplicateAsNew() async {
    await saveLocal();
    return local.duplicateAsNew(
      fromLocalId: args.localId,
      plusOneReplicableHeaderKeys: config.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: config.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> n) => update(
    CartillaPackingQualityPayload(
      payloadVersion:
          (n['payloadVersion'] as int?) ?? state.payload.payloadVersion,
      header:
          (n['header'] as Map?)?.cast<String, dynamic>() ??
          Map<String, dynamic>.from(state.payload.header),
      body:
          (n['body'] as Map?)?.cast<String, dynamic>() ??
          Map<String, dynamic>.from(state.payload.body),
    ),
  );
}
