import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../domain/registro.dart';

/// Snapshot independiente de la muestra; nunca se modifica después de enviarlo.
class BrixSyncItem {
  final Registro registro;
  final Map<String, dynamic> payload;
  final String revision;

  BrixSyncItem._(this.registro, this.payload, this.revision);

  factory BrixSyncItem.fromRegistro(Registro registro) {
    if (!RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(registro.clientRecordId)) {
      throw const FormatException(
        'La muestra no tiene un identificador estable.',
      );
    }
    final decoded = jsonDecode(registro.dataJson);
    if (decoded is! Map ||
        decoded['header'] is! Map ||
        decoded['body'] is! Map ||
        decoded['payloadVersion'] != 1) {
      throw const FormatException(
        'La muestra Brix no tiene un formato válido.',
      );
    }
    final payload = Map<String, dynamic>.from(decoded);
    if (payload.keys.any(
      (key) => !const {'payloadVersion', 'header', 'body'}.contains(key),
    )) {
      throw const FormatException(
        'La muestra contiene datos que requieren revisión.',
      );
    }
    final header = Map<String, dynamic>.from(payload['header'] as Map);
    if (registro.userId <= 0 ||
        registro.plantillaId <= 0 ||
        (header['userId'] != null && header['userId'] != registro.userId) ||
        (header['plantillaId'] != null &&
            header['plantillaId'] != registro.plantillaId)) {
      throw const FormatException(
        'La muestra no coincide con el usuario o la cartilla.',
      );
    }
    // Las versiones anteriores de +1 podían omitir esta identidad en el JSON.
    // La copia enviada siempre queda ligada a la sesión y plantilla originales;
    // el CAS local sigue comparando el JSON original, sin reescribir el equipo.
    header['userId'] = registro.userId;
    header['plantillaId'] = registro.plantillaId;
    payload['header'] = header;
    final capturedAt = header['fechaEjecucion'];
    if (capturedAt is! num || !capturedAt.isFinite || capturedAt <= 0) {
      throw const FormatException(
        'La muestra no tiene una fecha de captura válida.',
      );
    }
    return BrixSyncItem._(
      registro,
      payload,
      brixSnapshotRevision(registro.templateKey, payload),
    );
  }
}

String normalizeBrixTemplateKey(String value) =>
    value.trim().toLowerCase().replaceAll('-', '_');

/// Codificación compartida con la API. Los números usan los bits IEEE-754,
/// evitando diferencias de JSON entre Python y Dart (1 / 1.0, exponentes).
String brixSnapshotRevision(String templateKey, Map<String, dynamic> payload) {
  final snapshot = <String, dynamic>{
    'templateKey': normalizeBrixTemplateKey(templateKey),
    'payloadVersion': payload['payloadVersion'],
    'dataJson': payload,
  };
  return sha256
      .convert(utf8.encode(jsonEncode(_typedNode(snapshot))))
      .toString();
}

Object _typedNode(Object? value, [int depth = 0]) {
  if (depth > 24) {
    throw const FormatException(
      'La muestra contiene demasiados niveles de datos.',
    );
  }
  if (value == null) return const ['null'];
  if (value is bool) return ['bool', value];
  if (value is String) return ['string', value];
  if (value is num) {
    if (!value.isFinite || value.abs() > 9007199254740992) {
      throw const FormatException('La muestra contiene un número no admitido.');
    }
    final bytes = ByteData(8)..setFloat64(0, value == 0 ? 0 : value.toDouble());
    final hex = bytes.buffer
        .asUint8List()
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return ['number', hex];
  }
  if (value is List) {
    return ['list', value.map((item) => _typedNode(item, depth + 1)).toList()];
  }
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return [
      'map',
      [
        for (final key in keys) [key, _typedNode(value[key], depth + 1)],
      ],
    ];
  }
  throw const FormatException('La muestra contiene un valor no admitido.');
}

