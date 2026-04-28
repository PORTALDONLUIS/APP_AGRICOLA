class PersonaTipo {
  final int id;
  final String codigo;
  final String descripcion;
  final bool estado;

  const PersonaTipo({
    required this.id,
    required this.codigo,
    required this.descripcion,
    required this.estado,
  });

  factory PersonaTipo.fromMap(Map<String, dynamic> map) {
    final estadoRaw = map['estado'];
    return PersonaTipo(
      id: (map['id'] as num).toInt(),
      codigo: (map['codigo'] ?? '').toString(),
      descripcion: (map['descripcion'] ?? '').toString(),
      estado: estadoRaw == null
          ? true
          : estadoRaw == true ||
                estadoRaw == 1 ||
                (estadoRaw is String &&
                    (estadoRaw.toLowerCase() == 'true' || estadoRaw == '1')),
    );
  }
}
