/// Defaults are applied once when opening a new local sample, never on rebuild.
Map<String, dynamic> evaluationDefaults(Map<String, dynamic> body,
    Map<String, dynamic> header, {bool withStartTime = false, DateTime? now}) {
  final instant = header['fechaEjecucion'];
  final utc = instant is num && instant > 0
      ? DateTime.fromMillisecondsSinceEpoch(instant.toInt(), isUtc: true)
      : (now ?? DateTime.now()).toUtc();
  final pe = utc.subtract(const Duration(hours: 5));
  String two(int n) => n.toString().padLeft(2, '0');
  return {
    ...body,
    if (body['fecha'] == null || '${body['fecha']}'.trim().isEmpty)
      'fecha': '${two(pe.day)}/${two(pe.month)}/${pe.year}',
    if (withStartTime &&
        (body['horaInicioCarga'] == null ||
            '${body['horaInicioCarga']}'.trim().isEmpty))
      'horaInicioCarga': '${two(pe.hour)}:${two(pe.minute)}',
  };
}
