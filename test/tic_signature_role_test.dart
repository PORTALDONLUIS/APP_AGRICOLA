import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donluis_forms/features/tic/tic_form.dart';

void main() {
  for (final role in [
    'Firma del trabajador involucrado',
    'Firma de quien registra',
    'Firma de jefatura TIC',
  ]) {
    testWidgets('diálogo identifica: $role', (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => TicSignatureDialog(title: role),
                ),
                child: const Text('Firmar'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('Firmar'));
      await t.pumpAndSettle();
      expect(find.text(role), findsOneWidget);
      expect(find.text('Firma de quien recibe'), findsNothing);
      await t.tap(find.text('Cancelar'));
      await t.pumpAndSettle();
    });
  }
}
