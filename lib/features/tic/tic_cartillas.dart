import 'tic_surface.dart';
import 'tic_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/donluis_app_bar.dart';
import '../../shared/widgets/donluis_gradient_scaffold.dart';
import '../../shared/widgets/donluis_section_card.dart';
import 'tic_form.dart';
import 'tic_pages.dart';
import 'tic_repository.dart';

/// Plantilla TIC oficial unificada. El guardado confirma movimientos en el
/// inventario único de DonTec Web.
const ticCartillaUnificada = 'cartilla_tic_inventario';

const ticCartillas = <String, String>{
  ticCartillaUnificada: 'Inventario TIC',
};

/// Códigos anteriores conservados solo por compatibilidad mientras se migran
/// bases o instalaciones previas. No se muestran ni asignan como plantillas nuevas.
const ticCartillasLegacy = <String, String>{
  'cartilla_tic_equipos': 'Equipos TIC',
  'cartilla_tic_entregas': 'Entregas TIC',
  'cartilla_tic_devoluciones': 'Devoluciones TIC',
  'cartilla_tic_informes_tecnicos': 'Informes TIC',
  'cartilla_tic_ampliaciones': 'Ampliaciones TIC',
  'cartilla_tic_trabajadores': 'Trabajadores TIC',
  'cartilla_tic_recursos': 'Consumibles y servicios TIC',
  'cartilla_tic_reportes': 'Reportes TIC',
};

String normalizarTic(String key) =>
    key.trim().toLowerCase().replaceAll('-', '_');

bool esCartillaTic(String key) {
  final normalized = normalizarTic(key);
  return ticCartillas.containsKey(normalized) ||
      ticCartillasLegacy.containsKey(normalized);
}

String nombreCartillaTic(String key, {String fallback = ''}) {
  final normalized = normalizarTic(key);
  return ticCartillas[normalized] ??
      ticCartillasLegacy[normalized] ??
      (fallback.isNotEmpty ? fallback : 'Inventario TIC');
}

class TicCartillaPage extends ConsumerWidget {
  const TicCartillaPage({
    super.key,
    required this.templateKey,
    required this.title,
  });
  final String templateKey, title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = normalizarTic(templateKey);
    final isUnified = key == ticCartillaUnificada;
    final data = ref.watch(ticCatalogProvider);
    final drafts =
        ref.watch(ticDraftsProvider).valueOrNull ?? <Map<String, dynamic>>[];

