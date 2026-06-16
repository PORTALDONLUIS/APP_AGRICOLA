import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_conteo_racimos_config.dart';

final cartillaConteoRacimosReportConfig = CartillaReportConfig(
  templateKey: CartillaConteoRacimosConfig.templateKeyStatic,
  title: 'CONTEO DE RACIMOS',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaConteoRacimosConfig.kLoteId}',
    ),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaConteoRacimosConfig.kLoteId}',
    ),
    ReportColumnConfig.metric(
      key: 'acumRacimoSimple',
      label: 'Acum. Racimo Simple',
      path: 'body.${CartillaConteoRacimosConfig.kRacimoSimple}',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'acumRacimoDoble',
      label: 'Acum. Racimo Doble',
      path: 'body.${CartillaConteoRacimosConfig.kRacimoDoble}',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    ReportColumnConfig.computed(
      key: 'acumSimpleDoble',
      label: 'Acum. S+D',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: ['acumRacimoSimple', 'acumRacimoDoble'],
      ),
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'acumRacimoIndefinido',
      label: 'Acum. Racimo Indefinido',
      path: 'body.${CartillaConteoRacimosConfig.kRacimoIndefinido}',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'acumRacimoCorrido',
      label: 'Acum. Racimo Corrido',
      path: 'body.${CartillaConteoRacimosConfig.kRacimoCorrido}',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'acumTotal',
      label: 'Acum. Total',
      path: 'body.${CartillaConteoRacimosConfig.kTotal}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'promRacimoSimple',
      label: 'Prom. RS',
      path: 'body.${CartillaConteoRacimosConfig.kRacimoSimple}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'promRacimoDoble',
      label: 'Prom. RD',
      path: 'body.${CartillaConteoRacimosConfig.kRacimoDoble}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.computed(
      key: 'promSimpleDoble',
      label: 'Prom. S+D',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: ['promRacimoSimple', 'promRacimoDoble'],
      ),
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'promRacimoIndefinido',
      label: 'Prom. Racimo Indefinido',
      path: 'body.${CartillaConteoRacimosConfig.kRacimoIndefinido}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'promRacimoCorrido',
      label: 'Prom. Racimo Corrido',
      path: 'body.${CartillaConteoRacimosConfig.kRacimoCorrido}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'promTotal',
      label: 'Prom. Total',
      path: 'body.${CartillaConteoRacimosConfig.kTotal}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'acumuladoTotal',
      label: 'Acumulado Total',
      path: 'body.${CartillaConteoRacimosConfig.kTotal}',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    ReportColumnConfig.computed(
      key: 'porcTotalRacimoSimple',
      label: '%Total Racimo Simple',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'acumRacimoSimple',
        denominatorColumnKey: 'acumuladoTotal',
      ),
      format: 'percent2',
    ),
    ReportColumnConfig.computed(
      key: 'porcTotalRacimoDoble',
      label: '%Total Racimo Doble',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'acumRacimoDoble',
        denominatorColumnKey: 'acumuladoTotal',
      ),
      format: 'percent2',
    ),
    ReportColumnConfig.computed(
      key: 'porcTotalRacimoIndefinido',
      label: '%Total Racimo Indefinido',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'acumRacimoIndefinido',
        denominatorColumnKey: 'acumuladoTotal',
      ),
      format: 'percent2',
    ),
    ReportColumnConfig.computed(
      key: 'porcTotalSimpleDoble',
      label: '%Total Racimo(S+D)',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'acumSimpleDoble',
        denominatorColumnKey: 'acumuladoTotal',
      ),
      format: 'percent2',
    ),
    ReportColumnConfig.computed(
      key: 'porcTotalRacimoCorrido',
      label: '%Total Racimo Corrido',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'acumRacimoCorrido',
        denominatorColumnKey: 'acumuladoTotal',
      ),
      format: 'percent2',
    ),
    ReportColumnConfig.computed(
      key: 'porcTotal',
      label: '%Total',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'acumuladoTotal',
        denominatorColumnKey: 'acumuladoTotal',
      ),
      format: 'percent2',
    ),
  ],
);
