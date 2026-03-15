import 'package:flutter/material.dart';

import 'package:donluis_forms/app/theme/donluis_theme.dart';
import 'package:donluis_forms/features/cartillas/domain/report/cartilla_report_config.dart';

class DynamicReportTable extends StatelessWidget {
  final CartillaReportConfig config;
  final List<Map<String, dynamic>> rows;
  final Map<String, String>? loteIdToDescription;

  const DynamicReportTable({
    super.key,
    required this.config,
    required this.rows,
    this.loteIdToDescription,
  });

  @override
  Widget build(BuildContext context) {
    final visibleColumns =
        config.columns.where((c) => !c.hidden).toList(growable: false);

    if (visibleColumns.isEmpty) {
      return Center(
        child: Text(
          'No hay columnas configuradas.',
          style: TextStyle(color: DonLuisColors.primary.withOpacity(0.8)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: DonLuisColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Theme(
            data: Theme.of(context).copyWith(
              dataTableTheme: DataTableThemeData(
                headingRowColor: MaterialStateProperty.all(
                  DonLuisColors.primary.withOpacity(0.08),
                ),
                dataRowColor: MaterialStateProperty.resolveWith((states) {
                  return null;
                }),
                headingTextStyle: const TextStyle(
                  color: DonLuisColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                dataTextStyle: const TextStyle(
                  color: Color(0xFF1A1D21),
                  fontSize: 13,
                ),
                dividerThickness: 1,
                horizontalMargin: 16,
                columnSpacing: 20,
              ),
            ),
            child: DataTable(
              headingRowHeight: 48,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 56,
              columns: [
                for (final col in visibleColumns)
                  DataColumn(
                    label: Text(
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
                    color: MaterialStateProperty.all(
                      i.isEven
                          ? DonLuisColors.surfaceCard
                          : DonLuisColors.surface.withOpacity(0.6),
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
          ),
        ),
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
  if (col.key == 'lote' &&
      loteIdToDescription != null &&
      value != null) {
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
