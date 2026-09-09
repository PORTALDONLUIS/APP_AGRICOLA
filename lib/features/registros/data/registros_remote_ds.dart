import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;

import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class RegistrosRemoteDS {
  final DioClient _client;
  RegistrosRemoteDS(this._client);

  Future<int> upsertRegistro(Map<String, dynamic> payload) async {
    final res = await _client.dio.post(ApiEndpoints.registrosSync, data: payload);

    debugPrint("OK ${res.statusCode} ${res.data}");

    final data = res.data;
    if (data is! Map) {
      throw Exception('Respuesta inválida del servidor: $data');
    }

    final raw = data['serverRegistroId'];

    if (raw == null) {
      throw Exception('Respuesta sin serverRegistroId: $data');
    }

    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.parse(raw);

    throw Exception('serverRegistroId inválido: $raw (${raw.runtimeType})');
  }

  Future<void> deleteRegistroByClientRecordId(String clientRecordId) async {
    await _client.dio.delete(
      ApiEndpoints.registrosByClientRecordId(clientRecordId),
    );
  }

  /// Descarga la copia de nube de BRIX MOSCATEL perteneciente al usuario
  /// autenticado. El backend aplica además esa misma restricción.
  Future<RegistrosDownloadResponse> downloadBrixMoscatel({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if ((startDate == null) != (endDate == null)) {
      throw ArgumentError('startDate y endDate deben enviarse juntos');
    }
    String dateOnly(DateTime value) =>
        '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

    final res = await _client.dio.get(
      ApiEndpoints.registrosBrixMoscatelDownload,
      queryParameters: startDate == null
          ? null
          : {'startDate': dateOnly(startDate), 'endDate': dateOnly(endDate!)},
    );
    final data = res.data;
    if (data is! Map) {
      throw Exception('Respuesta inválida del servidor: $data');
    }
    final rawRecords = data['records'];
    final rawDeleted = data['deletedClientRecordIds'];
    if (rawRecords is! List || rawDeleted is! List) {
      throw Exception('Respuesta de descarga incompleta: $data');
    }
    return RegistrosDownloadResponse(
      records: rawRecords
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false),
      deletedClientRecordIds: rawDeleted
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
    );
  }

  /// Sube una foto al registro ya sincronizado.
  Future<String> uploadFoto({
    required int serverRegistroId,
    required int slot,
    required File file,
  }) async {
    if (!await file.exists()) {
      throw Exception('Archivo no existe: ${file.path}');
    }

    final formData = FormData.fromMap({
      'slot': slot,
      'file': await MultipartFile.fromFile(
        file.path,
        // Nombre real del archivo local (único); el servidor guarda con su propio nombre.
        filename: p.basename(file.path),
      ),
    });

    final res = await _client.dio.post(
      ApiEndpoints.registrosFoto(serverRegistroId),
      data: formData,
    );

    final data = res.data;
    if (data is! Map) throw Exception('Respuesta inválida: $data');

    final serverUrl = data['serverUrl'] as String?;
    if (serverUrl == null || serverUrl.isEmpty) {
      throw Exception('Respuesta sin serverUrl: $data');
    }

    return serverUrl;
  }
}

class RegistrosDownloadResponse {
  final List<Map<String, dynamic>> records;
  final List<String> deletedClientRecordIds;

  const RegistrosDownloadResponse({
    required this.records,
    required this.deletedClientRecordIds,
  });
}
