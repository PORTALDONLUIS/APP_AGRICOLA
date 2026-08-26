import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_brix_moscatel_config.dart';

final cartillaBrixMoscatelReportConfig = CartillaReportConfig(
  templateKey: CartillaBrixMoscatelConfig.templateKeyStatic,
  title: 'BRIX MOSCATEL',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: const [
    ReportGroupByConfig(key: 'lote', label: 'Lote', path: 'header.loteId'),
  ],
  columns: const [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.loteId',
    ),
    ReportColumnConfig.metric(
      key: 'promBrixSsc',
      label: 'Prom',
      path: 'body.brixSsc',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'minBrixSsc',
      label: 'Mínimo',
      path: 'body.brixSsc',
      aggregation: ReportAggregationType.minimum,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'maxBrixSsc',
      label: 'Máximo',
      path: 'body.brixSsc',
      aggregation: ReportAggregationType.maximum,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'mayorDe16',
      label: 'Mayor de 16',
      path: 'body.brixSsc',
      aggregation: ReportAggregationType.countRows,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'promRac',
      label: 'Prom rac',
      path: 'body.brixSsc',
      aggregation: ReportAggregationType.countRows,
      format: 'decimal2',
    ),
  ],
);
