class ApiEndpoints {
  static const login = '/api/auth/login/';
  static const registrosUpsert = '/api/registros/upsert/';
  static const registrosSync = '/api/registros/sync/';
  static const personas = '/api/personas/';
  static const personaTipos = '/api/persona-tipos/';
  static const personasConsultarDni = '/api/personas/consultar-dni/';
  static String registrosFoto(int serverRegistroId) =>
      '/api/registros/$serverRegistroId/fotos/';
  static String personaDetail(int personaId) => '/api/personas/$personaId/';
}
