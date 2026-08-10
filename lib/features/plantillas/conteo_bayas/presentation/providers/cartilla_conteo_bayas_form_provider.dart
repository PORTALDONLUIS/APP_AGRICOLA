import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers.dart';
import '../../../../../core/mixins/geo_save_mixin.dart';
import '../../../../../core/sync/sync_models.dart';
import '../../../../cartillas/application/cartilla_form_contract.dart';
import '../../../../registros/data/registros_local_ds.dart';
import '../../domain/cartilla_conteo_bayas_config.dart';
import '../../domain/cartilla_conteo_bayas_payload.dart';

class CartillaConteoBayasFormState implements CartillaFormStateBase {
  final int localId;
  @override
  final bool loading;
  @override
  final bool saving;
  final CartillaConteoBayasPayload payload;
  @override
  final List<String> errors;

  const CartillaConteoBayasFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  @override
  Map<String, dynamic> get dataJson => payload.toJson();

  CartillaConteoBayasFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaConteoBayasPayload? payload,
    List<String>? errors,
  }) => CartillaConteoBayasFormState(
    localId: localId,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    payload: payload ?? this.payload,
    errors: errors ?? this.errors,
  );
}

final cartillaConteoBayasFormProvider = StateNotifierProvider.family<
    CartillaConteoBayasFormNotifier, CartillaConteoBayasFormState, int>(
  (ref, localId) => CartillaConteoBayasFormNotifier(
    ref: ref,
    localId: localId,
    local: ref.read(registrosLocalDSProvider),
  )..load(),
);

class CartillaConteoBayasFormNotifier
    extends StateNotifier<CartillaConteoBayasFormState>
    with GeoSaveMixin
    implements CartillaFormNotifierBase {
  final Ref ref;
  final int localId;
  final RegistrosLocalDS local;

  CartillaConteoBayasFormNotifier({
    required this.ref,
    required this.localId,
    required this.local,
  }) : super(CartillaConteoBayasFormState(
          localId: localId,
          loading: true,
          saving: false,
          payload: CartillaConteoBayasPayload.empty(),
          errors: const [],
        ));

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final reg = await local.getByLocalId(localId);
      final raw = reg.dataJson.trim();
      final isEmpty = raw.isEmpty || raw == '{}' || raw == 'null';
      var payload = isEmpty
          ? CartillaConteoBayasPayload.empty().copyWith(header: {
              ...CartillaConteoBayasPayload.empty().header,
              'plantillaId': reg.plantillaId,
              'userId': reg.userId,
              'loteId': reg.loteId,
              'lat': reg.lat,
              'lon': reg.lon,
            })
          : CartillaConteoBayasPayload.fromJsonString(raw);
      payload = _recompute(payload);
      if (isEmpty) await local.updateDataJson(localId, payload.toJsonString());
      state = state.copyWith(loading: false, payload: payload, errors: const []);
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  String _fechaActualPeru() {
    final now = DateTime.now().toUtc().subtract(const Duration(hours: 5));
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  double? _toPositiveDouble(dynamic value) {
    if (value == null || '$value'.trim().isEmpty) return null;
    final parsed = value is num
        ? value.toDouble()
        : double.tryParse(value.toString().replaceAll(',', '.'));
    return parsed == null ? null : (parsed < 0 ? 0 : parsed);
  }

  CartillaConteoBayasPayload _recompute(CartillaConteoBayasPayload payload) {
    final body = Map<String, dynamic>.from(payload.body);
    body[CartillaConteoBayasConfig.kFecha] ??= _fechaActualPeru();
    final longitudes = <double>[];
    final bayas = <double>[];
    for (var racimo = 1; racimo <= 50; racimo++) {
      final longitudKey = CartillaConteoBayasConfig.longitudCmKey(racimo);
      final bayasKey = CartillaConteoBayasConfig.numeroBayasKey(racimo);
      final longitud = _toPositiveDouble(body[longitudKey]);
      final numeroBayas = _toPositiveDouble(body[bayasKey]);
      body[longitudKey] = longitud;
      body[bayasKey] = (numeroBayas ?? 0).round();
      // Los ceros son el valor inicial de los controles. No participan hasta
      // que el usuario registre una medición positiva en ese racimo.
      if (longitud != null && longitud > 0) longitudes.add(longitud);
      if (numeroBayas != null && numeroBayas > 0) bayas.add(numeroBayas);
    }
    body[CartillaConteoBayasConfig.kPromLongitud] = longitudes.isEmpty
        ? 0.0
        : longitudes.reduce((a, b) => a + b) / longitudes.length;
    body[CartillaConteoBayasConfig.kPromNumeroBayas] = bayas.isEmpty
        ? 0.0
        : bayas.reduce((a, b) => a + b) / bayas.length;
    body['fotos'] = body['fotos'] is List ? body['fotos'] : <Map<String, dynamic>>[];
    return payload.copyWith(body: body);
  }

  void update(CartillaConteoBayasPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    update(CartillaConteoBayasPayload(
      payloadVersion: (next['payloadVersion'] as int?) ?? state.payload.payloadVersion,
      header: (next['header'] as Map?)?.cast<String, dynamic>() ?? state.payload.header,
      body: (next['body'] as Map?)?.cast<String, dynamic>() ?? state.payload.body,
    ));
  }

  @override
  Future<void> saveLocal() async {
    final fixed = _recompute(state.payload.copyWith(
      header: await attachGeo(ref, state.payload.header),
    ));
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
    final config = CartillaConteoBayasConfig();
    return local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: config.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: config.plusOneReplicableBodyKeys,
    );
  }
}
