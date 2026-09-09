class BrixMoscatelReportMetrics {
  final int totalLecturas;
  final int totalMayoresDe16;
  final int cantidadHileras;
  final int cantidadHilerasMayoresDe16;

  const BrixMoscatelReportMetrics({
    required this.totalLecturas,
    required this.totalMayoresDe16,
    required this.cantidadHileras,
    required this.cantidadHilerasMayoresDe16,
  });

  double get promRacimo =>
      cantidadHileras == 0 ? 0 : totalLecturas / 3 / cantidadHileras;

  double get promRacimoMayorDe16 => cantidadHilerasMayoresDe16 == 0
      ? 0
      : totalMayoresDe16 / 3 / cantidadHilerasMayoresDe16;
}

/// Replica las fórmulas de la hoja "Resumen" del archivo de referencia:
/// - PROM. RACIMO = lecturas BRIX / 3 / hileras distintas.
/// - PROM. RACIMO > 16 = lecturas BRIX > 16 / 3 /
///   hileras distintas que tengan al menos una lectura > 16.
BrixMoscatelReportMetrics calculateBrixMoscatelReportMetrics(
  Iterable<Map<String, dynamic>> payloads,
) {
  final hileras = <String>{};
  final hilerasMayoresDe16 = <String>{};
  var totalLecturas = 0;
  var totalMayoresDe16 = 0;

  for (final payload in payloads) {
    final header =
        (payload['header'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final body =
        (payload['body'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final hilera = '${header['hilera'] ?? body['hilera'] ?? ''}'.trim();
    final brix = _toNum(body['brixSsc']);

    if (brix == null) continue;
    totalLecturas++;
    if (hilera.isNotEmpty) hileras.add(hilera);

    if (brix > 16) {
      totalMayoresDe16++;
      if (hilera.isNotEmpty) hilerasMayoresDe16.add(hilera);
    }
  }

  return BrixMoscatelReportMetrics(
    totalLecturas: totalLecturas,
    totalMayoresDe16: totalMayoresDe16,
    cantidadHileras: hileras.length,
    cantidadHilerasMayoresDe16: hilerasMayoresDe16.length,
  );
}

num? _toNum(dynamic value) {
  if (value is num) return value;
  if (value is String) {
    return num.tryParse(value.trim().replaceAll(',', '.'));
  }
  return null;
}
