import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_clasificacion_cargadores_config.dart';

/// Resumen diario por lote y evaluación. Los promedios incluyen las muestras
/// con valor cero, por lo que cada métrica es la suma de cargadores dividida
/// entre el total de muestras del grupo.
final cartillaClasificacionCargadoresReportConfig = CartillaReportConfig(
  templateKey: CartillaClasificacionCargadoresConfig.templateKeyStatic,
  title: 'CLASIFICACION DE CARGADORES',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaClasificacionCargadoresConfig.kLoteId}',
    ),
    ReportGroupByConfig(
      key: 'evaluacion',
      label: 'Evaluación',
      path: 'body.${CartillaClasificacionCargadoresConfig.kEvaluacion}',
    ),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaClasificacionCargadoresConfig.kLoteId}',
    ),
    ReportColumnConfig.dimension(
      key: 'evaluacion',
      label: 'Evaluación',
      path: 'body.${CartillaClasificacionCargadoresConfig.kEvaluacion}',
    ),
    ReportColumnConfig.metric(
      key: 'pDebiles',
      label: 'Primer alambre · Débil',
      path: 'body.${CartillaClasificacionCargadoresConfig.kPDebiles}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'pNormales',
      label: 'Primer alambre · Normal',
      path: 'body.${CartillaClasificacionCargadoresConfig.kPNormales}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'pVigorosos',
      label: 'Primer alambre · Vigoroso',
      path: 'body.${CartillaClasificacionCargadoresConfig.kPVigoroso}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'sDebiles',
      label: 'Segundo alambre · Débil',
      path: 'body.${CartillaClasificacionCargadoresConfig.kSDebiles}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'sNormales',
      label: 'Segundo alambre · Normal',
      path: 'body.${CartillaClasificacionCargadoresConfig.kSNormales}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'sVigorosos',
      label: 'Segundo alambre · Vigoroso',
      path: 'body.${CartillaClasificacionCargadoresConfig.kSVigoroso}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'tDebiles',
      label: 'Tercer alambre · Débil',
      path: 'body.${CartillaClasificacionCargadoresConfig.kTDebiles}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'tNormales',
      label: 'Tercer alambre · Normal',
      path: 'body.${CartillaClasificacionCargadoresConfig.kTNormales}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.metric(
      key: 'tVigorosos',
      label: 'Tercer alambre · Vigoroso',
      path: 'body.${CartillaClasificacionCargadoresConfig.kTVigoroso}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
    ReportColumnConfig.computed(
      key: 'globalDebiles',
      label: 'Global · Débil',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: ['pDebiles', 'sDebiles', 'tDebiles'],
      ),
      format: 'decimal2',
    ),
    ReportColumnConfig.computed(
      key: 'globalNormales',
      label: 'Global · Normal',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: ['pNormales', 'sNormales', 'tNormales'],
      ),
      format: 'decimal2',
    ),
    ReportColumnConfig.computed(
      key: 'globalVigorosos',
      label: 'Global · Vigoroso',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: ['pVigorosos', 'sVigorosos', 'tVigorosos'],
      ),
      format: 'decimal2',
    ),
    ReportColumnConfig.computed(
      key: 'totalCargadores',
      label: 'Total de cargadores',
      computation: ReportComputationConfig.sumColumns(
        sourceColumnKeys: [
          'globalDebiles',
          'globalNormales',
          'globalVigorosos',
        ],
      ),
      format: 'decimal2',
    ),
  ],
);
