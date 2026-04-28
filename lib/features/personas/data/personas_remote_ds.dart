import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';

class PersonasRemoteDS {
  final Dio dio;

  PersonasRemoteDS(this.dio);

  Future<List<Map<String, dynamic>>> fetchPersonas({
    String? dni,
    bool? estado,
  }) async {
    final response = await dio.get(
      ApiEndpoints.personas,
      queryParameters: {
        if (dni != null && dni.trim().isNotEmpty) 'dni': dni.trim(),
        if (estado != null) 'estado': estado,
      },
    );

    final data = (response.data as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    return data;
  }

  Future<List<Map<String, dynamic>>> fetchPersonaTipos() async {
    final response = await dio.get(ApiEndpoints.personaTipos);
    final data = (response.data as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    return data;
  }

  Future<Map<String, dynamic>> consultarDni(String dni) async {
    final response = await dio.post(
      ApiEndpoints.personasConsultarDni,
      data: {'dni': dni},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> createPersona(
    Map<String, dynamic> payload,
  ) async {
    final response = await dio.post(ApiEndpoints.personas, data: payload);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updatePersona(
    int personaId,
    Map<String, dynamic> payload,
  ) async {
    final response = await dio.put(
      ApiEndpoints.personaDetail(personaId),
      data: payload,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> deletePersona(int personaId) async {
    await dio.delete(ApiEndpoints.personaDetail(personaId));
  }
}
