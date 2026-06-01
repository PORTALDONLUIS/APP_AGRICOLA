import 'dart:convert';

import 'package:donluis_forms/features/registros/presentation/registros_sync_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/form_registry.dart';
import '../../../app/providers.dart';
import '../../cartillas/domain/cartilla_config_registry.dart';
import '../../cartillas/domain/cartilla_form_models.dart';
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

/// Línea principal de contexto para el registro.
(String loteLine, String? detailLine) _registroContextLines(
  Registro r,
  Map<int, String> loteDescriptions,
) {
  final lid = _registroLoteId(r);

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

  return (loteLine, null);
}

int? _registroLoteId(Registro r) {
  int? lid = r.loteId;
  if (lid != null) return lid;

  final payload = r.normalizedPayload();
  final header = payload['header'] as Map<String, dynamic>? ?? {};
  final h = header['loteId'];
  if (h is int) return h;
  if (h is num) return h.toInt();
  if (h is String) return int.tryParse(h.trim());
  return null;
}

List<_RegistroLoteGroup> _buildRegistroLoteGroups(
  List<Registro> registros,
  Map<int, String> loteDescriptions,
) {
  final groups = <String, _MutableRegistroLoteGroup>{};
  final orderedKeys = <String>[];

  for (final registro in registros) {
    final loteId = _registroLoteId(registro);
    final key = loteId?.toString() ?? 'sin_lote';
    final group = groups.putIfAbsent(key, () {
      orderedKeys.add(key);
      final (loteLine, _) = _registroContextLines(registro, loteDescriptions);
      return _MutableRegistroLoteGroup(loteId: loteId, loteLine: loteLine);
    });
    group.registros.add(registro);
  }

  return [for (final key in orderedKeys) groups[key]!.toImmutable()];
}

class _MutableRegistroLoteGroup {
  final int? loteId;
  final String loteLine;
  final List<Registro> registros = [];

  _MutableRegistroLoteGroup({required this.loteId, required this.loteLine});

  _RegistroLoteGroup toImmutable() {
    final orderedForRef = [...registros]
      ..sort((a, b) => a.localId.compareTo(b.localId));
    final refsByLocalId = <int, int>{
      for (var i = 0; i < orderedForRef.length; i++)
        orderedForRef[i].localId: i + 1,
    };

    return _RegistroLoteGroup(
      loteId: loteId,
      loteLine: loteLine,
      registros: List.unmodifiable(registros),
      refsByLocalId: refsByLocalId,
    );
  }
}

class _RegistroLoteGroup {
  final int? loteId;
  final String loteLine;
  final List<Registro> registros;
  final Map<int, int> refsByLocalId;

  const _RegistroLoteGroup({
    required this.loteId,
    required this.loteLine,
    required this.registros,
    required this.refsByLocalId,
  });

  int visualRefFor(Registro registro) => refsByLocalId[registro.localId] ?? 1;
}

bool _isRegistroSynced(Registro r) =>
    r.serverId != null || r.syncStatus == SyncStatus.synced;

bool _hasTableValue(dynamic value) {
  if (value == null) return false;
  if (value is String) return value.trim().isNotEmpty;
  if (value is Iterable) return value.isNotEmpty;
  if (value is Map) return value.isNotEmpty;
  return true;
}

String _compactTableLabel(String label) {
  final compact = label.replaceFirst(RegExp(r'^\s*\d+\.\s*'), '').trim();
  return compact.isEmpty ? label.trim() : compact;
}

