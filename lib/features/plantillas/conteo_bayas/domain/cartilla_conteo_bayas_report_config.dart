import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_conteo_bayas_config.dart';

final cartillaConteoBayasReportConfig = CartillaReportConfig(
  templateKey: CartillaConteoBayasConfig.templateKeyStatic,
  title: 'CONTEO DE BAYAS',
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
      key: 'muestras',
      label: 'Muestras',
      path: 'header.loteId',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'promBayas',
      label: 'Prom. N.º Bayas',
      path: 'body.promNumeroBayas',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
  ],
);
