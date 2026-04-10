import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaConteoCargadoresConfig implements CartillaFormConfig {
  // ========= Identidad =========
  static const String _templateKey = 'cartilla_conteo_cargadores';
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

  // ✅ BODY
  static const String kVariedad = 'variedad';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';
  static const String kCorresponde = 'corresponde';
  static const String kNumeroCargadores = 'numeroCargadores';
  static const String kObservaciones = 'observaciones';

  // ========= Header keys =========
  static const Set<String> _headerKeys = {
    kLoteId,
    kCampaniaId,
  };

  @override
  Set<String> get headerKeys => _headerKeys;

  // ========= Opciones estáticas =========
  static const List<String> _correspondeOptions = [
    'REPORDA',
    'PODA',
    'NINGUNO',
  ];

  // Interface obliga esto (no aplica)
  static const List<String> _etapas = [];
  @override
  List<String> get etapaFenologicaOptions => _etapas;

  // ========= (+1) replicables =========
  // Manual: (+1) replica Lote, Variedad, Corresponde, Campaña. :contentReference[oaicite:1]{index=1}
  static const Set<String> _plusOneHeaderKeys = {
    kLoteId,
    kCampaniaId,
  };

  static const Set<String> _plusOneBodyKeys = {
    kVariedad,
    kCorresponde,
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
          key: kVariedad,
          label: '2. Variedad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.variedades,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kHilera,
          label: '3. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),
        CartillaFieldConfig(
          key: kPlanta,
          label: '4. Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
        CartillaFieldConfig(
          key: kCorresponde,
          label: '5. Corresponde',
          type: CartillaFieldType.dropdown,
          staticOptions: _correspondeOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCampaniaId,
          label: '6. Campaña',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'conteo',
      title: 'CONTEO',
      fields: [
        CartillaFieldConfig(
          key: kNumeroCargadores,
          label: '7. Número de Cargadores',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: false, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kObservaciones,
          label: '8. Observaciones',
          type: CartillaFieldType.longText,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
