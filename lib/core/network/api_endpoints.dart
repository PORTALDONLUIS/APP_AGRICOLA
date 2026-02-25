class ApiEndpoints {
  static const login = '/api/auth/login/';
  static const registrosUpsert = '/api/registros/upsert/';
  static const registrosSync = '/api/registros/sync/';
  static String registrosFoto(int serverRegistroId) => '/api/registros/$serverRegistroId/fotos/';
}