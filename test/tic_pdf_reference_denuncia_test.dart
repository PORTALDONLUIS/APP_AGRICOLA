import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donluis_forms/features/tic/tic_cartillas.dart';
import 'package:donluis_forms/features/tic/tic_form.dart';
import 'package:donluis_forms/features/tic/tic_pages.dart';
import 'package:donluis_forms/features/tic/tic_repository.dart';
import 'tic_asignaciones_test.dart' show FakeTicRepository;

class _ReferenceAndDenunciaRepo extends FakeTicRepository {
  _ReferenceAndDenunciaRepo({this.isRobbery = false, this.initialIncidencia = ''});
  final bool isRobbery;
  final String initialIncidencia;

  @override
  Future<Map<String, dynamic>> schema(
    String op,
    String target, {
    String? type,
  }) async => {
    'title': op == 'informe_cerrar' ? 'Diagnóstico y cierre' : 'Nuevo informe',
    'revision': 'rev-1',
    'isRobbery': isRobbery,
    'summary': 'Informe #48 · PC004-1 · MARCADOR CABILDO',
    'reference': {
      'header': 'Informe #48',
      'equipment': 'PC004-1 · HP PRODESK 400 G5 DESKTOP MINI · DON LUIS',
      'equipmentCode': 'PC004-1',
      'hostName': 'RRHH-CABILDO',
      'assignedTo': 'MARCADOR CABILDO',
      'area': 'RRHH',
      'cargo': '',
      'status': 'Operativo',
      'reportMeta': 'Mantenimiento preventivo · Abierto · Limpieza',
    },
    'fields': [
      if (op == 'informe_nuevo')
        {
          'name': 'tipo',
          'label': 'Tipo de informe',
          'type': 'lista',
          'value': 'preventivo',
          'required': true,
          'choices': [
            {'value': 'preventivo', 'label': 'Mantenimiento preventivo'},
            {'value': 'falla', 'label': 'Falla / incidencia'},
          ],
        },
      {
        'name': 'incidencia',
        'label': 'Estado del equipo reportado',
        'type': 'lista',
        'value': initialIncidencia,
        'required': false,
        'choices': [
          {'value': '', 'label': 'Sin cambio de estado'},
          {'value': 'robado', 'label': 'Robado'},
          {'value': 'malogrado', 'label': 'Malogrado'},
        ],
      },
      {
        'name': 'documento_denuncia',
        'label': 'Denuncia policial / sustento adjunto (PDF, hasta 15 MB)',
        'type': 'pdf',
        'value': null,
        'required': false,
      },
    ],
  };

  @override
  Future<Map<String, dynamic>> get(
    String path, [
    Map<String, dynamic>? query,
  ]) async {
    if (path == 'documentos') {
      return {
        'items': [
          {
            'id': 'op-1',
            'title': 'Falla, mantenimiento o reparación · PC004-1',
            'subtitle': '2026-11-26T10:00:00',
            'equipmentCode': 'PC004-1',
            'equipmentLabel': 'PC004-1 · HP PRODESK 400 G5',
            'assignedTo': 'MARCADOR CABILDO',
            'area': 'RRHH',
            'reportSubject': '#48 · Mantenimiento preventivo',
            'document': {
              'title': 'Falla, mantenimiento o reparación',
              'pdf': 'informe/48',
              'messages': ['Informe registrado.'],
              'canClose': true,
              'reportId': '48',
            },
          },
        ],
        'pages': 1,
        'total': 1,
      };
    }
    return {
      'items': [
        {
          'id': 4,
          'title': 'PC004-1',
          'serial': 'MXL12345',
          'imei': '',
          'company': 'Don Luis',
          'subtitle': 'HP PRODESK · Asignado · Operativo',
          'assignedTo': 'MARCADOR CABILDO',
          'area': 'RRHH',
        },
      ],
      'pages': 1,
      'total': 1,
    };
  }
}