dynamic _payloadValueForColumn(Registro registro, _RegistroFieldColumn column) {
  final payload = registro.normalizedPayload();
  final header = payload['header'] as Map<String, dynamic>? ?? {};
  final body = payload['body'] as Map<String, dynamic>? ?? {};

  if (column.type == CartillaFieldType.signaturePad) {
    return null;
  }

  if (column.type == CartillaFieldType.photo) {
    final rawFotos = body['fotos'];
    if (rawFotos is! List) return null;
    final slot = column.photoIndex ?? 0;
    for (final foto in rawFotos) {
      if (foto is! Map) continue;
      final rawSlot = foto['slot'];
      final fotoSlot = rawSlot is num
          ? rawSlot.toInt()
          : int.tryParse(rawSlot?.toString() ?? '');
      if (fotoSlot == slot) return foto;
    }
    return null;
  }

  final primary = column.isHeader ? header[column.key] : body[column.key];
  if (_hasTableValue(primary)) return primary;

  // Registros antiguos pueden tener algunos campos de formulario en header
  // aunque hoy la configuración los declare en body, o viceversa.
  final fallback = column.isHeader ? body[column.key] : header[column.key];
  return fallback;
}

String _formatTableValue(dynamic value) {
  if (value == null) return '—';
  if (value is String) return value.trim().isEmpty ? '—' : value.trim();
  if (value is num) {
    return value == value.toInt() ? value.toInt().toString() : value.toString();
  }
  if (value is bool) return value ? 'Sí' : 'No';
  if (value is Iterable) {
    final count = value.length;
    return count == 0 ? '—' : '$count item(s)';
  }
  if (value is Map) {
    final localPath = value['localPath']?.toString();
    final serverUrl = value['serverUrl']?.toString();
    if ((localPath != null && localPath.isNotEmpty) ||
        (serverUrl != null && serverUrl.isNotEmpty)) {
      return 'Foto';
    }
    return value.isEmpty ? '—' : 'Dato';
  }
  return value.toString();
}

String _formatSyncLabel(Registro registro) {
  if (registro.serverId != null) return 'Sincronizado';
  switch (registro.syncStatus) {
    case SyncStatus.local:
      return 'Local';
    case SyncStatus.pending:
      return 'Pendiente';
    case SyncStatus.synced:
      return 'Sincronizado';
    case SyncStatus.failed:
      return 'Error';
  }
}

Future<void> _openRegistroForEdit(
  BuildContext context, {
  required String templateKey,
  required Registro registro,
}) async {
  final formRoute = FormRegistry.routeFor(templateKey);
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
      if (mode == _PodaCreateMode.editFinal) 'podaFinalMode': true,
    },
  );
}

List<_RegistroFieldColumn> _buildRegistroFieldColumns(
  String templateKey,
  List<Registro> registros,
) {
  final config = CartillaConfigRegistry.resolve(templateKey);
  final fields = <_RegistroFieldColumn>[];
  final seen = <String>{};

  for (final section in config.sections) {
    for (final field in section.fields) {
      if (!seen.add(field.key)) continue;
      fields.add(
        _RegistroFieldColumn(
          key: field.key,
          label: _compactTableLabel(field.label),
          isHeader: config.headerKeys.contains(field.key),
          type: field.type,
          photoIndex: field.photoIndex,
        ),
      );
    }
  }

  if (_isPodaTemplate(templateKey)) {
    final existing = fields.toList(growable: false);
    for (final field in existing) {
      if (field.type == CartillaFieldType.photo ||
          field.type == CartillaFieldType.signaturePad) {
        continue;
      }
      final finalKey = 'final_${field.key}';
      final hasFinalValue = registros.any((registro) {
        final payload = registro.normalizedPayload();
        final body = payload['body'] as Map<String, dynamic>? ?? {};
        return _hasTableValue(body[finalKey]);
      });
      if (!hasFinalValue || !seen.add(finalKey)) continue;
      fields.add(
        _RegistroFieldColumn(
          key: finalKey,
          label: 'Final ${field.label}',
          isHeader: false,
          type: field.type,
        ),
      );
    }

    final hasFinalFotos = registros.any((registro) {
      final payload = registro.normalizedPayload();
      final body = payload['body'] as Map<String, dynamic>? ?? {};
      return _hasTableValue(body['finalFotos']);
    });
    if (hasFinalFotos && seen.add('finalFotos')) {
      fields.add(
        const _RegistroFieldColumn(
          key: 'finalFotos',
          label: 'Fotos finales',
          isHeader: false,
        ),
      );
    }
  }

  return fields;
}

