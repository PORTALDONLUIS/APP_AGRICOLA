import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_raleo_config.dart';

final cartillaRaleoReportConfig = CartillaReportConfig(
  templateKey: CartillaRaleoConfig.templateKeyStatic,
  title: 'RALEO',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaRaleoConfig.kLoteId}',
    ),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaRaleoConfig.kLoteId}',
    ),
    ReportColumnConfig.metric(
      key: 'totalMuestras',
      label: 'Total de Muestras',
      path: 'header.${CartillaRaleoConfig.kLoteId}',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    _averageMetric(
      key: 'aladoPromLong',
      label: 'Alado Prom. Long',
      path: CartillaRaleoConfig.kRaLongRacimo,
    ),
    _averageMetric(
      key: 'aladoPromBayas',
      label: 'Alado Prom N.Bayas',
      path: CartillaRaleoConfig.kRaNTotalBayas,
    ),
    _averageMetric(
      key: 'semiAladoPromLong',
      label: 'S.Alado Prom. Long',
      path: CartillaRaleoConfig.kRsLongRacimo,
    ),
    _averageMetric(
      key: 'semiAladoPromBayas',
      label: 'S.Alado Prom N.Bayas',
      path: CartillaRaleoConfig.kRsNTotalBayas,
    ),
    _averageMetric(
      key: 'atubadoPromLong',
      label: 'Atubado Prom. Long',
      path: CartillaRaleoConfig.kRatLongRacimo,
    ),
    _averageMetric(
      key: 'atubadoPromBayas',
      label: 'Atubado Prom. N.Bayas',
      path: CartillaRaleoConfig.kRatNTotalBayas,
    ),
    _averageMetric(
      key: 'pequenoPromLong',
      label: 'Pequeño Prom. Long',
      path: CartillaRaleoConfig.kRpLongRacimo,
    ),
    _averageMetric(
      key: 'pequenoPromBayas',
      label: 'Pequeño Prom. N.Bayas',
      path: CartillaRaleoConfig.kRpNTotalBayas,
    ),
    _averageMetric(
      key: 'pampanoPromLong',
      label: 'Pampano Prom. Long',
      path: CartillaRaleoConfig.kRpaLongRacimo,
    ),
    _averageMetric(
      key: 'pampanoPromBayas',
      label: 'Pampano Prom. N.Bayas',
      path: CartillaRaleoConfig.kRpaNTotalBayas,
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
