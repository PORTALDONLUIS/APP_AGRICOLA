import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaConteoBayasConfig implements CartillaFormConfig {
  static const String templateKeyStatic = 'cartilla_conteo_bayas';
  static const int payloadVersionStatic = 2;

  static const String kLoteId = 'loteId';
  static const String kFecha = 'fecha';
  static const String kFundo = 'fundo';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';
  static const int maxRacimos = 120;
  static const String kCantidadRacimos = 'cantidadRacimos';
  static const String kPromNumeroBayas = 'promNumeroBayas';

  @override
  String get templateKey => templateKeyStatic;

  @override
  int get payloadVersion => payloadVersionStatic;

  @override
  Set<String> get headerKeys => const {kLoteId};

  @override
  List<String> get etapaFenologicaOptions => const [];

  @override
  Set<String> get plusOneReplicableHeaderKeys => const {kLoteId};

  @override
  Set<String> get plusOneReplicableBodyKeys => const {
    kFecha,
    kFundo,
    kHilera,
    kPlanta,
  };

  static const _tipoRacimoOptions = ['AL', 'SA', 'AT', 'P'];

  static String tipoRacimoKey(int racimo) => 'tipoRacimo$racimo';
  static String numeroBayasKey(int racimo) => 'numeroBayas$racimo';

  static List<CartillaFieldConfig> racimoFields(int racimo) => [
    CartillaFieldConfig(
      key: tipoRacimoKey(racimo),
      label: 'Tipo Rac.',
      type: CartillaFieldType.dropdown,
      staticOptions: _tipoRacimoOptions,
      rules: const CartillaFieldRules(),
    ),
    CartillaFieldConfig(
      key: numeroBayasKey(racimo),
      label: 'N.º Bayas',
      type: CartillaFieldType.stepperInt,
      rules: const CartillaFieldRules(minValue: 0),
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => [
    const CartillaSectionConfig(
      key: 'datos_generales',
      title: 'DATOS GENERALES',
      fields: [
        CartillaFieldConfig(
          key: kFecha,
          label: '1. Fecha',
          type: CartillaFieldType.date,
          rules: CartillaFieldRules(
            required: true,
            copyOnPlus1: true,
            readOnly: true,
          ),
        ),
        CartillaFieldConfig(
          key: kLoteId,
          label: '2. Lote',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kFundo,
          label: '3. Fundo',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(
            required: true,
            copyOnPlus1: true,
            readOnly: true,
          ),
        ),
        CartillaFieldConfig(
          key: kHilera,
          label: '4. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            required: true,
            maxDigits: 2,
            copyOnPlus1: true,
          ),
        ),
        CartillaFieldConfig(
          key: kPlanta,
          label: '5. Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            required: true,
            maxDigits: 3,
            copyOnPlus1: true,
          ),
        ),
      ],
    ),
    const CartillaSectionConfig(
      key: 'promedios',
      title: 'PROMEDIOS',
      fields: [
        CartillaFieldConfig(
          key: kPromNumeroBayas,
          label: 'Prom. N.º Bayas',
          type: CartillaFieldType.decimalReadOnly,
        ),
      ],
    ),
  ];
}
