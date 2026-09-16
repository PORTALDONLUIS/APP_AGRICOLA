import 'cartilla_fertilidad_config.dart';

/// Métricas del resumen diario de Fertilidad, calculadas por lote.
///
/// El total de yemas analizadas considera todos los parámetros disponibles en
/// la cartilla: FF, FG, F, FP, V, VI, A, FA, N, FN y S.
class FertilidadReportMetrics {
  final Map<String, int> parametros;
  final int yemasMaduras;
  final int yemasInmaduras;

  const FertilidadReportMetrics({
    required this.parametros,
    required this.yemasMaduras,
    required this.yemasInmaduras,
  });

  int count(String code) => parametros[code] ?? 0;

  int get totalRacimos => count('FF') + count('FG') + count('F') + count('FP');

  int get totalYemasAnalizadas => parametros.values.fold(0, (sum, value) => sum + value);

  int get totalYemasMadurez => yemasMaduras + yemasInmaduras;

  double percentParametro(String code) => _percent(count(code), totalYemasAnalizadas);

  /// Única excepción: este indicador se trunca a cuatro decimales antes de
  /// convertirlo a porcentaje (30.4762...% se muestra como 30.47%).
  double get percentTotalRacimos =>
      _percentTruncated(totalRacimos, totalYemasAnalizadas);

  /// Y. madura usa redondeo matemático normal a dos decimales.
  double get percentYemasMaduras =>
      _percentNormallyRounded(yemasMaduras, totalYemasMadurez);

  double get percentYemasInmaduras => _percent(yemasInmaduras, totalYemasMadurez);
}

const _parameterCodes = <String>{
  'FF',
  'FG',
  'F',
  'FP',
  'V',
  'VI',
  'A',
  'FA',
  'N',
  'FN',
  'S',
};

FertilidadReportMetrics calculateFertilidadReportMetrics(
  Iterable<Map<String, dynamic>> payloads,
) {
  final counts = <String, int>{for (final code in _parameterCodes) code: 0};
  var maduras = 0;
  var inmaduras = 0;

  for (final payload in payloads) {
    final body = (payload['body'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    for (final key in CartillaFertilidadConfig.parametrosFieldKeys) {
      final value = '${body[key] ?? ''}'.trim().toUpperCase();
      if (_parameterCodes.contains(value)) counts[value] = counts[value]! + 1;
    }
    for (final key in CartillaFertilidadConfig.catYemaFieldKeys) {
      final value = '${body[key] ?? ''}'.trim().toUpperCase();
      if (value == 'M') maduras++;
      if (value == 'I') inmaduras++;
    }
  }

  return FertilidadReportMetrics(
    parametros: Map.unmodifiable(counts),
    yemasMaduras: maduras,
    yemasInmaduras: inmaduras,
  );
}

/// Para los indicadores generales, el cuarto decimal del porcentaje define el
/// ajuste del segundo decimal, tal como el formato de referencia:
/// 61.9048% -> 61.91% y 5.7142% -> 5.71%.
double _percent(num numerator, num denominator) {
  if (denominator == 0) return 0;
  final percentage = numerator * 100 / denominator;
  final scaledTo4 = (percentage * 10000).floor();
  final secondDecimalBase = (scaledTo4 ~/ 100) / 100;
  final fourthDecimal = scaledTo4 % 10;
  return fourthDecimal >= 5 ? secondDecimalBase + 0.01 : secondDecimalBase;
}

double _percentTruncated(num numerator, num denominator) {
  if (denominator == 0) return 0;
  final ratioTruncatedTo4 = ((numerator / denominator) * 10000).floor() / 10000;
  return ratioTruncatedTo4 * 100;
}

double _percentNormallyRounded(num numerator, num denominator) {
  if (denominator == 0) return 0;
  return ((numerator * 100 / denominator) * 100).round() / 100;
}