void main() {
  test('nombre de archivo PDF respeta Content-Disposition de DonTec Web', () {
    expect(
      ticFilenameFromContentDisposition(
        'attachment; filename="informe-mantenimiento-preventivo-pc004-1-marcador-cabildo-2026-11-26.pdf"',
        reference: 'informe/48',
        title: 'Informe',
      ),
      'informe-mantenimiento-preventivo-pc004-1-marcador-cabildo-2026-11-26.pdf',
    );
    expect(
      ticFilenameFromContentDisposition(
        "attachment; filename*=UTF-8''asignacion-david-culqui-laptop033-1-2026-11-26.pdf",
        reference: 'acta/abc',
        title: 'Acta de entrega',
      ),
      'asignacion-david-culqui-laptop033-1-2026-11-26.pdf',
    );
    expect(
      ticFilenameFromContentDisposition(
        'attachment; filename="../../malicioso/reporte-tic-informes-2026-11-26.pdf"',
        reference: 'reporte/tecnico',
        title: 'Reporte',
      ),
      'reporte-tic-informes-2026-11-26.pdf',
    );
    // Fallback legible sin hash SHA256 cuando falta el encabezado
    expect(
      ticFilenameFromContentDisposition(
        null,
        reference: 'informe/48',
        title: 'Informe preventivo',
      ),
      'informe-preventivo-informe-48.pdf',
    );
  });

  testWidgets(
    'formulario de informe muestra referencia de equipo y trabajador y oculta denuncia si no es robado',
    (tester) async {
      final repo = _ReferenceAndDenunciaRepo(
        isRobbery: false,
        initialIncidencia: '',
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [ticRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(
            home: TicFormPage(operation: 'informe_cerrar', target: '48'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Informe #48'), findsOneWidget);
      expect(
        find.text('PC004-1 · HP PRODESK 400 G5 DESKTOP MINI · DON LUIS'),
        findsOneWidget,
      );
      expect(find.text('Asignación vinculada'), findsOneWidget);
      expect(find.text('MARCADOR CABILDO · RRHH'), findsOneWidget);
      expect(find.text('Host: RRHH-CABILDO'), findsOneWidget);
      // Denuncia oculta en informe no robado
      expect(find.text('Adjuntar denuncia (PDF)'), findsNothing);
    },
  );

  testWidgets(
    'formulario de informe muestra adjuntar denuncia PDF únicamente cuando es Robado',
    (tester) async {
      final repo = _ReferenceAndDenunciaRepo(
        isRobbery: true,
        initialIncidencia: 'robado',
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [ticRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(
            home: TicFormPage(operation: 'informe_cerrar', target: '48'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Adjuntar denuncia (PDF)'), findsOneWidget);
    },
  );

  testWidgets(
    'listados de equipos y documentos muestran trabajador asignado y referencia del equipo',
    (tester) async {
      final repo = _ReferenceAndDenunciaRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [ticRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(
            home: TicListPage(resource: 'documentos', title: 'Documentos TIC'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('PC004-1 · HP PRODESK 400 G5'),
        findsOneWidget,
      );
      expect(find.text('Asignado a: MARCADOR CABILDO · RRHH'), findsOneWidget);
      expect(find.text('#48 · Mantenimiento preventivo'), findsOneWidget);
    },
  );

  testWidgets(
    'plantilla unificada Inventario TIC expone acciones rápidas, 4 módulos y borradores',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ticCatalogProvider.overrideWith(
              (ref) async => {
                'operations': [
                  {'id': 'equipo_nuevo', 'title': 'Registrar equipo', 'target': ''},
                  {'id': 'entrega', 'title': 'Entrega de equipo', 'target': 'equipo'},
                  {'id': 'devolucion', 'title': 'Devolución', 'target': 'equipo'},
                  {'id': 'informe_nuevo', 'title': 'Informe', 'target': 'equipo'},
                  {'id': 'informe_cerrar', 'title': 'Cerrar informe', 'target': 'informe'},
                  {'id': 'componentes', 'title': 'Ampliación', 'target': 'equipo'},
                ],
              },
            ),
            ticDraftsProvider.overrideWith(
              (ref) async => [
                {
                  'operation': 'informe_cerrar',
                  'target': '48',
                  'title': 'Diagnóstico y cierre',
                  'summary': 'Informe #48 · PC004-1 · MARCADOR CABILDO',
                },
              ],
            ),
          ],
          child: const MaterialApp(
            home: TicCartillaPage(
              templateKey: ticCartillaUnificada,
              title: 'Inventario TIC',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Inventario TIC'), findsOneWidget);
      expect(find.text('Escanear QR o código de barras'), findsOneWidget);
      expect(find.text('Informes pendientes de cierre'), findsOneWidget);
      expect(find.text('Nuevo equipo'), findsOneWidget);
      expect(find.text('Entregar'), findsOneWidget);
      expect(find.text('Devolver'), findsOneWidget);
      expect(find.text('Nuevo informe'), findsOneWidget);
      expect(find.text('Ampliación'), findsOneWidget);
      expect(find.text('Equipos'), findsOneWidget);
      expect(find.text('Trabajadores'), findsOneWidget);
      expect(find.text('Consumibles y servicios'), findsOneWidget);
      expect(find.text('Reportes corporativos'), findsOneWidget);
      expect(find.text('Resumen y documentos PDF'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Informe #48 · PC004-1 · MARCADOR CABILDO'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text('Informe #48 · PC004-1 · MARCADOR CABILDO'),
        findsOneWidget,
      );
    },
  );
}