enum _PodaCreateMode { editCurrent, editFinal }

enum _RegistrosViewMode { list, table }

class _RegistroFieldColumn {
  final String key;
  final String label;
  final bool isHeader;
  final CartillaFieldType? type;
  final int? photoIndex;

  const _RegistroFieldColumn({
    required this.key,
    required this.label,
    required this.isHeader,
    this.type,
    this.photoIndex,
  });
}

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
  int visualRef,
) async {
  final remote = ref.read(registrosRemoteDSProvider);
  final synced = _isRegistroSynced(registro);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminar registro'),
      content: Text(
        synced
            ? '¿Eliminar el registro sincronizado?\n\n'
                  'Código: ${registro.displayClientCode}\n'
                  'Servidor: #${registro.serverId ?? '-'}\n'
                  'Ref. #$visualRef\n\n'
                  'Se borrará del dispositivo y también del backend.'
            : '¿Eliminar el registro local?\n\n'
                  'Código: ${registro.displayClientCode}\n'
                  'Ref. #$visualRef\n'
                  'Ref. local: #${registro.localId}\n\n'
                  'Esta acción no se puede deshacer.',
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
  if (confirmed != true) return;

  try {
    if (synced) {
      await remote.deleteRegistroByClientRecordId(registro.clientRecordId);
    }
    await local.deleteByLocalId(registro.localId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            synced
                ? 'Registro eliminado en app y backend'
                : 'Registro eliminado localmente',
          ),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el registro: $e')),
      );
    }
  }
}

class RegistrosPage extends ConsumerStatefulWidget {
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
  ConsumerState<RegistrosPage> createState() => _RegistrosPageState();
}

class _RegistrosPageState extends ConsumerState<RegistrosPage> {
  _RegistrosViewMode _viewMode = _RegistrosViewMode.list;

