import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_conteo_cargadores_config.dart';

/// Resumen diario por lote: suma de cargadores dividida entre las muestras.
/// La agregación `average` incluye los ceros, por lo que equivale exactamente
/// a total de cargadores / total de muestras registradas.
final cartillaConteoCargadoresReportConfig = CartillaReportConfig(
  templateKey: CartillaConteoCargadoresConfig.templateKeyStatic,
  title: 'CONTEO DE CARGADORES',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaConteoCargadoresConfig.kLoteId}',
    ),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaConteoCargadoresConfig.kLoteId}',
    ),
    ReportColumnConfig.metric(
      key: 'promedioCargadores',
      label: 'Promedio de cargadores',
      path: 'body.${CartillaConteoCargadoresConfig.kNumeroCargadores}',
      aggregation: ReportAggregationType.average,
      format: 'decimal2',
    ),
  ],
);
