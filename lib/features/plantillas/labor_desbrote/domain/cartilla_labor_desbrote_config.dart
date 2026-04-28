import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaLaborDesbroteConfig implements CartillaFormConfig {
  // ========= Identidad =========
  static const String _templateKey = 'cartilla_labor_desbrote';
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

  // BODY - Datos generales
  static const String kOperario1Id = 'operario1Id';
  static const String kOperario2Id = 'operario2Id';
  static const String kSupervisorId = 'supervisorId';
  static const String kVariedad = 'variedad';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';

  // BODY - Brotes
  static const String kPitonBrote = 'pitonBrote';
  static const String kCargadores = 'cargadores';
  static const String kMaterialViejo = 'materialViejo';
  static const String kTotalBrotes = 'totalBrotes';

  // BODY - Racimos
  static const String kPiton = 'piton';
  static const String kRacimoSimple = 'racimoSimple';
  static const String kRacimoDoble = 'racimoDoble';
  static const String kTotalSimpleDoble = 'totalSimpleDoble';
  static const String kRacimoIndefinido = 'racimoIndefinido';

  // BODY - Final
  static const String kObservaciones = 'observaciones';
  static const String kFoto1 = 'foto1';
  static const String kFoto2 = 'foto2';

  // ========= Header keys =========
  static const Set<String> _headerKeys = {kLoteId, kCampaniaId};

  @override
  Set<String> get headerKeys => _headerKeys;

  // Interface obliga esto
  static const List<String> _etapas = [];
  @override
  List<String> get etapaFenologicaOptions => _etapas;

  // ========= (+1) replicables =========
  // Manual: Lote y Variedad se replican con +1.
  static const Set<String> _plusOneHeaderKeys = {kLoteId};

  static const Set<String> _plusOneBodyKeys = {kVariedad};

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
          key: kOperario1Id,
          label: '2. Operario 1',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasPodador,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kOperario2Id,
          label: '3. Operario 2',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasPodador,
        ),
        CartillaFieldConfig(
          key: kSupervisorId,
          label: '4. Supervisor',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasSupervisor,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kVariedad,
          label: '5. Variedad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.variedades,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kHilera,
          label: '6. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),
        CartillaFieldConfig(
          key: kPlanta,
          label: '7. Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'brotes',
      title: 'BROTES',
      fields: [
        CartillaFieldConfig(
          key: kPitonBrote,
          label: '8. Piton en brote',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0, maxValue: 50),
        ),
        CartillaFieldConfig(
          key: kCargadores,
          label: '9. Cargadores',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0, maxValue: 150),
        ),
        CartillaFieldConfig(
          key: kMaterialViejo,
          label: '10. Material Viejo',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0, maxValue: 50),
        ),
        CartillaFieldConfig(
          key: kTotalBrotes,
          label: '11. Total Brotes',
          type: CartillaFieldType.decimalReadOnly,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'racimos',
      title: 'RACIMOS',
      fields: [
        CartillaFieldConfig(
          key: kPiton,
          label: '12. Piton',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0, maxValue: 50),
        ),
        CartillaFieldConfig(
          key: kRacimoSimple,
          label: '13. Racimo Simple',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kRacimoDoble,
          label: '14. Racimo Doble',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0, maxValue: 100),
        ),
        CartillaFieldConfig(
          key: kTotalSimpleDoble,
          label: '15. Total S+D',
          type: CartillaFieldType.decimalReadOnly,
        ),
        CartillaFieldConfig(
          key: kRacimoIndefinido,
          label: '16. Racimo indefinido',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'final',
      title: 'OBSERVACIONES / FOTOS',
      fields: [
        CartillaFieldConfig(
          key: kObservaciones,
          label: '17. Observaciones',
          type: CartillaFieldType.longText,
        ),
        CartillaFieldConfig(
          key: kFoto1,
          label: '18. FOTO 1',
          type: CartillaFieldType.photo,
          photoIndex: 1,
        ),
        CartillaFieldConfig(
          key: kFoto2,
          label: '19. FOTO 2',
          type: CartillaFieldType.photo,
          photoIndex: 2,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
