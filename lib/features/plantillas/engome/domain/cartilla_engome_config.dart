import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaEngomeConfig implements CartillaFormConfig {
  // ========= Identidad =========
  static const String _templateKey = 'cartilla_engome';
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

  // ✅ BODY (generales)
  static const String kCorresponde = 'corresponde';
  static const String kCantidadMuestras = 'cantidadMuestras';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';

  // ✅ BODY (conteos)
  static const String kVerde = 'verdeNRacPlanta';
  static const String kEngome = 'engomeNRacPlanta';

  // ✅ BODY (calculado)
  static const String kPintaTotal = 'pintaTotalRacPlanta';

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

  // Campaña: el PDF indica opciones estáticas (iniciar con campaña 2026)
  // Como el motor de Brotación usa catálogo dinámico en campaña, aquí mantenemos catálogo
  // para no romper flujos existentes. Si quieres forzar estáticas, me dices y lo cambiamos.
  static const List<String> _etapas = [];
  @override
  List<String> get etapaFenologicaOptions => _etapas;

  // ========= (+1) replicables =========
  // PDF: Lote, Corresponde, Campaña, Cantidad de muestras replican en +1.
  static const Set<String> _plusOneHeaderKeys = {
    kLoteId,
    kCampaniaId,
  };

  static const Set<String> _plusOneBodyKeys = {
    kCorresponde,
    kCantidadMuestras,
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
          key: kCorresponde,
          label: '2. Corresponde',
          type: CartillaFieldType.dropdown,
          staticOptions: _correspondeOptions,
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
          key: kCantidadMuestras,
          label: '4. Cantidad de muestras',
          type: CartillaFieldType.intNumber,
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
      key: 'conteos',
      title: 'ENGOME',
      fields: [
        CartillaFieldConfig(
          key: kVerde,
          label: '7. Verde n.rac/planta',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: false, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kEngome,
          label: '8. Engome n.rac/planta',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: false, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kPintaTotal,
          label: '9. Pinta total rac/planta',
          type: CartillaFieldType.decimalReadOnly,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
