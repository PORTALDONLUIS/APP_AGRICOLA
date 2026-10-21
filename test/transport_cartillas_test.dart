import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donluis_forms/features/master/presentation/master_providers.dart';
import 'package:donluis_forms/features/cartillas/presentation/widgets/offline_person_picker.dart';
import 'package:donluis_forms/features/cartillas/domain/evaluation_defaults.dart';
import 'package:donluis_forms/features/plantillas/movilidades_cosecha/domain/movilidades_guias.dart';
import 'package:donluis_forms/features/plantillas/movilidades_cosecha/domain/cartilla_movilidades_cosecha_config.dart';
import 'package:donluis_forms/features/cartillas/application/cartilla_validator.dart';
import 'package:donluis_forms/features/cartillas/domain/report/transport_report_configs.dart';

void main() {
  testWidgets('large operario catalog searches locally and selects stable ID', (tester) async {
    String? selected;
    final rows = List<dynamic>.generate(2268, (i) => _Person(i));
    await tester.pumpWidget(ProviderScope(overrides: [
      personasActivasByTipoCodigoProvider('OPE').overrideWith((ref) => Stream.value(rows)),
    ], child: MaterialApp(home: Scaffold(body: OfflinePersonPicker(label:'Operario',
      value:null, enabled:true, onChanged:(id) => selected=id)))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buscar o seleccionar'));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.text('Operario 0')).style?.color, Colors.black);
    expect(find.byType(ListTile).evaluate().length, lessThan(50));
    await tester.enterText(find.byType(TextField), '2267');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Operario 2267'));
    await tester.pumpAndSettle();
    expect(selected, '2267');
    await tester.pump(const Duration(seconds: 2));
  });
  test('Peru defaults preserve user values and input', () {
    final body = <String, dynamic>{};
    final result = evaluationDefaults(body, {}, withStartTime: true,
      now: DateTime.utc(2026, 10, 20, 2, 30));
    expect(result['fecha'], '19/10/2026');
    expect(result['horaInicioCarga'], '21:30');
    expect(body, isEmpty);
    expect(evaluationDefaults(result, {}, withStartTime: true,
      now: DateTime.utc(2026, 11, 1)), result);
  });
  test('both summaries include saved local samples before synchronization', () {
    for (final config in [portabinReportConfig, movilidadesReportConfig]) {
      expect(config.allowedEstados, containsAll(['borrador', 'pendienteSync', 'enviado', 'error']));
    }
  });
  test('legacy sample becomes one guide without modifying original', () {
    final body = <String, dynamic>{'cantidadCajas': 12, 'serieGuia': '0001', 'nroGuia': '000003'};
    final result = movilidadesBody(body, {'loteId': 10});
    expect(result['cantidadGuias'], 1);
    expect(result['totalCajas'], 12);
    expect((result['guias'] as List).first['serieGuia'], '0001');
    expect(body.containsKey('guias'), isFalse);
  });
  test('multiple guides sum boxes and retain first-guide aliases', () {
    final result = movilidadesBody({'guias': [
      {'loteId': 10, 'cantidadCajas': 12, 'serieGuia': '0001', 'nroGuia': '001'},
      {'loteId': 11, 'cantidadCajas': 20, 'serieGuia': '0001', 'nroGuia': '002'},
    ]}, {});
    expect(result['cantidadGuias'], 2);
    expect(result['totalCajas'], 32);
    expect(result['nroGuia'], '001');
  });
  test('validation checks every guide', () {
    final issues = validateRequired(config: CartillaMovilidadesCosechaConfig(),
      getHeaderValue: (_) => '1', getBodyValue: (key) => key == 'guias' ? [
        {'loteId': 10, 'cantidadCajas': 12, 'supervisor': '3', 'serieGuia': '01', 'nroGuia': '001'},
        {'loteId': 11, 'cantidadCajas': -1},
      ] : 'value');
    expect(issues.any((i) => i.fieldLabel.contains('Guía 2')), isTrue);
  });
}

class _Person {
  _Person(this.id);
  final int id;
  String get nombreCompleto => 'Operario $id';
  String get dni => id.toString().padLeft(8,'0');
}
