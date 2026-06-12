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

    return formattedValue;
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

  Future<void> _shareLongBroteRacimoReport() async {
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
    final loteKeys = <String>[
      for (final row in broteRows)
        if (row['lote'] != null) row['lote'].toString(),
      for (final row in racimoRows)
        if (row['lote'] != null &&
            !broteRows.any(
              (b) => b['lote']?.toString() == row['lote'].toString(),
            ))
          row['lote'].toString(),
    ];

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
      buffer.writeln('DDC:     -');
      buffer.writeln();
      buffer.writeln('PROM. LONG. BROTE:  $promBrote');
      buffer.writeln('TASA: -');
      buffer.writeln();
      buffer.writeln('LONGITUD DE RACIMO');
      buffer.writeln();
      buffer.writeln('PROM. LONG. RAC.:  $promRacimo');
      buffer.writeln('TASA: -');
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
