import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donluis_forms/features/cartillas/domain/report/cartilla_report_config.dart';
import 'package:donluis_forms/app/cartilla_report_registry.dart';
import 'package:donluis_forms/features/registros/domain/registro.dart';
import 'package:donluis_forms/app/providers.dart';
import 'package:donluis_forms/features/master/presentation/master_providers.dart';

final cartillaReportProvider =
    FutureProvider.family<List<Map<String, dynamic>>, CartillaReportRequest>((
      ref,
      request,
    ) async {
      final config = CartillaReportRegistry.resolve(
        request.templateKey,
        reportKey: request.reportKey,
      );
      final local = ref.read(registrosLocalDSProvider);

      final registros = await local.getRegistrosForReport(
        templateKey: request.templateKey,
        day: request.date,
        userId: request.userId,
        allowedEstados: config.allowedEstados,
      );

      if (config.groupBy.isEmpty) return _buildRowsNoGroup(config, registros);

      final groupLotesByName =
          config.dailyReport &&
          config.groupBy.any((group) => _isLoteGroupPath(group.path));
      final loteDescriptions = groupLotesByName
          ? await _readLoteDescriptions(ref)
          : const <String, String>{};
      final Map<String, _ReportGroupBucket> grupos = {};

      for (final r in registros) {
        final payload = _withReportMeta(r);
        final groupValues = <String, String>{};
        final groupKeys = <String>[];
        String? loteId;

        for (final group in config.groupBy) {
          final raw = _getByPath(payload, group.path)?.toString().trim() ?? '';
          final isLoteGroup = _isLoteGroupPath(group.path);
          final display = isLoteGroup
              ? (loteDescriptions[raw]?.trim().isNotEmpty == true
                    ? loteDescriptions[raw]!.trim()
                    : raw)
              : raw;
          final key = isLoteGroup && display.isNotEmpty
              ? _normalizeLoteDescription(display)
              : display;

          groupValues[group.key] = display;
          groupKeys.add('${group.key}=$key');
          if (isLoteGroup && raw.isNotEmpty) loteId = raw;
        }

        final groupKey = groupKeys.join('|');
        final bucket = grupos.putIfAbsent(
          groupKey,
          () => _ReportGroupBucket(groupValues: groupValues),
        );
        bucket.items.add(payload);
        if (loteId != null) bucket.loteIds.add(loteId);
      }

      final List<Map<String, dynamic>> rows = [];

      for (final entry in grupos.entries) {
        final bucket = entry.value;
        final items = bucket.items;

        final Map<String, dynamic> row = {};
        for (final col in config.columns) {
          switch (col.kind) {
            case ReportColumnKind.dimension:
              row[col.key] = _resolveDimensionValue(
                col: col,
                groupValues: bucket.groupValues,
                items: items,
              );
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
          if (col.kind == ReportColumnKind.computed &&
              col.computation != null) {
            row[col.key] = _compute(col.computation!, row);
          }
        }

        if (groupLotesByName) {
          row['_loteIds'] = bucket.loteIds.toList(growable: false);
          row['_loteGroupKey'] = entry.key;
        }

        rows.add(row);
      }

      return rows;
    });

Future<Map<String, String>> _readLoteDescriptions(Ref ref) async {
  final lotes = await ref.read(masterLocalDsProvider).watchLotes().first;
  return {
    for (final lote in lotes) lote.idLote.toString(): lote.descripcion.trim(),
  };
}

Map<String, dynamic> _withReportMeta(Registro registro) {
  return {
    ...registro.normalizedPayload(),
    '_meta': {
      'localId': registro.localId,
      'clientRecordId': registro.clientRecordId,
      'createdAt': registro.createdAt.toIso8601String(),
      'updatedAt': registro.updatedAt.toIso8601String(),
    },
  };
}

dynamic _resolveDimensionValue({
  required ReportColumnConfig col,
  required Map<String, String> groupValues,
  required List<Map<String, dynamic>> items,
}) {
  final path = col.path ?? '';
  if (groupValues.containsKey(col.key)) return groupValues[col.key];
  if (path.isEmpty) return null;
  if (items.isEmpty) return null;
  return _getByPath(items.first, path);
}

bool _isLoteGroupPath(String path) {
  final normalized = path.trim().toLowerCase();
  return normalized == 'header.loteid' ||
      normalized.endsWith('.loteid') ||
      normalized.endsWith('.lote_id');
}

String _normalizeLoteDescription(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
}

class _ReportGroupBucket {
  final Map<String, String> groupValues;
  final List<Map<String, dynamic>> items = [];
  final Set<String> loteIds = {};

  _ReportGroupBucket({required this.groupValues});
}

num _round2(num value) {
  return (value * 100).round() / 100;
}

List<Map<String, dynamic>> _buildRowsNoGroup(
  CartillaReportConfig config,
  List<Registro> registros,
) {
  final payloads = registros.map(_withReportMeta).toList();
  final Map<String, dynamic> row = {};
  for (final col in config.columns) {
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
      return items.length * col.multiplier;
    case ReportAggregationType.sum:
      final path = col.path ?? '';
      num sum = 0;
      for (final el in items) {
        final v = _coerceNum(_getByPath(el, path));
        if (v != null) sum += v * col.multiplier;
      }
      return _round2(sum);
    case ReportAggregationType.average:
      final path = col.path ?? '';
      num sum = 0;
      var count = 0;
      for (final el in items) {
        final v = _coerceNum(_getByPath(el, path));
        if (v != null && (!col.ignoreZeroForAverage || v != 0)) {
          sum += v;
          count++;
        }
      }
      if (count == 0) return 0;
      return _round2(sum / count);
    case ReportAggregationType.weightedAverage:
      final path = col.path ?? '';
      final weightPath = col.weightPath ?? '';
      num weightedSum = 0;
      num totalWeight = 0;
      for (final el in items) {
        final value = _coerceNum(_getByPath(el, path));
        final weight = _coerceNum(_getByPath(el, weightPath));
        if (value == null || weight == null || weight <= 0) continue;
        weightedSum += value * weight;
        totalWeight += weight;
      }
      if (totalWeight == 0) return 0;
      return _round2(weightedSum / totalWeight);
    case ReportAggregationType.countNonZero:
      final path = col.path ?? '';
      var count = 0;
      for (final el in items) {
        final v = _coerceNum(_getByPath(el, path));
        if (v != null && v != 0) count++;
      }
      return count;
  }
}

num? _coerceNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim());
  return null;
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
  final String? reportKey;
  final DateTime date;
  final int userId;

  const CartillaReportRequest({
    required this.templateKey,
    this.reportKey,
    required this.date,
    required this.userId,
  });

  String get normalizedTemplateKey =>
      templateKey.trim().toLowerCase().replaceAll('-', '_');

  String get normalizedReportKey => reportKey ?? '';

  DateTime get normalizedDate => DateTime(date.year, date.month, date.day);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartillaReportRequest &&
          normalizedTemplateKey == other.normalizedTemplateKey &&
          normalizedReportKey == other.normalizedReportKey &&
          normalizedDate == other.normalizedDate &&
          userId == other.userId;

  @override
  int get hashCode => Object.hash(
    normalizedTemplateKey,
    normalizedReportKey,
    normalizedDate,
    userId,
  );
}
