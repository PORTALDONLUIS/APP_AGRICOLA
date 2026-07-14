import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/cartilla_report_registry.dart';
import '../../../../app/theme/donluis_theme.dart';
import '../../../../app/providers.dart';
import '../../../../features/master/presentation/master_providers.dart';
import '../../domain/report/cartilla_report_config.dart';
import '../../domain/report/cartilla_report_provider.dart';
import '../../../../shared/widgets/donluis_gradient_scaffold.dart';
import '../../../../shared/widgets/donluis_app_bar.dart';
import 'widgets/dynamic_report_table.dart';

class CartillaReportPage extends ConsumerStatefulWidget {
  final String templateKey;
  final DateTime day;
  final String plantillaNombre;

  const CartillaReportPage({
    super.key,
    required this.templateKey,
    required this.day,
    required this.plantillaNombre,
  });

  @override
  ConsumerState<CartillaReportPage> createState() => _CartillaReportPageState();
}

class _CartillaReportPageState extends ConsumerState<CartillaReportPage> {
  int _selectedReportIndex = 0;

  String _formatSharedValue(ReportColumnConfig col, dynamic value) {
    if (value == null) return '—';

    if (col.format == 'topicoMedicamentos') {
      return _formatTopicoMedicamentos(value, bulletList: false);
    }

    final isDecimalLike = col.format == 'decimal2' || col.format == 'percent2';
    if (isDecimalLike) {
      final parsed = _toNum(value);
      if (parsed != null) return parsed.toStringAsFixed(2);
    }

    if (value is num) {
      switch (col.format) {
        case 'int':
          return value.toInt().toString();
        case 'percent2':
        case 'decimal2':
          return value.toStringAsFixed(2);
        default:
          return value == value.toInt()
              ? value.toInt().toString()
              : value.toStringAsFixed(2);
      }
    }

    return value.toString();
  }

  String _formatTopicoValue(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  String _formatTopicoMedicamentos(dynamic value, {required bool bulletList}) {
    if (value is! Iterable || value is String) {
      final text = value?.toString().trim() ?? '';
      return text.isEmpty ? '-' : text;
    }

    final items = <String>[];
    for (final item in value) {
      if (item is Map) {
        final medicamento =
            '${item['medicamento'] ?? item['label'] ?? item['nombre'] ?? item['codigo'] ?? ''}'
                .trim();
        if (medicamento.isEmpty) continue;
        final cantidad = int.tryParse('${item['cantidad'] ?? 1}'.trim()) ?? 1;
        items.add('${bulletList ? '- ' : ''}$medicamento x$cantidad');
      } else {
        final text = '${item ?? ''}'.trim();
        if (text.isNotEmpty) items.add('${bulletList ? '- ' : ''}$text');
      }
    }

    if (items.isEmpty) return '-';
    return bulletList ? items.join('\n') : items.join(', ');
  }

  String _topicoShareText({
    required CartillaReportConfig config,
    required List<Map<String, dynamic>> rows,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Buen día, comparto el resumen diario de tópico:');
    buffer.writeln(
      'Reporte diario: ${config.title.isNotEmpty ? config.title : widget.plantillaNombre}',
    );
    buffer.writeln('Fecha: ${_formatDay(widget.day)}');
    buffer.writeln();

    for (final row in rows) {
      buffer.writeln('------------------------------');
      buffer.writeln('DNI: ${_formatTopicoValue(row['dni'])}');
      buffer.writeln(
        'Nombres y apellidos: ${_formatTopicoValue(row['pacienteNombre'])}',
      );
      buffer.writeln('Área: ${_formatTopicoValue(row['area'])}');
      buffer.writeln('Regimen: ${_formatTopicoValue(row['regimen'])}');
      buffer.writeln();
      buffer.writeln('Aptitud: ${_formatTopicoValue(row['aptitud'])}');
      buffer.writeln(
        'Tipo Atencion: ${_formatTopicoValue(row['tipoAtencion'])}',
      );
      buffer.writeln('Diagnostico / Observacion:');
      buffer.writeln('- ${_formatTopicoValue(row['diagnosticoObservacion'])}');
      buffer.writeln('Medicamentos:');
      buffer.writeln(
        _formatTopicoMedicamentos(row['medicamentos'], bulletList: true),
      );
      buffer.writeln();
    }

    return buffer.toString();
  }

  num? _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value.replaceAll(',', '.'));
    return null;
  }

  String _formatSharedMetricLabel(
    CartillaReportConfig config,
    ReportColumnConfig col,
  ) {
    if ((config.templateKey == 'cartilla_brotacion' ||
            config.templateKey == 'cartilla_long_brote_racimo') &&
        col.format == 'percent2') {
      return col.label.replaceFirst(RegExp(r'^\s*%\s*'), '');
    }

    return col.label;
  }

  String _formatSharedMetricValue(
    CartillaReportConfig config,
    ReportColumnConfig col,
    dynamic value,
  ) {
    final formattedValue = _formatSharedValue(col, value);

    if ((config.templateKey == 'cartilla_brotacion' ||
            config.templateKey == 'cartilla_long_brote_racimo') &&
        col.format == 'percent2') {
      return '$formattedValue %';
    }

    if (_isFitoReport(config)) {
      if (col.format == 'percent2') return _formatFitoSharedPercent(value);
      if (_isFitoGradeColumn(col)) return _formatFitoSharedGrade(value);
    }

    return formattedValue;
  }

