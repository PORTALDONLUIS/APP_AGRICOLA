import 'tic_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/donluis_app_bar.dart';
import '../../shared/widgets/donluis_gradient_scaffold.dart';
import '../../shared/widgets/donluis_section_card.dart';
import 'tic_form.dart';
import 'tic_pages.dart';
import 'tic_repository.dart';

/// Extensión de cartillas transaccionales: el catálogo/asignación y el acceso
/// son los habituales. El guardado confirma movimientos del inventario web.
const ticCartillas = <String, String>{
  'cartilla_tic_equipos': 'Equipos TIC',
  'cartilla_tic_entregas': 'Entregas TIC',
  'cartilla_tic_devoluciones': 'Devoluciones TIC',
  'cartilla_tic_informes_tecnicos': 'Informes técnicos TIC',
  'cartilla_tic_ampliaciones': 'Ampliaciones TIC',
  'cartilla_tic_trabajadores': 'Trabajadores TIC',
  'cartilla_tic_recursos': 'Consumibles y servicios TIC',
  'cartilla_tic_reportes': 'Reportes TIC',
};
String normalizarTic(String key) =>
    key.trim().toLowerCase().replaceAll('-', '_');
bool esCartillaTic(String key) => ticCartillas.containsKey(normalizarTic(key));

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
    final data = ref.watch(ticCatalogProvider);
    final drafts =
        ref.watch(ticDraftsProvider).valueOrNull ?? <Map<String, dynamic>>[];
    return TicSurface(
      child: DonLuisGradientScaffold(
        appBar: DonLuisAppBar(title: Text(ticCartillas[key] ?? title)),
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
            void openForm(String operation, [String target = '']) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TicFormPage(operation: operation, target: target),
                ),
              ).then((_) => ref.invalidate(ticDraftsProvider));
            }

            void openList({String? operation}) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicListPage(
                    resource: resource,
                    title: ticCartillas[key] ?? title,
                    operations: ops,
                    operation: operation,
                    extraQuery: {
                      if (operation == 'entrega') 'disponibles': '1',
                      if (operation == 'devolucion') 'asignados': '1',
                      if (key.endsWith('ampliaciones'))
                        'tipos': 'pc,laptop,servidor',
                    },
                  ),
                ),
              ).then((_) => ref.invalidate(ticDraftsProvider));
            }

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
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
                      if (newOp != null && ops.any((o) => o['id'] == newOp))
                        ListTile(
                          leading: const Icon(Icons.add_circle_outline),
                          title: const Text('Nuevo registro'),
                          subtitle: const Text(
                            'Completar o continuar el borrador',
                          ),
                          onTap: () => openForm(newOp),
                        ),
                      if (primary != null && ops.any((o) => o['id'] == primary))
                        ListTile(
                          leading: const Icon(Icons.edit_note),
                          title: Text(
                            primary == 'informe_nuevo'
                                ? 'Registrar falla o intervención'
                                : primary == 'componentes'
                                ? 'Registrar ampliación o reemplazo'
                                : 'Seleccionar equipo y registrar',
                          ),
                          onTap: () => openList(operation: primary),
                        ),
                      if (!key.endsWith('reportes'))
                        ListTile(
                          leading: const Icon(Icons.manage_search),
                          title: const Text('Consultar y editar'),
                          subtitle: const Text(
                            'Ficha, responsables, historial e informes',
                          ),
                          onTap: () => openList(),
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
                            MaterialPageRoute(
                              builder: (_) => const TicReportsPage(),
                            ),
                          ),
                        ),
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf_outlined),
                        title: const Text('Resumen y documentos PDF'),
                        subtitle: const Text(
                          'Compartir el archivo por WhatsApp u otra aplicación',
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TicListPage(
                              resource: 'documentos',
                              title: 'Resumen y documentos TIC',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (pending.isNotEmpty)
                  DonLuisSectionCard(
                    title: 'BORRADORES DEL EQUIPO',
                    icon: Icons.save_outlined,
                    child: Column(
                      children: [
                        for (final draft in pending)
                          ListTile(
                            title: Text('${draft['title']}'),
                            subtitle: Text(
                              'Pendiente de confirmar · ${draft['target']}',
                            ),
                            trailing: IconButton(
                              tooltip: 'Descartar borrador',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                final yes = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => TicDialog(
                                    title: const Text(
                                      '¿Descartar este borrador?',
                                    ),
                                    content: const Text(
                                      'Solo se elimina el avance de este celular. No se modifica el inventario.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Conservar'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Descartar'),
                                      ),
                                    ],
                                  ),
                                );
                                if (yes == true) {
                                  await ref
                                      .read(ticRepositoryProvider)
                                      .clearDraft(
                                        '${draft['operation']}',
                                        '${draft['target']}',
                                      );
                                  ref.invalidate(ticDraftsProvider);
                                }
                              },
                            ),
                            onTap: () => openForm(
                              '${draft['operation']}',
                              '${draft['target']}',
                            ),
                          ),
                      ],
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'El inventario y las validaciones son los mismos de DonTec Web. Un borrador no acredita entrega, devolución ni reparación.',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
