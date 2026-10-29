import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donluis_forms/features/tic/tic_form.dart';
import 'package:donluis_forms/features/tic/tic_cartillas.dart';
import 'package:donluis_forms/features/cartillas/application/photo_service.dart';
import 'package:donluis_forms/features/tic/tic_repository.dart';

class FakeTicRepository extends TicRepository {
  FakeTicRepository() : super(Dio(), const FlutterSecureStorage(), 4023);
  Map<String, dynamic>? saved;
  int confirmations = 0;
  @override
  Future<Map<String, dynamic>?> draft(String op, String target) async => saved;
  @override
  Future<void> saveDraft(
    String op,
    String target,
    Map<String, dynamic> value,
  ) async {
    saved = jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
  }

  @override
  Future<void> clearDraft(String op, String target) async {
    saved = null;
  }

  @override
  Future<Map<String, dynamic>> schema(
    String op,
    String target, {
    String? type,
  }) async => {
    'title': 'Registrar equipo',
    'revision': 'version-1',
    'suggestions': {
      'ram_capacidad': ['8', '16', '32', '64'],
    },
    'fields': [
      {
        'name': 'tipo',
        'label': 'Tipo',
        'type': 'lista',
        'value': 'pc',
        'required': true,
        'choices': [
          {'value': 'pc', 'label': 'PC'},
        ],
      },
      {
        'name': 'marca',
        'label': 'Marca',
        'type': 'texto',
        'value': 'Marca prueba',
        'required': true,
      },
      {
        'name': 'procesador',
        'label': 'Procesador',
        'type': 'texto',
        'value': 'CPU',
        'required': true,
      },
      {
        'name': 'ram_cantidad',
        'label': 'Cantidad RAM',
        'type': 'numero',
        'value': 2,
        'required': true,
      },
      {
        'name': 'disco_cantidad',
        'label': 'Cantidad discos',
        'type': 'numero',
        'value': 1,
        'required': true,
      },
    ],
    'components': {
      'ram': [8, 16],
      'discos': [512],
      'tipos': ['ssd'],
    },
  };
  @override
  Future<Map<String, dynamic>> confirm(
    String op,
    String target,
    Map<String, dynamic> draft,
  ) async {
    confirmations++;
    return {
      'ok': true,
      'title': 'Equipo registrado',
      'messages': ['Registro confirmado'],
      'pdf': 'equipo/1',
    };
  }
}

void main() {
  test('registro de ocho cartillas TIC no altera las agrícolas', () {
    expect(ticCartillas.length, 8);
    expect(esCartillaTic('cartilla-tic-equipos'), true);
    expect(esCartillaTic('cartilla_brix_moscatel'), false);
    expect(esCartillaTic('cartilla_cosecha_uva'), false);
  });
  test(
    'servicio compartido de fotos rechaza ámbito fuera de carpeta',
    () async {
      await expectLater(
        PhotoService().captureToSlot(
          localId: 0,
          slot: 1,
          storageScope: '../otra-carpeta',
        ),
        throwsArgumentError,
      );
    },
  );
  testWidgets('cartilla TIC reutiliza acceso a nuevo registro y resumen PDF', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticCatalogProvider.overrideWith(
            (ref) async => {
              'operations': [
                {
                  'id': 'equipo_nuevo',
                  'title': 'Registrar equipo',
                  'target': '',
                },
              ],
            },
          ),
          ticDraftsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          home: TicCartillaPage(
            templateKey: 'cartilla_tic_equipos',
            title: 'Plantilla TIC Equipos',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nuevo registro'), findsOneWidget);
    expect(find.text('Resumen y documentos PDF'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('reducir componentes envía exactamente la cantidad indicada', () async {
    final dio = Dio();
    FormData? sent;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          sent = options.data as FormData;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'ok': true},
            ),
          );
        },
      ),
    );
    final repo = TicRepository(dio, const FlutterSecureStorage(), 4023);
    await repo.confirm('equipo_nuevo', '', {
      'operationId': ticId(),
      'revision': '',
      'photos': {},
      'values': {
        'tipo': 'pc',
        'ram_cantidad': '1',
        'ram_capacidad': ['8', '16'],
        'disco_cantidad': '1',
        'disco_capacidad': ['512', '1024'],
        'disco_tipo_item': ['ssd', 'hdd'],
      },
    });
    expect(
      sent!.fields
          .where((v) => v.key == 'ram_capacidad')
          .map((v) => v.value)
          .toList(),
      ['8'],
    );
    expect(
      sent!.fields
          .where((v) => v.key == 'disco_capacidad')
          .map((v) => v.value)
          .toList(),
      ['512'],
    );
  });
  test('respuesta perdida recupera acuse sin repetir el envío', () async {
    final dio = Dio();
    var posts = 0;
    var gets = 0;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.method == 'POST') {
            posts++;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          } else {
            gets++;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'ok': true, 'pdf': 'equipo/1'},
              ),
            );
          }
        },
      ),
    );
    final repo = TicRepository(dio, const FlutterSecureStorage(), 4023);
    final receipt = await repo.confirm('equipo_nuevo', '', {
      'operationId': ticId(),
      'revision': '',
      'photos': {},
      'values': {'tipo': 'radio'},
    });
    expect(receipt['ok'], true);
    expect(posts, 1);
    expect(gets, 1);
  });

  test(
    'cambiar cuenta bloquea una confirmación iniciada por otro usuario',
    () async {
      final repo = TicRepository(
        Dio(),
        const FlutterSecureStorage(),
        4023,
        currentUserId: () => 77,
      );
      await expectLater(
        repo.confirm('equipo_nuevo', '', {}),
        throwsA(isA<FormatException>()),
      );
    },
  );

  test('identificadores de operación UUID únicos', () {
    final ids = List.generate(500, (_) => ticId());
    expect(ids.toSet().length, 500);
    expect(
      ids.every(
        (id) => RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(id),
      ),
      isTrue,
    );
  });
  testWidgets(
    'varias RAM conservan valores independientes y guardar borrador no confirma',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = FakeTicRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [ticRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(
            home: TicFormPage(operation: 'equipo_nuevo'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final caps = find.widgetWithText(TextField, 'Capacidad (GB o TB)');
      await tester.ensureVisible(caps.at(0));
      await tester.enterText(caps.at(0), '32');
      await tester.pump();
      await tester.ensureVisible(caps.at(1));
      await tester.enterText(caps.at(1), '64');
      await tester.pump();
      tester.testTextInput.hide();
      await tester.pump();
      final save = find.text('Guardar borrador');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repo.saved!['values']['ram_capacidad'], ['32', '64']);
      expect(repo.confirmations, 0);
      expect(repo.saved!['revision'], 'version-1');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    },
  );
  testWidgets('cancelar confirmación no envía movimiento', (tester) async {
    final repo = FakeTicRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [ticRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: TicFormPage(operation: 'equipo_nuevo')),
      ),
    );
    await tester.pumpAndSettle();
    final confirm = find.text('Confirmar en DonTec');
    await tester.scrollUntilVisible(
      confirm,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revisar'));
    await tester.pumpAndSettle();
    expect(repo.confirmations, 0);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
  testWidgets('firma no permite confirmar recuadro vacío', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TicSignatureDialog())),
    );
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Usar firma'),
    );
    expect(button.onPressed, isNull);
  });
}
