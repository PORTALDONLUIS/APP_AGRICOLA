import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_long_brote_racimo_config.dart';

final cartillaLongBroteReportConfig = CartillaReportConfig(
  templateKey: CartillaLongBroteRacimoConfig.templateKeyStatic,
  reportKey: 'brote',
  title: 'LONGITUD DE BROTE',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaLongBroteRacimoConfig.kLoteId}',
    ),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaLongBroteRacimoConfig.kLoteId}',
    ),
    ReportColumnConfig.metric(
      key: 'totalMuestras',
      label: 'Muestras',
      path: 'header.${CartillaLongBroteRacimoConfig.kLoteId}',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'totalBrote',
      label: 'T.Brotes',
      path: 'body.${CartillaLongBroteRacimoConfig.kTotalBroteEvaluado}',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'promTotalBrote',
      label: 'Prom. TOTAL BROTE',
      path: 'body.${CartillaLongBroteRacimoConfig.kTotalBroteEvaluado}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ..._weightedBroteColumns,
    ReportColumnConfig.computed(
      key: '_totalWeightedBrote',
      label: 'Total ponderado brote',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: _weightedBroteKeys,
      ),
      format: 'decimal2',
      hidden: true,
    ),
    ReportColumnConfig.computed(
      key: 'promLongitudBrote',
      label: 'Prom. De Longitud por Planta',
      computation: const ReportComputationConfig.divideColumns(
        numeratorColumnKey: '_totalWeightedBrote',
        denominatorColumnKey: 'totalBrote',
      ),
      format: 'decimal2',
    ),
    ..._broteDetailColumns,
  ],
);

final cartillaLongRacimoReportConfig = CartillaReportConfig(
  templateKey: CartillaLongBroteRacimoConfig.templateKeyStatic,
  reportKey: 'racimo',
  title: 'LONGITUD DE RACIMO',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaLongBroteRacimoConfig.kLoteId}',
    ),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaLongBroteRacimoConfig.kLoteId}',
    ),
    ReportColumnConfig.metric(
      key: 'totalMuestras',
      label: 'Muestras',
      path: 'header.${CartillaLongBroteRacimoConfig.kLoteId}',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'totalRacimo',
      label: 'T.Racimos',
      path: 'body.${CartillaLongBroteRacimoConfig.kTotalRacimoEvaluado}',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'promTotalRacimo',
      label: 'Prom. TOTAL RACIMO',
      path: 'body.${CartillaLongBroteRacimoConfig.kTotalRacimoEvaluado}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ..._weightedRacimoColumns,
    ReportColumnConfig.computed(
      key: '_totalWeightedRacimo',
      label: 'Total ponderado racimo',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: _weightedRacimoKeys,
      ),
      format: 'decimal2',
      hidden: true,
    ),
    ReportColumnConfig.computed(
      key: 'promLongitudRacimo',
      label: 'Prom. De Longitud x Planta',
      computation: const ReportComputationConfig.divideColumns(
        numeratorColumnKey: '_totalWeightedRacimo',
        denominatorColumnKey: 'totalRacimo',
      ),
      format: 'decimal2',
    ),
    ..._racimoDetailColumns,
  ],
);

final cartillaLongBroteRacimoReportConfigs = [
  cartillaLongBroteReportConfig,
  cartillaLongRacimoReportConfig,
];

final _weightedBroteKeys = [
  for (var cm = 1; cm <= 120; cm++) '_weightedBrote$cm',
];

final _weightedBroteColumns = [
  for (var cm = 1; cm <= 120; cm++)
    ReportColumnConfig.metric(
      key: '_weightedBrote$cm',
      label: 'Ponderado brote $cm cm',
      path: 'body.long_brote_$cm',
      aggregation: ReportAggregationType.sum,
      multiplier: cm,
      format: 'decimal2',
      hidden: true,
    ),
];

final _broteDetailColumns = [
  for (var cm = 1; cm <= 120; cm++) ...[
    ReportColumnConfig.metric(
      key: 'sumBrote$cm',
      label: 'Sum $cm cm',
      path: 'body.long_brote_$cm',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'promBrote$cm',
      label: 'Prom $cm cm',
      path: 'body.long_brote_$cm',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.computed(
      key: 'porcBrote$cm',
      label: '% $cm cm',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'sumBrote$cm',
        denominatorColumnKey: 'totalBrote',
      ),
      format: 'percent2',
    ),
  ],
];

final _weightedRacimoKeys = [
  for (var cm = 1; cm <= 25; cm++) '_weightedRacimo$cm',
];

final _weightedRacimoColumns = [
  for (var cm = 1; cm <= 25; cm++)
    ReportColumnConfig.metric(
      key: '_weightedRacimo$cm',
      label: 'Ponderado racimo $cm cm',
      path: 'body.long_racimo_$cm',
      aggregation: ReportAggregationType.sum,
      multiplier: cm,
      format: 'decimal2',
      hidden: true,
    ),
];

final _racimoDetailColumns = [
  for (var cm = 1; cm <= 25; cm++) ...[
    ReportColumnConfig.metric(
      key: 'sumRacimo$cm',
      label: 'Sum $cm cm',
      path: 'body.long_racimo_$cm',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'promRacimo$cm',
      label: 'Prom $cm cm',
      path: 'body.long_racimo_$cm',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.computed(
      key: 'porcRacimo$cm',
      label: '% $cm cm',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'sumRacimo$cm',
        denominatorColumnKey: 'totalRacimo',
      ),
      format: 'percent2',
    ),
  ],
];
