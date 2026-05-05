import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donluis_forms/features/cartillas/domain/report/cartilla_report_config.dart';
import 'package:donluis_forms/app/cartilla_report_registry.dart';
import 'package:donluis_forms/features/registros/domain/registro.dart';
import 'package:donluis_forms/app/providers.dart';

final cartillaReportProvider =
    FutureProvider.family<List<Map<String, dynamic>>, CartillaReportRequest>((
      ref,
      request,
    ) async {
      final config = CartillaReportRegistry.resolve(request.templateKey);
      final local = ref.read(registrosLocalDSProvider);

      final registros = await local.getRegistrosForReport(
        templateKey: request.templateKey,
        day: request.date,
        userId: request.userId,
        allowedEstados: config.allowedEstados,
      );

      if (config.groupBy.isEmpty) return _buildRowsNoGroup(config, registros);

      final groupPath = config.groupBy.first.path;
      final Map<String, List<Map<String, dynamic>>> grupos = {};

      for (final r in registros) {
        final payload = r.normalizedPayload();
        final groupKey = _getByPath(payload, groupPath)?.toString() ?? '';
        grupos.putIfAbsent(groupKey, () => []).add(payload);
      }

      final List<Map<String, dynamic>> rows = [];

      for (final entry in grupos.entries) {
        final groupKey = entry.key;
        final items = entry.value;

        final Map<String, dynamic> row = {};
        for (final col in config.columns) {
          if (col.hidden) continue;
          switch (col.kind) {
            case ReportColumnKind.dimension:
              row[col.key] = groupKey;
              break;
            case ReportColumnKind.metric:
              row[col.key] = _aggregate(config, col, items);
              break;
            case ReportColumnKind.computed:
              // computed se resuelve después de tener todas las metric/dimension
              break;
          }
        }

        for (final col in config.columns) {
          if (col.hidden) continue;
          if (col.kind == ReportColumnKind.computed &&
              col.computation != null) {
            row[col.key] = _compute(col.computation!, row);
          }
        }

        rows.add(row);
      }

      return rows;
    });

num _round2(num value) {
  return (value * 100).round() / 100;
}

List<Map<String, dynamic>> _buildRowsNoGroup(
  CartillaReportConfig config,
  List<Registro> registros,
) {
  final payloads = registros.map((r) => r.normalizedPayload()).toList();
  final Map<String, dynamic> row = {};
  for (final col in config.columns) {
    if (col.hidden) continue;
    switch (col.kind) {
      case ReportColumnKind.dimension:
        row[col.key] = col.path != null
            ? _getByPath(payloads.isNotEmpty ? payloads.first : {}, col.path!)
            : null;
        break;
      case ReportColumnKind.metric:
        row[col.key] = _aggregate(config, col, payloads);
        break;
      case ReportColumnKind.computed:
        break;
    }
  }
  for (final col in config.columns) {
    if (col.hidden) continue;
    if (col.kind == ReportColumnKind.computed && col.computation != null) {
      row[col.key] = _compute(col.computation!, row);
    }
  }
  return payloads.isEmpty ? [] : [row];
}

num _aggregate(
  CartillaReportConfig config,
  ReportColumnConfig col,
  List<Map<String, dynamic>> items,
) {
  final agg = col.aggregation;
  if (agg == null) return 0;
  switch (agg) {
    case ReportAggregationType.countRows:
      return items.length;
    case ReportAggregationType.sum:
      final path = col.path ?? '';
      num sum = 0;
      for (final el in items) {
        final v = _getByPath(el, path);
        if (v is num) sum += v;
      }
      return _round2(sum);
    case ReportAggregationType.average:
      final path = col.path ?? '';
      num sum = 0;
      var count = 0;
      for (final el in items) {
        final v = _getByPath(el, path);
        if (v is num) {
          sum += v;
          count++;
        }
      }
      if (count == 0) return 0;
      return _round2(sum / count);
  }
}

num _compute(ReportComputationConfig comp, Map<String, dynamic> row) {
  switch (comp.type) {
    case ReportComputationType.sumColumns:
      final keys = comp.sourceColumnKeys ?? [];
      num sum = 0;
      for (final k in keys) {
        final v = row[k];
        if (v is num) sum += v;
      }
      return _round2(sum);
    case ReportComputationType.percentage:
      final numVal = row[comp.numeratorColumnKey] is num
          ? (row[comp.numeratorColumnKey] as num)
          : 0;
      final denVal = row[comp.denominatorColumnKey] is num
          ? (row[comp.denominatorColumnKey] as num)
          : 0;
      if (denVal == 0) return 0;
      return _round2(numVal / denVal * 100);
    case ReportComputationType.divideColumns:
      final numVal = row[comp.numeratorColumnKey] is num
          ? (row[comp.numeratorColumnKey] as num)
          : 0;
      final denVal = row[comp.denominatorColumnKey] is num
          ? (row[comp.denominatorColumnKey] as num)
          : 0;
      if (denVal == 0) return 0;
      return _round2(numVal / denVal);
  }
}

dynamic _getByPath(Map<String, dynamic> payload, String path) {
  final parts = path.split('.');
  dynamic current = payload;
  for (final p in parts) {
    if (current is! Map<String, dynamic>) return null;
    current = current[p];
  }
  return current;
}

class CartillaReportRequest {
  final String templateKey;
  final DateTime date;
  final int userId;

  const CartillaReportRequest({
    required this.templateKey,
    required this.date,
    required this.userId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartillaReportRequest &&
          templateKey == other.templateKey &&
          date == other.date &&
          userId == other.userId;

  @override
  int get hashCode => Object.hash(templateKey, date, userId);
}