    return TicSurface(
      child: DonLuisGradientScaffold(
        appBar: DonLuisAppBar(
          title: Text(nombreCartillaTic(key, fallback: title)),
        ),
        body: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(ticError(e)),
            ),
          ),
          data: (catalog) {
            final ops = (catalog['operations'] as List)
                .map((o) => Map<String, dynamic>.from(o as Map))
                .toList();
            bool hasOp(String id) => ops.any((o) => o['id'] == id);

            void openForm(String operation, [String target = '']) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TicFormPage(operation: operation, target: target),
                ),
              ).then((_) => ref.invalidate(ticDraftsProvider));
            }

            void openResourceList({
              required String resource,
              required String listTitle,
              String? operation,
              Map<String, dynamic> extra = const {},
              String initialQuery = '',
            }) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicListPage(
                    resource: resource,
                    title: listTitle,
                    operations: ops,
                    operation: operation,
                    extraQuery: extra,
                    initialQuery: initialQuery,
                  ),
                ),
              ).then((_) => ref.invalidate(ticDraftsProvider));
            }

            if (isUnified) {
              return _buildUnifiedHub(
                context: context,
                ref: ref,
                catalog: catalog,
                drafts: drafts,
                hasOp: hasOp,
                openForm: openForm,
                openResourceList: openResourceList,
              );
            }

            return _buildLegacyCartilla(
              context: context,
              ref: ref,
              key: key,
              catalog: catalog,
              drafts: drafts,
              hasOp: hasOp,
              openForm: openForm,
              openResourceList: openResourceList,
            );
          },
        ),
      ),
    );
  }

  Widget _moduleBadge(IconData icon, Color bg, Color fg) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Icon(icon, color: fg, size: 22),
  );

  Widget _buildUnifiedHub({
    required BuildContext context,
    required WidgetRef ref,
    required Map<String, dynamic> catalog,
    required List<Map<String, dynamic>> drafts,
    required bool Function(String id) hasOp,
    required void Function(String operation, [String target]) openForm,
    required void Function({
      required String resource,
      required String listTitle,
      String? operation,
      Map<String, dynamic> extra,
      String initialQuery,
    }) openResourceList,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        if (catalog['offline'] == true)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Card(
              color: const Color(0xfffff7ed),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Sin conexión. Puedes revisar tus borradores locales; confirmar movimientos en inventario requiere conexión.',
                  style: TextStyle(color: Color(0xff9a3412)),
                ),
              ),
            ),
          ),
        DonLuisSectionCard(
          title: 'ACCIONES RÁPIDAS',
          icon: Icons.flash_on_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff168375),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text(
                    'Escanear QR o código de barras',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  onPressed: () async {
                    final code = await scanTicCode(context);
                    if (!context.mounted || code == null || code.isEmpty) return;
                    openResourceList(
                      resource: 'equipos',
                      listTitle: 'Equipos TIC',
                      initialQuery: code,
                    );
                  },
                ),
              ),
              if (hasOp('informe_cerrar'))
                ListTile(
                  leading: _moduleBadge(
                    Icons.task_alt_outlined,
                    const Color(0xfffef3c7),
                    const Color(0xffb45309),
                  ),
                  title: const Text(
                    'Informes pendientes de cierre',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Ver equipos con informes abiertos y cerrar',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openResourceList(
                    resource: 'equipos',
                    listTitle: 'Informes pendientes de cierre',
                    operation: 'informe_cerrar',
                    extra: const {'informe_abierto': '1'},
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (hasOp('equipo_nuevo'))
                      ActionChip(
                        avatar: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('Nuevo equipo'),
                        onPressed: () => openForm('equipo_nuevo'),
                      ),
                    if (hasOp('entrega'))
                      ActionChip(
                        avatar: const Icon(Icons.assignment_turned_in_outlined, size: 18),
                        label: const Text('Entregar'),
                        onPressed: () => openResourceList(
                          resource: 'equipos',
                          listTitle: 'Entregar equipo disponible',
                          operation: 'entrega',
                          extra: const {'disponibles': '1'},
                        ),
                      ),
                    if (hasOp('devolucion'))
                      ActionChip(
                        avatar: const Icon(Icons.assignment_return_outlined, size: 18),
                        label: const Text('Devolver'),
                        onPressed: () => openResourceList(
                          resource: 'equipos',
                          listTitle: 'Registrar devolución',
                          operation: 'devolucion',
                          extra: const {'asignados': '1'},
                        ),
                      ),
                    if (hasOp('informe_nuevo'))
                      ActionChip(
                        avatar: const Icon(Icons.build_outlined, size: 18),
                        label: const Text('Nuevo informe'),
                        onPressed: () => openResourceList(
                          resource: 'equipos',
                          listTitle: 'Registrar falla o mantenimiento',
                          operation: 'informe_nuevo',
                        ),
                      ),
                    if (hasOp('componentes'))
                      ActionChip(
                        avatar: const Icon(Icons.memory_outlined, size: 18),
                        label: const Text('Ampliación'),
                        onPressed: () => openResourceList(
                          resource: 'equipos',
                          listTitle: 'Ampliación RAM / disco',
                          operation: 'componentes',
                          extra: const {'tipos': 'pc,laptop,servidor'},
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DonLuisSectionCard(
          title: 'MÓDULOS DE INVENTARIO TIC',
          icon: Icons.inventory_2_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: _moduleBadge(
                  Icons.devices_outlined,
                  const Color(0xffe0f2f1),
                  const Color(0xff0f766e),
                ),
                title: const Text(
                  'Equipos',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Inventario, entregas, devoluciones, informes y PDF',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openResourceList(
                  resource: 'equipos',
                  listTitle: 'Equipos TIC',
                ),
              ),
              ListTile(
                leading: _moduleBadge(
                  Icons.people_outline,
                  const Color(0xffdbeafe),
                  const Color(0xff1d4ed8),
                ),
                title: const Text(
                  'Trabajadores',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Padrón, activos en custodia y asignar equipos',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openResourceList(
                  resource: 'trabajadores',
                  listTitle: 'Trabajadores TIC',
                ),
              ),
              ListTile(
                leading: _moduleBadge(
                  Icons.category_outlined,
                  const Color(0xfff3e8ff),
                  const Color(0xff7e22ce),
                ),
                title: const Text(
                  'Consumibles y servicios',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Stock, líneas, licencias, entregas y devoluciones',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openResourceList(
                  resource: 'recursos',
                  listTitle: 'Consumibles y servicios TIC',
                ),
              ),
              ListTile(
                leading: _moduleBadge(
                  Icons.donut_large,
                  const Color(0xffe0e7ff),
                  const Color(0xff4338ca),
                ),
                title: const Text(
                  'Reportes corporativos',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Filtros, indicadores y gráficas en PDF',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TicReportsPage()),
                ),
              ),
              ListTile(
                leading: _moduleBadge(
                  Icons.picture_as_pdf_outlined,
                  const Color(0xfffee2e2),
                  const Color(0xffb91c1c),
                ),
                title: const Text(
                  'Resumen y documentos PDF',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Actas e informes recientes para compartir por WhatsApp',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openResourceList(
                  resource: 'documentos',
                  listTitle: 'Resumen y documentos TIC',
                ),
              ),
            ],
          ),
        ),
        if (drafts.isNotEmpty)
          _buildDraftsCard(
            context: context,
            ref: ref,
            drafts: drafts,
            openForm: openForm,
          ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'El inventario y las validaciones son los mismos de DonTec Web. Un borrador no acredita entrega, devolución ni reparación.',
          ),
        ),
      ],
    );
  }

  Widget _buildLegacyCartilla({
    required BuildContext context,
    required WidgetRef ref,
    required String key,
    required Map<String, dynamic> catalog,
    required List<Map<String, dynamic>> drafts,
    required bool Function(String id) hasOp,
    required void Function(String operation, [String target]) openForm,
    required void Function({
      required String resource,
      required String listTitle,
      String? operation,
      Map<String, dynamic> extra,
      String initialQuery,
    }) openResourceList,
  }) {
    final resource = key.endsWith('trabajadores')
        ? 'trabajadores'
        : key.endsWith('recursos')
        ? 'recursos'
        : 'equipos';
    final newOp = key.endsWith('equipos')
        ? 'equipo_nuevo'
        : key.endsWith('trabajadores')
        ? 'trabajador_nuevo'
        : key.endsWith('recursos')
        ? 'recurso_nuevo'
        : null;
    final primary = key.endsWith('entregas')
        ? 'entrega'
        : key.endsWith('devoluciones')
        ? 'devolucion'
        : key.endsWith('informes_tecnicos')
        ? 'informe_nuevo'
        : key.endsWith('ampliaciones')
        ? 'componentes'
        : null;
    final allowed = <String>{
      if (newOp != null) newOp,
      if (primary != null) primary,
      if (resource == 'trabajadores') 'trabajador_editar',
      if (resource == 'trabajadores') 'trabajador_corregir',
      if (resource == 'recursos') ...[
        'recurso_editar',
        'recurso_corregir',
        'recurso_movimiento',
      ],
      if (resource == 'equipos') ...[
        'equipo_editar',
        'equipo_corregir',
        'conciliar',
        'informe_nuevo',
        'informe_cerrar',
        'componentes',
        'entrega',
        'devolucion',
      ],
    };
    final pending = drafts
        .where((d) => allowed.contains(d['operation']))
        .toList();

    void openLegacyList({
      String? operation,
      String? listTitle,
      Map<String, dynamic> extra = const {},
    }) {
      openResourceList(
        resource: resource,
        listTitle: listTitle ?? nombreCartillaTic(key, fallback: title),
        operation: operation,
        extra: {
          if (operation == 'entrega') 'disponibles': '1',
          if (operation == 'devolucion') 'asignados': '1',
          if (key.endsWith('ampliaciones')) 'tipos': 'pc,laptop,servidor',
          ...extra,
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Cartilla asignada · TIC',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        DonLuisSectionCard(
          title: 'REGISTRO Y CONSULTA',
          icon: Icons.assignment_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (catalog['offline'] == true)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Sin conexión. Recupera tu borrador; confirmar en inventario requiere conexión.',
                  ),
                ),
              if (newOp != null && hasOp(newOp))
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('Nuevo registro'),
                  subtitle: const Text('Completar o continuar el borrador'),
                  onTap: () => openForm(newOp),
                ),
              if (primary != null && hasOp(primary))
                ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: Text(
                    primary == 'informe_nuevo'
                        ? 'Registrar falla o intervención'
                        : primary == 'componentes'
                        ? 'Registrar ampliación o reemplazo'
                        : 'Seleccionar equipo y registrar',
                  ),
                  onTap: () => openLegacyList(operation: primary),
                ),
              if ((key.endsWith('informes_tecnicos') ||
                      key.endsWith('ampliaciones')) &&
                  hasOp('informe_cerrar'))
                ListTile(
                  leading: const Icon(
                    Icons.task_alt_outlined,
                    color: Color(0xff168375),
                  ),
                  title: const Text('Cerrar informe pendiente'),
                  subtitle: Text(
                    key.endsWith('ampliaciones')
                        ? 'Registrar diagnóstico, pruebas y cierre de mejoras abiertas'
                        : 'Listar equipos con informes abiertos y confirmar cierre',
                  ),
                  onTap: () => openLegacyList(
                    operation: 'informe_cerrar',
                    listTitle: 'Informes pendientes de cierre',
                    extra: {
                      'informe_abierto': '1',
                      if (key.endsWith('ampliaciones')) 'solo_mejoras': '1',
                    },
                  ),
                ),
              if (!key.endsWith('reportes'))
                ListTile(
                  leading: const Icon(Icons.manage_search),
                  title: const Text('Consultar y editar'),
                  subtitle: const Text(
                    'Ficha, responsables, historial e informes',
                  ),
                  onTap: () => openLegacyList(),
                ),
              if (key.endsWith('reportes'))
                ListTile(
                  leading: const Icon(Icons.donut_large),
                  title: const Text('Reportes corporativos'),
                  subtitle: const Text(
                    'Filtros, indicadores y gráficas en PDF',
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TicReportsPage()),
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Resumen y documentos PDF'),
                subtitle: const Text(
                  'Compartir el archivo por WhatsApp u otra aplicación',
                ),
                onTap: () => openResourceList(
                  resource: 'documentos',
                  listTitle: 'Resumen y documentos TIC',
                ),
              ),
            ],
          ),
        ),
        if (pending.isNotEmpty)
          _buildDraftsCard(
            context: context,
            ref: ref,
            drafts: pending,
            openForm: openForm,
          ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'El inventario y las validaciones son los mismos de DonTec Web. Un borrador no acredita entrega, devolución ni reparación.',
          ),
        ),
      ],
    );
  }

  Widget _buildDraftsCard({
    required BuildContext context,
    required WidgetRef ref,
    required List<Map<String, dynamic>> drafts,
    required void Function(String operation, [String target]) openForm,
  }) {
    return DonLuisSectionCard(
      title: 'BORRADORES DEL EQUIPO',
      icon: Icons.save_outlined,
      child: Column(
        children: [
          for (final draft in drafts)
            ListTile(
              title: Text('${draft['title']}'),
              subtitle: Text(
                '${draft['summary'] ?? ''}'.isNotEmpty
                    ? '${draft['summary']}'
                    : 'Pendiente de confirmar · ${draft['target']}',
              ),
              trailing: IconButton(
                tooltip: 'Descartar borrador',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final yes = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => TicDialog(
                      title: const Text('¿Descartar este borrador?'),
                      content: const Text(
                        'Solo se elimina el avance de este celular. No se modifica el inventario.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Conservar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Descartar'),
                        ),
                      ],
                    ),
                  );
                  if (yes == true) {
                    await ref
                        .read(ticRepositoryProvider)
                        .clearDraft('${draft['operation']}', '${draft['target']}');
                    ref.invalidate(ticDraftsProvider);
                  }
                },
              ),
              onTap: () =>
                  openForm('${draft['operation']}', '${draft['target']}'),
            ),
        ],
      ),
    );
  }
}
