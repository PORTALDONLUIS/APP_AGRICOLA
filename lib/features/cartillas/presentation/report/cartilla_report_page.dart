import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/cartilla_report_registry.dart';
import '../../../../app/theme/donluis_theme.dart';
import '../../../../app/providers.dart';
import '../../../../features/master/presentation/master_providers.dart';
import '../../domain/report/cartilla_report_provider.dart';
import '../../../../shared/widgets/donluis_gradient_scaffold.dart';
import '../../../../shared/widgets/donluis_app_bar.dart';
import 'widgets/dynamic_report_table.dart';

class CartillaReportPage extends ConsumerStatefulWidget {
  final String templateKey;
  final DateTime day;
  final String plantillaNombre;

  const CartillaReportPage({
    super.key,
    required this.templateKey,
    required this.day,
    required this.plantillaNombre,
  });

  @override
  ConsumerState<CartillaReportPage> createState() => _CartillaReportPageState();
}

class _CartillaReportPageState extends ConsumerState<CartillaReportPage> {
  Future<void> _shareReport() async {
    final config = CartillaReportRegistry.tryResolve(widget.templateKey);
    if (config == null) return;

    final userId = ref.read(currentUserIdProvider);
    final request = CartillaReportRequest(
      templateKey: widget.templateKey,
      date: widget.day,
      userId: userId,
    );
    final asyncReport = ref.read(cartillaReportProvider(request));
    final rows = asyncReport.valueOrNull;
    if (rows == null || rows.isEmpty) return;

    final lotesAsync = ref.read(lotesStreamProvider);
    final loteIdToDescription = lotesAsync.whenOrNull(data: (list) {
      final map = <String, String>{};
      for (final l in list) {
        map[l.idLote.toString()] = l.descripcion;
      }
      return map;
    }) ?? <String, String>{};

    final visibleColumns =
        config.columns.where((c) => !c.hidden).toList(growable: false);
    if (visibleColumns.isEmpty) return;

    final size = DynamicReportTable.captureContentSize(
      visibleColumns.length,
      rows.length,
    );

    final fullTableWidget = Material(
      type: MaterialType.transparency,
      child: Theme(
        data: Theme.of(context),
        child: DynamicReportTable(
          config: config,
          rows: rows,
          loteIdToDescription: loteIdToDescription.isEmpty
              ? null
              : loteIdToDescription,
          forCapture: true,
          contentWidth: size.width,
          contentHeight: size.height,
        ),
      ),
    );

    final controller = ScreenshotController();
    final imageBytes = await controller.captureFromWidget(
      fullTableWidget,
      pixelRatio: 2,
      targetSize: size,
    );
    if (imageBytes.isEmpty) return;

    final tempDir = await getTemporaryDirectory();
    final path = await _fileFromBytes(
      tempDir.path,
      'reporte_${_formatDay(widget.day).replaceAll(' ', '_')}.png',
      imageBytes,
    );
    if (path == null) return;

    if (mounted) {
      await Share.shareXFiles(
        [XFile(path)],
        text: 'Reporte ${widget.plantillaNombre} - ${_formatDay(widget.day)}',
      );
    }
  }

  Future<String?> _fileFromBytes(
    String dir,
    String name,
    List<int> bytes,
  ) async {
    try {
      final path = '$dir/$name';
      final file = File(path);
      await file.writeAsBytes(bytes);
      return path;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = CartillaReportRegistry.tryResolve(widget.templateKey);
    if (config == null) {
      return DonLuisGradientScaffold(
        appBar: DonLuisAppBar(
          title: Text(widget.plantillaNombre),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assessment_outlined,
                  size: 56,
                  color: DonLuisColors.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Esta cartilla aún no tiene un reporte configurado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: DonLuisColors.primary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final userId = ref.watch(currentUserIdProvider);
    final asyncReport = ref.watch(
      cartillaReportProvider(
        CartillaReportRequest(
          templateKey: widget.templateKey,
          date: widget.day,
          userId: userId,
        ),
      ),
    );
    final lotesAsync = ref.watch(lotesStreamProvider);
    final loteIdToDescription = lotesAsync.whenOrNull(data: (list) {
      final map = <String, String>{};
      for (final l in list) {
        map[l.idLote.toString()] = l.descripcion;
      }
      return map;
    }) ?? <String, String>{};

    return DonLuisGradientScaffold(
      appBar: DonLuisAppBar(
        title: Text(
          config.title.isNotEmpty ? config.title : widget.plantillaNombre,
        ),
        actions: [
          Builder(
            builder: (context) {
              final hasData = asyncReport.hasValue &&
                  asyncReport.value != null &&
                  asyncReport.value!.isNotEmpty;
              if (!hasData) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Compartir reporte',
                onPressed: () async {
                  await _shareReport();
                },
              );
            },
          ),
        ],
      ),
      body: asyncReport.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: DonLuisColors.primary,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando reporte…',
                style: TextStyle(
                  color: DonLuisColors.primary.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: DonLuisColors.primary.withOpacity(0.8),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar el reporte',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DonLuisColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$e',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: DonLuisColors.primary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.table_chart_outlined,
                      size: 56,
                      color: DonLuisColors.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay datos para el reporte del día seleccionado',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: DonLuisColors.primary.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDay(widget.day),
                      style: TextStyle(
                        fontSize: 13,
                        color: DonLuisColors.primary.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _formatDay(widget.day),
                      style: TextStyle(
                        fontSize: 13,
                        color: DonLuisColors.primary.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: DynamicReportTable(
                      config: config,
                      rows: rows,
                      loteIdToDescription: loteIdToDescription.isEmpty
                          ? null
                          : loteIdToDescription,
                    ),
                  ),
                ],
              ),
            );
        },
      ),
    );
  }

  static String _formatDay(DateTime day) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${day.day} ${months[day.month - 1]} ${day.year}';
  }
}
