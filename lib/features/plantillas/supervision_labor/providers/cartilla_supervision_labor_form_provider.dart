import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/sync/sync_models.dart';
import '../../../cartillas/application/cartilla_form_contract.dart';
import '../../../registros/data/registros_local_ds.dart';
import '../domain/cartilla_supervision_labor_config.dart';
import '../domain/cartilla_supervision_labor_payload.dart';

class CartillaSupervisionLaborFormState {
  final int localId;
  final bool loading;
  final bool saving;
  final CartillaSupervisionLaborPayload payload;
  final List<String> errors;

  const CartillaSupervisionLaborFormState({
    required this.localId,
    required this.loading,
    required this.saving,
    required this.payload,
    required this.errors,
  });

  CartillaSupervisionLaborFormState copyWith({
    bool? loading,
    bool? saving,
    CartillaSupervisionLaborPayload? payload,
    List<String>? errors,
  }) {
    return CartillaSupervisionLaborFormState(
      localId: localId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      payload: payload ?? this.payload,
      errors: errors ?? this.errors,
    );
  }
}

final cartillaSupervisionLaborFormProvider =
    StateNotifierProvider.family<
      CartillaSupervisionLaborFormNotifier,
      CartillaSupervisionLaborFormState,
      int
    >((ref, localId) {
      final local = ref.read(registrosLocalDSProvider);

      return CartillaSupervisionLaborFormNotifier(
        localId: localId,
        local: local,
      )..load();
    });

