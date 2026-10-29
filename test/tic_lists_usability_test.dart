import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donluis_forms/app/theme/donluis_theme.dart';
import 'package:donluis_forms/features/tic/tic_pages.dart';
import 'package:donluis_forms/features/tic/tic_cartillas.dart';
import 'package:donluis_forms/features/tic/tic_form.dart';
import 'package:donluis_forms/features/tic/tic_repository.dart';
import 'package:donluis_forms/features/tic/tic_scan.dart';
import 'tic_asignaciones_test.dart' show FakeTicRepository;

class ListRepository extends FakeTicRepository {
  final queries = <Map<String, dynamic>>[];
  Completer<Map<String, dynamic>>? delayed;
  @override
  Future<Map<String, dynamic>> get(
    String path, [
    Map<String, dynamic>? query,
  ]) async {
    queries.add(Map.from(query ?? {}));
    if (query?['q'] == 'antigua') return delayed!.future;
    return {
      'items': [
        {
          'id': 1,
          'title': 'LAP-1',
          'serial': 'SERIE-12345',
          'imei': '123456789',
          'company': 'Don Luis',
          'subtitle': 'DELL Latitude · Asignado',
        },
      ],
      'pages': 2,
      'total': 22,
    };
  }
}

void main() {
  Future<void> mount(
    WidgetTester t,
    ListRepository repo, {
    String resource = 'equipos',
    bool pick = false,
    List<Map<String, dynamic>> ops = const [],
  }) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [ticRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: donluisTheme.copyWith(
            listTileTheme: const ListTileThemeData(
              titleTextStyle: TextStyle(color: Colors.white),
            ),
          ),
          home: TicListPage(
            resource: resource,
            title: 'TIC',
            pick: pick,
            operations: ops,
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets(
    'código serie e IMEI visibles y consulta limitada a 15 registros',
    (t) async {
      final repo = ListRepository();
      await mount(t, repo);
      expect(find.text('LAP-1'), findsOneWidget);
      expect(find.text('Serie: SERIE-12345'), findsOneWidget);
      expect(find.text('IMEI: 123456789'), findsOneWidget);
      expect(repo.queries.single['page_size'], 15);
      final paragraph = t.renderObject<RenderParagraph>(find.text('LAP-1'));
      expect(paragraph.text.style?.color, Colors.black);
      expect(find.byTooltip('Leer QR o código de barras'), findsOneWidget);
      await t.tap(find.byIcon(Icons.chevron_right).last);
      await t.pumpAndSettle();
      expect(repo.queries.last['page'], 2);
    },
  );
  testWidgets(
    'buscar reinicia página y limpiar busca todos sin confirmar movimientos',
    (t) async {
      final repo = ListRepository();
      await mount(t, repo);
      await t.enterText(find.byType(TextField), 'dell 349');
      await t.pump(const Duration(milliseconds: 400));
      await t.pumpAndSettle();
      expect(repo.queries.last['q'], 'dell 349');
      expect(repo.queries.last['page'], 1);
      await t.tap(find.byTooltip('Limpiar búsqueda'));
      await t.pump(const Duration(milliseconds: 400));
      await t.pumpAndSettle();
      expect(repo.queries.last['q'], '');
      expect(repo.confirmations, 0);
    },
  );
  testWidgets('una respuesta antigua no sobrescribe la búsqueda nueva', (
    t,
  ) async {
    final repo = ListRepository()..delayed = Completer();
    await mount(t, repo);
    await t.enterText(find.byType(TextField), 'antigua');
    await t.pump(const Duration(milliseconds: 400));
    await t.pump();
    await t.enterText(find.byType(TextField), 'nueva');
    repo.delayed!.complete({
      'items': [
        {'id': 99, 'title': 'ANTIGUO', 'subtitle': ''},
      ],
      'pages': 1,
      'total': 1,
    });
    await t.pump();
    expect(find.text('ANTIGUO'), findsNothing);
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    expect(repo.queries.last['q'], 'nueva');
  });
  testWidgets('trabajadores muestra anulación cuando el catálogo la autoriza', (
    t,
  ) async {
    final repo = ListRepository();
    await mount(
      t,
      repo,
      resource: 'trabajadores',
      ops: [
        {
          'id': 'trabajador_editar',
          'target': 'trabajador',
          'title': 'Corregir trabajador',
        },
        {
          'id': 'trabajador_corregir',
          'target': 'trabajador',
          'title': 'Eliminar ficha por error',
        },
      ],
    );
    await t.tap(find.text('LAP-1'));
    await t.pumpAndSettle();
    expect(find.text('Eliminar ficha por error'), findsOneWidget);
    final text = t.renderObject<RenderParagraph>(
      find.text('Eliminar ficha por error'),
    );
    expect(text.text.style?.color, Colors.black);
  });
  testWidgets(
    'descartar formulario borra solo el borrador y no lo recrea al salir',
    (t) async {
      final repo = ListRepository();
      await t.pumpWidget(
        ProviderScope(
          overrides: [ticRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: TextButton(
                  child: const Text('Abrir'),
                  onPressed: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) =>
                          const TicFormPage(operation: 'equipo_nuevo'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('Abrir'));
      await t.pumpAndSettle();
      await t.enterText(
        find.widgetWithText(TextField, 'Marca *'),
        'Dato de prueba',
      );
      await t.pump(const Duration(milliseconds: 500));
      await t.pumpAndSettle();
      expect(repo.saved, isNotNull);
      await t.tap(find.byTooltip('Descartar borrador'));
      await t.pumpAndSettle();
      await t.tap(find.text('Descartar'));
      await t.pumpAndSettle();
      await t.pump(const Duration(seconds: 1));
      expect(repo.saved, isNull);
      expect(repo.confirmations, 0);
      expect(find.text('Abrir'), findsOneWidget);
    },
  );
  test('código leído es texto acotado y nunca se ejecuta como enlace', () {
    expect(ticScanText('  GEN-000123\n'), 'GEN-000123');
    expect(
      ticScanText('https://ejemplo.test/equipo/1'),
      'https://ejemplo.test/equipo/1',
    );
    expect(ticScanText('x' * 300).length, 150);
    expect(ticScanText(''), '');
  });
  for (final cartilla in ticCartillas.entries) {
    testWidgets('menú visible con texto negro en ${cartilla.value}', (t) async {
      await t.pumpWidget(
        ProviderScope(
          overrides: [
            ticCatalogProvider.overrideWith(
              (ref) async => {'operations': <Map<String, dynamic>>[]},
            ),
            ticDraftsProvider.overrideWith(
              (ref) async => <Map<String, dynamic>>[],
            ),
          ],
          child: MaterialApp(
            theme: donluisTheme.copyWith(
              listTileTheme: const ListTileThemeData(
                titleTextStyle: TextStyle(color: Colors.white),
              ),
            ),
            home: TicCartillaPage(
              templateKey: cartilla.key,
              title: cartilla.value,
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final label = cartilla.key.endsWith('reportes')
          ? 'Reportes corporativos'
          : 'Consultar y editar';
      final text = t.renderObject<RenderParagraph>(find.text(label));
      expect(text.text.style?.color, Colors.black);
      expect(t.takeException(), isNull);
    });
  }
  testWidgets(
    'quitar una RAM conserva la otra pieza y no confirma inventario',
    (t) async {
      final repo = ListRepository();
      await t.pumpWidget(
        ProviderScope(
          overrides: [ticRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(
            home: TicFormPage(operation: 'equipo_nuevo'),
          ),
        ),
      );
      await t.pumpAndSettle();
      final trash = find.byTooltip('Quitar memoria RAM 1');
      await t.scrollUntilVisible(
        trash.hitTestable(),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await t.pumpAndSettle();
      await t.tap(trash);
      await t.pumpAndSettle();
      await t.tap(find.text('Quitar'));
      await t.pumpAndSettle();
      await t.pump(const Duration(milliseconds: 500));
      await t.pumpAndSettle();
      expect(repo.saved!['values']['ram_cantidad'], 1);
      expect(repo.saved!['values']['ram_capacidad'], [16]);
      expect(repo.saved!['values']['disco_capacidad'], [512]);
      expect(repo.confirmations, 0);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));
    },
  );
}
