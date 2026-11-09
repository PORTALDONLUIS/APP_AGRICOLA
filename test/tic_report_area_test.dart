import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donluis_forms/features/tic/tic_pages.dart';
import 'package:donluis_forms/features/tic/tic_repository.dart';

void main() {
  testWidgets('reportes recibe y permite seleccionar áreas del servidor', (t) async {
    await t.pumpWidget(ProviderScope(overrides: [
      ticCatalogProvider.overrideWith((ref) async => {'areas': ['TIC', 'LEGAL']}),
    ], child: const MaterialApp(home: TicReportsPage())));
    await t.pumpAndSettle();
    expect(find.text('Área del responsable actual'), findsOneWidget);
    await t.tap(find.text('Todas las áreas'));
    await t.pumpAndSettle();
    expect(find.text('LEGAL').hitTestable(), findsOneWidget);
    await t.tap(find.text('LEGAL').last);
    await t.pumpAndSettle();
    expect(find.text('LEGAL'), findsOneWidget);
  });
}
