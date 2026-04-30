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

  const DynamicReportTable({
    super.key,
    required this.config,
    required this.rows,
    this.loteIdToDescription,
    this.forCapture = false,
    this.contentWidth,
    this.contentHeight,
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
    return Theme(
      data: _tableTheme(context),
      child: DataTable(
        headingRowHeight: 48,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 56,
        columns: [
          for (final col in visibleColumns)
            DataColumn(
              label: forCapture
                  ? SizedBox(
                      width: _kCaptureColumnWidth - 24,
                      child: Text(
                        col.label,
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
                      col.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: DonLuisColors.primary,
                      ),
                    ),
            ),
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
                for (final col in visibleColumns)
                  DataCell(
                    Text(
                      _displayValue(
                        col,
                        rows[i],
                        loteIdToDescription: loteIdToDescription,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
        ],
      ),
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

    return Theme(
      data: _tableTheme(context),
      child: DataTable(
        headingRowHeight: 52,
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
                width: forCapture ? _kCaptureColumnWidth - 24 : 150,
                child: Text(
                  'Lote ${_displayValue(dimensionColumn, row, loteIdToDescription: loteIdToDescription)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: DonLuisColors.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
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
                      width: forCapture ? _kCaptureColumnWidth - 24 : 110,
                      child: Text(
                        _displayValue(
                          metricColumns[i],
                          row,
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

String _displayValue(
  ReportColumnConfig col,
  Map<String, dynamic> row, {
  Map<String, String>? loteIdToDescription,
}) {
  final value = row[col.key];
  if (col.key == 'lote' && loteIdToDescription != null && value != null) {
    final key = value.toString().trim();
    final desc = loteIdToDescription[key];
    if (desc != null && desc.isNotEmpty) return desc;
  }
  return _formatValue(col.format, value);
}

String _formatValue(String? format, dynamic value) {
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
