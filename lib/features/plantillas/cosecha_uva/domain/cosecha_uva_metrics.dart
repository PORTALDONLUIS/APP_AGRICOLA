// Fórmulas del manual Cosecha Uva Calidad. No contar bayas como racimos.
Map<String, dynamic> cosechaUvaMetrics(Map<String, dynamic> body) {
  int n(String key) => int.tryParse('${body[key] ?? 0}') ?? 0;
  int sum(List<String> keys) => keys.fold(0, (total, key) => total + n(key));
  final total = sum(['conformados', 'pampanos', 'semipaludos', 'paludos']);
  final defects = sum([
    'chanchitoBlanco',
    'paloNegro',
    'presenciaPolvo',
    'presenciaAranaTela',
    'bayasAcuosas',
    'golpeSol',
    'raquisLignificado',
    'pediceloNecrosado',
    'russet',
    'descalibre',
    'colapso',
  ]);
  final healthy = (total - defects).clamp(0, total);
  final vegetation = body['restosVegetales'];
  return {
    'totalRacimos': total,
    'totalRacimosColor': sum(['verde', 'cremoso', 'ambar']),
    'racimosConDefectos': defects,
    'racimosSinDefectos': healthy,
    'porcentajeConDefectos': total == 0 ? 0.0 : defects / total * 100,
    'porcentajeSinDefectos': total == 0 ? 0.0 : healthy / total * 100,
    'totalBayasDefectuosas': sum([
      'pudricion',
      'partiduras',
      'mediaLuna',
      'oidium',
      'danoMecanico',
    ]),
    'restosVegetalesSiNo': vegetation is List && vegetation.isNotEmpty
        ? 'SI'
        : 'NO',
    'restosVegetalesPresente': vegetation is List && vegetation.isNotEmpty
        ? 1
        : 0,
  };
}
