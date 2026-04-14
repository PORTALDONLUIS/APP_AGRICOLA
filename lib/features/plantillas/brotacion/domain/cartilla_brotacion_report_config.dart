import 'cartilla_brotacion_config.dart';
import '../../../cartillas/domain/report/cartilla_report_config.dart';

final cartillaBrotacionReportConfig = CartillaReportConfig(
  templateKey: CartillaBrotacionConfig.templateKeyStatic,
  title: 'BROTACION',
  dailyReport: true,
  allowedEstados: const [
    'borrador',
    'pendienteSync',
    'enviado',
    'error',
  ],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaBrotacionConfig.kLoteId}',
    ),
  ],
  displayTransposed: true,
  columns: [
    // 1 Lote
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaBrotacionConfig.kLoteId}',
    ),
    // 2 Total de Muestras
    ReportColumnConfig.metric(
      key: 'totalMuestras',
      label: 'Total de Muestras',
      path: 'header.${CartillaBrotacionConfig.kLoteId}',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    // 3 Acum. Yema Hinchada
    ReportColumnConfig.metric(
      key: 'acumYemaHinchada',
      label: 'Acum. Yema Hinchada',
      path: 'body.${CartillaBrotacionConfig.kYemaHinchada}',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    // 4 Acum. Boton Algodonoso
    ReportColumnConfig.metric(
      key: 'acumBotonAlgodonoso',
      label: 'Acum. Boton Algodonoso',
      path: 'body.${CartillaBrotacionConfig.kBotonAlgodonoso}',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    // 5 Acum. Punta Verde
    ReportColumnConfig.metric(
      key: 'acumPuntaVerde',
      label: 'Acum. Punta Verde',
      path: 'body.${CartillaBrotacionConfig.kPuntaVerde}',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    // 6 Acum. Hojas Extendidas
    ReportColumnConfig.metric(
      key: 'acumHojasExtendidas',
      label: 'Acum. Hojas Extendidas',
      path: 'body.${CartillaBrotacionConfig.kHojasExtendidas}',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    // 7 Acum. Yemas necróticas
    ReportColumnConfig.metric(
      key: 'acumYemasNecroticas',
      label: 'Acum. Yemas necróticas',
      path: 'body.${CartillaBrotacionConfig.kYemasNecroticas}',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),

    // 8
    ReportColumnConfig.computed(
      key: 'acumTotalYemas',
      label: 'Acum. Total de yemas',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: [
          'acumYemaHinchada',
          'acumBotonAlgodonoso',
          'acumPuntaVerde',
          'acumHojasExtendidas',
          'acumYemasNecroticas',
        ],
      ),
      format: 'int',
    ),

    // 9
    ReportColumnConfig.computed(
      key: 'porcYemaHinchada',
      label: '%Yema Hinchada',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'acumYemaHinchada',
        denominatorColumnKey: 'acumTotalYemas',
      ),
      format: 'percent2',
    ),

    // 10
    ReportColumnConfig.computed(
      key: 'porcBotonAlgodonoso',
      label: '% Boton Algodonoso',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'acumBotonAlgodonoso',
        denominatorColumnKey: 'acumTotalYemas',
      ),
      format: 'percent2',
    ),

    // 11
    ReportColumnConfig.computed(
      key: 'porcPuntaVerde',
      label: '% Punta Verde',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'acumPuntaVerde',
        denominatorColumnKey: 'acumTotalYemas',
      ),
      format: 'percent2',
    ),

    // 12
    ReportColumnConfig.computed(
      key: 'porcHojasExtendidas',
      label: '% Hojas Extendidas',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'acumHojasExtendidas',
        denominatorColumnKey: 'acumTotalYemas',
      ),
      format: 'percent2',
    ),

    // 13
    ReportColumnConfig.computed(
      key: 'porcYemasNecroticas',
      label: '% Yemas necróticas',
      computation: ReportComputationConfig.percentage(
        numeratorColumnKey: 'acumYemasNecroticas',
        denominatorColumnKey: 'acumTotalYemas',
      ),
      format: 'percent2',
    ),

    // 14
    ReportColumnConfig.computed(
      key: 'tBrotamiento',
      label: 'T. de Brotamiento',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: [
          'porcPuntaVerde',
          'porcHojasExtendidas',
        ],
      ),
      format: 'percent2',
    ),
  ],
);