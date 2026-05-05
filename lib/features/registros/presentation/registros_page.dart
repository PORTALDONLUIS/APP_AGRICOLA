import 'dart:convert';

import 'package:donluis_forms/features/registros/presentation/registros_sync_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/form_registry.dart';
import '../../../app/providers.dart';
import '../../cartillas/domain/report/cartilla_report_provider.dart';
import '../../cartillas/presentation/report/cartilla_report_page.dart';
import '../../../app/theme/donluis_theme.dart';
import 'cartilla_map_page.dart';
import '../../../core/sync/sync_models.dart';
import '../../master/presentation/master_providers.dart';
import '../../../shared/widgets/donluis_empty_state.dart';
import '../../../shared/widgets/donluis_gradient_scaffold.dart';
import '../../../shared/widgets/donluis_app_bar.dart';
import '../../../shared/widgets/app_loading_overlay.dart';
import '../data/registros_local_ds.dart';
import '../domain/registro.dart';
import 'registros_controller.dart';

/// Rango del día actual en UTC para zona UTC-5 (inicio y fin en UTC).
({DateTime start, DateTime end}) _todayRangeUtc5() {
  final nowUtc = DateTime.now().toUtc();
  final utcMinus5 = nowUtc.subtract(const Duration(hours: 5));
  final start = DateTime.utc(
    utcMinus5.year,
    utcMinus5.month,
    utcMinus5.day,
    5,
    0,
  );
  final end = start.add(const Duration(hours: 24));
  return (start: start, end: end);
}

List<Registro> _filterRegistrosOfTodayUtc5(List<Registro> items) {
  final range = _todayRangeUtc5();
  return items.where((r) {
    final t = r.registrationDateTimeUtc();
    return !t.isBefore(range.start) && t.isBefore(range.end);
  }).toList();
}

/// Quita prefijo tipo "Plantilla" / "Plantilla:" del nombre mostrado en servidor.
String _displayPlantillaName(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return raw;
  final lower = s.toLowerCase();
  if (lower.startsWith('plantilla')) {
    s = s.substring('plantilla'.length).trim();
    if (s.startsWith(':') ||
        s.startsWith('-') ||
        s.startsWith('–') ||
        s.startsWith('—')) {
      s = s.substring(1).trim();
    }
  }
  return s.isEmpty ? raw.trim() : s;
}

