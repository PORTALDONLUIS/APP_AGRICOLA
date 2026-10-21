import 'package:flutter/material.dart';

/// Formal daylight-friendly report, without treating codes as measurements.
class MovilidadesDailyReport extends StatelessWidget {
  const MovilidadesDailyReport({super.key, required this.summary});
  final Map<String, dynamic> summary;
  static const ink = Color(0xFF172B3A),
      blue = Color(0xFF145C94),
      green = Color(0xFF087A46);

  Widget _metric(String label, dynamic value) => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: ink, fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: const TextStyle(
              color: green,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final trips = (summary['viajesDetalle'] as List? ?? []).cast<Map>();
    final plates = <String, List<Map>>{};
    for (var i = 0; i < trips.length; i++) {
      final plate = '${trips[i]['placa'] ?? ''}';
      plates
          .putIfAbsent(
            plate.isEmpty ? 'Sin placa · viaje ${i + 1}' : plate,
            () => [],
          )
          .add(trips[i]);
    }
    return ListView(
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final width = (box.maxWidth - 8) / 2;
            return Wrap(
              children: [
                for (final pair in const [
                  ['viajes', 'Cargas / viajes'],
                  ['camiones', 'Camiones distintos'],
                  ['guias', 'Guías distintas'],
                  ['cajas', 'Total de cajas'],
                ])
                  SizedBox(
                    width: width,
                    child: _metric(pair[1], summary[pair[0]] ?? 0),
                  ),
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            '${summary['lotes']} lotes · ${summary['pendientes']} muestras pendientes de sincronizar.\n'
            'Una muestra = un viaje. Una placa puede tener varios viajes. '
            'Las cajas se suman por lote, no se promedian.',
            style: const TextStyle(color: ink, fontSize: 14),
          ),
        ),
        if ((summary['guiasIncompletas'] as int? ?? 0) > 0 ||
            (summary['guiasSinProveedor'] as int? ?? 0) > 0 ||
            (summary['lineasSinCantidad'] as int? ?? 0) > 0 ||
            (summary['viajesSinPlaca'] as int? ?? 0) > 0)
          Card(
            color: const Color(0xFFFFF3D6),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'Datos por completar: ${summary['viajesSinPlaca']} viajes sin placa; '
                '${summary['guiasIncompletas']} bloques sin serie o número; '
                '${summary['guiasSinProveedor']} guías sin proveedor; '
                '${summary['lineasSinCantidad']} cantidades pendientes. '
                'Las placas vacías y guías sin serie/número no se cuentan como distintas. '
                'Si falta proveedor, se agrupan las guías que tengan igual serie y número.',
                style: const TextStyle(color: ink),
              ),
            ),
          ),
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Detalle por camión y viaje',
            style: TextStyle(
              color: blue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        for (final entry in plates.entries)
          Card(
            color: Colors.white,
            child: ExpansionTile(
              textColor: ink,
              collapsedTextColor: ink,
              iconColor: blue,
              collapsedIconColor: blue,
              title: Text(
                '${entry.key} · ${entry.value.length} viaje(s)',
                style: const TextStyle(
                  color: blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                for (var i = 0; i < entry.value.length; i++)
                  ExpansionTile(
                    textColor: ink,
                    collapsedTextColor: ink,
                    title: Text(
                      'Viaje ${i + 1} · ${entry.value[i]['horaInicioCarga']} · ${entry.value[i]['cajas']} cajas',
                      style: const TextStyle(color: ink),
                    ),
                    children: [
                      for (final guide in entry.value[i]['guias'] as List)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Guía ${guide['serieGuia']}-${guide['nroGuia']} · ${guide['cajas']} cajas',
                                style: const TextStyle(
                                  color: green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Proveedor: ${guide['proveedor']}',
                                style: const TextStyle(color: ink),
                              ),
                              for (final lot in guide['lotes'] as List)
                                ListTile(
                                  dense: true,
                                  title: Text(
                                    '${lot['loteDescripcion'] ?? lot['loteId'] ?? 'Sin lote'}',
                                    style: const TextStyle(color: ink),
                                  ),
                                  subtitle: Text(
                                    '${lot['cantidadCajas'] ?? 'Pendiente'} cajas · ${lot['variedad'] ?? ''}',
                                    style: const TextStyle(color: ink),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
