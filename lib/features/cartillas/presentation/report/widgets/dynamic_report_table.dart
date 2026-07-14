import 'package:flutter/material.dart';

import 'package:donluis_forms/app/theme/donluis_theme.dart';
import 'package:donluis_forms/features/cartillas/domain/report/cartilla_report_config.dart';

const double _kCaptureColumnWidth = 140;
const double _kCaptureRowHeight = 44;
const double _kCaptureHeaderHeight = 48;

class DynamicReportTable extends StatelessWidget {
  final CartillaReportConfig config;
  final List<Map<String, dynamic>> rows;
  final Map<String, String>? loteIdToDescription;
  final bool forCapture;
  final double? contentWidth;
  final double? contentHeight;
  final ValueChanged<Map<String, dynamic>>? onShareRow;

  const DynamicReportTable({
    super.key,
    required this.config,
    required this.rows,
    this.loteIdToDescription,
    this.forCapture = false,
    this.contentWidth,
    this.contentHeight,
    this.onShareRow,
  });

  static Size captureContentSize(int columnCount, int rowCount) {
    return Size(
      columnCount * _kCaptureColumnWidth,
      _kCaptureHeaderHeight + rowCount * _kCaptureRowHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleColumns = config.columns
        .where((c) => !c.hidden)
        .toList(growable: false);

    if (visibleColumns.isEmpty) {
      return Center(
        child: Text(
          'No hay columnas configuradas.',
          style: TextStyle(color: DonLuisColors.primary.withValues(alpha: 0.8)),
        ),
      );
    }

    final table = config.transposeMetrics
        ? _buildTransposedTable(context, visibleColumns)
        : _buildStandardTable(context, visibleColumns);

    Widget tableContent = Container(
      decoration: BoxDecoration(
        color: DonLuisColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: table,
    );

    if (forCapture &&
        contentWidth != null &&
        contentHeight != null &&
        contentWidth! > 0 &&
        contentHeight! > 0) {
      tableContent = SizedBox(
        width: contentWidth,
        height: contentHeight,
        child: tableContent,
      );
    } else if (!forCapture) {
      tableContent = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: tableContent,
        ),
      );
    }

    return tableContent;
  }