String _formatRegistroLocalTime(Registro r) {
  final local = r.registrationDateTimeUtc().toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

bool _isPodaTemplate(String templateKey) {
  final normalized = templateKey.trim().toLowerCase().replaceAll('-', '_');
  return normalized == 'cartilla_poda' || normalized == 'cartilla_podas';
}

/// Líneas auxiliares para la tarjeta (lote + campos de cabecera si existen).
(String loteLine, String? detailLine) _registroContextLines(
  Registro r,
  Map<int, String> loteDescriptions,
) {
  final payload = r.normalizedPayload();
  final header = payload['header'] as Map<String, dynamic>? ?? {};
  int? lid = r.loteId;
  if (lid == null) {
    final h = header['loteId'];
    if (h is int) lid = h;
    if (h is num) lid = h.toInt();
  }

  String loteLine;
  if (lid != null) {
    final desc = loteDescriptions[lid];
    if (desc != null && desc.trim().isNotEmpty) {
      loteLine = desc.trim();
    } else {
      loteLine = 'Lote $lid';
    }
  } else {
    loteLine = 'Sin lote';
  }

  final extras = <String>[];
  for (final key in ['variedad', 'hilera', 'sector', 'planta', 'actividad']) {
    final v = header[key];
    if (v == null) continue;
    final t = v.toString().trim();
    if (t.isNotEmpty) extras.add(t);
  }
  final detail = extras.isEmpty ? null : extras.take(3).join(' · ');
  return (loteLine, detail);
}

/// Solo se puede eliminar mientras el registro NO haya sido sincronizado.
/// Se permite tanto en borrador (lápiz) como listo para sincronizar (cloud_upload)
/// o con error, pero nunca cuando ya tiene serverId/syncStatus.synced.
bool _canDeleteRegistro(Registro r) {
  if (r.serverId != null) return false; // ya subido al servidor
  if (r.syncStatus == SyncStatus.synced) return false;
  return true;
}

enum _PodaCreateMode { editCurrent, editFinal }

bool _podaHasFinalData(Registro registro) {
  final payload = registro.normalizedPayload();
  final body = payload['body'] as Map<String, dynamic>? ?? {};

  for (final entry in body.entries) {
    if (!entry.key.startsWith('final_')) continue;
    final value = entry.value;
    if (value == null) continue;
    if (value is String && value.trim().isEmpty) continue;
    if (value is Iterable && value.isEmpty) continue;
    if (value is Map && value.isEmpty) continue;
    return true;
  }

  final finalFotos = body['finalFotos'];
  if (finalFotos is Iterable && finalFotos.isNotEmpty) return true;

  return false;
}

typedef _GlobalSyncPreview = ({
  int totalRegistros,
  int nuevosPendientes,
  int conFotosPendientes,
});

List<Map<String, dynamic>> _pendingFotosFromRegistroData(
  Map<String, dynamic> dataMap,
) {
  final body = dataMap['body'];
  List<dynamic> raw = const [];
  if (body is Map && body['fotos'] is List) {
    raw = body['fotos'] as List;
  } else if (dataMap['fotos'] is List) {
    raw = dataMap['fotos'] as List;
  }

  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e.cast<String, dynamic>()))
      .where((f) {
        final localPath = f['localPath'] as String?;
        final serverUrl = f['serverUrl'] as String?;
        return localPath != null &&
            localPath.isNotEmpty &&
            (serverUrl == null || serverUrl.isEmpty);
      })
      .toList();
}

Future<_GlobalSyncPreview> _buildGlobalSyncPreview(WidgetRef ref) async {
  final local = ref.read(registrosLocalDSProvider);
  final userId = ref.read(currentUserIdProvider);

  final pendientes = await local.listSyncQueue(userId: userId);
  final syncedWithServer = await local.listWithServerId(userId: userId);

  var conFotosPendientes = 0;
  for (final registro in syncedWithServer) {
    final dataMap = (jsonDecode(registro.dataJson) as Map)
        .cast<String, dynamic>();
    if (_pendingFotosFromRegistroData(dataMap).isNotEmpty) {
      conFotosPendientes++;
    }
  }

  return (
    totalRegistros: pendientes.length + conFotosPendientes,
    nuevosPendientes: pendientes.length,
    conFotosPendientes: conFotosPendientes,
  );
}

Future<bool> _confirmGlobalSyncUpload(
  BuildContext context, {
  required String plantillaTitulo,
  required _GlobalSyncPreview preview,
}) async {
  final total = preview.totalRegistros;
  if (total <= 0) return false;

  final detailParts = <String>[
    if (preview.nuevosPendientes > 0)
      '${preview.nuevosPendientes} registro(s) pendientes',
    if (preview.conFotosPendientes > 0)
      '${preview.conFotosPendientes} registro(s) con fotos pendientes',
  ];

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirmar subida'),
      content: Text(
        'Se subirán $total registro(s) a la nube.\n\n'
        'Esta sincronización es global: se enviarán registros de todas las plantillas, '
        'no solo de "$plantillaTitulo".\n\n'
        '${detailParts.join(' y ')}.\n\n'
        '¿Deseas continuar?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(ctx, true),
          icon: const Icon(Icons.cloud_upload_outlined),
          label: const Text('Continuar'),
        ),
      ],
    ),
  );

  return confirmed == true;
}

