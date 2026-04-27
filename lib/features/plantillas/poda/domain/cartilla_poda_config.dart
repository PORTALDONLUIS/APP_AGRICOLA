import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaPodaConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_poda';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  static const String kLoteId = 'loteId';
  static const String kCampaniaId = 'campaniaId';
  static const String kVariedad = 'variedad';
  static const String kPodador = 'podador';
  static const String kSupervisor = 'supervisor';
  static const String kPautaCargadores = 'pautaCargadores';
  static const String kPautaYemas = 'pautaYemas';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';
  static const String kPitones = 'pitones';
  static const String kYemasPiton = 'yemasPiton';
  static const String kCargDer = 'cargDer';
  static const String kCargIzq = 'cargIzq';
  static const String kTotalCargadores = 'totalCargadores';
  static const String kDebil = 'debil';
  static const String kNormal = 'normal';
  static const String kVigoroso = 'vigoroso';
  static const String kTotalConteo = 'totalConteo';
  static const String kLimpieza = 'limpieza';
  static const String kObservacion = 'observacion';
  static const String kFoto1 = 'foto1';

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const Set<String> _headerKeys = {
    kLoteId,
    kCampaniaId,
  };

  @override
  Set<String> get headerKeys => _headerKeys;

  @override
  List<String> get etapaFenologicaOptions => const [];

  static const Set<String> _plusOneHeaderKeys = {
    kLoteId,
    kCampaniaId,
  };

  static const Set<String> _plusOneBodyKeys = {
    kVariedad,
    kPodador,
    kSupervisor,
    kPautaCargadores,
    kPautaYemas,
    kPitones,
    kYemasPiton,
  };

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static final List<CartillaSectionConfig> _sections = [
    const CartillaSectionConfig(
      key: 'datos_generales',
      title: 'DATOS GENERALES',
      fields: [
        CartillaFieldConfig(
          key: kLoteId,
          label: 'Lote',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kVariedad,
          label: 'Variedad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.variedades,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kPodador,
          label: 'Podador',
          type: CartillaFieldType.shortText,
        ),
        CartillaFieldConfig(
          key: kSupervisor,
          label: 'Supervisor',
          type: CartillaFieldType.shortText,
        ),
      ],
    ),
    const CartillaSectionConfig(
      key: 'pauta',
      title: 'PAUTA',
      fields: [
        CartillaFieldConfig(
          key: kPautaCargadores,
          label: 'Pauta cargadores',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kPautaYemas,
          label: 'Pauta yemas',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kHilera,
          label: 'Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
        CartillaFieldConfig(
          key: kPlanta,
          label: 'Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
      ],
    ),
    const CartillaSectionConfig(
      key: 'pitones',
      title: 'PITONES',
      fields: [
        CartillaFieldConfig(
          key: kPitones,
          label: 'N° Pitones',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kYemasPiton,
          label: 'Yemas / Piton',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
      ],
    ),
    const CartillaSectionConfig(
      key: 'cargadores',
      title: 'CARGADORES',
      fields: [
        CartillaFieldConfig(
          key: kCargDer,
          label: 'Cargadores DER',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kCargIzq,
          label: 'Cargadores IZQ',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kTotalCargadores,
          label: 'Total cargadores',
          type: CartillaFieldType.intReadOnly,
        ),
        CartillaFieldConfig(
          key: kDebil,
          label: 'Debil',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kNormal,
          label: 'Normal',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kVigoroso,
          label: 'Vigoroso',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kTotalConteo,
          label: 'Total',
          type: CartillaFieldType.intReadOnly,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'yemas',
      title: 'YEMAS',
      fields: List.generate(
        50,
        (index) => CartillaFieldConfig(
          key: 'c${index + 1}',
          label: 'C${index + 1}',
          type: CartillaFieldType.intNumber,
        ),
      ),
    ),
    const CartillaSectionConfig(
      key: 'calificacion',
      title: 'CALIFICACION',
      fields: [
        CartillaFieldConfig(
          key: kLimpieza,
          label: 'Limpieza',
          type: CartillaFieldType.dropdown,
          staticOptions: ['Buena', 'Regular', 'Mala'],
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kObservacion,
          label: 'Observacion',
          type: CartillaFieldType.longText,
        ),
        CartillaFieldConfig(
          key: kFoto1,
          label: 'Foto',
          type: CartillaFieldType.photo,
          photoIndex: 1,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
