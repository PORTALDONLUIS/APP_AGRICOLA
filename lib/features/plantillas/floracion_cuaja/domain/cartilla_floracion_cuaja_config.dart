

import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaFloracionCuajaConfig implements CartillaFormConfig {
  // ========= Identidad =========
  static const String _templateKey = 'cartilla_floracion_cuaja';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  // ========= Keys =========
  // HEADER
  static const String kLoteId = 'loteId';
  static const String kCampaniaId = 'campaniaId';

  // BODY – generales
  static const String kCantidadMuestras = 'cantidadMuestras';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';

  // BODY – conteos
  static const String kCaliptra = 'caliptraHinchada';
  static const String kP10 = 'p10';
  static const String kP20 = 'p20';
  static const String kP30 = 'p30';
  static const String kP40 = 'p40';
  static const String kP50 = 'p50';
  static const String kP60 = 'p60';
  static const String kP70 = 'p70';
  static const String kP80 = 'p80';
  static const String kP90 = 'p90';
  static const String kP100 = 'p100';
  static const String kCuaja = 'cuaja';

  // BODY – calculados
  static const String kCaliptraPct = 'caliptraPct';
  static const String kFloracionPct = 'floracionPct';
  static const String kCuajaPct = 'cuajaPct';
  static const String kSumFloracion = 'sumFloracion';
  static const String kTotalRacimos = 'totalRacimos';

  static const String kObservaciones = 'observaciones';

  // ========= Header keys =========
  static const Set<String> _headerKeys = {
    kLoteId,
    kCampaniaId,
  };

  @override
  Set<String> get headerKeys => _headerKeys;

  // ========= Etapas (no aplica) =========
  static const List<String> _etapas = [];
  @override
  List<String> get etapaFenologicaOptions => _etapas;

  // ========= (+1) replicables =========
  static const Set<String> _plusOneHeaderKeys = {
    kLoteId,
    kCampaniaId,
  };

  static const Set<String> _plusOneBodyKeys = {
    kCantidadMuestras,
    kCaliptra,
    kP10,
    kP20,
    kP30,
    kP40,
    kP50,
    kP60,
    kP70,
    kP80,
    kP90,
    kP100,
    kCuaja,
  };

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  // ========= Sections =========
  static const List<CartillaSectionConfig> _sections = [
    CartillaSectionConfig(
      key: 'datos_generales',
      title: 'DATOS GENERALES',
      fields: [
        CartillaFieldConfig(
          key: kLoteId,
          label: '1. Lote',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCampaniaId,
          label: '2. Campaña',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCantidadMuestras,
          label: '3. Cantidad de muestras',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kHilera,
          label: '4. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),
        CartillaFieldConfig(
          key: kPlanta,
          label: '5. Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'conteos',
      title: 'FLORACIÓN Y CUAJA',
      fields: [
        CartillaFieldConfig(key: kCaliptra, label: '6. Caliptra Hinchada N° Rac/planta', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kP10, label: '7. 10%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kP20, label: '8. 20%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kP30, label: '9. 30%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kP40, label: '10. 40%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kP50, label: '11. 50%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kP60, label: '12. 60%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kP70, label: '13. 70%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kP80, label: '14. 80%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kP90, label: '15. 90%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kP100, label: '16. 100%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kCuaja, label: '17. Cuaja', type: CartillaFieldType.stepperInt),
      ],
    ),

    CartillaSectionConfig(
      key: 'resultados',
      title: 'RESULTADOS',
      fields: [
        CartillaFieldConfig(key: kCaliptraPct, label: '18. Caliptra hinchada % / planta', type: CartillaFieldType.decimalReadOnly),
        CartillaFieldConfig(key: kFloracionPct, label: '19. % Floración / Planta', type: CartillaFieldType.decimalReadOnly),
        CartillaFieldConfig(key: kCuajaPct, label: '20. % Cuaja', type: CartillaFieldType.decimalReadOnly),
        CartillaFieldConfig(key: kSumFloracion, label: '21. Sum. Floración / Planta', type: CartillaFieldType.decimalReadOnly),
        CartillaFieldConfig(key: kTotalRacimos, label: '22. Total Racimos / Planta', type: CartillaFieldType.decimalReadOnly),
        CartillaFieldConfig(key: kObservaciones, label: '23. Observaciones', type: CartillaFieldType.longText),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
