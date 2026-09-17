import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/donluis_theme.dart';
import '../../../shared/widgets/donluis_empty_state.dart';
import '../../../shared/widgets/donluis_gradient_scaffold.dart';
import '../../../shared/widgets/donluis_app_bar.dart';
import '../../master/presentation/master_providers.dart';
import '../../master/presentation/lotes_map_page.dart';
import '../../personas/presentation/personas_page.dart';
import '../../registros/presentation/cartilla_map_page.dart';
import '../../../core/network/http_error_handler.dart';
import '../../../core/update/app_update_dialog.dart';
import '../../../core/update/app_update_service.dart';
import 'templates_controller.dart' hide templatesNotifierProvider;
import '../../registros/presentation/registros_page.dart';

class TemplatesPage extends ConsumerWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final auth = ref.watch(authProvider);
    final isSuperadmin = ref.watch(isSuperadminProvider);
    final ui = ref.watch(
      templatesNotifierProvider,
    ); // TemplatesUiState (query/syncing/error)
    final asyncPlantillas = ref.watch(
      assignedPlantillasProvider(userId),
    ); // StreamProvider
    final masterSync = ref.watch(masterSyncControllerProvider);

    return DonLuisGradientScaffold(
      appBar: DonLuisAppBar(
        centerTitle: false,
        title: _UserHeader(
          fullName: auth.fullName,
          dni: auth.dni ?? auth.username,
        ),
        actions: [
          IconButton(
            tooltip: 'Mapa de lotes',
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LotesMapPage()),
            ),
          ),
          PopupMenuButton<_HeaderMenuOption>(
            tooltip: 'Más opciones',
            icon: const Icon(Icons.more_vert),
            // Abre el menú debajo de la barra superior, sin cubrir la cabecera.
            offset: const Offset(0, kToolbarHeight),
            onSelected: (option) async {
              switch (option) {
                case _HeaderMenuOption.syncMaster:
                  if (masterSync.loading) return;
                  await ref
                      .read(masterSyncControllerProvider.notifier)
                      .runForcedSync();
                  if (context.mounted) {
                    final st = ref.read(masterSyncControllerProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          st.error ?? 'Campañas y lotes sincronizados',
                        ),
                        backgroundColor: st.error != null ? Colors.red : null,
                      ),
                    );
                  }
                  break;
                case _HeaderMenuOption.updateApp:
                  await _checkForAppUpdate(context);
                  break;
                case _HeaderMenuOption.personas:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PersonasPage()),
                  );
                  break;
                case _HeaderMenuOption.logout:
                  ref.read(authProvider.notifier).logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _HeaderMenuOption.syncMaster,
                enabled: !masterSync.loading,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: masterSync.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_for_offline_outlined),
                  title: Text(
                    masterSync.loading
                        ? 'Sincronizando campañas y lotes...'
                        : 'Sincronizar campañas y lotes',
                  ),
                ),
              ),
              const PopupMenuItem(
                value: _HeaderMenuOption.updateApp,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.system_update_alt_rounded),
                  title: Text('Actualizar app'),
                ),
              ),
              if (isSuperadmin)
                const PopupMenuItem(
                  value: _HeaderMenuOption.personas,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.admin_panel_settings_outlined),
                    title: Text('Personas'),
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: _HeaderMenuOption.logout,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout),
                  title: Text('Cerrar sesión'),
                ),
              ),
            ],
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
                prefixIcon: Icon(
                  Icons.search,
                  color: DonLuisColors.primary.withValues(alpha: 0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (v) =>
                  ref.read(templatesNotifierProvider.notifier).setQuery(v),
            ),
          ),

          if (ui.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                ui.error!,
                style: TextStyle(
                  color: DonLuisColors.primary.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
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
                      color: DonLuisColors.primary.withValues(alpha: 0.9),
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
                        return nombre.contains(q) ||
                            codigo.contains(q) ||
                            desc.contains(q);
                      }).toList();

                if (filtered.isEmpty) {
                  return DonLuisEmptyState(
                    message: 'No hay plantillas asignadas',
                    submessage:
                        'Ajusta el filtro o sincroniza en el inicio de sesión',
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: DonLuisColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        '${p.codigo} • ${p.descripcion ?? ''}'
                                            .trim(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: DonLuisColors.primary
                                              .withValues(alpha: 0.7),
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
                                      child: Icon(
                                        Icons.map,
                                        color: DonLuisColors.primary.withValues(
                                          alpha: 0.8,
                                        ),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: DonLuisColors.primary.withValues(
                                    alpha: 0.6,
                                  ),
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

enum _HeaderMenuOption { syncMaster, updateApp, personas, logout }

class _UserHeader extends StatelessWidget {
  const _UserHeader({this.fullName, this.dni});

  final String? fullName;
  final String? dni;

  @override
  Widget build(BuildContext context) {
    final name = (fullName ?? '').trim();
    final document = (dni ?? '').trim();
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
          ),
          child: const Icon(Icons.person_rounded, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'Usuario' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                document.isEmpty ? 'Sin DNI' : 'DNI: $document',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _checkForAppUpdate(BuildContext context) async {
  final updateService = AppUpdateService();
  final result = await updateService.check();
  if (!context.mounted) return;

  if (result == AppUpdateResult.optional ||
      result == AppUpdateResult.mandatory) {
    await showDialog<void>(
      context: context,
      barrierDismissible: result != AppUpdateResult.mandatory,
      builder: (_) => AppUpdateDialog(
        service: updateService,
        mandatory: result == AppUpdateResult.mandatory,
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('No hay una actualización disponible.')),
  );
}
