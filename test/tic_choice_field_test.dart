import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donluis_forms/features/tic/tic_choice_field.dart';

void main() {
  Future<void> mount(
    WidgetTester tester, {
    bool allowNew = false,
    String initial = '',
    required ValueChanged<String> changed,
  }) async {
    var value = initial;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, update) => Padding(
              padding: const EdgeInsets.all(20),
              child: TicChoiceField(
                label: 'Empresa',
                value: value,
                allowNew: allowNew,
                options: const [
                  {'value': '', 'label': '--------'},
                  {'value': 'dl', 'label': 'Don Luis'},
                  {'value': 'cv', 'label': 'Campoverde agrícola'},
                ],
                onChanged: (v) {
                  update(() => value = v);
                  changed(v);
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('abre lista en el mismo formulario y guarda el código elegido', (
    t,
  ) async {
    var selected = '';
    await mount(t, changed: (v) => selected = v);
    await t.tap(find.byType(TextField));
    await t.pumpAndSettle();
    expect(find.widgetWithText(ListTile, '--------'), findsNothing);
    await t.tap(find.widgetWithText(ListTile, 'Don Luis'));
    await t.pumpAndSettle();
    expect(selected, 'dl');
    expect(find.text('Don Luis'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets(
    'busca por coincidencias sin acentos y permite quitar selección',
    (t) async {
      var selected = 'dl';
      await mount(t, initial: selected, changed: (v) => selected = v);
      await t.tap(find.byTooltip('Mostrar opciones de Empresa'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField), 'agricola campo');
      await t.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Don Luis'), findsNothing);
      await t.tap(find.widgetWithText(ListTile, 'Campoverde agrícola'));
      await t.pumpAndSettle();
      expect(selected, 'cv');
      await t.tap(find.byTooltip('Quitar selección de Empresa'));
      await t.pumpAndSettle();
      expect(selected, '');
    },
  );

  testWidgets('buscar un valor inexistente no cambia una opción controlada', (
    t,
  ) async {
    var selected = 'dl';
    await mount(t, initial: selected, changed: (v) => selected = v);
    await t.tap(find.byType(TextField));
    await t.enterText(find.byType(TextField), 'No existe');
    await t.pumpAndSettle();
    expect(find.text('No hay coincidencias'), findsOneWidget);
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
    expect(selected, 'dl');
    expect(find.text('Don Luis'), findsOneWidget);
  });

  testWidgets(
    'catálogo editable acepta un valor nuevo sin enviar el formulario',
    (t) async {
      var selected = '';
      await mount(t, allowNew: true, changed: (v) => selected = v);
      await t.tap(find.byType(TextField));
      await t.enterText(find.byType(TextField), 'Nueva marca');
      await t.pumpAndSettle();
      expect(find.text('Usar: Nueva marca'), findsOneWidget);
      await t.testTextInput.receiveAction(TextInputAction.done);
      await t.pumpAndSettle();
      expect(selected, 'Nueva marca');
      expect(find.byType(ListTile), findsNothing);
    },
  );

  testWidgets('lista funciona en pantalla de celular con teclado visible', (
    t,
  ) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await mount(t, changed: (_) {});
    await t.tap(find.byType(TextField));
    await t.pumpAndSettle();
    t.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(t.view.resetViewInsets);
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(ListTile, 'Don Luis'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.text('Don Luis'), findsOneWidget);
  });
}
