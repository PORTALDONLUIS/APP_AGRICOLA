import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_cosecha_palta_config.dart';

final cartillaCosechaPaltaReportConfig = CartillaReportConfig(
  templateKey: CartillaCosechaPaltaConfig.templateKeyStatic,
  title: 'COSECHA PALTA',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaCosechaPaltaConfig.kLoteId}',
    ),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaCosechaPaltaConfig.kLoteId}',
    ),
    ReportColumnConfig.metric(
      key: 'totalMuestras',
      label: 'Total de Muestras',
      path: 'header.${CartillaCosechaPaltaConfig.kLoteId}',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    ReportColumnConfig.metric(
      key: 'totalFrutos',
      label: 'Total de frutos',
      path: 'body.${CartillaCosechaPaltaConfig.kNroFrutoEvaluados}',
      aggregation: ReportAggregationType.sum,
      format: 'int',
    ),
    _sumMetric(
      key: '_sumConDefectos',
      path: CartillaCosechaPaltaConfig.kConDefectos,
    ),
    _sumMetric(
      key: '_sumSinDefectos',
      path: CartillaCosechaPaltaConfig.kSinDefectos,
    ),
    _percentMetric(
      key: 'porcConDefecto',
      label: '% Con Defecto',
      numeratorKey: '_sumConDefectos',
    ),
    _percentMetric(
      key: 'porcSinDefecto',
      label: '% Sin defecto',
      numeratorKey: '_sumSinDefectos',
    ),
    ..._defectPercentColumns,
  ],
);

const _defectSources = [
  (
    key: 'danoBichoCesto',
    label: '% Daño por Bicho del Cesto',
    path: CartillaCosechaPaltaConfig.kDanoBichoCesto,
  ),
  (
    key: 'ausenciaPedunculo',
    label: '% Ausencia de Pedunculo',
    path: CartillaCosechaPaltaConfig.kAusenciaPedunculo,
  ),
  (
    key: 'pedunculoLargo',
    label: '% Pedunculo Largo',
    path: CartillaCosechaPaltaConfig.kPedunculoLargo,
  ),
  (
    key: 'danoMecanico',
    label: '% Daño Mecanico',
    path: CartillaCosechaPaltaConfig.kDanoMecanico,
  ),
  (
    key: 'danoGolpe',
    label: '% Daño por Golpe',
    path: CartillaCosechaPaltaConfig.kDanoGolpe,
  ),
  (
    key: 'fumagina',
    label: '% Fumagina',
    path: CartillaCosechaPaltaConfig.kFumagina,
  ),
  (
    key: 'lenticelosis',
    label: '% Lenticelosis',
    path: CartillaCosechaPaltaConfig.kLenticelosis,
  ),
  (
    key: 'quemaduraSol',
    label: '% Quemadura de Sol',
    path: CartillaCosechaPaltaConfig.kQuemaduraSol,
  ),
  (
    key: 'frutoDeforme',
    label: '% Fruto Deforme',
    path: CartillaCosechaPaltaConfig.kFrutoDeforme,
  ),
  (
    key: 'viracionColor',
    label: '% Viracion de color',
    path: CartillaCosechaPaltaConfig.kViracionColor,
  ),
  (
    key: 'presenciaQueresas',
    label: '% Presencia de Queresas',
    path: CartillaCosechaPaltaConfig.kPresenciaQueresas,
  ),
  (
    key: 'danoTrips',
    label: '% Daño por Trips',
    path: CartillaCosechaPaltaConfig.kDanoTrips,
  ),
  (
    key: 'sombreamiento',
    label: '% Sombreamiento',
    path: CartillaCosechaPaltaConfig.kSombreamiento,
  ),
  (
    key: 'danoRoedor',
    label: '% Daño por roedor',
    path: CartillaCosechaPaltaConfig.kDanoRoedor,
  ),
  (
    key: 'sumbloth',
    label: '% Sumbloth',
    path: CartillaCosechaPaltaConfig.kSumbloth,
  ),
  (
    key: 'quimera',
    label: '% Quimera',
    path: CartillaCosechaPaltaConfig.kQuimera,
  ),
  (
    key: 'rameado',
    label: '% Rameado',
    path: CartillaCosechaPaltaConfig.kRameado,
  ),
  (
    key: 'frutoBarro',
    label: '% Fruto con barro',
    path: CartillaCosechaPaltaConfig.kFrutoBarro,
  ),
  (
    key: 'frutosDeshidratados',
    label: '% Frutos Deshidratados',
    path: CartillaCosechaPaltaConfig.kFrutosDeshidratados,
  ),
  (
    key: 'preCalibre',
    label: '% Pre calibre',
    path: CartillaCosechaPaltaConfig.kPreCalibre,
  ),
  (
    key: 'frutoExcretaAves',
    label: '% Fruto con excreta de aves',
    path: CartillaCosechaPaltaConfig.kFrutoExcretaAves,
  ),
];

final _defectPercentColumns = [
  for (final source in _defectSources) ...[
    _sumMetric(key: '_sum${_capitalize(source.key)}', path: source.path),
    _percentMetric(
      key: 'porc${_capitalize(source.key)}',
      label: source.label,
      numeratorKey: '_sum${_capitalize(source.key)}',
    ),
  ],
];

ReportColumnConfig _sumMetric({required String key, required String path}) {
  return ReportColumnConfig.metric(
    key: key,
    label: key,
    path: 'body.$path',
    aggregation: ReportAggregationType.sum,
    format: 'decimal2',
    hidden: true,
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
      denominatorColumnKey: 'totalFrutos',
    ),
    format: 'percent2',
  );
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
