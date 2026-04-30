enum CartillaFieldType {
  dropdown,
  multiSelectChips,
  shortText,
  intNumber,

  /// Decimal editable (caja de texto; guarda `double` en payload).
  decimalNumber,
  stepperInt,
  longText,
  photo,

  // ✅ NUEVOS: campos calculados / solo lectura
  intReadOnly,
  decimalReadOnly,
}

/// ✅ Fuente genérica de catálogos (sin hardcodear cartillas)
enum CartillaCatalogSource {
  campanias,
  lotes,
  variedades,
  personas,
  personasPodador,
  personasSupervisor,

  /// Orillas del lote (BRIX: solo cuando fenología = ORILLA).
  orillasPorLote,
}

class CartillaFieldRules {
  final bool required;
  final int? maxDigits;
  final int? minValue;
  final int? maxValue;
  final bool copyOnPlus1;
  final bool resetOnPlus1;

  /// Si es true, el usuario no puede editar el valor (p. ej. variedad fija en un manual).
  final bool readOnly;

  const CartillaFieldRules({
    this.required = false,
    this.maxDigits,
    this.minValue,
    this.maxValue,
    this.copyOnPlus1 = false,
    this.resetOnPlus1 = false,
    this.readOnly = false,
  });
}

class CartillaFieldConfig {
  final String key;
  final String label;
  final CartillaFieldType type;

  /// ✅ Dropdown estático
  final List<String>? staticOptions;

  /// ✅ Dropdown dinámico (catálogos sincronizados)
  final CartillaCatalogSource? catalogSource;

  /// ✅ Dependencia (ej: lote depende de campaniaId)
  final String? dependsOnHeaderKey;

  final int? photoIndex;
  final CartillaFieldRules rules;

  const CartillaFieldConfig({
    required this.key,
    required this.label,
    required this.type,
    this.staticOptions,
    this.catalogSource,
    this.dependsOnHeaderKey,
    this.photoIndex,
    this.rules = const CartillaFieldRules(),
  });
}

class CartillaSectionConfig {
  final String key;
  final String title;
  final List<CartillaFieldConfig> fields;

  /// Si la sección del formulario inicia expandida (`DonLuisSectionCard`).
  final bool initiallyExpanded;

  const CartillaSectionConfig({
    required this.key,
    required this.title,
    required this.fields,
    this.initiallyExpanded = true,
  });
}
