class PersonaTipo {
  final int id;
  final String codigo;
  final String descripcion;

  const PersonaTipo({
    required this.id,
    required this.codigo,
    required this.descripcion,
  });

  factory PersonaTipo.fromMap(Map<String, dynamic> map) {
    return PersonaTipo(
      id: (map['id'] as num).toInt(),
      codigo: (map['codigo'] ?? '').toString(),
      descripcion: (map['descripcion'] ?? '').toString(),
    );
  }
}
