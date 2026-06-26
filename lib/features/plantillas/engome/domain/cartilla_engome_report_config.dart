import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_engome_config.dart';

final cartillaEngomeReportConfig = CartillaReportConfig(
  templateKey: CartillaEngomeConfig.templateKeyStatic,
  title: 'ENGOME',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaEngomeConfig.kLoteId}',
    ),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaEngomeConfig.kLoteId}',
    ),
    ReportColumnConfig.metric(
      key: 'totalMuestras',
      label: 'Total de Muestras',
      path: 'header.${CartillaEngomeConfig.kLoteId}',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    _sumMetric(
      key: 'sumVerde',
      label: 'Acum. VERDE',
      path: CartillaEngomeConfig.kVerde,
      hidden: true,
    ),
    _sumMetric(
      key: 'sumEngome',
      label: 'Acum. ENGOME',
      path: CartillaEngomeConfig.kEngome,
      hidden: true,
    ),
    _sumMetric(
      key: 'sumPintaTotal',
      label: 'Acum. PINTA TOTAL',
      path: CartillaEngomeConfig.kPintaTotal,
      hidden: true,
    ),
    ReportColumnConfig.computed(
      key: 'porcVerde',
      label: 'VERDE',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'sumVerde',
        denominatorColumnKey: 'sumPintaTotal',
      ),
      format: 'percent2',
    ),
    ReportColumnConfig.computed(
      key: 'porcEngome',
      label: 'ENGOME',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'sumEngome',
        denominatorColumnKey: 'sumPintaTotal',
      ),
      format: 'percent2',
    ),
    ReportColumnConfig.computed(
      key: 'total',
      label: 'TOTAL',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: ['porcVerde', 'porcEngome'],
      ),
      format: 'percent2',
    ),
    _averageMetric(
      key: 'promVerde',
      label: 'Prom. VERDE',
      path: CartillaEngomeConfig.kVerde,
      hidden: true,
    ),
    _averageMetric(
      key: 'promEngome',
      label: 'Prom. ENGOME',
      path: CartillaEngomeConfig.kEngome,
      hidden: true,
    ),
    ReportColumnConfig.computed(
      key: 'promRacimos',
      label: 'PROM DE RACIMOS',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: ['promVerde', 'promEngome'],
      ),
      format: 'decimal2',
    ),
  ],
);

ReportColumnConfig _sumMetric({
  required String key,
  required String label,
  required String path,
  bool hidden = false,
}) {
  return ReportColumnConfig.metric(
    key: key,
    label: label,
    path: 'body.$path',
    aggregation: ReportAggregationType.sum,
    format: 'decimal2',
    hidden: hidden,
  );
}

ReportColumnConfig _averageMetric({
  required String key,
  required String label,
  required String path,
  bool hidden = false,
}) {
  return ReportColumnConfig.metric(
    key: key,
    label: label,
    path: 'body.$path',
    aggregation: ReportAggregationType.average,
    format: 'decimal2',
    hidden: hidden,
  );
}
