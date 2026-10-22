import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/network/api_endpoints.dart';

class TicAssignmentsRemoteDS {
  TicAssignmentsRemoteDS(this.dio);
  final Dio dio;

  Future<List<Map<String, dynamic>>> availableAssets({String? category}) async {
    final response = await dio.get(ApiEndpoints.ticAvailableAssets,
        queryParameters: {if (category != null) 'category': category});
    return (response.data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<Map<String, dynamic>> assign({
    required int assetId,
    required String document,
    required String name,
    required String email,
    required String phone,
    required String observations,
    required Uint8List signature,
    Uint8List? evidence,
  }) async {
    final data = FormData.fromMap({
      'asset_id': assetId,
      'worker_document': document,
      'worker_name': name,
      'worker_email': email,
      'worker_phone': phone,
      'observations': observations,
      'signature': MultipartFile.fromBytes(signature, filename: 'firma.png'),
      if (evidence != null)
        'evidence': MultipartFile.fromBytes(evidence, filename: 'evidencia.jpg'),
    });
    final response = await dio.post(ApiEndpoints.ticRegisterAssignment, data: data);
    return Map<String, dynamic>.from(response.data as Map);
  }
}
