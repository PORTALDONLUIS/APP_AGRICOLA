import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donluis_forms/features/tic/tic_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donluis_forms/features/tic/tic_form.dart';
import 'package:donluis_forms/features/tic/tic_pages.dart';
import 'tic_asignaciones_test.dart' show FakeTicRepository;

class PartialRepository extends FakeTicRepository {
  PartialRepository(this.scope);
  final String scope;
  @override
  Future<Map<String, dynamic>> schema(
    String op,
    String target, {
    String? type,
  }) async {
    final data = await super.schema(op, target, type: type);
    (data['fields'] as List).insert(0, {
      'name': 'alcance',
      'label': '¿Qué deseas actualizar?',
      'type': 'lista',
      'value': scope,
      'required': false,
      'choices': [
        {'value': 'ram', 'label': 'Solo memoria RAM'},
        {'value': 'disco', 'label': 'Solo almacenamiento'},
        {'value': 'completo', 'label': 'Configuración completa'},
      ],
    });
    return data;
  }
}

class WorkerRepository extends FakeTicRepository {
  Map<String, dynamic>? query;
  @override
  Future<Map<String, dynamic>> catalog() async => {
    'operations': [
      {'id': 'entrega', 'title': 'Entrega de equipo', 'target': 'equipo'},
      {'id': 'equipo_corregir', 'title': 'Eliminar equipo', 'target': 'equipo'},
    ],
  };
  @override
  Future<Map<String, dynamic>> get(
    String path, [
    Map<String, dynamic>? params,
  ]) async {
    if (path == 'trabajadores') {
      return {
        'items': [
          {
            'id': 7,
            'title': 'TRABAJADOR PRUEBA',
            'subtitle': 'TIC',
            'dni': '12345678',
            'area': 'TIC',
            'canReceive': true,
          },
        ],
        'pages': 1,
        'total': 1,
      };
    }
    if (path == 'equipos') {
      query = params;
      return {
        'items': [
          {
            'id': 1,
            'title': 'LAPTOP001',
            'serial': 'SERIE-UNO',
            'subtitle': 'Dell · Asignado',
            'company': 'Don Luis',
          },
        ],
        'pages': 1,
        'total': 1,
      };
    }
    return {
      'id': 1,
      'title': 'LAPTOP001',
      'subtitle': 'Dell',
      'status': 'Asignado',
      'assignedTo': 'TRABAJADOR PRUEBA',
      'assignmentId': '',
      'details': [],
      'ram': [],
      'disks': [],
      'history': [],
      'reports': [],
    };
  }
}

void main() {
  testWidgets(
    'desde trabajador muestra equipos y abre acciones de cada equipo',
    (tester) async {
      final repo = WorkerRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [ticRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(
            home: TicListPage(resource: 'trabajadores', title: 'Trabajadores'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('TRABAJADOR PRUEBA'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver todo lo asignado'));
      await tester.pumpAndSettle();
      expect(repo.query?['trabajador_id'], '7');
      expect(find.text('Serie: SERIE-UNO'), findsOneWidget);
      expect(
        find.byTooltip('Asignar equipo a este trabajador'),
        findsOneWidget,
      );
      await tester.tap(find.text('LAPTOP001'));
      await tester.pumpAndSettle();
      expect(find.text('Eliminar equipo / anular movimiento'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final scope in ['ram', 'disco']) {
    testWidgets('ampliación $scope muestra solo los campos seleccionados', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ticRepositoryProvider.overrideWithValue(PartialRepository(scope)),
          ],
          child: const MaterialApp(
            home: TicFormPage(operation: 'componentes', target: '1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          scope == 'ram' ? 'Cantidad RAM' : 'Cantidad discos',
        ),
        findsWidgets,
      );
      expect(
        find.textContaining(
          scope == 'ram' ? 'Cantidad discos' : 'Cantidad RAM',
        ),
        findsNothing,
      );
      expect(find.text('Procesador'), findsNothing);
      expect(
        find.text(scope == 'ram' ? 'Agregar disco' : 'Agregar memoria RAM'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
