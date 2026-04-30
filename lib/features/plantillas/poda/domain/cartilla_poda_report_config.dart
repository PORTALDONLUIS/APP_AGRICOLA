import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_poda_config.dart';

final cartillaPodaReportConfig = CartillaReportConfig(
  templateKey: CartillaPodaConfig.templateKeyStatic,
  title: 'PODA',
  dailyReport: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaPodaConfig.kLoteId}',
    ),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaPodaConfig.kLoteId}',
    ),
    ReportColumnConfig.metric(
      key: 'totalMuestras',
      label: 'Total de Muestras',
      path: 'header.${CartillaPodaConfig.kLoteId}',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'cargadoresDebiles',
      label: 'Cargadores Débiles',
      path: 'body.${CartillaPodaConfig.kDebil}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'cargadoresNormales',
      label: 'Cargadores Normales',
      path: 'body.${CartillaPodaConfig.kNormal}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'cargadoresVigorosos',
      label: 'Cargadores Vigorosos',
      path: 'body.${CartillaPodaConfig.kVigoroso}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'totalCargadores',
      label: 'Total de Cargadores',
      path: 'body.${CartillaPodaConfig.kTotalCargadores}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'nroPitones',
      label: 'Nro Pitones',
      path: 'body.${CartillaPodaConfig.kPitones}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'promYemasPiton',
      label: 'Prom. de Yemas en Pitón',
      path: 'body.${CartillaPodaConfig.kYemasPiton}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'promYemasCargadores',
      label: 'Prom. Yemas en cargadores',
      path: 'body.${CartillaPodaConfig.kTotalYemas}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.computed(
      key: 'totalYemas',
      label: 'Total de Yemas (Cargador + Pitón)',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: ['promYemasCargadores', 'promYemasPiton'],
      ),
      format: 'decimal2',
    ),
    ReportColumnConfig.computed(
      key: 'nroYemasPorCargador',
      label: 'Nro Yemas por Cargador',
      computation: ReportComputationConfig.divideColumns(
        numeratorColumnKey: 'promYemasCargadores',
        denominatorColumnKey: 'totalCargadores',
      ),
      format: 'decimal2',
    ),
    ReportColumnConfig.computed(
      key: 'nroYemasPorPiton',
      label: 'Nro Yemas por Pitón',
      computation: ReportComputationConfig.divideColumns(
        numeratorColumnKey: 'promYemasPiton',
        denominatorColumnKey: 'nroPitones',
      ),
      format: 'decimal2',
    ),
  ],
);
