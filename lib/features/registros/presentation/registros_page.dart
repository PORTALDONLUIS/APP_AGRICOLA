import 'package:donluis_forms/features/registros/presentation/registros_sync_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/form_registry.dart';
import '../../../app/providers.dart';
import '../../../app/theme/donluis_theme.dart';
import '../../../core/sync/sync_models.dart';
import '../../../shared/widgets/donluis_empty_state.dart';
import '../../../shared/widgets/donluis_gradient_scaffold.dart';
import '../domain/registro.dart';
import 'registros_controller.dart';

class RegistrosPage extends ConsumerWidget {
  final int plantillaId;
  final String templateKey;
  final String plantillaNombre;

  const RegistrosPage({
    super.key,
    required this.plantillaId,
    required this.templateKey,
    required this.plantillaNombre,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrosAsync =
    ref.watch(registrosByPlantillaProvider(plantillaId));

    return DonLuisGradientScaffold(
      appBar: AppBar(
        title: const Text('Registros'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final sync = ref.watch(registrosSyncControllerProvider);
              final isBusy = sync.isSyncing;

              return IconButton(
                tooltip: isBusy
                    ? 'Sincronizando ${sync.current}/${sync.total}'
                    : 'Sincronizar pendientes',
                onPressed: isBusy
                    ? null
                    : () async {
                  await ref
                      .read(registrosSyncControllerProvider.notifier)
                      .sync(templateKey: null); // 👈 GLOBAL

                  final st = ref.read(registrosSyncControllerProvider);
                  if (context.mounted && st.message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(st.message!),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                icon: isBusy
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${sync.current}/${sync.total}'),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                )
                    : const Icon(Icons.sync),
              );
            },
          ),
        ],
      ),
      body: registrosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return DonLuisEmptyState(
              message: 'No hay registros aún',
              submessage: 'Presiona + para crear uno.',
              icon: Icons.list_alt_outlined,
            );
          }

          final formRoute = FormRegistry.routeFor(templateKey);
          debugPrint('1TEMPLATEKEY=$templateKey -> ROUTE=$formRoute');
          debugPrint('[FORM_REGISTRY] TEMPLATEKEY=$templateKey ROUTE=$formRoute');
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _RegistroTile(registro: items[i], formRoute: formRoute, ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nuevo registro',
        child: const Icon(Icons.add),
        onPressed: () async {
          debugPrint('🔥 BOTON + PRESIONADO');
          final nav = Navigator.of(context); // ✅ capturado antes del await
          final local = ref.read(registrosLocalDSProvider);
          final userId = ref.read(currentUserIdProvider);

          // 1️⃣ Crear borrador local
          final localId = await local.createDraft(
            plantillaId: plantillaId,
            templateKey: templateKey,
            userId: userId,
          );

          // 2️⃣ Navegar al formulario correspondiente
          final formRoute = FormRegistry.routeFor(templateKey);
          debugPrint('2TEMPLATEKEY=$templateKey -> ROUTE=$formRoute');

          nav.pushNamed(
            formRoute,
            arguments: {'localId': localId},
          );
        },
      ),
    );
  }
}

class _RegistroTile extends StatelessWidget {
  final Registro registro;
  final String formRoute;
  const _RegistroTile({
    required this.registro,
    required this.formRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            formRoute,
            arguments: {'localId': registro.localId},
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _StatusIcon(registro.syncStatus),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Registro #${registro.localId}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Estado: ${registro.estado.name}',
                        style: TextStyle(
                          fontSize: 13,
                          color: DonLuisColors.primary.withOpacity(0.7),
                        ),
                      ),
                      if (registro.syncError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Error: ${registro.syncError}',
                            style: TextStyle(
                              fontSize: 12,
                              color: DonLuisColors.primary.withOpacity(0.9),
                            ),
                          ),
                        ),
                    ],
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
  }
}

class _StatusIcon extends StatelessWidget {
  final SyncStatus status;
  const _StatusIcon(this.status);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case SyncStatus.local:
        return const Icon(Icons.edit, color: Colors.grey, size: 24);
      case SyncStatus.pending:
        return Icon(Icons.cloud_upload, color: DonLuisColors.accent, size: 24);
      case SyncStatus.synced:
        return Icon(Icons.cloud_done, color: DonLuisColors.secondary, size: 24);
      case SyncStatus.failed:
        return const Icon(Icons.error, color: Color(0xFFB3261E), size: 24);
    }
  }
}