/// Un bloque siempre incluye sus propios contextos: se puede repetir de forma
/// independiente tras perder la señal, sin depender del bloque anterior.
class BrixSyncBatch {
  static const maxRecords = 50;
  static const maxBytes = 512 * 1024;

  final List<BrixSyncItem> items;
  final Map<String, dynamic> request;

  BrixSyncBatch._(this.items, this.request);

  factory BrixSyncBatch(List<BrixSyncItem> items) {
    if (items.isEmpty || items.length > maxRecords) {
      throw ArgumentError(
        'El bloque debe contener entre 1 y $maxRecords muestras.',
      );
    }
    final plantillaId = items.first.registro.plantillaId;
    final userId = items.first.registro.userId;
    final templateKey = items.first.registro.templateKey;
    final contexts = <Map<String, dynamic>>[];
    final contextIds = <String, int>{};
    final records = <Map<String, dynamic>>[];
    final clientIds = <String>{};

    for (final item in items) {
      final registro = item.registro;
      final clientId = registro.clientRecordId.toLowerCase();
      if (!clientIds.add(clientId)) {
        throw ArgumentError(
          'Dos muestras tienen el mismo identificador estable.',
        );
      }
      if (registro.plantillaId != plantillaId ||
          registro.userId != userId ||
          normalizeBrixTemplateKey(registro.templateKey) !=
              'cartilla_brix_moscatel') {
        throw ArgumentError('El bloque mezcla usuarios o cartillas.');
      }
      final header = Map<String, dynamic>.from(item.payload['header'] as Map);
      final body = Map<String, dynamic>.from(item.payload['body'] as Map);
      final sampleHeader = <String, dynamic>{
        if (header.containsKey('fechaEjecucion'))
          'fechaEjecucion': header.remove('fechaEjecucion'),
      };
      final sampleBody = <String, dynamic>{
        if (body.containsKey('brixSsc')) 'brixSsc': body.remove('brixSsc'),
      };
      final context = <String, dynamic>{'header': header, 'body': body};
      final contextKey = jsonEncode(_typedNode(context));
      final contextId = contextIds.putIfAbsent(contextKey, () {
        contexts.add(context);
        return contexts.length - 1;
      });
      records.add({
        'clientRecordId': clientId,
        'revision': item.revision,
        'context': contextId,
        'payloadVersion': 1,
        'header': sampleHeader,
        'body': sampleBody,
        // Si ya están en el contexto, la API los deriva del header. El fallback
        // conserva compatibilidad con muestras antiguas que solo tienen columnas.
        if (!header.containsKey('campaniaId') && registro.campaniaId != null)
          'campaniaId': registro.campaniaId,
        if (!header.containsKey('loteId') && registro.loteId != null)
          'loteId': registro.loteId,
        if (!header.containsKey('lat') && registro.lat != null)
          'lat': registro.lat,
        if (!header.containsKey('lon') && registro.lon != null)
          'lon': registro.lon,
      });
    }
    return BrixSyncBatch._(List.unmodifiable(items), {
      'protocolVersion': 1,
      'plantillaId': plantillaId,
      'key': templateKey,
      'plantillaVersion': 1,
      'contexts': contexts,
      'records': records,
    });
  }

  late final int byteLength = utf8.encode(jsonEncode(request)).length;
}

class BrixSyncAcknowledgement {
  final String clientRecordId;
  final String revision;
  final String status;
  final int? serverRegistroId;
  final String? error;

  const BrixSyncAcknowledgement({
    required this.clientRecordId,
    required this.revision,
    required this.status,
    this.serverRegistroId,
    this.error,
  });

  factory BrixSyncAcknowledgement.fromJson(Map<String, dynamic> value) {
    final id = value['serverRegistroId'];
    return BrixSyncAcknowledgement(
      clientRecordId: value['clientRecordId']?.toString() ?? '',
      revision: value['revision']?.toString() ?? '',
      status: value['status']?.toString() ?? '',
      serverRegistroId: id is num ? id.toInt() : int.tryParse('$id'),
      error: value['error']?.toString(),
    );
  }
}
