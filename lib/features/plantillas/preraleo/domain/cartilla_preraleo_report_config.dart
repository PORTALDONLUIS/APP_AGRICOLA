import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_preraleo_config.dart';

final cartillaPreraleoReportConfig = CartillaReportConfig(
  templateKey: CartillaPreraleoConfig.templateKeyStatic,
  title: 'PRE RALEO',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaPreraleoConfig.kLoteId}',
    ),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaPreraleoConfig.kLoteId}',
    ),
    ReportColumnConfig.metric(
      key: 'totalMuestras',
      label: 'Total de Muestras',
      path: 'header.${CartillaPreraleoConfig.kLoteId}',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    _averageMetric(
      key: 'promRgLong',
      label: 'Prom.RG Long',
      path: CartillaPreraleoConfig.kRacimoGrandeLong,
    ),
    _averageMetric(
      key: 'promRgNPisos',
      label: 'Prom.RG N.PISOS',
      path: CartillaPreraleoConfig.kRacimoGrandeNPisos,
    ),
    _averageMetric(
      key: 'promRpLong',
      label: 'Prom.Rp Long',
      path: CartillaPreraleoConfig.kRacimoPequenoLong,
    ),
    _averageMetric(
      key: 'promRpNPisos',
      label: 'Prom.RP N.PISOS',
      path: CartillaPreraleoConfig.kRacimoPequenoNPisos,
    ),
  ],
);

ReportColumnConfig _averageMetric({
  required String key,
  required String label,
  required String path,
}) {
  return ReportColumnConfig.metric(
    key: key,
    label: label,
    path: 'body.$path',
    aggregation: ReportAggregationType.average,
    format: 'decimal2',
  );
}
