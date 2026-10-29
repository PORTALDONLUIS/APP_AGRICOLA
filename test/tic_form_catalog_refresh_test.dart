import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donluis_forms/features/tic/tic_form.dart';
import 'package:donluis_forms/features/tic/tic_repository.dart';
import 'tic_asignaciones_test.dart' show FakeTicRepository;

class CatalogRepository extends FakeTicRepository {
  int generation = 1;
  bool offline = false;
  @override
  Future<Map<String, dynamic>> schema(
    String op,
    String target, {
    String? type,
  }) async {
    if (offline) throw Exception('Sin conexión');
    return {
      'title': 'Equipo',
      'revision': 'v$generation',
      'fields': [
        {
          'name': 'marca',
          'label': 'Marca',
          'type': 'catalogo',
          'value': '',
          'choicesCatalogo': [
            {'value': 'Marca $generation', 'label': 'Marca $generation'},
          ],
        },
        {'name': 'serie', 'label': 'Serie', 'type': 'texto', 'value': ''},
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> get(
    String path, [
    Map<String, dynamic>? query,
  ]) async {
    throw DioException(
      requestOptions: RequestOptions(path: path),
      response: Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 404,
      ),
    );
  }
}

void main() {
  Future<void> mount(WidgetTester t, CatalogRepository repo) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [ticRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: TicFormPage(operation: 'equipo_nuevo')),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> close(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
  }

  testWidgets('actualizar carga opciones nuevas y conserva serie ingresada', (
    t,
  ) async {
    final repo = CatalogRepository();
    await mount(t, repo);
    await t.enterText(find.widgetWithText(TextField, 'Serie'), 'SERIE-123');
    repo.generation = 2;
    await t.tap(find.byIcon(Icons.refresh));
    await t.pumpAndSettle();
    await t.tap(find.text('Cargar ficha actual'));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Mostrar opciones de Marca'));
    await t.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Marca 2'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Marca 1'), findsNothing);
    expect(find.text('SERIE-123'), findsOneWidget);
    expect(repo.confirmations, 0);
    await close(t);
    expect(repo.saved!['values']['serie'], 'SERIE-123');
  });
  for (final offline in [false, true]) {
    testWidgets(
      'recupera borrador y fotos con catálogo ${offline ? 'local' : 'actualizado'}',
      (t) async {
        final repo = CatalogRepository();
        repo.saved = {
          'schema': await repo.schema('equipo_nuevo', ''),
          'values': {'marca': 'Marca propia', 'serie': 'ABC'},
          'photos': {'foto': '/local/foto.jpg'},
          'operationId': 'id-conservado',
          'revision': 'v1',
        };
        repo.generation = 2;
        repo.offline = offline;
        await mount(t, repo);
        await t.tap(find.byTooltip('Mostrar opciones de Marca'));
        await t.pumpAndSettle();
        expect(
          find.widgetWithText(ListTile, offline ? 'Marca 1' : 'Marca 2'),
          findsOneWidget,
        );
        expect(find.text('ABC'), findsOneWidget);
        await close(t);
        expect(repo.saved!['values']['marca'], 'Marca propia');
        expect(repo.saved!['photos']['foto'], '/local/foto.jpg');
        expect(repo.saved!['revision'], 'v1');
        expect(repo.saved!['operationId'], 'id-conservado');
        expect(repo.confirmations, 0);
      },
    );
  }
}
