import 'dart:convert';

String? movilidadesGuideKey(dynamic issuer, Map guide) {
  String part(dynamic v) => (v == null ? '' : '$v')
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'\s+'), ' ');
  final series = part(guide['serieGuia']), number = part(guide['nroGuia']);
  return series.isEmpty || number.isEmpty
      ? null
      : jsonEncode([part(issuer), series, number]);
}

int? movilidadesCajas(dynamic value) {
  if (value is bool || value == null) return null;
  if (value is num) {
    return value.isFinite && value >= 0 && value == value.truncateToDouble()
        ? value.toInt()
        : null;
  }
  final text = '$value'.trim();
  return RegExp(r'^[0-9]+$').hasMatch(text) ? int.tryParse(text) : null;
}

const guiaKeys = [
  'sector',
  'loteId',
  'cantidadCajas',
  'variedad',
  'supervisor',
  'serieGuia',
  'nroGuia',
];

List<Map<String, dynamic>> movilidadesGuias(
  Map<String, dynamic> body,
  Map<String, dynamic> header,
) {
  final raw = body['guias'];
  if (raw is List && raw.isNotEmpty) {
    return raw
        .whereType<Map>()
        .map((g) => Map<String, dynamic>.from(g))
        .toList();
  }
  return [
    {
      'guiaId': 'legacy',
      for (final key in guiaKeys)
        key: key == 'loteId' ? header[key] : body[key],
    },
  ];
}

/// Additive v1 extension: keep the first-guide aliases for older readers.
Map<String, dynamic> movilidadesBody(
  Map<String, dynamic> body,
  Map<String, dynamic> header,
) {
  final guias = movilidadesGuias(body, header);
  return {
    ...body,
    'guias': guias,
    'guiasSchemaVersion': 1,
    'cantidadGuias': guias
        .map((g) => movilidadesGuideKey(body['nombreProveedor'], g))
        .whereType<String>()
        .toSet()
        .length,
    'cantidadBloquesGuia': guias.length,
    'totalCajas': guias.fold<int>(
      0,
      (sum, g) => sum + (movilidadesCajas(g['cantidadCajas']) ?? 0),
    ),
    if (guias.isNotEmpty)
      for (final key in guiaKeys.where((k) => k != 'loteId'))
        key: guias.first[key],
  };
}
