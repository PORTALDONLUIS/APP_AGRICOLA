import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donluis_forms/features/plantillas/movilidades_cosecha/domain/movilidades_daily_summary.dart';
import 'package:donluis_forms/features/plantillas/movilidades_cosecha/domain/movilidades_guias.dart';
import 'package:donluis_forms/features/cartillas/presentation/report/widgets/movilidades_daily_report.dart';

void main() {
  final cases =
      (jsonDecode(
                File('test/movilidades_summary_cases.json').readAsStringSync(),
              )
              as List)
          .cast<Map>();
  for (final sample in cases) {
    test('shared counting contract: ${sample['name']}', () {
      final records = (sample['records'] as List)
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList();
      final before = jsonEncode(records);
      final actual = movilidadesDailySummary(records);
      for (final entry in (sample['expected'] as Map).entries) {
        expect(
          actual[entry.key],
          entry.value,
          reason: '${sample['name']}: ${entry.key}',
        );
      }
      expect(jsonEncode(records), before);
    });
  }
  test(
    'one daily link has no lot filter and preserves evaluator/day/template scope',
    () {
      final url = movilidadesDailyUrl(
        baseUrl: 'https://example.test/',
        day: DateTime(2026, 10, 20),
        plantillaId: 20,
        userId: 3,
      )!;
      final query = Uri.parse(url).queryParameters;
      expect(query, {
        'resumen': 'diario',
        'fecha': '2026-10-20',
        'usuarioId': '3',
        'cartillaId': '20',
      });
      expect(query.containsKey('loteId'), false);
      expect(
        movilidadesDailyUrl(
          baseUrl: 'https://example.test',
          day: DateTime(2026),
          plantillaId: null,
          userId: 3,
        ),
        isNull,
      );
    },
  );
  test('same guide groups two lots, without summing its document twice', () {
    final records = (cases.first['records'] as List)
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();
    final result = movilidadesDailySummary(records);
    final guides = (result['viajesDetalle'] as List).first['guias'] as List;
    expect(guides.length, 1);
    expect((guides.first['lotes'] as List).length, 2);
    expect(guides.first['cajas'], 55);
    final body = movilidadesBody(
      Map<String, dynamic>.from(records.first['body'] as Map),
      {},
    );
    expect(body['cantidadGuias'], 1);
    expect(body['cantidadBloquesGuia'], 2);
    expect(body['totalCajas'], 55);
  });
  test('share text has totals without code averages or empty warnings', () {
    final records = (cases.first['records'] as List)
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();
    final summary = movilidadesDailySummary(records);
    final text = movilidadesDailyShareText(summary, dayLabel: '20/10/2026');
    expect(
      text,
      startsWith(
        'Buen día, comparto el reporte diario de la cartilla:\n*MOVILIDADES COSECHA*\nFecha: 20/10/2026\n\n',
      ),
    );
    expect(text, contains('Guías distintas: 1'));
    expect(text, contains('Total de cajas: 55'));
    expect(text, isNot(contains('Promedio')));
    expect(text, isNot(contains('Datos por completar')));
    final pendingText = movilidadesDailyShareText({
      ...summary,
      'pendientes': 1,
    }, dayLabel: '20/10/2026');
    expect(pendingText, contains('Pendientes de sincronizar: 1'));
  });
  testWidgets(
    'daily report shows totals, not Lote column or averages of codes',
    (tester) async {
      final records = (cases.first['records'] as List)
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList();
      final summary = movilidadesDailySummary(records);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MovilidadesDailyReport(summary: summary)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Camiones distintos'), findsOneWidget);
      expect(find.text('Guías distintas'), findsOneWidget);
      expect(find.text('Total de cajas'), findsOneWidget);
      expect(find.text('55'), findsOneWidget);
      expect(find.textContaining('Promedio'), findsNothing);
      expect(find.text('Lote 12345'), findsNothing);
    },
  );
}
