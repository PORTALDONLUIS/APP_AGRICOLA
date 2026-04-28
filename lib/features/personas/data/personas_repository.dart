import '../domain/persona.dart';
import '../domain/persona_tipo.dart';
import 'personas_remote_ds.dart';

class DniLookupResult {
  final bool found;
  final String? nombreCompleto;
  final String? message;

  const DniLookupResult({
    required this.found,
    this.nombreCompleto,
    this.message,
  });
}

class PersonasRepository {
  final PersonasRemoteDS remote;

  PersonasRepository({required this.remote});

  Future<List<Persona>> fetchPersonas({String? dni}) async {
    final items = await remote.fetchPersonas(dni: dni);
    return items.map(Persona.fromMap).toList();
  }

  Future<List<PersonaTipo>> fetchTipos() async {
    final items = await remote.fetchPersonaTipos();
    return items.map(PersonaTipo.fromMap).toList();
  }

  Future<DniLookupResult> consultarDni(String dni) async {
    final data = await remote.consultarDni(dni);
    return DniLookupResult(
      found: data['success'] == true,
      nombreCompleto: data['nombre_completo']?.toString(),
      message: data['message']?.toString(),
    );
  }

  Future<Persona> createPersona({
    required String dni,
    required String nombreCompleto,
    required int tipoId,
    required bool estado,
  }) async {
    final data = await remote.createPersona({
      'dni': dni,
      'nombre_completo': nombreCompleto,
      'tipo_id': tipoId,
      'estado': estado,
    });
    return Persona.fromMap(data);
  }

  Future<Persona> updatePersona({
    required int personaId,
    required String dni,
    required String nombreCompleto,
    required int tipoId,
    required bool estado,
  }) async {
    final data = await remote.updatePersona(personaId, {
      'dni': dni,
      'nombre_completo': nombreCompleto,
      'tipo_id': tipoId,
      'estado': estado,
    });
    return Persona.fromMap(data);
  }

  Future<void> deletePersona(int personaId) {
    return remote.deletePersona(personaId);
  }
}
