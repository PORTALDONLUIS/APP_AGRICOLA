import '../../../core/network/dio_client.dart';

class MasterRemoteDs {
  final DioClient _client;
  MasterRemoteDs(this._client);

  List<Map<String, dynamic>> _catalogItems(dynamic response) {
    final data = response as Map?;
    if (data?['catalogReady'] != true) {
      throw StateError('El catálogo Packing todavía no está disponible.');
    }
    final raw = data?['items'];
    return (raw is List ? raw : const [])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }

  Future<Map<String, dynamic>> fetchBootstrap() async {
    // ✅ usa la instancia Dio real
    final r = await _client.dio.get('/api/bootstrap');

    if (r.data is Map<String, dynamic>) return r.data as Map<String, dynamic>;
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<List<Map<String, dynamic>>> fetchPackingQualityCatalog() async {
    final r = await _client.dio.get('/api/packing-calidad/catalogos/');
    return _catalogItems(r.data);
  }

  Future<List<Map<String, dynamic>>> savePackingQualityCatalog(
    List<Map<String, dynamic>> items,
  ) async {
    final r = await _client.dio.post(
      '/api/packing-calidad/catalogos/',
      data: {'items': items},
    );
    return _catalogItems(r.data);
  }

  Future<List<Map<String, dynamic>>> updatePackingQualityCatalogOption({
    required String tipo,
    required String valorAnterior,
    required String valor,
  }) async {
    final r = await _client.dio.patch(
      '/api/packing-calidad/catalogos/opcion/',
      data: {'tipo': tipo, 'valorAnterior': valorAnterior, 'valor': valor},
    );
    return _catalogItems(r.data);
  }

  Future<List<Map<String, dynamic>>> deletePackingQualityCatalogOption({
    required String tipo,
    required String valorAnterior,
  }) async {
    final r = await _client.dio.delete(
      '/api/packing-calidad/catalogos/opcion/',
      data: {'tipo': tipo, 'valorAnterior': valorAnterior},
    );
    return _catalogItems(r.data);
  }
}
