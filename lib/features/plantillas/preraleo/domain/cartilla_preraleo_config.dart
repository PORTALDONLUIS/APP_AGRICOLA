import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaPreraleoConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_preraleo';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const String kCampaniaId = 'campaniaId';
  static const String kLoteId = 'loteId';
  static const String kVariedad = 'variedad';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';
  static const String kSupervisor = 'supervisor';
  static const String kOperario1 = 'operario1';
  static const String kOperario2 = 'operario2';

  static const String kRacimoGrandeLong = 'racimoGrandeLong';
  static const String kRacimoGrandeNPisos = 'racimoGrandeNPisos';
  static const String kRacimoGrandeObservaciones = 'racimoGrandeObservaciones';

  static const String kRacimoPequenoLong = 'racimoPequenoLong';
  static const String kRacimoPequenoNPisos = 'racimoPequenoNPisos';
  static const String kRacimoPequenoObservaciones =
      'racimoPequenoObservaciones';

  static const String kConteo = 'conteo';
  static const String kRacimosPreRaleados = 'racimosPreRaleados';
  static const String kRacimosNoPreRaleados = 'racimosNoPreRaleados';
  static const String kTotalRacimos = 'totalRacimos';

  static const Set<String> _headerKeys = {kCampaniaId, kLoteId};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {kCampaniaId, kLoteId};

  static const Set<String> _plusOneBodyKeys = {kVariedad};

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static const CartillaFieldRules _decimalRules = CartillaFieldRules(
    minValue: 0,
  );

  static const CartillaFieldRules _counterRules = CartillaFieldRules(
    minValue: 0,
  );

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
          key: kHilera,
          label: '2. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
        CartillaFieldConfig(
          key: kPlanta,
          label: '3. Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
        CartillaFieldConfig(
          key: kVariedad,
          label: '4. Variedad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.variedades,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kSupervisor,
          label: '5. Supervisor',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasSupervisor,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kOperario1,
          label: '6. Operario 1',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasOperario,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kOperario2,
          label: '7. Operario 2',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasOperario,
        ),
        CartillaFieldConfig(
          key: kCampaniaId,
          label: 'Campaña',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'racimos_grandes',
      title: 'RACIMOS GRANDES (7-8CM)',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kRacimoGrandeLong,
          label: '8. RA-LONG',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRacimoGrandeNPisos,
          label: '9. RG N PISOS',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRacimoGrandeObservaciones,
          label: '10. RG OBSERVACIONES',
          type: CartillaFieldType.longText,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'racimos_pequenos',
      title: 'RACIMOS PEQUEÑOS (5-6CM)',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kRacimoPequenoLong,
          label: '11. RP-LONG',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRacimoPequenoNPisos,
          label: '12. RP N PISOS',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRacimoPequenoObservaciones,
          label: '13. RP OBSERVACIONES',
          type: CartillaFieldType.longText,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'conteo',
      title: 'CONTEO',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kConteo,
          label: '14. CONTEO',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kRacimosPreRaleados,
          label: '15. N racimos Pre raleados',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kRacimosNoPreRaleados,
          label: '16. N racimos no Pre raleados',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kTotalRacimos,
          label: '17. Total de racimos',
          type: CartillaFieldType.intReadOnly,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'fotos',
      title: 'FOTOS',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: 'foto1',
          label: '18. FOTO 1',
          type: CartillaFieldType.photo,
          photoIndex: 1,
        ),
        CartillaFieldConfig(
          key: 'foto2',
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