  bool _isFitoReport(CartillaReportConfig config) {
    final normalized = config.templateKey.trim().toLowerCase().replaceAll(
      '-',
      '_',
    );
    return normalized == 'cartilla_fito' ||
        normalized == 'cartilla_fitosanidad';
  }

  bool _isFitoGradeColumn(ReportColumnConfig col) {
    final key = col.key.trim().toLowerCase();
    final label = col.label.trim().toLowerCase();
    return key.startsWith('grad') || label.startsWith('grad.');
  }

  bool _shouldShareMetricValue(CartillaReportConfig config, dynamic value) {
    if (value == null) return false;

    if (config.templateKey != 'cartilla_fito') return true;

    if (value is num) return value != 0;

    final normalized = value.toString().trim();
    if (normalized.isEmpty) return false;

    final numericValue = num.tryParse(normalized.replaceAll(',', '.'));
    if (numericValue != null) return numericValue != 0;

    return true;
  }

  List<List<ReportColumnConfig>> _shareMetricGroups(
    CartillaReportConfig config,
    List<ReportColumnConfig> visibleColumns,
  ) {
    if (config.templateKey == 'cartilla_long_brote_racimo') {
      final byKey = {for (final col in visibleColumns) col.key: col};
      if (config.reportKey == 'brote') {
        return [
          [
            for (final key in [
              'totalMuestras',
              'totalBrote',
              'promTotalBrote',
              'promLongitudBrote',
            ])
              if (byKey[key] != null) byKey[key]!,
          ],
          visibleColumns
              .where((col) => col.key.startsWith('sumBrote'))
              .toList(growable: false),
          visibleColumns
              .where((col) => col.key.startsWith('promBrote'))
              .toList(growable: false),
          visibleColumns
              .where((col) => col.key.startsWith('porcBrote'))
              .toList(growable: false),
        ].where((group) => group.isNotEmpty).toList(growable: false);
      }

      if (config.reportKey == 'racimo') {
        return [
          [
            for (final key in [
              'totalMuestras',
              'totalRacimo',
              'promTotalRacimo',
              'promLongitudRacimo',
            ])
              if (byKey[key] != null) byKey[key]!,
          ],
          visibleColumns
              .where((col) => col.key.startsWith('sumRacimo'))
              .toList(growable: false),
          visibleColumns
              .where((col) => col.key.startsWith('promRacimo'))
              .toList(growable: false),
          visibleColumns
              .where((col) => col.key.startsWith('porcRacimo'))
              .toList(growable: false),
        ].where((group) => group.isNotEmpty).toList(growable: false);
      }
    }

    if (config.templateKey != 'cartilla_brotacion') {
      return [visibleColumns];
    }

    const brotacionShareOrder = [
      ['totalMuestras'],
      [
        'porcYemaHinchada',
        'porcBotonAlgodonoso',
        'porcPuntaVerde',
        'porcHojasExtendidas',
        'porcYemasNecroticas',
      ],
      ['tBrotamiento'],
      [
        'acumYemaHinchada',
        'acumBotonAlgodonoso',
        'acumPuntaVerde',
        'acumHojasExtendidas',
        'acumYemasNecroticas',
        'acumTotalYemas',
      ],
    ];

    final byKey = {for (final col in visibleColumns) col.key: col};

    return brotacionShareOrder
        .map(
          (group) => [
            for (final key in group)
              if (byKey[key] != null) byKey[key]!,
          ],
        )
        .where((group) => group.isNotEmpty)
        .toList(growable: false);
  }

  Map<String, String> _readLoteIdToDescription() {
    final lotesAsync = ref.read(lotesStreamProvider);
    return lotesAsync.whenOrNull(
          data: (list) {
            final map = <String, String>{};
            for (final l in list) {
              map[l.idLote.toString()] = l.descripcion;
            }
            return map;
          },
        ) ??
        <String, String>{};
  }

  String? _findColumnKey(
    List<ReportColumnConfig> visibleColumns,
    Iterable<String> candidates,
  ) {
    for (final c in visibleColumns) {
      final key = c.key.toLowerCase();
      for (final cand in candidates) {
        if (key.contains(cand)) return c.key;
      }
    }
    return null;
  }

