import '../../../core/network/dio_client.dart';

class MasterRemoteDs {
  final DioClient _client;
  MasterRemoteDs(this._client);

  Future<Map<String, dynamic>> fetchBootstrap() async {
    // ✅ usa la instancia Dio real
    final r = await _client.dio.get('/api/bootstrap');

    if (r.data is Map<String, dynamic>) return r.data as Map<String, dynamic>;
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<List<Map<String, dynamic>>> fetchPackingQualityCatalog() async {
    final r = await _client.dio.get('/api/packing-calidad/catalogos/');
    final raw = (r.data as Map?)?['items'];
    return (raw is List ? raw : const [])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }

  Future<List<Map<String, dynamic>>> savePackingQualityCatalog(
    List<Map<String, dynamic>> items,
  ) async {
    final r = await _client.dio.post(
      '/api/packing-calidad/catalogos/',
      data: {'items': items},
    );
    final raw = (r.data as Map?)?['items'];
    return (raw is List ? raw : const [])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }
}
