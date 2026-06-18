import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_packing_descarte_calidad_config.dart';
import '../../domain/cartilla_packing_descarte_calidad_payload.dart';

class CartillaPackingDescarteCalidadFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaPackingDescarteCalidadPayload payload;
  final List<String> errors;

  const CartillaPackingDescarteCalidadFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaPackingDescarteCalidadFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaPackingDescarteCalidadPayload? payload,
    List<String>? errors,
  }) {
    return CartillaPackingDescarteCalidadFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaPackingDescarteCalidadFormProvider =
    StateNotifierProvider.family<
      CartillaPackingDescarteCalidadFormNotifier,
      CartillaPackingDescarteCalidadFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);
      return CartillaPackingDescarteCalidadFormNotifier(
        ref: ref,
        localId: localId,
        local: local,
      )..load();
    });

class CartillaPackingDescarteCalidadFormNotifier
    extends StateNotifier<CartillaPackingDescarteCalidadFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaPackingDescarteCalidadFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(
         CartillaPackingDescarteCalidadFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaPackingDescarteCalidadPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);
      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaPackingDescarteCalidadPayload payload;
      if (isEmptyJson) {
        payload = CartillaPackingDescarteCalidadPayload.empty();
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

        await local.updateDataJson(localId, payload.toJsonString());
      } else {
        payload = CartillaPackingDescarteCalidadPayload.fromJsonString(raw);
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

  void update(CartillaPackingDescarteCalidadPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaPackingDescarteCalidadPayload _recompute(
    CartillaPackingDescarteCalidadPayload p,
  ) {
    final body = Map<String, dynamic>.from(p.body);

    int asNonNegativeInt(dynamic value) {
      if (value == null || '$value'.trim().isEmpty) return 0;
      final parsed = value is num ? value.toInt() : int.tryParse('$value');
      if (parsed == null) return 0;
      return parsed < 0 ? 0 : parsed;
    }

    double? asNonNegativeDoubleOrNull(dynamic value) {
      if (value == null || '$value'.trim().isEmpty) return null;
      final parsed = value is num
          ? value.toDouble()
          : double.tryParse('$value'.replaceAll(',', '.'));
      if (parsed == null) return null;
      return parsed < 0 ? 0 : parsed;
    }

    var nBinesTotal = 0;
    for (final key in CartillaPackingDescarteCalidadConfig.guideBinesKeys) {
      final normalized = asNonNegativeInt(body[key]);
      body[key] = normalized;
      nBinesTotal += normalized;
    }

    var pesoNetoTotal = 0.0;
    for (final key in CartillaPackingDescarteCalidadConfig.guidePesoNetoKeys) {
      final normalized = asNonNegativeDoubleOrNull(body[key]);
      body[key] = normalized;
      pesoNetoTotal += normalized ?? 0;
    }

    body[CartillaPackingDescarteCalidadConfig.kNBinesTotal] = nBinesTotal;
    body[CartillaPackingDescarteCalidadConfig.kPesoNetoTotal] = double.parse(
      pesoNetoTotal.toStringAsFixed(2),
    );

    final descartePesoNetoTotal = asNonNegativeDoubleOrNull(
      body[CartillaPackingDescarteCalidadConfig.kDescartePesoNetoTotal],
    );
    body[CartillaPackingDescarteCalidadConfig.kDescartePesoNetoTotal] =
        descartePesoNetoTotal;
    body[CartillaPackingDescarteCalidadConfig.kPorcentajeDescarte] =
        pesoNetoTotal == 0 || descartePesoNetoTotal == null
        ? 0.0
        : double.parse(
            ((descartePesoNetoTotal * 100) / pesoNetoTotal).toStringAsFixed(2),
          );

    for (final key in CartillaPackingDescarteCalidadConfig.defectCounterKeys) {
      body[key] = asNonNegativeInt(body[key]);
    }

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
    final cfg = CartillaPackingDescarteCalidadConfig();

    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    final payload = CartillaPackingDescarteCalidadPayload(
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
