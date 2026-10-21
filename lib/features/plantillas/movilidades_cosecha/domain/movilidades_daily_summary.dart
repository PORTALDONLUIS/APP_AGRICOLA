import 'movilidades_guias.dart';

String _text(dynamic value) => value == null ? '' : '$value'.trim();
String _documentPart(dynamic value) =>
    _text(value).toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
String _plate(dynamic value) =>
    _documentPart(value).replaceAll(RegExp(r'[^A-Z0-9]'), '');

/// One saved sample is one trip. Documents are distinct by issuer/series/number,
/// not by lot or by the number of repeated guide blocks. No source maps are changed.
Map<String, dynamic> movilidadesDailySummary(
  List<Map<String, dynamic>> records,
) {
  final seen = <String>{},
      plates = <String>{},
      documents = <String>{},
      lots = <String>{};
  final unknownIssuers = <String>{};
  final trips = <Map<String, dynamic>>[];
  var totalBoxes = 0,
      missingBoxes = 0,
      incompleteGuides = 0,
      missingPlates = 0,
      pending = 0;
  for (var index = 0; index < records.length; index++) {
    final record = records[index];
    final body = Map<String, dynamic>.from(record['body'] as Map? ?? {});
    final header = Map<String, dynamic>.from(record['header'] as Map? ?? {});
    final meta = Map<String, dynamic>.from(record['_meta'] as Map? ?? {});
    final client = _text(meta['clientRecordId']);
    final server = _text(meta['registroId']);
    final identity = client.isNotEmpty
        ? 'client:$client'
        : server.isNotEmpty
        ? 'server:$server'
        : 'row:$index';
    if (!seen.add(identity)) continue;
    final plate = _plate(body['placa']);
    if (plate.isEmpty) {
      missingPlates++;
    } else {
      plates.add(plate);
    }
    if (meta['sincronizado'] == false) pending++;
    final issuer = _documentPart(body['nombreProveedor']);
    final guideGroups = <String, Map<String, dynamic>>{};
    var tripBoxes = 0;
    final guides = movilidadesGuias(body, header);
    for (var j = 0; j < guides.length; j++) {
      final guide = guides[j];
      final docKey = movilidadesGuideKey(issuer, guide);
      if (docKey != null) {
        documents.add(docKey);
        if (issuer.isEmpty) unknownIssuers.add(docKey);
      } else {
        incompleteGuides++;
      }
      final count = movilidadesCajas(guide['cantidadCajas']);
      if (count == null) {
        missingBoxes++;
      } else {
        totalBoxes += count;
        tripBoxes += count;
      }
      final lot = _text(guide['loteId']);
      if (lot.isNotEmpty) lots.add(int.tryParse(lot)?.toString() ?? lot);
      final group = guideGroups.putIfAbsent(
        docKey ?? 'incomplete:$j',
        () => {
          'serieGuia': _text(guide['serieGuia']),
          'nroGuia': _text(guide['nroGuia']),
          'proveedor': _text(body['nombreProveedor']),
          'cajas': 0,
          'lotes': <Map<String, dynamic>>[],
        },
      );
      group['cajas'] = (group['cajas'] as int) + (count ?? 0);
      (group['lotes'] as List).add({...guide, 'cantidadCajas': count});
    }
    trips.add({
      'registroId': meta['registroId'],
      'placa': plate,
      'proveedor': _text(body['nombreProveedor']),
      'horaInicioCarga': _text(body['horaInicioCarga']),
      'finHoraCarga': _text(body['finHoraCarga']),
      'cajas': tripBoxes,
      'guias': guideGroups.values.toList(),
      'sincronizado': meta['sincronizado'] != false,
    });
  }
  return {
    'viajes': trips.length,
    'camiones': plates.length,
    'guias': documents.length,
    'cajas': totalBoxes,
    'lotes': lots.length,
    'viajesSinPlaca': missingPlates,
    'guiasIncompletas': incompleteGuides,
    'guiasSinProveedor': unknownIssuers.length,
    'lineasSinCantidad': missingBoxes,
    'pendientes': pending,
    'viajesDetalle': trips,
  };
}

/// One link for the evaluator's entire day, independent of the number of lots.
String? movilidadesDailyUrl({
  required String baseUrl,
  required DateTime day,
  required int? plantillaId,
  required int userId,
}) {
  if (plantillaId == null || plantillaId <= 0 || userId <= 0) return null;
  final month = day.month.toString().padLeft(2, '0'),
      date = day.day.toString().padLeft(2, '0');
  return Uri.parse(
        '${baseUrl.replaceFirst(RegExp(r'/$'), '')}/cartillas-agricolas/publico/evaluacion/',
      )
      .replace(
        queryParameters: {
          'resumen': 'diario',
          'fecha': '${day.year}-$month-$date',
          'usuarioId': '$userId',
          'cartillaId': '$plantillaId',
        },
      )
      .toString();
}

String movilidadesDailyShareText(Map summary, {required String dayLabel}) {
  final buffer =
      StringBuffer(
          'Buen día, comparto el reporte diario de la cartilla:\n'
          '*MOVILIDADES COSECHA*\n'
          'Fecha: $dayLabel\n\n',
        )
        ..writeln('Cargas / viajes: ${summary['viajes']}')
        ..writeln('Camiones distintos: ${summary['camiones']}')
        ..writeln('Guías distintas: ${summary['guias']}')
        ..writeln('Total de cajas: ${summary['cajas']}')
        ..writeln('Lotes: ${summary['lotes']}')
        ..writeln();
  if ((summary['pendientes'] as int? ?? 0) > 0) {
    buffer.writeln(
      'Pendientes de sincronizar: ${summary['pendientes']}. El enlace muestra solo lo sincronizado.',
    );
  } else {
    buffer.writeln('El enlace contiene la información sincronizada del día.');
  }
  final warnings = <String>[];
  for (final pair in const [
    ['viajesSinPlaca', 'viajes sin placa'],
    ['guiasIncompletas', 'bloques sin serie o número'],
    ['guiasSinProveedor', 'guías sin proveedor'],
    ['lineasSinCantidad', 'cantidades pendientes'],
  ]) {
    if ((summary[pair[0]] as int? ?? 0) > 0) {
      warnings.add('${summary[pair[0]]} ${pair[1]}');
    }
  }
  if (warnings.isNotEmpty) {
    buffer.writeln('Datos por completar: ${warnings.join('; ')}.');
  }
  buffer.write(
    'Una guía puede incluir varios lotes. Las cajas se suman por lote.',
  );
  return buffer.toString();
}
