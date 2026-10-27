import 'dart:async';
import 'dart:convert';

import 'package:donluis_forms/app/providers.dart';
import 'package:donluis_forms/core/sync/sync_models.dart';
import 'package:donluis_forms/features/master/presentation/master_providers.dart';
import 'package:donluis_forms/features/registros/data/registros_local_ds.dart';
import 'package:donluis_forms/features/registros/domain/registro.dart';
import 'package:donluis_forms/features/registros/presentation/registros_controller.dart';
import 'package:donluis_forms/features/registros/presentation/registros_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _templateKey = 'cartilla_brix_moscatel';
const _plantillaId = 77;

class _LocalSinIO extends Fake implements RegistrosLocalDS {
  int draftsCreated = 0;
  int queuedSamples = 0;
  ({int userId, String templateKey, int? plantillaId, List<int>? localIds})?
  queueRequest;

  @override
  Future<int> createDraft({
    required int plantillaId,
    required String templateKey,
    required int userId,
  }) async {
    draftsCreated++;
    return 10000 + draftsCreated;
  }

  @override
  Future<int> countSyncQueue({
    required int userId,
    required String templateKey,
    int? plantillaId,
    List<int>? localIds,
  }) async {
    queueRequest = (
      userId: userId,
      templateKey: templateKey,
      plantillaId: plantillaId,
      localIds: localIds,
    );
    return queuedSamples;
  }
}

class _MuestraContada extends Registro {
  int payloadReads = 0;

  _MuestraContada(int id, {int loteId = 1})
    : super(
        localId: id,
        clientRecordId: 'diagnostico-$id',
        serverId: null,
        plantillaId: _plantillaId,
        templateKey: _templateKey,
        userId: 1,
        campaniaId: '2026',
        loteId: loteId,
        lat: -14.06,
        lon: -75.73,
        estado: EstadoRegistro.borrador,
        syncStatus: SyncStatus.pending,
        syncError: null,
        syncAttempts: 0,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        deletedAt: null,
        dataJson: jsonEncode({
          'payloadVersion': 1,
          'header': {
            'plantillaId': _plantillaId,
            'userId': 1,
            'loteId': loteId,
            'fechaEjecucion': DateTime.now().toUtc().millisecondsSinceEpoch,
          },
          'body': {
            'hilera': 10,
            'planta': 2,
            'variedad': 3,
            'corresponde': 'PODA',
            'brixSsc': 16.5,
          },
        }),
      );

  @override
  Map<String, dynamic> normalizedPayload() {
    payloadReads++;
    return super.normalizedPayload();
  }
}

class _Fixture {
  final local = _LocalSinIO();
  final updates = StreamController<List<Registro>>.broadcast();
  List<Registro> records;
  int activeSubscriptions = 0;
  int subscriptionsStarted = 0;
  int formsOpened = 0;

  _Fixture(int count)
    : records = List.generate(count, (i) => _MuestraContada(count - i));

  Stream<List<Registro>> watch() => Stream.multi((sink) {
    activeSubscriptions++;
    subscriptionsStarted++;
    sink.add(records);
    final subscription = updates.stream.listen(
      sink.add,
      onError: sink.addError,
    );
    sink.onCancel = () async {
      activeSubscriptions--;
      await subscription.cancel();
    };
  });

  void append(Registro registro) {
    records = [registro, ...records];
    updates.add(records);
  }
}

Finder _tiles({bool skipOffstage = true}) => find.byWidgetPredicate(
  (widget) => widget.runtimeType.toString() == '_RegistroTile',
  skipOffstage: skipOffstage,
);

int _tableRowCount(WidgetTester tester) => tester
    .widgetList<DataTable>(find.byType(DataTable))
    .fold(0, (count, table) => count + table.rows.length);

