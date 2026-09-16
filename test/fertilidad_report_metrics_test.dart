import 'package:donluis_forms/features/plantillas/fertilidad/domain/cartilla_fertilidad_report_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calcula Fertilidad por las siete yemas de cada muestra', () {
    final metrics = calculateFertilidadReportMetrics([
      {
        'body': {
          'yema1_parametros': 'FF',
          'yema2_parametros': 'FG',
          'yema3_parametros': 'F',
          'yema4_parametros': 'FP',
          'yema5_parametros': 'V',
          'yema6_parametros': 'VI',
          'yema7_parametros': 'N',
          'yema1_catYema': 'M',
          'yema2_catYema': 'M',
          'yema3_catYema': 'I',
        },
      },
      {
        'body': {
          'yema1_parametros': 'S',
          'yema2_parametros': 'A',
          // FA y FN también son parámetros válidos y se incluyen en el total.
          'yema3_parametros': 'FA',
          'yema4_parametros': 'FN',
          'yema1_catYema': 'I',
        },
      },
    ]);

    expect(metrics.totalRacimos, 4);
    expect(metrics.totalYemasAnalizadas, 11);
    expect(metrics.percentTotalRacimos, 36.36);
    expect(metrics.percentParametro('V'), 9.1);
    expect(metrics.percentYemasMaduras, closeTo(50, 0.0001));
    expect(metrics.percentYemasInmaduras, closeTo(50, 0.0001));
  });

  test('usa el cuarto decimal del porcentaje para redondear', () {
    const metrics = FertilidadReportMetrics(
      parametros: {'V': 65, 'F': 40},
      yemasMaduras: 0,
      yemasInmaduras: 0,
    );

    expect(metrics.percentParametro('V'), 61.91);
  });

  test('trunca únicamente el porcentaje de total de racimos', () {
    const metrics = FertilidadReportMetrics(
      parametros: {'F': 32, 'V': 73},
      yemasMaduras: 0,
      yemasInmaduras: 0,
    );

    expect(metrics.percentTotalRacimos, 30.47);
    expect(metrics.percentParametro('V'), 69.53);
  });

  test('no ajusta cuando el cuarto decimal del porcentaje es menor que cinco', () {
    const metrics = FertilidadReportMetrics(
      parametros: {'F': 99, 'VI': 6},
      yemasMaduras: 0,
      yemasInmaduras: 0,
    );

    expect(metrics.percentParametro('VI'), 5.71);
  });

  test('redondea normalmente el porcentaje de yema madura', () {
    const metrics = FertilidadReportMetrics(
      parametros: {},
      yemasMaduras: 15,
      yemasInmaduras: 17,
    );

    expect(metrics.percentYemasMaduras, 46.88);
  });
}