Future<_PodaCreateMode?> _showPodaOpenModeSheet(
  BuildContext context, {
  required bool hasFinalData,
}) {
  return showModalBottomSheet<_PodaCreateMode>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final colorScheme = Theme.of(ctx).colorScheme;
      final titleStyle = TextStyle(
        color: colorScheme.onSurface,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      );
      final subtitleStyle = TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 14,
        height: 1.3,
      );

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.75),
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.edit_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text('Editar actual', style: titleStyle),
                  subtitle: Text(
                    'Edita el registro inicial como lo haces normalmente.',
                    style: subtitleStyle,
                  ),
                  onTap: () =>
                      Navigator.of(ctx).pop(_PodaCreateMode.editCurrent),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.28),
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.compare_arrows,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    hasFinalData
                        ? 'Editar registro final'
                        : 'Ingresar registro final',
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    'Bloquea las secciones no comparativas y captura los datos corregidos.',
                    style: subtitleStyle,
                  ),
                  onTap: () => Navigator.of(ctx).pop(_PodaCreateMode.editFinal),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _confirmAndDelete(
  BuildContext context,
  WidgetRef ref,
  Registro registro,
  RegistrosLocalDS local,
) async {
  if (!_canDeleteRegistro(registro)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solo se pueden eliminar registros que aún no han sido sincronizados. '
            'Los que ya están sincronizados no se pueden eliminar.',
          ),
        ),
      );
    }
    return;
  }
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminar registro'),
      content: Text(
        '¿Eliminar el registro #${registro.localId}? Esta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await local.deleteByLocalId(registro.localId);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Registro eliminado')));
  }
}

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
    final registrosAsync = ref.watch(registrosByPlantillaProvider(plantillaId));
    final lotesAsync = ref.watch(lotesStreamProvider);
    final syncState = ref.watch(registrosSyncControllerProvider);

    final plantillaTitulo = _displayPlantillaName(plantillaNombre);
    final loteDescriptions = lotesAsync.maybeWhen(
      data: (lotes) => {for (final l in lotes) l.idLote: l.descripcion},
      orElse: () => <int, String>{},
    );

    return AppLoadingOverlay(
      loading: syncState.isSyncing,
      message: 'Sincronizando registros...',
      child: DonLuisGradientScaffold(
        appBar: DonLuisAppBar(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                plantillaTitulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(
                'Registros del día',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Mapa',
              icon: const Icon(Icons.map),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartillaMapPage(
                    plantillaId: plantillaId,
                    templateKey: templateKey,
                    plantillaNombre: plantillaNombre,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Reporte diario',
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                final now = DateTime.now();
                final day = DateTime(now.year, now.month, now.day);
                final userId = ref.read(currentUserIdProvider);
                ref.invalidate(
                  cartillaReportProvider(
                    CartillaReportRequest(
                      templateKey: templateKey,
                      date: day,
                      userId: userId,
                    ),
                  ),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CartillaReportPage(
                      templateKey: templateKey,
                      day: day,
                      plantillaNombre: plantillaNombre,
                    ),
                  ),
                );
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final sync = ref.watch(registrosSyncControllerProvider);
                final isBusy = sync.isSyncing;

                return IconButton(
                  tooltip: isBusy
                      ? 'Sincronizando ${sync.current}/${sync.total}'
                      : 'Subir registros a la nube',
                  onPressed: isBusy
                      ? null
                      : () async {
                          final preview = await _buildGlobalSyncPreview(ref);
                          if (preview.totalRegistros == 0) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No hay registros pendientes por subir.',
                                  ),
                                ),
                              );
                            }
                            return;
                          }
                          if (!context.mounted) return;

                          final confirmed = await _confirmGlobalSyncUpload(
                            context,
                            plantillaTitulo: plantillaTitulo,
                            preview: preview,
                          );
                          if (!confirmed) return;

                          await ref
                              .read(registrosSyncControllerProvider.notifier)
                              .sync(templateKey: null); // 👈 GLOBAL

                          final st = ref.read(registrosSyncControllerProvider);
                          if (context.mounted) {
                            final msg =
                                st.message ??
                                'Sync terminado: ${st.ok} OK, ${st.fail} con error';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(msg),
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
                      : const Icon(Icons.cloud_upload_outlined),
                );
              },
            ),
          ],
        ),
        body: registrosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (items) {
            final ofToday = _filterRegistrosOfTodayUtc5(items);
            if (ofToday.isEmpty) {
              return DonLuisEmptyState(
                message: 'No hay registros del día',
                submessage:
                    '$plantillaTitulo · Solo se listan los de hoy (UTC-5). '
                    'Toca + para crear uno.',
                icon: Icons.today_outlined,
              );
            }

            final formRoute = FormRegistry.routeFor(templateKey);
            final local = ref.read(registrosLocalDSProvider);
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: ofToday.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final registro = ofToday[i];
                return _RegistroTile(
                  registro: registro,
                  loteDescriptions: loteDescriptions,
                  onTap: () async {
                    if (!_isPodaTemplate(templateKey)) {
                      Navigator.pushNamed(
                        context,
                        formRoute,
                        arguments: {'localId': registro.localId},
                      );
                      return;
                    }

                    final mode = await _showPodaOpenModeSheet(
                      context,
                      hasFinalData: _podaHasFinalData(registro),
                    );
                    if (mode == null || !context.mounted) return;

                    Navigator.pushNamed(
                      context,
                      formRoute,
                      arguments: {
                        'localId': registro.localId,
                        if (mode == _PodaCreateMode.editFinal)
                          'podaFinalMode': true,
                      },
                    );
                  },
                  onDelete: () =>
                      _confirmAndDelete(context, ref, ofToday[i], local),
                );
              },
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

            nav.pushNamed(formRoute, arguments: {'localId': localId});
          },
        ),
      ),
    );
  }
}