Future<void> _mount(
  WidgetTester tester,
  _Fixture fixture, {
  Size size = const Size(430, 900),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        registrosLocalDSProvider.overrideWithValue(fixture.local),
        currentUserIdProvider.overrideWithValue(1),
        registrosByPlantillaProvider(
          _plantillaId,
        ).overrideWith((ref) => fixture.watch()),
        lotesStreamProvider.overrideWith((ref) => Stream.value([])),
      ],
      child: MaterialApp(
        home: const RegistrosPage(
          plantillaId: _plantillaId,
          templateKey: _templateKey,
          plantillaNombre: 'Brix Moscatel',
        ),
        onGenerateRoute: (settings) {
          fixture.formsOpened++;
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Formulario de prueba')),
              body: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver a muestras'),
              ),
            ),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _unmount(WidgetTester tester, _Fixture fixture) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  expect(fixture.activeSubscriptions, 0);
  await fixture.updates.close();
}

void main() {
  for (final count in [100, 1000, 1500]) {
    testWidgets('lista lazy con $count muestras y pausa al editar', (
      tester,
    ) async {
      final fixture = _Fixture(count);
      final initial = Stopwatch()..start();
      await _mount(tester, fixture);
      initial.stop();
      final mountedTiles = _tiles().evaluate().length;
      expect(mountedTiles, inInclusiveRange(1, 20));
      expect(find.text('Muestras hoy: $count'), findsOneWidget);
      expect(fixture.activeSubscriptions, 1);
      expect(tester.takeException(), isNull);

      await tester.tap(_tiles().first);
      await tester.pumpAndSettle();
      expect(find.text('Formulario de prueba'), findsOneWidget);
      expect(fixture.activeSubscriptions, 0);
      expect(_tiles(skipOffstage: false), findsNothing);
      final readsBefore = fixture.records.cast<_MuestraContada>().fold<int>(
        0,
        (sum, registro) => sum + registro.payloadReads,
      );
      final covered = Stopwatch()..start();
      fixture.append(_MuestraContada(count + 1));
      await tester.pumpAndSettle();
      covered.stop();
      expect(
        fixture.records.cast<_MuestraContada>().fold<int>(
          0,
          (sum, registro) => sum + registro.payloadReads,
        ),
        readsBefore,
      );

      await tester.tap(find.text('Volver a muestras'));
      await tester.pumpAndSettle();
      expect(fixture.activeSubscriptions, 1);
      expect(fixture.subscriptionsStarted, 2);
      expect(find.text('Muestras hoy: ${count + 1}'), findsOneWidget);
      expect(_tiles().evaluate().length, inInclusiveRange(1, 20));
      // Medición diagnóstica en host; no equivale a rendimiento en Android.
      // ignore: avoid_print
      print(
        'PERF_RESULT ${jsonEncode({'n': count, 'tilesMounted': mountedTiles, 'initialPumpMs': initial.elapsedMilliseconds, 'coveredUpdateMs': covered.elapsedMilliseconds})}',
      );
      await _unmount(tester, fixture);
    });
  }

  testWidgets('crear suspende stream y evita doble creación', (tester) async {
    final fixture = _Fixture(1000);
    await _mount(tester, fixture);
    final createButton = tester.widget<FloatingActionButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is FloatingActionButton &&
            widget.tooltip == 'Nuevo registro',
      ),
    );
    createButton.onPressed!();
    createButton.onPressed!();
    await tester.pumpAndSettle();
    expect(fixture.local.draftsCreated, 1);
    expect(fixture.formsOpened, 1);
    expect(fixture.activeSubscriptions, 0);
    fixture.append(_MuestraContada(1001));
    await tester.tap(find.text('Volver a muestras'));
    await tester.pumpAndSettle();
    expect(fixture.activeSubscriptions, 1);
    expect(find.text('Muestras hoy: 1001'), findsOneWidget);
    await _unmount(tester, fixture);
  });

  testWidgets('tabla paginada conserva referencias y limita decodificaciones', (
    tester,
  ) async {
    final fixture = _Fixture(1500);
    await _mount(tester, fixture);
    for (final registro in fixture.records.cast<_MuestraContada>()) {
      registro.payloadReads = 0;
    }
    await tester.tap(find.text('Tabla'));
    await tester.pumpAndSettle();
    expect(_tableRowCount(tester), 25);
    expect(find.text('Muestras 1–25 de 1500'), findsOneWidget);
    expect(find.text('Ref. #1500'), findsOneWidget);
    final payloadReads = fixture.records.cast<_MuestraContada>().fold<int>(
      0,
      (sum, registro) => sum + registro.payloadReads,
    );
    // Dos filtros por fecha en la pantalla + una lectura por fila visible.
    expect(payloadReads, lessThanOrEqualTo(1500 * 2 + 25));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Página siguiente'));
    await tester.pumpAndSettle();
    expect(_tableRowCount(tester), 25);
    expect(find.text('Muestras 26–50 de 1500'), findsOneWidget);
    expect(find.text('Ref. #1475'), findsOneWidget);
    expect(find.text('Ref. #1500'), findsNothing);

    final row = tester.widget<DataTable>(find.byType(DataTable)).rows.first;
    row.cells.first.onTap!();
    await tester.pumpAndSettle();
    expect(fixture.activeSubscriptions, 0);
    await tester.tap(find.text('Volver a muestras'));
    await tester.pumpAndSettle();
    expect(fixture.activeSubscriptions, 1);
    expect(find.text('Muestras 26–50 de 1500'), findsOneWidget);
    expect(find.text('Ref. #1475'), findsOneWidget);

    final sizePicker = tester.widget<DropdownButton<int>>(
      find.byType(DropdownButton<int>),
    );
    sizePicker.onChanged!(50);
    await tester.pumpAndSettle();
    expect(_tableRowCount(tester), 50);
    expect(find.text('Muestras 1–50 de 1500'), findsOneWidget);
    // La referencia no se reinicia al cambiar el tamaño de página.
    expect(find.text('Ref. #1500'), findsOneWidget);
    await _unmount(tester, fixture);
  });

  testWidgets(
    'tabla pagina entre lotes y ajusta la última página al eliminar',
    (tester) async {
      final fixture = _Fixture(0);
      fixture.records = List.generate(
        30,
        (i) => _MuestraContada(30 - i, loteId: i ~/ 10 + 1),
      );
      await _mount(tester, fixture, size: const Size(800, 2600));
      await tester.tap(find.text('Tabla'));
      await tester.pumpAndSettle();
      expect(_tableRowCount(tester), 25);
      expect(
        tester
            .widgetList<DataTable>(find.byType(DataTable))
            .expand((table) => table.rows)
            .map((row) => row.key),
        [for (var id = 30; id >= 6; id--) ValueKey(id)],
      );
      await tester.tap(find.byTooltip('Página siguiente'));
      await tester.pumpAndSettle();
      expect(_tableRowCount(tester), 5);
      expect(find.text('Muestras 26–30 de 30'), findsOneWidget);
      fixture.records = fixture.records.take(10).toList();
      fixture.updates.add(fixture.records);
      await tester.pumpAndSettle();
      expect(_tableRowCount(tester), 10);
      expect(find.text('Muestras 1–10 de 10'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _unmount(tester, fixture);
    },
  );

  testWidgets('subida Brix incluye cola de otros días dentro de la plantilla', (
    tester,
  ) async {
    final fixture = _Fixture(3);
    fixture.local.queuedSamples = 7;
    await _mount(tester, fixture);
    await tester.tap(find.byTooltip('Subir registros a la nube'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Se subirán 7 registro(s)'), findsOneWidget);
    expect(
      find.textContaining('pendientes de días anteriores'),
      findsOneWidget,
    );
    expect(fixture.local.queueRequest, (
      userId: 1,
      templateKey: _templateKey,
      plantillaId: _plantillaId,
      localIds: null,
    ));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await _unmount(tester, fixture);
  });
}