  Widget _buildStandardTable(
    BuildContext context,
    List<ReportColumnConfig> visibleColumns,
  ) {
    final showShareActions = !forCapture && onShareRow != null;
    final shareColumnIndex = _shareColumnAnchorIndex(visibleColumns);

    return Theme(
      data: _tableTheme(context),
      child: DataTable(
        headingRowHeight: 48,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 56,
        columns: [
          for (
            var colIndex = 0;
            colIndex < visibleColumns.length;
            colIndex++
          ) ...[
            DataColumn(
              label: forCapture
                  ? SizedBox(
                      width: _kCaptureColumnWidth - 24,
                      child: Text(
                        visibleColumns[colIndex].label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: DonLuisColors.primary,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    )
                  : Text(
                      visibleColumns[colIndex].label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: DonLuisColors.primary,
                      ),
                    ),
            ),
            if (showShareActions && colIndex == shareColumnIndex)
              _shareDataColumn(),
          ],
        ],
        rows: [
          for (var i = 0; i < rows.length; i++)
            DataRow(
              color: WidgetStateProperty.all(
                i.isEven
                    ? DonLuisColors.surfaceCard
                    : DonLuisColors.surface.withValues(alpha: 0.6),
              ),
              cells: [
                for (
                  var colIndex = 0;
                  colIndex < visibleColumns.length;
                  colIndex++
                ) ...[
                  DataCell(
                    Text(
                      _displayValue(
                        visibleColumns[colIndex],
                        rows[i],
                        templateKey: config.templateKey,
                        loteIdToDescription: loteIdToDescription,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  if (showShareActions && colIndex == shareColumnIndex)
                    _shareDataCell(rows[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }

  int _shareColumnAnchorIndex(List<ReportColumnConfig> visibleColumns) {
    if (visibleColumns.isEmpty) return -1;

    int findBy(Iterable<String> terms) {
      return visibleColumns.indexWhere((col) {
        final haystack = [
          col.key,
          col.label,
          col.path ?? '',
        ].join(' ').toLowerCase();
        return terms.any(haystack.contains);
      });
    }

    final loteIndex = findBy(const ['lote', 'fundo']);
    if (loteIndex >= 0) return loteIndex;

    final dimensionIndex = visibleColumns.indexWhere(
      (col) => col.kind == ReportColumnKind.dimension,
    );
    if (dimensionIndex >= 0) return dimensionIndex;

    return 0;
  }

  DataColumn _shareDataColumn() {
    return const DataColumn(
      label: SizedBox(width: 48, child: Text('', semanticsLabel: 'Compartir')),
    );
  }

  DataCell _shareDataCell(Map<String, dynamic> row) {
    return DataCell(
      _ShareLoteButton(size: 36, onPressed: () => onShareRow?.call(row)),
    );
  }

  Widget _buildTransposedTable(
    BuildContext context,
    List<ReportColumnConfig> visibleColumns,
  ) {
    final dimensionColumn = visibleColumns.firstWhere(
      (col) => col.kind == ReportColumnKind.dimension,
      orElse: () => visibleColumns.first,
    );
    final metricColumns = visibleColumns
        .where((col) => col.key != dimensionColumn.key)
        .toList(growable: false);

    final showShareActions = !forCapture && onShareRow != null;

    return Theme(
      data: _tableTheme(context),
      child: DataTable(
        headingRowHeight: showShareActions ? 64 : 52,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 68,
        columns: [
          DataColumn(
            label: SizedBox(
              width: forCapture ? _kCaptureColumnWidth : 190,
              child: const Text(
                'Concepto',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: DonLuisColors.primary,
                ),
              ),
            ),
          ),
          for (final row in rows)
            DataColumn(
              label: SizedBox(
                width: forCapture ? _kCaptureColumnWidth - 24 : 170,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        'Lote ${_displayValue(dimensionColumn, row, templateKey: config.templateKey, loteIdToDescription: loteIdToDescription)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: DonLuisColors.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                    if (showShareActions)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: _ShareLoteButton(
                          size: 32,
                          onPressed: () => onShareRow?.call(row),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
        rows: [
          for (var i = 0; i < metricColumns.length; i++)
            DataRow(
              color: WidgetStateProperty.all(
                i.isEven
                    ? DonLuisColors.surfaceCard
                    : DonLuisColors.surface.withValues(alpha: 0.6),
              ),
              cells: [
                DataCell(
                  SizedBox(
                    width: forCapture ? _kCaptureColumnWidth : 190,
                    child: Text(
                      metricColumns[i].label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                for (final row in rows)
                  DataCell(
                    SizedBox(
                      width: forCapture ? _kCaptureColumnWidth - 24 : 130,
                      child: Text(
                        _displayValue(
                          metricColumns[i],
                          row,
                          templateKey: config.templateKey,
                          loteIdToDescription: loteIdToDescription,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  ThemeData _tableTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(
          DonLuisColors.primary.withValues(alpha: 0.08),
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          return null;
        }),
        headingTextStyle: const TextStyle(
          color: DonLuisColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        dataTextStyle: const TextStyle(color: Color(0xFF1A1D21), fontSize: 13),
        dividerThickness: 1,
        horizontalMargin: 16,
        columnSpacing: 20,
      ),
    );
  }
}

class _ShareLoteButton extends StatelessWidget {
  final double size;
  final VoidCallback onPressed;

  const _ShareLoteButton({required this.size, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Compartir',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: DonLuisColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: DonLuisColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: DonLuisColors.primary.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.share,
              size: 18,
              color: DonLuisColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

String _displayValue(
  ReportColumnConfig col,
  Map<String, dynamic> row, {
  required String templateKey,
  Map<String, String>? loteIdToDescription,
}) {
  final value = row[col.key];
  if (col.key == 'lote' && loteIdToDescription != null && value != null) {
    final key = value.toString().trim();
    final desc = loteIdToDescription[key];
    if (desc != null && desc.isNotEmpty) return desc;
  }
  if (_isFitoTemplate(templateKey)) {
    return _formatFitoValue(col, value);
  }
  return _formatValue(col.format, value);
}

bool _isFitoTemplate(String templateKey) {
  final normalized = templateKey.trim().toLowerCase().replaceAll('-', '_');
  return normalized == 'cartilla_fito' || normalized == 'cartilla_fitosanidad';
}

bool _isFitoGradeColumn(ReportColumnConfig col) {
  final key = col.key.trim().toLowerCase();
  final label = col.label.trim().toLowerCase();
  return key.startsWith('grad') || label.startsWith('grad.');
}

String _formatFitoValue(ReportColumnConfig col, dynamic value) {
  if (value == null) return '—';
  final parsed = _toNum(value);
  if (parsed == null) return value.toString();

  if (col.format == 'percent2') return '${parsed.round()}%';
  if (_isFitoGradeColumn(col)) return '${parsed.round()}°';
  if (col.format == 'decimal2') return parsed.toStringAsFixed(2);
  if (col.format == 'int') return parsed.round().toString();

  return parsed == parsed.roundToDouble()
      ? parsed.round().toString()
      : parsed.toStringAsFixed(2);
}

String _formatValue(String? format, dynamic value) {
  if (value == null) return '—';

  if (format == 'topicoMedicamentos') {
    return _formatTopicoMedicamentos(value);
  }

  final isDecimalLike = format == 'decimal2' || format == 'percent2';
  if (isDecimalLike) {
    final parsed = _toNum(value);
    if (parsed != null) return parsed.toStringAsFixed(2);
  }

  if (value is num) {
    switch (format) {
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

String _formatTopicoMedicamentos(dynamic value) {
  if (value is! Iterable || value is String) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '—' : text;
  }

  final items = <String>[];
  for (final item in value) {
    if (item is Map) {
      final medicamento =
          '${item['medicamento'] ?? item['label'] ?? item['nombre'] ?? item['codigo'] ?? ''}'
              .trim();
      if (medicamento.isEmpty) continue;
      final cantidad = int.tryParse('${item['cantidad'] ?? 1}'.trim()) ?? 1;
      items.add('$medicamento x$cantidad');
    } else {
      final text = '${item ?? ''}'.trim();
      if (text.isNotEmpty) items.add(text);
    }
  }
  return items.isEmpty ? '—' : items.join(', ');
}

num? _toNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value.replaceAll(',', '.'));
  return null;
}