class _RegistroTile extends StatelessWidget {
  final Registro registro;
  final Map<int, String> loteDescriptions;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RegistroTile({
    required this.registro,
    required this.loteDescriptions,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatRegistroLocalTime(registro);
    final (loteLine, detailLine) = _registroContextLines(
      registro,
      loteDescriptions,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                _StatusIcon(registro),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: DonLuisColors.primary,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '·',
                              style: TextStyle(
                                fontSize: 15,
                                color: DonLuisColors.primary.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              loteLine,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (detailLine != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          detailLine,
                          style: TextStyle(
                            fontSize: 13,
                            color: DonLuisColors.primary.withValues(
                              alpha: 0.72,
                            ),
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      /*
                      const SizedBox(height: 6),
                      Text(
                        'Estado: ${registro.estado.name}',
                        style: TextStyle(
                          fontSize: 13,
                          color: DonLuisColors.primary.withOpacity(0.7),
                        ),
                      ),*/
                      const SizedBox(height: 2),
                      Text(
                        'Ref. local #${registro.localId}',
                        style: TextStyle(
                          fontSize: 11,
                          color: DonLuisColors.primary.withValues(alpha: 0.45),
                        ),
                      ),
                      if (registro.syncError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Error: ${registro.syncError}',
                            style: TextStyle(
                              fontSize: 12,
                              color: DonLuisColors.primary.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_canDeleteRegistro(registro))
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Eliminar (solo en borrador)',
                    color: DonLuisColors.primary.withValues(alpha: 0.7),
                    onPressed: onDelete,
                  ),
                Icon(
                  Icons.chevron_right,
                  color: DonLuisColors.primary.withValues(alpha: 0.6),
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
  final Registro registro;
  const _StatusIcon(this.registro);

  @override
  Widget build(BuildContext context) {
    // Si ya tiene serverId, prioriza icono de sincronizado aunque el syncStatus
    // no se haya actualizado por alguna razón.
    if (registro.serverId != null) {
      return Icon(Icons.cloud_done, color: DonLuisColors.secondary, size: 24);
    }

    switch (registro.syncStatus) {
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
