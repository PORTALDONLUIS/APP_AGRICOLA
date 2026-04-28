import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaPodaConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_poda';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  static const String kSectionDatosGenerales = 'datos_generales';
  static const String kSectionPauta = 'pauta';
  static const String kSectionPitones = 'pitones';
  static const String kSectionCargadores = 'cargadores';
  static const String kSectionYemas = 'yemas';
  static const String kSectionYemaDefectuosas = 'yema_defectuosas';
  static const String kSectionCalificacion = 'calificacion';

  static const String kLoteId = 'loteId';
  static const String kCampaniaId = 'campaniaId';
  static const String kVariedad = 'variedad';
  static const String kPodadorId = 'podadorId';
  static const String kSupervisorId = 'supervisorId';
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

  static const String kTotalYemas = 'totalYemas';

  static const String kCargDebilMin = 'cargDebilMin';
  static const String kCargDebilMax = 'cargDebilMax';
  static const String kCargNormalMin = 'cargNormalMin';
  static const String kCargNormalMax = 'cargNormalMax';
  static const String kCargVigorosoMin = 'cargVigorosoMin';
  static const String kCargVigorosoMax = 'cargVigorosoMax';
  static const String kTableados = 'tableados';

  static const String kLimpieza = 'limpieza';
  static const String kObservacion = 'observacion';
  static const String kFoto1 = 'foto1';
  static const String kFinalFotos = 'finalFotos';

  static String finalBodyKey(String key) => 'final_$key';

  static final Set<String> comparativeSectionKeys = {
    kSectionPitones,
    kSectionCargadores,
    kSectionYemas,
    kSectionYemaDefectuosas,
    kSectionCalificacion,
  };

  static final Set<String> comparativeBodyKeys = {
    kPitones,
    kYemasPiton,
    kCargDer,
    kCargIzq,
    kTotalCargadores,
    kDebil,
    kNormal,
    kVigoroso,
    kTotalConteo,
    kTotalYemas,
    kCargDebilMin,
    kCargDebilMax,
    kCargNormalMin,
    kCargNormalMax,
    kCargVigorosoMin,
    kCargVigorosoMax,
    kTableados,
    kLimpieza,
    kObservacion,
    for (int i = 1; i <= 50; i++) 'c$i',
  };

  static bool isComparativeSection(String sectionKey) =>
      comparativeSectionKeys.contains(sectionKey);

  static bool isComparativeBodyKey(String key) =>
      comparativeBodyKeys.contains(key);

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const Set<String> _headerKeys = {kLoteId, kCampaniaId};

  @override
  Set<String> get headerKeys => _headerKeys;

  @override
  List<String> get etapaFenologicaOptions => const [];

  static const Set<String> _plusOneHeaderKeys = {kLoteId, kCampaniaId};

  static const Set<String> _plusOneBodyKeys = {
    kVariedad,
    kPodadorId,
    kSupervisorId,
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
      key: kSectionDatosGenerales,
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
          key: kPodadorId,
          label: 'Podador',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasPodador,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kSupervisorId,
          label: 'Supervisor',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasSupervisor,
          rules: CartillaFieldRules(required: true),
        ),
      ],
    ),
    const CartillaSectionConfig(
      key: kSectionPauta,
      title: 'PAUTA',
      fields: [
        CartillaFieldConfig(
          key: kPautaCargadores,
          label: 'Pauta cargadores',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0, maxValue: 99),
        ),
        CartillaFieldConfig(
          key: kPautaYemas,
          label: 'Pauta yemas',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0, maxValue: 9),
        ),
        CartillaFieldConfig(
          key: kHilera,
          label: 'Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
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
      key: kSectionPitones,
      title: 'PITONES',
      fields: [
        CartillaFieldConfig(
          key: kPitones,
          label: 'N° Pitones',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            required: true,
            maxDigits: 2,
            copyOnPlus1: true,
          ),
        ),
        CartillaFieldConfig(
          key: kYemasPiton,
          label: 'Total de Yemas / Piton',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            required: true,
            maxDigits: 2,
            copyOnPlus1: true,
          ),
        ),
      ],
    ),
    const CartillaSectionConfig(
      key: kSectionCargadores,
      title: 'N CARGADORES',
      fields: [
        CartillaFieldConfig(
          key: kCargDer,
          label: 'Cargadores Lado DER',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),
        CartillaFieldConfig(
          key: kCargIzq,
          label: 'Cargadores Lado IZQ',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),
        CartillaFieldConfig(
          key: kTotalCargadores,
          label: 'Total cargadores',
          type: CartillaFieldType.intReadOnly,
        ),
        CartillaFieldConfig(
          key: kDebil,
          label: 'Conteo Debil',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),
        CartillaFieldConfig(
          key: kNormal,
          label: 'Conteo Normal',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),
        CartillaFieldConfig(
          key: kVigoroso,
          label: 'Conteo Vigoroso',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),
        CartillaFieldConfig(
          key: kTotalConteo,
          label: 'Total',
          type: CartillaFieldType.intReadOnly,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: kSectionYemas,
      title: 'N DE YEMAS',
      fields: [
        const CartillaFieldConfig(
          key: kTotalYemas,
          label: 'Total',
          type: CartillaFieldType.intReadOnly,
        ),
        ...List.generate(
          50,
          (index) => CartillaFieldConfig(
            key: 'c${index + 1}',
            label: 'C${index + 1}',
            type: CartillaFieldType.intNumber,
            rules: const CartillaFieldRules(maxDigits: 1),
          ),
        ),
      ],
    ),
    const CartillaSectionConfig(
      key: kSectionYemaDefectuosas,
      title: 'YEMA DEFECTUOSAS',
      fields: [
        CartillaFieldConfig(
          key: kCargDebilMin,
          label: 'Carg. Debil < MIN',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 10),
        ),
        CartillaFieldConfig(
          key: kCargDebilMax,
          label: 'Carg. Debil > MAX',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 3),
        ),
        CartillaFieldConfig(
          key: kCargNormalMin,
          label: 'Carg. Normal < MIN',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 40),
        ),
        CartillaFieldConfig(
          key: kCargNormalMax,
          label: 'Carg. Normal > MAX',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 40),
        ),
        CartillaFieldConfig(
          key: kCargVigorosoMin,
          label: 'Carg. Vigoroso < MIN',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 40),
        ),
        CartillaFieldConfig(
          key: kCargVigorosoMax,
          label: 'Carg. Vigoroso > MAX',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 40),
        ),
        CartillaFieldConfig(
          key: kTableados,
          label: 'Tableados',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(maxDigits: 30),
        ),
      ],
    ),
    const CartillaSectionConfig(
      key: kSectionCalificacion,
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
