import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_brix_config.dart';

/// Resumen diario por lote y ubicación de muestreo.
///
/// El BRIX promedio se pondera por la cantidad de bayas de cada planta,
/// equivalente a sumar todos los rangos de BRIX y dividirlos entre el total
/// de bayas evaluadas, como en el archivo de referencia.
final cartillaBrixReportConfig = CartillaReportConfig(
  templateKey: CartillaBrixConfig.templateKeyStatic,
  title: 'BRIX',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: const [
    ReportGroupByConfig(key: 'lote', label: 'Lote', path: 'header.loteId'),
    ReportGroupByConfig(
      key: 'ubicacion',
      label: 'Ubicación',
      path: 'body.fenologia',
    ),
  ],
  columns: const [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.loteId',
    ),
    ReportColumnConfig.dimension(
      key: 'ubicacion',
      label: 'Ubicación',
      path: 'body.fenologia',
    ),
    ReportColumnConfig.metric(
      key: 'totalMuestras',
      label: 'Total de muestras',
      path: 'header.loteId',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'totalBayas',
      label: 'Total de bayas evaluadas',
      path: 'body.totalBayasEvaluadas',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'promBrix',
      label: 'Prom. BRIX',
      path: 'body.promBrixPlanta',
      weightPath: 'body.totalBayasEvaluadas',
      aggregation: ReportAggregationType.weightedAverage,
      format: 'decimal2',
    ),
    ReportColumnConfig.computed(
      key: 'promBayasPlanta',
      label: 'Prom. bayas/planta',
      computation: ReportComputationConfig.divideColumns(
        numeratorColumnKey: 'totalBayas',
        denominatorColumnKey: 'totalMuestras',
      ),
      format: 'decimal2',
    ),
  ],
);
