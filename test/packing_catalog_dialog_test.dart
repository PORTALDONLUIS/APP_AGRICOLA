import 'package:donluis_forms/features/cartillas/presentation/widgets/packing_catalog_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Agregar opción cierra el diálogo y actualiza la ficha', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Column(
              children: [
                Text(selected ?? 'Sin selección'),
                ElevatedButton(
                  onPressed: () async {
                    final result = await showPackingCatalogDialog(
                      context,
                      'ETIQUETA',
                    );
                    if (!context.mounted || result == null) return;
                    setState(() => selected = result['primero']);
                  },
                  child: const Text('Abrir catálogo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir catálogo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'NUEVA ETIQUETA');
    await tester.tap(find.text('Agregar'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(find.text('NUEVA ETIQUETA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('El catálogo de lugar mantiene fundo y código', (tester) async {
    Map<String, String>? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showPackingCatalogDialog(
                  context,
                  'LUGAR_PRODUCCION',
                );
              },
              child: const Text('Abrir lugar'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir lugar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Don Luis');
    await tester.enterText(find.byType(TextField).last, '016-00929-02');
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    expect(result, {'primero': 'Don Luis', 'segundo': '016-00929-02'});
    expect(tester.takeException(), isNull);
  });
}
