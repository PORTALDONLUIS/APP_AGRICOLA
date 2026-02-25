import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import 'templates_controller.dart' hide templatesNotifierProvider;
import '../../registros/presentation/registros_page.dart';

class TemplatesPage extends ConsumerWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final userId = ref.watch(currentUserIdProvider);
    final ui = ref.watch(templatesNotifierProvider); // TemplatesUiState (query/syncing/error)
    final asyncPlantillas = ref.watch(assignedPlantillasProvider(userId)); // StreamProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantillas'),
        actions: [
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
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar plantilla...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => ref.read(templatesNotifierProvider.notifier).setQuery(v),
            ),
          ),

          if (ui.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(ui.error!, style: const TextStyle(color: Colors.red)),
            ),

          Expanded(
            child: asyncPlantillas.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
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
                  return const Center(child: Text('No hay plantillas asignadas'));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = filtered[i];

                    return ListTile(
                      title: Text(p.nombre ?? ''),
                      subtitle: Text('${p.codigo} • ${p.descripcion ?? ''}'.trim()),
                      trailing: const Icon(Icons.chevron_right),
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
