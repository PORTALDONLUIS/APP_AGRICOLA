class Persona {
  final int id;
  final String dni;
  final String nombreCompleto;
  final int tipoId;
  final String tipoCodigo;
  final String tipoDescripcion;
  final bool estado;

  const Persona({
    required this.id,
    required this.dni,
    required this.nombreCompleto,
    required this.tipoId,
    required this.tipoCodigo,
    required this.tipoDescripcion,
    required this.estado,
  });

  factory Persona.fromMap(Map<String, dynamic> map) {
    return Persona(
      id: (map['id'] as num).toInt(),
      dni: (map['dni'] ?? '').toString(),
      nombreCompleto: (map['nombre_completo'] ?? '').toString(),
      tipoId: (map['tipo_id'] as num).toInt(),
      tipoCodigo: (map['tipo_codigo'] ?? '').toString(),
      tipoDescripcion: (map['tipo_descripcion'] ?? '').toString(),
      estado: map['estado'] == true,
    );
  }
}
