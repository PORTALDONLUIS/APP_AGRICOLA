import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaCalibrePaltaConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_calibre_palta';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const String kLoteId = 'loteId';
  static const String kCampaniaId = 'campaniaId';
  static const String kVariedad = 'variedad';
  static const String kSupervisor = 'supervisor';
  static const String kPreCalibre = 'preCalibre';
  static const String kCal8 = 'cal8';
  static const String kCal9 = 'cal9';
  static const String kCal10 = 'cal10';
  static const String kCal11 = 'cal11';
  static const String kCal12 = 'cal12';
  static const String kCal13 = 'cal13';
  static const String kCal14 = 'cal14';
  static const String kCal15 = 'cal15';
  static const String kCal16 = 'cal16';
  static const String kCal17 = 'cal17';
  static const String kCal18 = 'cal18';
  static const String kCal19 = 'cal19';
  static const String kCal20 = 'cal20';
  static const String kCal21 = 'cal21';
  static const String kCal22 = 'cal22';
  static const String kCal23 = 'cal23';
  static const String kCal24 = 'cal24';
  static const String kCal25 = 'cal25';
  static const String kCal26 = 'cal26';
  static const String kCal27 = 'cal27';
  static const String kCal28 = 'cal28';
  static const String kCal29 = 'cal29';
  static const String kCal30 = 'cal30';
  static const String kCal31 = 'cal31';
  static const String kCal32 = 'cal32';
  static const String kObservaciones = 'observaciones';

  static const Set<String> _headerKeys = {kLoteId, kCampaniaId};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {kLoteId, kCampaniaId};

  static const Set<String> _plusOneBodyKeys = {kVariedad, kSupervisor};

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static const List<String> calibreKeys = [
    kPreCalibre,
    kCal8,
    kCal9,
    kCal10,
    kCal11,
    kCal12,
    kCal13,
    kCal14,
    kCal15,
    kCal16,
    kCal17,
    kCal18,
    kCal19,
    kCal20,
    kCal21,
    kCal22,
    kCal23,
    kCal24,
    kCal25,
    kCal26,
    kCal27,
    kCal28,
    kCal29,
    kCal30,
    kCal31,
    kCal32,
  ];

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
          key: kVariedad,
          label: '2. Variedad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.variedades,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kSupervisor,
          label: '3. Seleccionar Supervisor',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasSupervisor,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
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
      key: 'calibres_1',
      title: 'CALIBRES 1',
      fields: [
        CartillaFieldConfig(
          key: kPreCalibre,
          label: '4. Pre-calibre',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal8,
          label: '5. Cal-8',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal9,
          label: '6. Cal-9',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal10,
          label: '7. Cal-10',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal11,
          label: '8. Cal-11',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal12,
          label: '9. Cal-12',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal13,
          label: '10. Cal-13',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal14,
          label: '11. Cal-14',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal15,
          label: '12. Cal-15',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal16,
          label: '13. Cal-16',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal17,
          label: '14. Cal-17',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'calibres_2',
      title: 'CALIBRES 2',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kCal18,
          label: '15. Cal-18',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal19,
          label: '16. Cal-19',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal20,
          label: '17. Cal-20',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal21,
          label: '18. Cal-21',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal22,
          label: '19. Cal-22',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal23,
          label: '20. Cal-23',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal24,
          label: '21. Cal-24',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal25,
          label: '22. Cal-25',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal26,
          label: '23. Cal-26',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal27,
          label: '24. Cal-27',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal28,
          label: '25. Cal-28',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'calibres_3',
      title: 'CALIBRES 3',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kCal29,
          label: '26. Cal-29',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal30,
          label: '27. Cal-30',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal31,
          label: '28. Cal-31',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kCal32,
          label: '29. Cal-32',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kObservaciones,
          label: '30. OBSERVACIONES',
          type: CartillaFieldType.longText,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
