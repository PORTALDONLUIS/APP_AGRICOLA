import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/cartilla_report_registry.dart';
import '../../../../app/theme/donluis_theme.dart';
import '../../../../app/providers.dart';
import '../../../../features/master/presentation/master_providers.dart';
import '../../domain/report/cartilla_report_provider.dart';
import '../../../../shared/widgets/donluis_gradient_scaffold.dart';
import '../../../../shared/widgets/donluis_app_bar.dart';
import 'widgets/dynamic_report_table.dart';

class CartillaReportPage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final config = CartillaReportRegistry.tryResolve(templateKey);
    if (config == null) {
      return DonLuisGradientScaffold(
        appBar: DonLuisAppBar(
          title: Text(plantillaNombre),
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
          templateKey: templateKey,
          date: day,
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
          config.title.isNotEmpty ? config.title : plantillaNombre,
        ),
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
                      _formatDay(day),
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
                    _formatDay(day),
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
