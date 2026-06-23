import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_floracion_cuaja_config.dart';

final cartillaFloracionCuajaReportConfig = CartillaReportConfig(
  templateKey: CartillaFloracionCuajaConfig.templateKeyStatic,
  title: 'FLORACION CUAJA',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaFloracionCuajaConfig.kLoteId}',
    ),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaFloracionCuajaConfig.kLoteId}',
    ),
    _sumMetric(
      key: 'totalRacimosPlanta',
      label: 'T.RACIMOS/PLANTA',
      path: CartillaFloracionCuajaConfig.kTotalRacimos,
      format: 'int',
    ),
    _averageMetric(
      key: 'promTotalRacimosPlanta',
      label: 'Prom. T.RACIMOS/PLANTA',
      path: CartillaFloracionCuajaConfig.kTotalRacimos,
    ),
    _sumMetric(
      key: 'sumCaliptraHinRacPlanta',
      label: 'Sum. CALIPTRA.Hin Rac/PLANTA',
      path: CartillaFloracionCuajaConfig.kCaliptra,
      format: 'int',
    ),
    _averageMetric(
      key: 'promCaliptraHinRacPlanta',
      label: 'Prom. CALIPTRA.Hin Rac/PLANTA',
      path: CartillaFloracionCuajaConfig.kCaliptra,
    ),
    _percentMetric(
      key: 'porcCaliptraHinRacPlanta',
      label: '% CALIPTRA.Hin Rac/PLANTA',
      numeratorKey: 'sumCaliptraHinRacPlanta',
    ),
    _sumMetric(
      key: 'sumFloracionPlanta',
      label: 'Sum. FLORACION/PLANTA',
      path: CartillaFloracionCuajaConfig.kSumFloracion,
      format: 'int',
    ),
    _averageMetric(
      key: 'promFloracionPlanta',
      label: 'Prom. FLORACION/PLANTA',
      path: CartillaFloracionCuajaConfig.kSumFloracion,
    ),
    _percentMetric(
      key: 'porcFloracionPlanta',
      label: '% FLORACION/PLANTA',
      numeratorKey: 'sumFloracionPlanta',
    ),
    _sumMetric(
      key: 'sumCuaja',
      label: 'Sum. CUAJA',
      path: CartillaFloracionCuajaConfig.kCuaja,
      format: 'int',
    ),
    _averageMetric(
      key: 'promCuaja',
      label: 'Prom. CUAJA',
      path: CartillaFloracionCuajaConfig.kCuaja,
    ),
    _percentMetric(
      key: 'porcCuaja',
      label: '% CUAJA',
      numeratorKey: 'sumCuaja',
    ),
    ..._percentageColumns,
  ],
);

const _percentageSources = [
  (suffix: '10', label: '10%', path: CartillaFloracionCuajaConfig.kP10),
  (suffix: '20', label: '20%', path: CartillaFloracionCuajaConfig.kP20),
  (suffix: '30', label: '30%', path: CartillaFloracionCuajaConfig.kP30),
  (suffix: '40', label: '40%', path: CartillaFloracionCuajaConfig.kP40),
  (suffix: '50', label: '50%', path: CartillaFloracionCuajaConfig.kP50),
  (suffix: '60', label: '60%', path: CartillaFloracionCuajaConfig.kP60),
  (suffix: '70', label: '70%', path: CartillaFloracionCuajaConfig.kP70),
  (suffix: '80', label: '80%', path: CartillaFloracionCuajaConfig.kP80),
  (suffix: '90', label: '90%', path: CartillaFloracionCuajaConfig.kP90),
  (suffix: '100', label: '100%', path: CartillaFloracionCuajaConfig.kP100),
];

final _percentageColumns = [
  for (final source in _percentageSources) ...[
    _sumMetric(
      key: 'sumP${source.suffix}',
      label: 'Sum. ${source.label}',
      path: source.path,
      format: 'int',
    ),
    _averageMetric(
      key: 'promP${source.suffix}',
      label: 'Prom. ${source.label}',
      path: source.path,
    ),
    _percentMetric(
      key: 'porcP${source.suffix}',
      label: '%. ${source.label}',
      numeratorKey: 'sumP${source.suffix}',
    ),
  ],
];

ReportColumnConfig _sumMetric({
  required String key,
  required String label,
  required String path,
  String format = 'decimal2',
}) {
  return ReportColumnConfig.metric(
    key: key,
    label: label,
    path: 'body.$path',
    aggregation: ReportAggregationType.sum,
    format: format,
  );
}

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

ReportColumnConfig _percentMetric({
  required String key,
  required String label,
  required String numeratorKey,
}) {
  return ReportColumnConfig.computed(
    key: key,
    label: label,
    computation: ReportComputationConfig.percentage(
      numeratorColumnKey: numeratorKey,
      denominatorColumnKey: 'totalRacimosPlanta',
    ),
    format: 'percent2',
  );
}