class CartillaSupervisionLaborFormNotifier
    extends StateNotifier<CartillaSupervisionLaborFormState>
    implements CartillaFormNotifierBase {
  final int localId;
  final RegistrosLocalDS local;

  CartillaSupervisionLaborFormNotifier({
    required this.localId,
    required this.local,
  }) : super(
         CartillaSupervisionLaborFormState(
           localId: localId,
           loading: true,
           saving: false,
           payload: CartillaSupervisionLaborPayload.empty(),
           errors: const [],
         ),
       );

  Future<void> load() async {
    state = state.copyWith(loading: true);

    try {
      final reg = await local.getByLocalId(localId);

      debugPrint('🟦 SUPERVISION_LABOR load localId=$localId');
      debugPrint('🟦 SUPERVISION_LABOR dataJsonLen=${reg.dataJson.length}');

      final raw = reg.dataJson.trim();
      final isEmptyJson = raw.isEmpty || raw == '{}' || raw == 'null';

      CartillaSupervisionLaborPayload payload;

      if (isEmptyJson) {
        payload = CartillaSupervisionLaborPayload.empty();

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
        payload = CartillaSupervisionLaborPayload.fromJsonString(raw);
      }

      state = state.copyWith(
        loading: false,
        payload: _recompute(payload),
        errors: const [],
      );
    } catch (e) {
      debugPrint('🟥 SUPERVISION_LABOR load ERROR: $e');
      state = state.copyWith(loading: false);
    }
  }

  void update(CartillaSupervisionLaborPayload payload) {
    state = state.copyWith(payload: _recompute(payload), errors: const []);
  }

  CartillaSupervisionLaborPayload _recompute(
    CartillaSupervisionLaborPayload p,
  ) {
    final body = Map<String, dynamic>.from(p.body);

    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    bool hasWorker(int i) {
      final nombre = body['trabajador${i}_nombre'];
      final dni = body['trabajador${i}_dni'];
      final rows = body['trabajador${i}_hileras'];

      return (nombre != null && nombre.toString().trim().isNotEmpty) ||
          (dni != null && dni.toString().trim().isNotEmpty) ||
          (rows is List && rows.isNotEmpty);
    }

    List<Map<String, dynamic>> workerRows(int i) {
      final rawRows = body['trabajador${i}_hileras'];
      if (rawRows is List && rawRows.isNotEmpty) {
        return rawRows
            .whereType<dynamic>()
            .map(
              (row) => row is Map
                  ? Map<String, dynamic>.from(row)
                  : <String, dynamic>{},
            )
            .where((row) => row.isNotEmpty)
            .toList();
      }

      final hasLegacyRow =
          asInt(body['trabajador${i}_hilera']) > 0 ||
          asInt(body['trabajador${i}_plantasInicio']) > 0 ||
          asInt(body['trabajador${i}_plantasFinal']) > 0 ||
          asInt(body['trabajador${i}_plantasRacimoRechazado']) > 0;

      if (!hasLegacyRow) return <Map<String, dynamic>>[];

      return [
        {
          'hilera': body['trabajador${i}_hilera'],
          'plantasInicio': body['trabajador${i}_plantasInicio'],
          'plantasFinal': body['trabajador${i}_plantasFinal'],
          'plantasRacimoRechazado':
              body['trabajador${i}_plantasRacimoRechazado'],
        },
      ];
    }

    double totalGeneral = 0.0;
    int trabajadores = 0;

    for (var i = 1; i <= 6; i++) {
      final rows = workerRows(i);

      var subtotalTrabajador = 0.0;
      var totalTrabajador = 0.0;

      for (final row in rows) {
        final inicio = asInt(row['plantasInicio']);
        final fin = asInt(row['plantasFinal']);
        final rechazadas = asInt(row['plantasRacimoRechazado']);

        var subtotal = 0;

        if (inicio >= 0 && fin >= inicio) {
          subtotal = fin - inicio;
        }

        var total = subtotal - rechazadas;
        if (total < 0) total = 0;

        row['subtotal'] = subtotal.toDouble();
        row['total'] = total.toDouble();

        subtotalTrabajador += subtotal;
        totalTrabajador += total;
      }

      body['trabajador${i}_hileras'] = rows;
      body['trabajador${i}_subtotal'] = subtotalTrabajador;
      body['trabajador${i}_total'] = totalTrabajador;

      if (rows.isNotEmpty) {
        final first = rows.first;
        body['trabajador${i}_hilera'] = first['hilera'];
        body['trabajador${i}_plantasInicio'] = first['plantasInicio'];
        body['trabajador${i}_plantasFinal'] = first['plantasFinal'];
        body['trabajador${i}_plantasRacimoRechazado'] =
            first['plantasRacimoRechazado'];
      }

      totalGeneral += totalTrabajador;

      if (hasWorker(i)) {
        trabajadores++;
      }
    }

    final rendimiento = trabajadores == 0 ? 0.0 : totalGeneral / trabajadores;

    body['totalPlantasORacimos'] = totalGeneral;
    body['numeroTrabajadores'] = trabajadores.toDouble();
    body['rendimientoPromedioJornal'] = rendimiento;

    return p.copyWith(body: body);
  }

  @override
  Future<void> saveLocal() async {
    debugPrint('✅ SUPERVISION_LABOR saveLocal START localId=$localId');

    final fixed = _recompute(state.payload);

    debugPrint('🧾 ===== JSON BEFORE SAVE =====');
    debugPrint(jsonEncode(fixed.toJson()));
    debugPrint('🧾 ===== END JSON =====');

    state = state.copyWith(saving: true);

    try {
      state = state.copyWith(payload: fixed);

      await local.saveLocal(
        localId: localId,
        data: fixed.toJson(),
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.local,
      );

      debugPrint('✅ SUPERVISION_LABOR saveLocal DONE');
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

    final cfg = CartillaSupervisionLaborConfig();

    final newLocalId = await local.duplicateAsNew(
      fromLocalId: localId,
      plusOneReplicableHeaderKeys: cfg.plusOneReplicableHeaderKeys,
      plusOneReplicableBodyKeys: cfg.plusOneReplicableBodyKeys,
    );

    return newLocalId;
  }

  @override
  void updateDataJson(Map<String, dynamic> next) {
    // TODO
  }
}
