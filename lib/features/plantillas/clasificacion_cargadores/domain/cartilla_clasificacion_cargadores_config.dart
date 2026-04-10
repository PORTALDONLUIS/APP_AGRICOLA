import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaClasificacionCargadoresConfig implements CartillaFormConfig {
  // ========= Identidad =========
  static const String _templateKey = 'cartilla_clasificacion_cargadores';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  // ========= Keys =========
  // ✅ HEADER
  static const String kLoteId = 'loteId';
  static const String kCampaniaId = 'campaniaId';

  // ✅ BODY (datos generales)
  static const String kEvaluacion = 'evaluacion';
  static const String kVariedad = 'variedad';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';

  // ✅ BODY (PRIMER ALAMBRE)
  static const String kPDebiles = 'p_debiles_456';
  static const String kPNormales = 'p_normales_789';
  static const String kPVigoroso = 'p_vigoroso_10111213';

  // ✅ BODY (SEGUNDO ALAMBRE)
  static const String kSDebiles = 's_debiles_456';
  static const String kSNormales = 's_normales_789';
  static const String kSVigoroso = 's_vigoroso_10111213';

  // ✅ BODY (TERCER ALAMBRE)
  static const String kTDebiles = 't_debiles_456';
  static const String kTNormales = 't_normales_789';
  static const String kTVigoroso = 't_vigoroso_10111213';

  // ✅ BODY (calculado)
  static const String kTotal = 'total';

  // ✅ BODY (final)
  static const String kObservaciones = 'observaciones';

  // ========= Header keys =========
  static const Set<String> _headerKeys = {
    kLoteId,
    kCampaniaId,
  };

  @override
  Set<String> get headerKeys => _headerKeys;

  // ========= Opciones estáticas =========
  static const List<String> _evaluacionOptions = [
    'PRIMERA_EVALUACION',
    'SEGUNDA_EVALUACION',
  ];

  static const List<String> _campaniaOptions = [
    'CAMP2026',
  ];

  // Interface obliga esto (no aplica)
  static const List<String> _etapas = [];
  @override
  List<String> get etapaFenologicaOptions => _etapas;

  // ========= (+1) replicables =========
  // Manual: (+1) replica Lote, Evaluación, Campaña, Variedad. :contentReference[oaicite:1]{index=1}
  static const Set<String> _plusOneHeaderKeys = {
    kLoteId,
    kCampaniaId,
  };

  static const Set<String> _plusOneBodyKeys = {
    kEvaluacion,
    kVariedad,
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
          key: kEvaluacion,
          label: '2. Evaluación',
          type: CartillaFieldType.dropdown,
          staticOptions: _evaluacionOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCampaniaId,
          label: '3. Campaña',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kVariedad,
          label: '4. Variedad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.variedades,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kHilera,
          label: '5. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),
        CartillaFieldConfig(
          key: kPlanta,
          label: '6. Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'primer_alambre',
      title: 'PRIMER ALAMBRE',
      fields: [
        CartillaFieldConfig(
          key: kPDebiles,
          label: '7. P_debiles:4,5,6mm',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kPNormales,
          label: '8. P_normales:7,8,9mm',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kPVigoroso,
          label: '9. P_vigoroso:10,11,12,13mm',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'segundo_alambre',
      title: 'SEGUNDO ALAMBRE',
      fields: [
        CartillaFieldConfig(
          key: kSDebiles,
          label: '10. S_debiles:4,5,6mm',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kSNormales,
          label: '11. S_normales:7,8,9mm',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kSVigoroso,
          label: '12. S_vigoroso:10,11,12,13mm',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'tercer_alambre',
      title: 'TERCER ALAMBRE',
      fields: [
        CartillaFieldConfig(
          key: kTDebiles,
          label: '13. T_debiles:4,5,6mm',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kTNormales,
          label: '14. T_normales:7,8,9mm',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kTVigoroso,
          label: '15. T_vigoroso:10,11,12,13mm',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'total_obs',
      title: 'TOTAL Y OBSERVACIONES',
      fields: [
        CartillaFieldConfig(
          key: kTotal,
          label: '16. Total',
          type: CartillaFieldType.decimalReadOnly,
        ),
        CartillaFieldConfig(
          key: kObservaciones,
          label: '17. Observaciones',
          type: CartillaFieldType.longText,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