  @override
  Widget build(BuildContext context) {
    final plantillaId = widget.plantillaId;
    final templateKey = widget.templateKey;
    final plantillaNombre = widget.plantillaNombre;
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

            final local = ref.read(registrosLocalDSProvider);
            final loteGroups = _buildRegistroLoteGroups(
              ofToday,
              loteDescriptions,
            );

            return Column(
              children: [
                _RegistrosViewModeSelector(
                  value: _viewMode,
                  onChanged: (mode) => setState(() => _viewMode = mode),
                  registrosCount: ofToday.length,
                ),
                Expanded(
                  child: _viewMode == _RegistrosViewMode.table
                      ? _RegistrosLiteralTableView(
                          templateKey: templateKey,
                          groups: loteGroups,
                          loteDescriptions: loteDescriptions,
                          onOpen: (registro) => _openRegistroForEdit(
                            context,
                            templateKey: templateKey,
                            registro: registro,
                          ),
                          onDelete: (registro, visualRef) => _confirmAndDelete(
                            context,
                            ref,
                            registro,
                            local,
                            visualRef,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: loteGroups.length,
                          itemBuilder: (_, groupIndex) {
                            final group = loteGroups[groupIndex];
                            return _RegistroLoteSection(
                              group: group,
                              loteDescriptions: loteDescriptions,
                              onOpen: (registro) => _openRegistroForEdit(
                                context,
                                templateKey: templateKey,
                                registro: registro,
                              ),
                              onDelete: (registro, visualRef) =>
                                  _confirmAndDelete(
                                    context,
                                    ref,
                                    registro,
                                    local,
                                    visualRef,
                                  ),
                            );
                          },
                        ),
                ),
              ],
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

class _RegistrosViewModeSelector extends StatelessWidget {
  final _RegistrosViewMode value;
  final ValueChanged<_RegistrosViewMode> onChanged;
  final int registrosCount;

  const _RegistrosViewModeSelector({
    required this.value,
    required this.onChanged,
    required this.registrosCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DonLuisColors.primary.withValues(alpha: 0.14),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ViewModeButton(
                  icon: Icons.view_list_outlined,
                  label: 'Lista',
                  selected: value == _RegistrosViewMode.list,
                  onTap: () => onChanged(_RegistrosViewMode.list),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: DonLuisColors.primary.withValues(alpha: 0.1),
                ),
                _ViewModeButton(
                  icon: Icons.table_chart_outlined,
                  label: 'Tabla',
                  selected: value == _RegistrosViewMode.table,
                  onTap: () => onChanged(_RegistrosViewMode.table),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DonLuisColors.primary.withValues(alpha: 0.14),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.format_list_numbered_rounded,
                  size: 18,
                  color: DonLuisColors.primary.withValues(alpha: 0.78),
                ),
                const SizedBox(width: 8),
                Text(
                  'Muestras hoy: $registrosCount',
                  style: TextStyle(
                    color: DonLuisColors.primary.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : DonLuisColors.primary;
    return Material(
      color: selected ? DonLuisColors.primary : Colors.transparent,
      child: InkWell(
        onTap: selected ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegistrosLiteralTableView extends StatelessWidget {
  final String templateKey;
  final List<_RegistroLoteGroup> groups;
  final Map<int, String> loteDescriptions;
  final ValueChanged<Registro> onOpen;
  final void Function(Registro registro, int visualRef) onDelete;

  const _RegistrosLiteralTableView({
    required this.templateKey,
    required this.groups,
    required this.loteDescriptions,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final registros = [for (final group in groups) ...group.registros];
    final refsByLocalId = {for (final group in groups) ...group.refsByLocalId};
    final fieldColumns = _buildRegistroFieldColumns(templateKey, registros);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DonLuisColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dataTableTheme: DataTableThemeData(
                      headingRowColor: WidgetStateProperty.all(
                        DonLuisColors.primary.withValues(alpha: 0.08),
                      ),
                      dataTextStyle: const TextStyle(
                        color: Color(0xFF1A1D21),
                        fontSize: 12.5,
                      ),
                      headingTextStyle: const TextStyle(
                        color: DonLuisColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                      horizontalMargin: 12,
                      columnSpacing: 14,
                      dividerThickness: 1,
                    ),
                  ),
                  child: DataTable(
                    showCheckboxColumn: false,
                    headingRowHeight: 52,
                    dataRowMinHeight: 50,
                    dataRowMaxHeight: 64,
                    columns: [
                      _metaColumn('Ref.', 128),
                      _metaColumn('Hora', 70),
                      _metaColumn('Estado', 112),
                      _metaColumn('Codigo', 130),
                      _metaColumn('Lote', 180),
                      for (final col in fieldColumns) _fieldColumn(col.label),
                      _metaColumn('Acciones', 104),
                    ],
                    rows: [
                      for (var i = 0; i < registros.length; i++)
                        _buildRow(
                          context,
                          registros[i],
                          fieldColumns,
                          i,
                          refsByLocalId[registros[i].localId] ?? 1,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataColumn _metaColumn(String label, double width) {
    return DataColumn(
      label: SizedBox(
        width: width,
        child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  DataColumn _fieldColumn(String label) {
    return DataColumn(
      label: SizedBox(
        width: 136,
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
      ),
    );
  }

  DataRow _buildRow(
    BuildContext context,
    Registro registro,
    List<_RegistroFieldColumn> fieldColumns,
    int index,
    int visualRef,
  ) {
    final (loteLine, _) = _registroContextLines(registro, loteDescriptions);
    final ids = _isRegistroSynced(registro)
        ? 'Srv #${registro.serverId ?? '-'} / Ref. #$visualRef'
        : 'Ref. #$visualRef';

    return DataRow(
      color: WidgetStateProperty.all(
        index.isEven
            ? DonLuisColors.surfaceCard
            : DonLuisColors.surface.withValues(alpha: 0.6),
      ),
      onSelectChanged: (_) => onOpen(registro),
      cells: [
        _textCell(ids, 128, registro),
        _textCell(_formatRegistroLocalTime(registro), 70, registro),
        _textCell(_formatSyncLabel(registro), 112, registro),
        _textCell(registro.shortClientCode, 130, registro, monospace: true),
        _textCell(loteLine, 180, registro),
        for (final col in fieldColumns)
          _textCell(
            _formatTableValue(_payloadValueForColumn(registro, col)),
            136,
            registro,
          ),
        DataCell(
          SizedBox(
            width: 104,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: DonLuisColors.primary.withValues(alpha: 0.78),
                  onPressed: () => onOpen(registro),
                ),
                IconButton(
                  tooltip: _isRegistroSynced(registro)
                      ? 'Eliminar en app y backend'
                      : 'Eliminar registro local',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: DonLuisColors.primary.withValues(alpha: 0.68),
                  onPressed: () => onDelete(registro, visualRef),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DataCell _textCell(
    String text,
    double width,
    Registro registro, {
    bool monospace = false,
  }) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5,
            fontFamily: monospace ? 'monospace' : null,
          ),
        ),
      ),
      onTap: () => onOpen(registro),
    );
  }
}

class _RegistroLoteSection extends StatelessWidget {
  final _RegistroLoteGroup group;
  final Map<int, String> loteDescriptions;
  final ValueChanged<Registro> onOpen;
  final void Function(Registro registro, int visualRef) onDelete;

  const _RegistroLoteSection({
    required this.group,
    required this.loteDescriptions,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RegistroLoteHeader(group: group),
          const SizedBox(height: 8),
          for (var i = 0; i < group.registros.length; i++) ...[
            _RegistroTile(
              registro: group.registros[i],
              visualRef: group.visualRefFor(group.registros[i]),
              loteDescriptions: loteDescriptions,
              onTap: () => onOpen(group.registros[i]),
              onDelete: () => onDelete(
                group.registros[i],
                group.visualRefFor(group.registros[i]),
              ),
            ),
            if (i < group.registros.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _RegistroLoteHeader extends StatelessWidget {
  final _RegistroLoteGroup group;

  const _RegistroLoteHeader({required this.group});

  @override
  Widget build(BuildContext context) {
    final count = group.registros.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DonLuisColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DonLuisColors.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 18,
            color: DonLuisColors.primary.withValues(alpha: 0.78),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              group.loteLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DonLuisColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: DonLuisColors.primary.withValues(alpha: 0.14),
              ),
            ),
            child: Text(
              '$count ${count == 1 ? 'registro' : 'registros'}',
              style: TextStyle(
                color: DonLuisColors.primary.withValues(alpha: 0.82),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistroTile extends StatelessWidget {
  final Registro registro;
  final int visualRef;
  final Map<int, String> loteDescriptions;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RegistroTile({
    required this.registro,
    required this.visualRef,
    required this.loteDescriptions,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatRegistroLocalTime(registro);
    final (loteLine, _) = _registroContextLines(registro, loteDescriptions);

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
                      const SizedBox(height: 8),
                      Text(
                        _isRegistroSynced(registro)
                            ? 'Servidor #${registro.serverId} · Ref. #$visualRef'
                            : 'Ref. #$visualRef',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: DonLuisColors.primary.withValues(alpha: 0.78),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Código: ${registro.displayClientCode}',
                        style: TextStyle(
                          fontSize: 11,
                          color: DonLuisColors.primary.withValues(alpha: 0.6),
                          fontFamily: 'monospace',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: _isRegistroSynced(registro)
                      ? 'Eliminar en app y backend'
                      : 'Eliminar registro local',
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
