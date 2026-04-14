import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/cartilla_report_registry.dart';
import '../../../../app/theme/donluis_theme.dart';
import '../../../../app/providers.dart';
import '../../../../features/master/presentation/master_providers.dart';
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
  Future<void> _shareReport() async {
    final config = CartillaReportRegistry.tryResolve(widget.templateKey);
    if (config == null) return;

    final userId = ref.read(currentUserIdProvider);
    final request = CartillaReportRequest(
      templateKey: widget.templateKey,
      date: widget.day,
      userId: userId,
    );
    final asyncReport = ref.read(cartillaReportProvider(request));
    final rows = asyncReport.valueOrNull;
    if (rows == null || rows.isEmpty) return;

    final lotesAsync = ref.read(lotesStreamProvider);
    final loteIdToDescription = lotesAsync.whenOrNull(data: (list) {
      final map = <String, String>{};
      for (final l in list) {
        map[l.idLote.toString()] = l.descripcion;
      }
      return map;
    }) ?? <String, String>{};

    if (mounted) {
      final buffer = StringBuffer();

      // Encabezado tipo mensaje de WhatsApp
      buffer.writeln('Buenas tardes');
      buffer.writeln(
          'Reporte diario: ${config.title.isNotEmpty ? config.title : widget.plantillaNombre}');
      buffer.writeln('Fecha: ${_formatDay(widget.day)}');
      buffer.writeln();

      final visibleColumns =
          config.columns.where((c) => !c.hidden).toList(growable: false);
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

      if (config.displayTransposed) {
        final loteKey = config.groupBy.isNotEmpty
            ? config.groupBy.first.key
            : (loteColKey ?? 'lote');
        final metricCols = visibleColumns
            .where((c) => c.key != loteKey)
            .toList(growable: false);
        final sorted = List<Map<String, dynamic>>.from(rows);
        sorted.sort((a, b) {
          final sa = _shareLoteLabel(a[loteKey], loteIdToDescription);
          final sb = _shareLoteLabel(b[loteKey], loteIdToDescription);
          return sa.toLowerCase().compareTo(sb.toLowerCase());
        });
        buffer.writeln('Resumen (métrica × lote):');
        buffer.writeln();
        for (final col in metricCols) {
          buffer.writeln('· ${col.label}');
          for (final r in sorted) {
            final lotel = _shareLoteLabel(r[loteKey], loteIdToDescription);
            buffer.writeln(
                '  - $lotel: ${_shareFormatValue(col.format, r[col.key])}');
          }
          buffer.writeln();
        }
      } else {
        for (final row in rows) {
          buffer.writeln('------------------------------');

          final loteVal = loteColKey != null ? row[loteColKey] : null;
          final loteDesc = loteVal != null
              ? (loteIdToDescription[loteVal.toString()] ??
                  loteVal.toString())
              : null;
          final sectorVal =
              sectorColKey != null ? row[sectorColKey]?.toString() : null;
          final laborVal =
              laborColKey != null ? row[laborColKey]?.toString() : null;

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
          for (final col in visibleColumns) {
            if (col.key == loteColKey ||
                col.key == sectorColKey ||
                col.key == laborColKey) {
              continue;
            }
            final value = row[col.key];
            if (value == null) continue;
            buffer.writeln('· ${col.label}: $value');
          }

          buffer.writeln();
        }
      }

      await Share.share(
        buffer.toString(),
        subject:
            'Reporte ${widget.plantillaNombre} - ${_formatDay(widget.day)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = CartillaReportRegistry.tryResolve(widget.templateKey);
    if (config == null) {
      return DonLuisGradientScaffold(
        appBar: DonLuisAppBar(
          title: Text(widget.plantillaNombre),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assessment_outlined,
                  size: 56,
                  color: DonLuisColors.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Esta cartilla aún no tiene un reporte configurado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: DonLuisColors.primary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final userId = ref.watch(currentUserIdProvider);
    final asyncReport = ref.watch(
      cartillaReportProvider(
        CartillaReportRequest(
          templateKey: widget.templateKey,
          date: widget.day,
          userId: userId,
        ),
      ),
    );
    final lotesAsync = ref.watch(lotesStreamProvider);
    final loteIdToDescription = lotesAsync.whenOrNull(data: (list) {
      final map = <String, String>{};
      for (final l in list) {
        map[l.idLote.toString()] = l.descripcion;
      }
      return map;
    }) ?? <String, String>{};

    return DonLuisGradientScaffold(
      appBar: DonLuisAppBar(
        title: Text(
          config.title.isNotEmpty ? config.title : widget.plantillaNombre,
        ),
        actions: [
          Builder(
            builder: (context) {
              final hasData = asyncReport.hasValue &&
                  asyncReport.value != null &&
                  asyncReport.value!.isNotEmpty;
              if (!hasData) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Compartir reporte',
                onPressed: () async {
                  await _shareReport();
                },
              );
            },
          ),
        ],
      ),
      body: asyncReport.when(
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
                  color: DonLuisColors.primary.withOpacity(0.8),
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
                  color: DonLuisColors.primary.withOpacity(0.8),
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
                    color: DonLuisColors.primary.withOpacity(0.8),
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
                      color: DonLuisColors.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay datos para el reporte del día seleccionado',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: DonLuisColors.primary.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDay(widget.day),
                      style: TextStyle(
                        fontSize: 13,
                        color: DonLuisColors.primary.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _formatDay(widget.day),
                      style: TextStyle(
                        fontSize: 13,
                        color: DonLuisColors.primary.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: DynamicReportTable(
                      config: config,
                      rows: rows,
                      loteIdToDescription: loteIdToDescription.isEmpty
                          ? null
                          : loteIdToDescription,
                    ),
                  ),
                ],
              ),
            );
        },
      ),
    );
  }

  static String _shareLoteLabel(
    dynamic loteVal,
    Map<String, String> loteIdToDescription,
  ) {
    if (loteVal == null) return '—';
    final k = loteVal.toString().trim();
    if (k.isEmpty) return '—';
    final desc = loteIdToDescription[k];
    if (desc != null && desc.isNotEmpty) return desc;
    return k;
  }

  static String _shareFormatValue(String? format, dynamic value) {
    if (value == null) return '—';
    if (value is num) {
      switch (format) {
        case 'int':
          return value.toInt().toString();
        case 'percent2':
        case 'decimal2':
          return value.toStringAsFixed(2);
        default:
          return value.toString();
      }
    }
    return value.toString();
  }

  static String _formatDay(DateTime day) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${day.day} ${months[day.month - 1]} ${day.year}';
  }
}
