import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/donluis_theme.dart';
import '../../../shared/widgets/donluis_empty_state.dart';
import '../../../shared/widgets/donluis_gradient_scaffold.dart';
import '../../../shared/widgets/donluis_app_bar.dart';
import '../../master/presentation/master_providers.dart';
import '../../master/presentation/lotes_map_page.dart';
import '../../registros/presentation/cartilla_map_page.dart';
import '../../../core/network/http_error_handler.dart';
import 'templates_controller.dart' hide templatesNotifierProvider;
import '../../registros/presentation/registros_page.dart';

class TemplatesPage extends ConsumerWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final userId = ref.watch(currentUserIdProvider);
    final ui = ref.watch(templatesNotifierProvider); // TemplatesUiState (query/syncing/error)
    final asyncPlantillas = ref.watch(assignedPlantillasProvider(userId)); // StreamProvider
    final masterSync = ref.watch(masterSyncControllerProvider);

    return DonLuisGradientScaffold(
      appBar: DonLuisAppBar(
        title: const Text('Plantillas'),
        actions: [
          IconButton(
            tooltip: 'Mapa de lotes',
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LotesMapPage()),
            ),
          ),
          IconButton(
            tooltip: masterSync.loading ? 'Sincronizando campañas y lotes...' : 'Sincronizar campañas y lotes',
            icon: masterSync.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_sync),
            onPressed: masterSync.loading
                ? null
                : () async {
              await ref.read(masterSyncControllerProvider.notifier).runForcedSync();
              if (context.mounted) {
                final st = ref.read(masterSyncControllerProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(st.error ?? 'Campañas y lotes sincronizados'),
                    backgroundColor: st.error != null ? Colors.red : null,
                  ),
                );
              }
            },
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar plantilla...',
                prefixIcon: Icon(Icons.search, color: DonLuisColors.primary.withOpacity(0.7)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (v) => ref.read(templatesNotifierProvider.notifier).setQuery(v),
            ),
          ),

          if (ui.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                ui.error!,
                style: TextStyle(color: DonLuisColors.primary.withOpacity(0.9), fontSize: 13),
              ),
            ),

          Expanded(
            child: asyncPlantillas.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    HttpErrorHandler.toUserMessageOnly(e),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: DonLuisColors.primary.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              data: (items) {
                final q = ui.query.trim().toLowerCase();
                final filtered = q.isEmpty
                    ? items
                    : items.where((p) {
                  final nombre = (p.nombre ?? '').toLowerCase();
                  final codigo = (p.codigo ?? '').toLowerCase();
                  final desc = (p.descripcion ?? '').toLowerCase();
                  return nombre.contains(q) || codigo.contains(q) || desc.contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return DonLuisEmptyState(
                    message: 'No hay plantillas asignadas',
                    submessage: 'Ajusta el filtro o sincroniza en el inicio de sesión',
                    icon: Icons.description_outlined,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final p = filtered[i];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RegistrosPage(
                                plantillaId: p.plantillaId,
                                templateKey: (p.codigo ?? ''),
                                plantillaNombre: p.nombre ?? '',
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Card(
                          elevation: 2,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: DonLuisColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.assignment_outlined,
                                    color: DonLuisColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.nombre ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${p.codigo} • ${p.descripcion ?? ''}'.trim(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: DonLuisColors.primary.withOpacity(0.7),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Tooltip(
                                  message: 'Mapa',
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CartillaMapPage(
                                        plantillaId: p.plantillaId,
                                        templateKey: (p.codigo ?? ''),
                                        plantillaNombre: p.nombre ?? '',
                                      ),
                                    ),
                                  ),
                                  behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(Icons.map, color: DonLuisColors.primary.withOpacity(0.8), size: 22),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: DonLuisColors.primary.withOpacity(0.6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
