import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

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
        filename: 'foto_$slot.jpg',
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