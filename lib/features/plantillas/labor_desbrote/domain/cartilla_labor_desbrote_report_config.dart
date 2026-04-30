import 'cartilla_labor_desbrote_config.dart';
import '../../../cartillas/domain/report/cartilla_report_config.dart';

final cartillaLaborDesbroteReportConfig = CartillaReportConfig(
  templateKey: CartillaLaborDesbroteConfig.templateKeyStatic,
  title: 'LABOR DE DESBROTE',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaLaborDesbroteConfig.kLoteId}',
    ),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaLaborDesbroteConfig.kLoteId}',
    ),
    ReportColumnConfig.metric(
      key: 'totalMuestras',
      label: 'Total de Muestras',
      path: 'header.${CartillaLaborDesbroteConfig.kLoteId}',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'promBrotesPiton',
      label: 'Prom. Brotes en Piton',
      path: 'body.${CartillaLaborDesbroteConfig.kPitonBrote}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'promBrotesCargador',
      label: 'Prom. Brotes en cargador',
      path: 'body.${CartillaLaborDesbroteConfig.kCargadores}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'promBrotesMaderaVieja',
      label: 'Prom. Brotes en madera vieja',
      path: 'body.${CartillaLaborDesbroteConfig.kMaterialViejo}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.computed(
      key: 'totalBrotes',
      label: 'T. Brotes',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: [
          'promBrotesPiton',
          'promBrotesCargador',
          'promBrotesMaderaVieja',
        ],
      ),
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'brotesFruterosPiton',
      label: 'Brotes Fruteros en Piton',
      path: 'body.${CartillaLaborDesbroteConfig.kPiton}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'promRacimoSimple',
      label: 'Prom. R. SIMPLE',
      path: 'body.${CartillaLaborDesbroteConfig.kRacimoSimple}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'promRacimoDoble',
      label: 'Prom. R. DOBLE',
      path: 'body.${CartillaLaborDesbroteConfig.kRacimoDoble}',
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
      label: 'Prom. R. Indefinido',
      path: 'body.${CartillaLaborDesbroteConfig.kRacimoIndefinido}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.computed(
      key: 'promTotalRacimo',
      label: 'Prom. TOTAL DE RACIMO',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: ['promSimpleDoble', 'promRacimoDoble'],
      ),
      format: 'decimal2',
    ),
  ],
);
