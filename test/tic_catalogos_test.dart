import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:donluis_forms/features/tic/tic_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donluis_forms/features/tic/tic_form.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    bool allowNew = true,
    int? maxLength,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showSearch<Map<String, dynamic>?>(
                context: context,
                delegate: TicChoiceSearch(
                  [
                    {
                      'value': 'TECNOLOGÍA DE INFORMACIÓN',
                      'label': 'TECNOLOGÍA DE INFORMACIÓN',
                    },
                  ],
                  allowNew: allowNew,
                  maxLength: maxLength,
                ),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('filtra sin exigir acentos ni texto completo', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'tecnologia informacion');
    await tester.pumpAndSettle();
    expect(find.text('TECNOLOGÍA DE INFORMACIÓN'), findsOneWidget);
  });
  testWidgets('permite elegir un valor nuevo sin guardar automáticamente', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'Nueva sede');
    await tester.pumpAndSettle();
    expect(find.text('Usar: Nueva sede'), findsOneWidget);
    await tester.tap(find.text('Usar: Nueva sede'));
    await tester.pumpAndSettle();
    expect(find.text('Abrir'), findsOneWidget);
  });
  testWidgets('empresa y estados controlados no admiten opciones nuevas', (
    tester,
  ) async {
    await open(tester, allowNew: false);
    await tester.enterText(find.byType(TextField), 'Empresa inventada');
    await tester.pumpAndSettle();
    expect(find.text('Usar: Empresa inventada'), findsNothing);
  });
  testWidgets('respeta longitud máxima y permite quitar una selección', (
    tester,
  ) async {
    await open(tester, maxLength: 5);
    expect(find.text('Dejar sin seleccionar'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Demasiado largo');
    await tester.pumpAndSettle();
    expect(find.text('Usar: Demasiado largo'), findsNothing);
  });
  test('un acuse anulado no se presenta como confirmado', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.method == 'POST') {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 409,
                  data: {
                    'ok': false,
                    'annulled': true,
                    'error': 'Operación anulada',
                  },
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          } else {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'ok': false,
                  'annulled': true,
                  'error': 'Operación anulada',
                },
              ),
            );
          }
        },
      ),
    );
    final repo = TicRepository(dio, const FlutterSecureStorage(), 4023);
    await expectLater(
      repo.confirm('equipo_nuevo', '', {
        'operationId': ticId(),
        'values': {},
        'photos': {},
      }),
      throwsA(isA<DioException>()),
    );
  });
  test('una respuesta sin confirmación conserva el error', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'ok': false, 'error': 'Sin confirmación'},
          ),
        ),
      ),
    );
    final repo = TicRepository(dio, const FlutterSecureStorage(), 4023);
    await expectLater(
      repo.confirm('equipo_nuevo', '', {
        'operationId': ticId(),
        'values': {},
        'photos': {},
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
