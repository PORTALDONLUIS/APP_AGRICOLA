import 'dart:convert';
import '../../../core/sync/sync_models.dart';

class Registro {
  final int localId;        // PK local
  final int? serverId;      // nullable
  final int plantillaId;
  final String templateKey; // 👈 NUEVO
  final int userId;

  final String? campaniaId;
  final int? loteId;
  final double? lat;
  final double? lon;

  final EstadoRegistro estado;
  final SyncStatus syncStatus;
  final String? syncError;
  final int syncAttempts;

  final String dataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Registro({
    required this.localId,
    required this.serverId,
    required this.plantillaId,
    required this.templateKey,
    required this.userId,
    required this.campaniaId,
    required this.loteId,
    required this.lat,
    required this.lon,
    required this.estado,
    required this.syncStatus,
    required this.syncError,
    required this.syncAttempts,
    required this.dataJson,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  Map<String, dynamic> dataMap() {
    try {
      final d = jsonDecode(dataJson);
      return d is Map<String, dynamic> ? d : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  /// Fecha/hora del registro en UTC (desde header.fechaEjecucion o createdAt).
  /// Usado para filtrar por "día" en zona UTC-5.
  DateTime registrationDateTimeUtc() {
    final payload = normalizedPayload();
    final header = payload['header'] as Map<String, dynamic>? ?? {};
    final fecha = header['fechaEjecucion'];
    if (fecha != null) {
      final raw = fecha is num ? fecha.toInt() : int.tryParse(fecha.toString());
      if (raw != null) {
        final ms = raw < 10000000000 ? raw * 1000 : raw;
        return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
      }
    }
    return createdAt.isUtc ? createdAt : createdAt.toUtc();
  }

  /// payload para backend (lo usará SyncService)
  Map<String, dynamic> toApiPayload() {
    return {
      "serverRegistroId": serverId,
      "plantillaId": plantillaId,
      "templateKey": templateKey,
      "campaniaId": campaniaId,
      "loteId": loteId,
      "lat": lat,
      "lon": lon,
      "estado": estado.name,
      "data": normalizedPayload(),
      "updatedAt": updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> normalizedPayload() {
    final data = dataMap();

    // 1) Detecta estándar
    final isStandard = data['payloadVersion'] != null &&
        data['header'] is Map &&
        data['body'] is Map;

    // 2) Extrae header/body del JSON si existen
    final headerJson = isStandard
        ? Map<String, dynamic>.from(data['header'] as Map)
        : <String, dynamic>{};

    final body = isStandard
        ? Map<String, dynamic>.from(data['body'] as Map)
        : Map<String, dynamic>.from(data); // legacy: todo era "body"

    // 3) Header base desde columnas (tu regla)
    final headerBase = <String, dynamic>{
      'plantillaId': plantillaId,
      'userId': userId,
      'campaniaId': campaniaId,
      'loteId': loteId,
      'lat': lat,
      'lon': lon,
    };

    // 4) Merge NO destructivo: conserva keys extra (variedad, hilera, etc.)
    final header = <String, dynamic>{
      ...headerBase,
      ...headerJson,
    };

    // 5) Legacy rescue: si algunos campos estaban en body, súbelos a header
    const moveToHeaderKeys = [
      'variedad',
      'cantidadMuestras',
      'hilera',
      'planta',
      'corresponde',
      'campania',
    ];

    for (final k in moveToHeaderKeys) {
      if (header[k] == null && body[k] != null) {
        header[k] = body[k];
        body.remove(k);
      }
    }

    // 6) Defaults del body (para no tener body "corto")
    body.putIfAbsent('yemaHinchada', () => 0);
    body.putIfAbsent('botonAlgodonoso', () => 0);
    body.putIfAbsent('puntaVerde', () => 0);
    body.putIfAbsent('hojasExtendidas', () => 0);
    body.putIfAbsent('yemasNecroticas', () => 0);
    body.putIfAbsent('totalYemas', () => 0);
    body.putIfAbsent('observaciones', () => null);

    return {
      'payloadVersion': 1,
      'header': header,
      'body': body,
    };
  }



/*  Map<String, dynamic> normalizedPayload_bk() {
    final data = dataMap();

    if (data.containsKey('payloadVersion')) {
      return data;
    }

    // Legacy → migrado a estándar
    return {
      'payloadVersion': 1,
      'header': {
        'plantillaId': plantillaId,
        'userId': userId,
        'campaniaId': campaniaId,
        'loteId': loteId,
        'lat': lat,
        'lon': lon,
      },
      'body': data,
    };
  }*/

}