  Future<void> _shareReportRow(
    CartillaReportConfig config,
    Map<String, dynamic> row,
  ) async {
    if (config.templateKey == 'cartilla_long_brote_racimo') {
      final loteKey = _rowLoteKey(row);
      if (loteKey == null) return;
      await _shareLongBroteRacimoReport(loteKey: loteKey);
      return;
    }

    if (config.templateKey == 'cartilla_floracion_cuaja') {
      final loteKey = _rowLoteKey(row);
      if (loteKey == null) return;
      await _shareFloracionCuajaReport(config, [row], loteKey: loteKey);
      return;
    }

    final loteIdToDescription = _readLoteIdToDescription();
    final visibleColumns = config.columns
        .where((c) => !c.hidden)
        .toList(growable: false);
    if (visibleColumns.isEmpty) return;

    final loteColKey = _findColumnKey(visibleColumns, ['lote']);
    final sectorColKey = _findColumnKey(visibleColumns, ['sector']);
    final laborColKey = _findColumnKey(visibleColumns, [
      'labor',
      'actividad',
      'cartilla',
    ]);

    if (config.templateKey == 'cartilla_fito') {
      final userId = ref.read(currentUserIdProvider);
      await _shareFitoReportRowsByLote(
        config: config,
        rows: [row],
        loteIdToDescription: loteIdToDescription,
        loteColKey: loteColKey,
        sectorColKey: sectorColKey,
        laborColKey: laborColKey,
        userId: userId,
      );
      return;
    }

    if (config.templateKey == 'cartilla_topico') {
      await Share.share(
        _topicoShareText(config: config, rows: [row]),
        subject:
            'Reporte ${widget.plantillaNombre} - ${_formatDay(widget.day)}',
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('Buen día, comparto el reporte diario de la cartilla:');
    buffer.writeln(
      'Reporte diario: ${config.title.isNotEmpty ? config.title : widget.plantillaNombre}',
    );
    buffer.writeln('Fecha: ${_formatDay(widget.day)}');
    buffer.writeln();
    _writeSharedReportRows(
      buffer: buffer,
      config: config,
      rows: [row],
      visibleColumns: visibleColumns,
      loteIdToDescription: loteIdToDescription,
      loteColKey: loteColKey,
      sectorColKey: sectorColKey,
      laborColKey: laborColKey,
    );

    await Share.share(
      buffer.toString(),
      subject: 'Reporte ${widget.plantillaNombre} - ${_formatDay(widget.day)}',
    );
  }

  String? _rowLoteKey(Map<String, dynamic> row) {
    final direct = row['lote'];
    if (direct != null) return direct.toString();

    for (final entry in row.entries) {
      if (entry.key.toLowerCase().contains('lote') && entry.value != null) {
        return entry.value.toString();
      }
    }
    return null;
  }

  List<String> _rowLoteIds(Map<String, dynamic> row) {
    final rawIds = row['_loteIds'];
    if (rawIds is Iterable) {
      final ids = rawIds
          .map((id) => id?.toString().trim() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList(growable: false);
      if (ids.isNotEmpty) return ids;
    }

    final fallback = _rowLoteKey(row);
    return fallback == null || fallback.isEmpty ? const [] : [fallback];
  }

  void _writeSharedReportRows({
    required StringBuffer buffer,
    required CartillaReportConfig config,
    required List<Map<String, dynamic>> rows,
    required List<ReportColumnConfig> visibleColumns,
    required Map<String, String> loteIdToDescription,
    required String? loteColKey,
    required String? sectorColKey,
    required String? laborColKey,
  }) {
    for (final row in rows) {
      buffer.writeln('------------------------------');

      final loteVal = loteColKey != null ? row[loteColKey] : null;
      final loteDesc = loteVal != null
          ? (loteIdToDescription[loteVal.toString()] ?? loteVal.toString())
          : null;
      final sectorVal = sectorColKey != null
          ? row[sectorColKey]?.toString()
          : null;
      final laborVal = laborColKey != null
          ? row[laborColKey]?.toString()
          : null;

      if (laborVal != null && laborVal.isNotEmpty) {
        buffer.writeln('Labor : $laborVal');
      }
      if (sectorVal != null && sectorVal.isNotEmpty) {
        buffer.writeln('Sector : $sectorVal');
      }
      if (loteDesc != null && loteDesc.isNotEmpty) {
        buffer.writeln('Lote : $loteDesc');
      }

      buffer.writeln();
      buffer.writeln('Promedios / métricas:');
      final metricColumns = visibleColumns
          .where(
            (col) =>
                col.key != loteColKey &&
                col.key != sectorColKey &&
                col.key != laborColKey,
          )
          .toList(growable: false);
      final metricGroups = _shareMetricGroups(config, metricColumns);

      for (var groupIndex = 0; groupIndex < metricGroups.length; groupIndex++) {
        final group = metricGroups[groupIndex];
        var wroteGroupValue = false;
        for (final col in group) {
          final value = row[col.key];
          if (!_shouldShareMetricValue(config, value)) continue;
          buffer.writeln(
            '· ${_formatSharedMetricLabel(config, col)}: ${_formatSharedMetricValue(config, col, value)}',
          );
          wroteGroupValue = true;
        }
        if (wroteGroupValue && groupIndex < metricGroups.length - 1) {
          buffer.writeln();
        }
      }

      buffer.writeln();
    }
  }

  Future<void> _shareReport(CartillaReportConfig config) async {
    if (config.templateKey == 'cartilla_long_brote_racimo') {
      await _shareLongBroteRacimoReport();
      return;
    }

    final userId = ref.read(currentUserIdProvider);
    final request = CartillaReportRequest(
      templateKey: widget.templateKey,
      reportKey: config.reportKey,
      date: widget.day,
      userId: userId,
    );
    final asyncReport = ref.read(cartillaReportProvider(request));
    final rows = asyncReport.valueOrNull;
    if (rows == null || rows.isEmpty) return;

    if (config.templateKey == 'cartilla_floracion_cuaja') {
      await _shareFloracionCuajaReport(config, rows);
      return;
    }

    if (config.templateKey == 'cartilla_topico') {
      await Share.share(
        _topicoShareText(config: config, rows: rows),
        subject:
            'Reporte ${widget.plantillaNombre} - ${_formatDay(widget.day)}',
      );
      return;
    }

    final lotesAsync = ref.read(lotesStreamProvider);
    final loteIdToDescription =
        lotesAsync.whenOrNull(
          data: (list) {
            final map = <String, String>{};
            for (final l in list) {
              map[l.idLote.toString()] = l.descripcion;
            }
            return map;
          },
        ) ??
        <String, String>{};

    if (mounted) {
      final buffer = StringBuffer();

      // Encabezado tipo mensaje de WhatsApp
      buffer.writeln('Buen día, comparto el reporte diario de la cartilla:');
      buffer.writeln(
        'Reporte diario: ${config.title.isNotEmpty ? config.title : widget.plantillaNombre}',
      );
      buffer.writeln('Fecha: ${_formatDay(widget.day)}');
      buffer.writeln();

      final visibleColumns = config.columns
          .where((c) => !c.hidden)
          .toList(growable: false);
      if (visibleColumns.isEmpty) return;

      // Tratamos de identificar columnas claves por nombre
      String? findColumnKey(Iterable<String> candidates) {
        for (final c in visibleColumns) {
          final key = c.key.toLowerCase();
          for (final cand in candidates) {
            if (key.contains(cand)) return c.key;
          }
        }
        return null;
      }

      final loteColKey = findColumnKey(['lote']);
      final sectorColKey = findColumnKey(['sector']);
      final laborColKey = findColumnKey(['labor', 'actividad', 'cartilla']);

      if (config.templateKey == 'cartilla_fito') {
        await _shareFitoReportRowsByLote(
          config: config,
          rows: rows,
          loteIdToDescription: loteIdToDescription,
          loteColKey: loteColKey,
          sectorColKey: sectorColKey,
          laborColKey: laborColKey,
          userId: userId,
        );
        return;
      }

      for (final row in rows) {
        buffer.writeln('------------------------------');

        final loteVal = loteColKey != null ? row[loteColKey] : null;
        final loteDesc = loteVal != null
            ? (loteIdToDescription[loteVal.toString()] ?? loteVal.toString())
            : null;
        final sectorVal = sectorColKey != null
            ? row[sectorColKey]?.toString()
            : null;
        final laborVal = laborColKey != null
            ? row[laborColKey]?.toString()
            : null;

        if (laborVal != null && laborVal.isNotEmpty) {
          buffer.writeln('Labor : $laborVal');
        }
        if (sectorVal != null && sectorVal.isNotEmpty) {
          buffer.writeln('Sector : $sectorVal');
        }
        if (loteDesc != null && loteDesc.isNotEmpty) {
          buffer.writeln('Lote : $loteDesc');
        }

        buffer.writeln();
        buffer.writeln('Promedios / métricas:');
        final metricColumns = visibleColumns
            .where(
              (col) =>
                  col.key != loteColKey &&
                  col.key != sectorColKey &&
                  col.key != laborColKey,
            )
            .toList(growable: false);
        final metricGroups = _shareMetricGroups(config, metricColumns);

        for (
          var groupIndex = 0;
          groupIndex < metricGroups.length;
          groupIndex++
        ) {
          final group = metricGroups[groupIndex];
          var wroteGroupValue = false;
          for (final col in group) {
            final value = row[col.key];
            if (!_shouldShareMetricValue(config, value)) continue;
            buffer.writeln(
              '· ${_formatSharedMetricLabel(config, col)}: ${_formatSharedMetricValue(config, col, value)}',
            );
            wroteGroupValue = true;
          }
          if (wroteGroupValue && groupIndex < metricGroups.length - 1) {
            buffer.writeln();
          }
        }

        buffer.writeln();
      }

      await Share.share(
        buffer.toString(),
        subject:
            'Reporte ${widget.plantillaNombre} - ${_formatDay(widget.day)}',
      );
    }
  }

  Future<void> _shareFitoReportRowsByLote({
    required CartillaReportConfig config,
    required List<Map<String, dynamic>> rows,
    required Map<String, String> loteIdToDescription,
    required String? loteColKey,
    required String? sectorColKey,
    required String? laborColKey,
    required int userId,
  }) async {
    final buffer = StringBuffer();
    final local = ref.read(registrosLocalDSProvider);
    final registros = await local.getRegistrosForReport(
      templateKey: widget.templateKey,
      day: widget.day,
      userId: userId,
      allowedEstados: config.allowedEstados,
    );

    final observationsByLote = _collectFitoObservationsByLote(registros);

    // Encabezado tipo mensaje de WhatsApp
    buffer.writeln('Buen día, comparto el reporte diario de la cartilla:');
    buffer.writeln(
      'Reporte diario: ${config.title.isNotEmpty ? config.title : widget.plantillaNombre}',
    );
    buffer.writeln('Fecha: ${_formatDay(widget.day)}');
    buffer.writeln();

    for (final row in rows) {
      buffer.writeln('------------------------------');

      final loteVal = loteColKey != null ? row[loteColKey] : null;
      final loteDesc = loteVal != null
          ? (loteIdToDescription[loteVal.toString()] ?? loteVal.toString())
          : null;
      final loteKeys = _rowLoteIds(row);
      final sectorVal = sectorColKey != null
          ? row[sectorColKey]?.toString()
          : null;
      final laborVal = laborColKey != null
          ? row[laborColKey]?.toString()
          : null;

      if (laborVal != null && laborVal.isNotEmpty) {
        buffer.writeln('Labor : $laborVal');
      }
      if (sectorVal != null && sectorVal.isNotEmpty) {
        buffer.writeln('Sector : $sectorVal');
      }
      if (loteDesc != null && loteDesc.isNotEmpty) {
        buffer.writeln('Lote : $loteDesc');
      }

      buffer.writeln();
      buffer.writeln('Promedios / métricas:');

      final metricColumns = config.columns
          .where(
            (col) =>
                col.key != loteColKey &&
                col.key != sectorColKey &&
                col.key != laborColKey &&
                !col.hidden,
          )
          .toList(growable: false);

      _writeFitoSharedMetrics(
        buffer: buffer,
        config: config,
        row: row,
        metricColumns: metricColumns,
      );

      final observaciones = _collectObservationLinesForLotes(
        observationsByLote,
        loteKeys,
      );
      if (observaciones.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Observaciones');
        for (final obs in observaciones) {
          buffer.writeln('• $obs');
        }
      }

      buffer.writeln();
    }

    await Share.share(
      buffer.toString(),
      subject: 'Reporte ${widget.plantillaNombre} - ${_formatDay(widget.day)}',
    );
  }

  List<String> _collectObservationLinesForLotes(
    Map<String, List<String>> observationsByLote,
    List<String> loteKeys,
  ) {
    final seen = <String>{};
    final lines = <String>[];
    for (final loteKey in loteKeys) {
      final observations = observationsByLote[loteKey] ?? const <String>[];
      for (final obs in observations) {
        if (seen.add(obs)) lines.add(obs);
      }
    }
    return lines;
  }

  Map<String, List<String>> _collectFitoObservationsByLote(
    List<dynamic> registros,
  ) {
    final map = <String, List<String>>{};
    final seen = <String, Set<String>>{};

    for (final reg in registros) {
      final payload = reg.normalizedPayload();
      final header = payload['header'] as Map<String, dynamic>? ?? {};
      final loteId = header['loteId'];
      if (loteId == null) continue;

      final loteKey = loteId.toString();
      final body = payload['body'] as Map<String, dynamic>? ?? {};
      final rawObs = body['observaciones'];
      if (rawObs == null) continue;

      for (final line in _splitFitoObservations(rawObs.toString())) {
        final obs = _normalizeObservationLine(line);
        if (obs.isEmpty) continue;
        seen.putIfAbsent(loteKey, () => <String>{});
        if (seen[loteKey]!.add(obs)) {
          map.putIfAbsent(loteKey, () => <String>[]).add(obs);
        }
      }
    }

    return map;
  }

  void _writeFitoSharedMetrics({
    required StringBuffer buffer,
    required CartillaReportConfig config,
    required Map<String, dynamic> row,
    required List<ReportColumnConfig> metricColumns,
  }) {
    final promos = <String, ({ReportColumnConfig col, dynamic value})>{};
    final percents = <String, ({ReportColumnConfig col, dynamic value})>{};
    final grades = <String, ({ReportColumnConfig col, dynamic value})>{};

    for (final col in metricColumns) {
      final value = row[col.key];
      if (!_shouldShareMetricValue(config, value)) continue;

      final label = _fitoSharedMetricLabel(col.label);
      final base = _fitoSharedMetricBase(label);
      if (base == null) continue;

      if (_isFitoPromLabel(label)) {
        promos[base] = (col: col, value: value);
      } else if (_isFitoPercentLabel(label)) {
        percents[base] = (col: col, value: value);
      } else if (_isFitoGradeLabel(label)) {
        grades[base] = (col: col, value: value);
      }
    }

    final writtenCombined = <String>{};
    for (final col in metricColumns) {
      final value = row[col.key];
      if (!_shouldShareMetricValue(config, value)) continue;

      final label = _fitoSharedMetricLabel(col.label);
      final base = _fitoSharedMetricBase(label);
      final combinedCount = base == null
          ? 0
          : [
              promos.containsKey(base),
              grades.containsKey(base),
              percents.containsKey(base),
            ].where((exists) => exists).length;

      if (base != null && combinedCount > 1) {
        if (!writtenCombined.add(base)) continue;

        final values = <String>[];
        final prom = promos[base];
        final grade = grades[base];
        final percent = percents[base];

        if (prom != null) {
          values.add(_formatSharedMetricValue(config, prom.col, prom.value));
        }
        if (percent != null) {
          values.add(_formatFitoSharedPercent(percent.value));
        }
        if (grade != null) {
          values.add(_formatFitoSharedGrade(grade.value));
        }

        buffer.writeln('· $base  ${values.join('   ')}');
        continue;
      }

      buffer.writeln(
        '· $label: ${_formatSharedMetricValue(config, col, value)}',
      );
    }
  }

  String _fitoSharedMetricLabel(String label) {
    return label.replaceAll('FRUTOS', 'RACIMOS');
  }

  bool _isFitoPromLabel(String label) {
    return label.trimLeft().startsWith('Prom.');
  }

  bool _isFitoPercentLabel(String label) {
    return label.trimLeft().startsWith('%');
  }

  bool _isFitoGradeLabel(String label) {
    return label.trimLeft().startsWith('Grad.');
  }

  String? _fitoSharedMetricBase(String label) {
    final trimmed = label.trim();
    if (_isFitoPromLabel(trimmed)) {
      return trimmed.replaceFirst(RegExp(r'^\s*Prom\.\s*'), '').trim();
    }
    if (_isFitoPercentLabel(trimmed)) {
      return trimmed.replaceFirst(RegExp(r'^\s*%\s*'), '').trim();
    }
    if (_isFitoGradeLabel(trimmed)) {
      return trimmed.replaceFirst(RegExp(r'^\s*Grad\.\s*'), '').trim();
    }
    return null;
  }

  String _formatFitoSharedPercent(dynamic value) {
    final parsed = _toNum(value);
    if (parsed == null) {
      final text = value?.toString().trim() ?? '';
      return text.isEmpty ? '-' : '$text%';
    }

    return '${parsed.round()}%';
  }

  String _formatFitoSharedGrade(dynamic value) {
    final parsed = _toNum(value);
    if (parsed == null) {
      final text = value?.toString().trim() ?? '';
      return text.isEmpty ? '-' : '$text°';
    }

    return '${parsed.round()}°';
  }

  List<String> _splitFitoObservations(String raw) {
    final cleaned = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    if (cleaned.isEmpty) return const [];

    final lines = <String>[];
    final chunks = cleaned.split('\n');

    for (var chunk in chunks) {
      chunk = chunk.trim();
      if (chunk.isEmpty) continue;
      if (chunk.contains('•')) {
        for (final sub in chunk.split('•')) {
          final txt = sub.trim();
          if (txt.isNotEmpty) lines.add(txt);
        }
      } else if (chunk.contains('▪')) {
        for (final sub in chunk.split('▪')) {
          final txt = sub.trim();
          if (txt.isNotEmpty) lines.add(txt);
        }
      } else {
        lines.add(chunk);
      }
    }

    return lines;
  }

  String _normalizeObservationLine(String value) {
    return value.replaceAll(RegExp(r'^[\s•\-]+'), '').trim();
  }

  Future<void> _shareFloracionCuajaReport(
    CartillaReportConfig config,
    List<Map<String, dynamic>> rows, {
    String? loteKey,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    final local = ref.read(registrosLocalDSProvider);
    final registros = await local.getRegistrosForReport(
      templateKey: config.templateKey,
      day: widget.day,
      userId: userId,
      allowedEstados: config.allowedEstados,
    );
    final variedadIdToDescription = await _readVariedadIdToDescription();
    final moscatelByLote = _collectMoscatelByLote(
      registros,
      variedadIdToDescription,
    );
    final loteIdToDescription = _readLoteIdToDescription();
    final dateText = _formatDayNumeric(widget.day);

    final filteredRows = loteKey == null
        ? rows
        : rows
              .where((row) => _rowLoteKey(row) == loteKey)
              .toList(growable: false);
    if (filteredRows.isEmpty) return;

    final buffer = StringBuffer();
    for (var i = 0; i < filteredRows.length; i++) {
      final row = filteredRows[i];
      final key = _rowLoteKey(row);
      final loteIds = _rowLoteIds(row);
      final loteDesc = key == null ? '' : (loteIdToDescription[key] ?? key);
      final isMoscatel = loteIds.any((id) => moscatelByLote[id] ?? false);

      if (i > 0) {
        buffer.writeln();
        buffer.writeln('------------------------------');
        buffer.writeln();
      }

      if (isMoscatel) {
        _writeFloracionCuajaMoscatelShare(
          buffer: buffer,
          row: row,
          loteDesc: loteDesc,
          dateText: dateText,
        );
      } else {
        _writeFloracionCuajaRegularShare(
          buffer: buffer,
          row: row,
          loteDesc: loteDesc,
          dateText: dateText,
        );
      }
    }

    await Share.share(
      buffer.toString(),
      subject: 'Reporte ${widget.plantillaNombre} - ${_formatDay(widget.day)}',
    );
  }

  Future<Map<String, String>> _readVariedadIdToDescription() async {
    final variedades = await ref.read(masterLocalDsProvider).getVariedades();
    final map = <String, String>{};
    for (final variedad in variedades) {
      try {
        final json = (variedad as dynamic).toJson().cast<String, dynamic>();
        final id = json['id'] ?? json['ID'] ?? json['idVariedad'];
        final description = json['descripcion'] ?? json['DESCRIPCION'];
        if (id != null && description != null) {
          map[id.toString()] = description.toString();
        }
      } catch (_) {
        continue;
      }
    }
    return map;
  }

  Map<String, bool> _collectMoscatelByLote(
    List<dynamic> registros,
    Map<String, String> variedadIdToDescription,
  ) {
    final result = <String, bool>{};
    for (final reg in registros) {
      final payload = reg.normalizedPayload();
      final header = payload['header'] as Map<String, dynamic>? ?? {};
      final body = payload['body'] as Map<String, dynamic>? ?? {};
      final loteId = header['loteId'];
      if (loteId == null) continue;
      final loteKey = loteId.toString();
      final rawVariedad = body['variedad'] ?? header['variedad'];
      if (rawVariedad == null) {
        result.putIfAbsent(loteKey, () => false);
        continue;
      }
      final variedadText =
          variedadIdToDescription[rawVariedad.toString()] ??
          rawVariedad.toString();
      if (_isMoscatelText(variedadText)) {
        result[loteKey] = true;
      } else {
        result.putIfAbsent(loteKey, () => false);
      }
    }
    return result;
  }

  bool _isMoscatelText(String value) {
    final normalized = value
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[ÁÀÄÂ]'), 'A')
        .replaceAll(RegExp(r'[ÉÈËÊ]'), 'E')
        .replaceAll(RegExp(r'[ÍÌÏÎ]'), 'I')
        .replaceAll(RegExp(r'[ÓÒÖÔ]'), 'O')
        .replaceAll(RegExp(r'[ÚÙÜÛ]'), 'U');
    return normalized.contains('MOSCATEL');
  }

  void _writeFloracionCuajaMoscatelShare({
    required StringBuffer buffer,
    required Map<String, dynamic> row,
    required String loteDesc,
    required String dateText,
  }) {
    buffer.writeln('PORCENTAJE DE FLORACION');
    buffer.writeln('LOTE:  $loteDesc');
    buffer.writeln('FECHA: $dateText');
    buffer.writeln();
    buffer.writeln(
      'CALIPTRA HINCHADA:  PROMEDIO: ${_formatShareNumber(row['promCaliptraHinRacPlanta'])}',
    );
    for (final source in const [
      ('10', '10%'),
      ('20', '20%'),
      ('30', '30%'),
      ('40', '40%'),
      ('50', '50%'),
      ('60', '60%'),
      ('70', '70%'),
      ('80', '80%'),
      ('90', '90%'),
      ('100', '100%'),
    ]) {
      buffer.writeln(
        'FLORACION ${source.$2}:    PROMEDIO: ${_formatShareNumber(row['promP${source.$1}'])}',
      );
    }
    buffer.writeln('CUAJA: PROMEDIO: ${_formatShareNumber(row['promCuaja'])}');
    buffer.writeln();
    buffer.writeln();
    buffer.writeln(
      'PROM. RAC. ${_formatShareNumber(row['promTotalRacimosPlanta'])}',
    );

    final predominant = _predominantFloracion(row);
    if (predominant != null) {
      buffer.writeln(
        'Predomina ${predominant.label} con ${_formatShareNumber(predominant.count, decimals: 0)} racimos',
      );
    }
  }

  void _writeFloracionCuajaRegularShare({
    required StringBuffer buffer,
    required Map<String, dynamic> row,
    required String loteDesc,
    required String dateText,
  }) {
    buffer.writeln('PORCENTAJE DE FLORACION');
    buffer.writeln('LOTE:    $loteDesc');
    buffer.writeln('FECHA:   $dateText');
    buffer.writeln();
    buffer.writeln(
      'CALIPTRA HINCHADA:    ${_formatShareNumber(row['porcCaliptraHinRacPlanta'])}%',
    );
    buffer.writeln(
      'FLORACION:                      ${_formatShareNumber(row['porcFloracionPlanta'])}%',
    );
    buffer.writeln(
      'CUAJA:                                 ${_formatShareNumber(row['porcCuaja'])}',
    );
    buffer.writeln();
    buffer.writeln();
    buffer.writeln(
      'PROM. RAC. ${_formatShareNumber(row['promTotalRacimosPlanta'])}',
    );
  }

  ({String label, num count})? _predominantFloracion(Map<String, dynamic> row) {
    ({String label, num count})? best;
    for (final source in const [
      ('10', '10%'),
      ('20', '20%'),
      ('30', '30%'),
      ('40', '40%'),
      ('50', '50%'),
      ('60', '60%'),
      ('70', '70%'),
      ('80', '80%'),
      ('90', '90%'),
      ('100', '100%'),
    ]) {
      final count = _toNum(row['sumP${source.$1}']) ?? 0;
      if (best == null || count > best.count) {
        best = (label: source.$2, count: count);
      }
    }
    if (best == null || best.count <= 0) return null;
    return best;
  }

  String _formatShareNumber(dynamic value, {int decimals = 2}) {
    final parsed = _toNum(value);
    if (parsed == null) return '-';
    final fixed = parsed.toStringAsFixed(decimals);
    if (decimals == 0) return fixed;
    return fixed
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  Future<void> _shareLongBroteRacimoReport({String? loteKey}) async {
    final userId = ref.read(currentUserIdProvider);
    final broteConfig = CartillaReportRegistry.resolve(
      widget.templateKey,
      reportKey: 'brote',
    );
    final racimoConfig = CartillaReportRegistry.resolve(
      widget.templateKey,
      reportKey: 'racimo',
    );
    final broteRows = await ref.read(
      cartillaReportProvider(
        CartillaReportRequest(
          templateKey: widget.templateKey,
          reportKey: broteConfig.reportKey,
          date: widget.day,
          userId: userId,
        ),
      ).future,
    );
    final racimoRows = await ref.read(
      cartillaReportProvider(
        CartillaReportRequest(
          templateKey: widget.templateKey,
          reportKey: racimoConfig.reportKey,
          date: widget.day,
          userId: userId,
        ),
      ).future,
    );

    if (broteRows.isEmpty && racimoRows.isEmpty) return;

    final lotesAsync = ref.read(lotesStreamProvider);
    final loteIdToDescription =
        lotesAsync.whenOrNull(
          data: (list) {
            final map = <String, String>{};
            for (final l in list) {
              map[l.idLote.toString()] = l.descripcion;
            }
            return map;
          },
        ) ??
        <String, String>{};

    final racimoByLote = <String, Map<String, dynamic>>{
      for (final row in racimoRows)
        if (row['lote'] != null) row['lote'].toString(): row,
    };
    final allLoteKeys = <String>[
      for (final row in broteRows)
        if (row['lote'] != null) row['lote'].toString(),
      for (final row in racimoRows)
        if (row['lote'] != null &&
            !broteRows.any(
              (b) => b['lote']?.toString() == row['lote'].toString(),
            ))
          row['lote'].toString(),
    ];
    final loteKeys = loteKey == null
        ? allLoteKeys
        : allLoteKeys.where((key) => key == loteKey).toList(growable: false);
    if (loteKeys.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln('Buen día, comparto el reporte diario de la cartilla:');
    buffer.writeln('Reporte diario: ${broteConfig.title}');
    buffer.writeln('Fecha: ${_formatDay(widget.day)}');
    buffer.writeln();

    final dateText = _formatDayNumeric(widget.day);
    for (final loteKey in loteKeys) {
      Map<String, dynamic>? broteRow;
      for (final row in broteRows) {
        if (row['lote']?.toString() == loteKey) {
          broteRow = row;
          break;
        }
      }
      final racimoRow = racimoByLote[loteKey];
      final loteDesc = loteIdToDescription[loteKey] ?? loteKey;
      final promBrote = _formatCmValue(broteRow?['promLongitudBrote']);
      final promRacimo = _formatCmValue(racimoRow?['promLongitudRacimo']);

      buffer.writeln('------------------------------');
      buffer.writeln('LONGITUD DE BROTE');
      buffer.writeln('LOTE: $loteDesc');
      buffer.writeln('FECHA: $dateText');
      buffer.writeln();
      buffer.writeln('PROM. LONG. BROTE:  $promBrote');
      buffer.writeln();
      buffer.writeln('LONGITUD DE RACIMO');
      buffer.writeln();
      buffer.writeln('PROM. LONG. RAC.:  $promRacimo');
      buffer.writeln();
    }

    await Share.share(
      buffer.toString(),
      subject: 'Reporte ${widget.plantillaNombre} - ${_formatDay(widget.day)}',
    );
  }

  String _formatCmValue(dynamic value) {
    if (value is num) return '${value.toStringAsFixed(2)}cm';
    final parsed = num.tryParse(value?.toString() ?? '');
    if (parsed == null) return '-';
    return '${parsed.toStringAsFixed(2)}cm';
  }

  Widget _buildReportSelector(
    List<CartillaReportConfig> configs,
    int selectedIndex,
  ) {
    if (configs.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SegmentedButton<int>(
        showSelectedIcon: false,
        segments: [
          for (var i = 0; i < configs.length; i++)
            ButtonSegment<int>(
              value: i,
              label: Text(_reportOptionLabel(configs[i])),
            ),
        ],
        selected: {selectedIndex},
        onSelectionChanged: (selection) {
          if (selection.isEmpty) return;
          setState(() {
            _selectedReportIndex = selection.first;
          });
        },
      ),
    );
  }

  String _reportOptionLabel(CartillaReportConfig config) {
    switch (config.reportKey) {
      case 'brote':
        return 'Brote';
      case 'racimo':
        return 'Racimo';
      default:
        return config.title.isNotEmpty ? config.title : 'Reporte';
    }
  }

  @override
  Widget build(BuildContext context) {
    final configs = CartillaReportRegistry.tryResolveAll(widget.templateKey);
    if (configs.isEmpty) {
      return DonLuisGradientScaffold(
        appBar: DonLuisAppBar(title: Text(widget.plantillaNombre)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assessment_outlined,
                  size: 56,
                  color: DonLuisColors.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Esta cartilla aún no tiene un reporte configurado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: DonLuisColors.primary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final selectedIndex = _selectedReportIndex >= configs.length
        ? configs.length - 1
        : _selectedReportIndex;
    final config = configs[selectedIndex];
    final userId = ref.watch(currentUserIdProvider);
    final asyncReport = ref.watch(
      cartillaReportProvider(
        CartillaReportRequest(
          templateKey: widget.templateKey,
          reportKey: config.reportKey,
          date: widget.day,
          userId: userId,
        ),
      ),
    );
    final lotesAsync = ref.watch(lotesStreamProvider);
    final loteIdToDescription =
        lotesAsync.whenOrNull(
          data: (list) {
            final map = <String, String>{};
            for (final l in list) {
              map[l.idLote.toString()] = l.descripcion;
            }
            return map;
          },
        ) ??
        <String, String>{};

    return DonLuisGradientScaffold(
      appBar: DonLuisAppBar(
        title: Text(
          config.title.isNotEmpty ? config.title : widget.plantillaNombre,
        ),
        actions: [
          Builder(
            builder: (context) {
              final hasData =
                  asyncReport.hasValue &&
                  asyncReport.value != null &&
                  asyncReport.value!.isNotEmpty;
              if (!hasData) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Compartir reporte',
                onPressed: () async {
                  await _shareReport(config);
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportSelector(configs, selectedIndex),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _formatDay(widget.day),
                style: TextStyle(
                  fontSize: 13,
                  color: DonLuisColors.primary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: asyncReport.when(
                loading: () => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: DonLuisColors.primary,
                        strokeWidth: 2,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cargando reporte…',
                        style: TextStyle(
                          color: DonLuisColors.primary.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (e, st) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: DonLuisColors.primary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar el reporte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: DonLuisColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$e',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: DonLuisColors.primary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (rows) {
                  if (rows.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.table_chart_outlined,
                              size: 56,
                              color: DonLuisColors.primary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay datos para el reporte del día seleccionado',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: DonLuisColors.primary.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return DynamicReportTable(
                    config: config,
                    rows: rows,
                    loteIdToDescription: loteIdToDescription.isEmpty
                        ? null
                        : loteIdToDescription,
                    onShareRow: (row) => _shareReportRow(config, row),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDay(DateTime day) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${day.day} ${months[day.month - 1]} ${day.year}';
  }

  static String _formatDayNumeric(DateTime day) {
    final d = day.day.toString().padLeft(2, '0');
    final m = day.month.toString().padLeft(2, '0');
    return '$d-$m-${day.year}';
  }
}
