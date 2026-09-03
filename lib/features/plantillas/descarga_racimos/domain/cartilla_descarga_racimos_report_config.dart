import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_descarga_racimos_config.dart';

final cartillaDescargaRacimosReportConfig = CartillaReportConfig(
  templateKey: CartillaDescargaRacimosConfig.templateKeyStatic,
  title: 'DESCARGA RACIMOS',
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
      key: 'promRacimos',
      label: 'Prom. de Racimos',
      path: 'body.totalRacimo',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
  ],
);
