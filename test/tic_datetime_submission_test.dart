import 'package:donluis_forms/features/tic/tic_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normaliza segundos de fecha y hora para el formulario TIC', () {
    final values = ticValuesForSubmission({
      'schema': {
        'fields': [
          {'name': 'fecha_documento', 'type': 'fecha_hora'},
          {'name': 'asunto', 'type': 'texto'},
        ],
      },
      'values': {
        'fecha_documento': '2026-11-10T10:33:00',
        'asunto': 'MANTENIMIENTO PREVENTIVO',
      },
    });

    expect(values['fecha_documento'], '2026-11-10T10:33');
    expect(values['asunto'], 'MANTENIMIENTO PREVENTIVO');
  });

  test('no altera una fecha que ya está en el formato esperado', () {
    final values = ticValuesForSubmission({
      'schema': {
        'fields': [
          {'name': 'fecha_documento', 'type': 'fecha_hora'},
        ],
      },
      'values': {'fecha_documento': '2026-11-10T10:33'},
    });

    expect(values['fecha_documento'], '2026-11-10T10:33');
  });
}
