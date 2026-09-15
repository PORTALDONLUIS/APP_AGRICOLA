import 'package:donluis_forms/features/plantillas/brix_moscatel/domain/cartilla_brix_moscatel_report_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calcula los promedios por hilera como el Excel de referencia', () {
    final payloads = <Map<String, dynamic>>[
      for (final value in [17, 18, 19])
        {
          'body': {'hilera': 10, 'planta': 1, 'brixSsc': value},
        },
      for (final value in [14, 15, 16])
        {
          'body': {'hilera': 10, 'planta': 2, 'brixSsc': value},
        },
      for (final value in [12, 13, 14])
        {
          'body': {'hilera': 20, 'planta': 3, 'brixSsc': value},
        },
    ];

    final metrics = calculateBrixMoscatelReportMetrics(payloads);

    expect(metrics.totalLecturas, 9);
    expect(metrics.cantidadHileras, 2);
    expect(metrics.promRacimo, 1.5);
    // Incluye 16.0 además de los valores superiores a 16.
    expect(metrics.totalMayoresDe16, 4);
    expect(metrics.cantidadHilerasMayoresDe16, 1);
    expect(metrics.promRacimoMayorDe16, closeTo(4 / 3, 0.000001));
  });
}
