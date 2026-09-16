import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_fertilidad_config.dart';

final cartillaFertilidadReportConfig = CartillaReportConfig(
  templateKey: CartillaFertilidadConfig.templateKeyStatic,
  title: 'FERTILIDAD',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: const [
    ReportGroupByConfig(key: 'lote', label: 'Lote', path: 'header.loteId'),
  ],
  columns: const [
    ReportColumnConfig.dimension(key: 'lote', label: 'Lote', path: 'header.loteId'),
    ReportColumnConfig.metric(
      key: 'totalRacimosPercent',
      label: 'F (Total de racimos) %',
      path: 'body.yema1_parametros',
      aggregation: ReportAggregationType.countRows,
      format: 'percent2',
    ),
    ReportColumnConfig.metric(
      key: 'vPercent',
      label: 'V %',
      path: 'body.yema1_parametros',
      aggregation: ReportAggregationType.countRows,
      format: 'percent2',
    ),
    ReportColumnConfig.metric(
      key: 'viPercent',
      label: 'VI %',
      path: 'body.yema1_parametros',
      aggregation: ReportAggregationType.countRows,
      format: 'percent2',
    ),
    ReportColumnConfig.metric(
      key: 'nPercent',
      label: 'N %',
      path: 'body.yema1_parametros',
      aggregation: ReportAggregationType.countRows,
      format: 'percent2',
    ),
    ReportColumnConfig.metric(
      key: 'sPercent',
      label: 'S %',
      path: 'body.yema1_parametros',
      aggregation: ReportAggregationType.countRows,
      format: 'percent2',
    ),
    ReportColumnConfig.metric(
      key: 'madurasPercent',
      label: 'Y. madura %',
      path: 'body.yema1_catYema',
      aggregation: ReportAggregationType.countRows,
      format: 'percent2',
    ),
    ReportColumnConfig.metric(
      key: 'inmadurasPercent',
      label: 'Y. inmadura %',
      path: 'body.yema1_catYema',
      aggregation: ReportAggregationType.countRows,
      format: 'percent2',
    ),
  ],
);
