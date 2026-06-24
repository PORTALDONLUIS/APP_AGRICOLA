import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaRaleoConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_raleo';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const String kCampaniaId = 'campaniaId';
  static const String kLoteId = 'loteId';
  static const String kControlCalidad = 'controlCalidad';
  static const String kSupervisor = 'supervisor';
  static const String kOperario1 = 'operario1';
  static const String kOperario2 = 'operario2';
  static const String kVariedad = 'variedad';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';

  static const String kRaPautaRaleo = 'raPautaRaleo';
  static const String kRaLongRacimo = 'raLongRacimo';
  static const String kRaNTotalBayas = 'raNTotalBayas';
  static const String kRaUvillas = 'raUvillas';
  static const String kRaResultado = 'raResultado';

  static const String kRsPautaRaleo = 'rsPautaRaleo';
  static const String kRsLongRacimo = 'rsLongRacimo';
  static const String kRsNTotalBayas = 'rsNTotalBayas';
  static const String kRsUvillas = 'rsUvillas';
  static const String kRsResultado = 'rsResultado';

  static const String kRatPautaRaleo = 'ratPautaRaleo';
  static const String kRatLongRacimo = 'ratLongRacimo';
  static const String kRatNTotalBayas = 'ratNTotalBayas';
  static const String kRatUvillas = 'ratUvillas';
  static const String kRatResultado = 'ratResultado';

  static const String kRpPautaRaleo = 'rpPautaRaleo';
  static const String kRpLongRacimo = 'rpLongRacimo';
  static const String kRpNTotalBayas = 'rpNTotalBayas';
  static const String kRpUvillas = 'rpUvillas';
  static const String kRpResultado = 'rpResultado';

  static const String kRpaPautaRaleo = 'rpaPautaRaleo';
  static const String kRpaLongRacimo = 'rpaLongRacimo';
  static const String kRpaNTotalBayas = 'rpaNTotalBayas';
  static const String kRpaUvillas = 'rpaUvillas';
  static const String kRpaResultado = 'rpaResultado';

  static const String kObservaciones = 'observaciones';

  static const Set<String> _headerKeys = {kCampaniaId, kLoteId};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {kCampaniaId, kLoteId};

  static const Set<String> _plusOneBodyKeys = {
    kControlCalidad,
    kVariedad,
    kRaPautaRaleo,
    kRsPautaRaleo,
    kRatPautaRaleo,
    kRpPautaRaleo,
    kRpaPautaRaleo,
  };

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static const List<String> siNoOptions = ['SI', 'NO'];

  static const List<String> resultadoOptions = [
    'BIEN RALEADO',
    'MAL RALEADO',
    'FALTA RALEAR',
    'SOBRE RALEADO',
    'FALTA DISTRIBUCIÓN',
    'BAYA CON DAÑO DE TRIPS',
    'PRESENCIA DE OIDIUM',
    'PRESENCIA DE CACHITO',
    'PRESENCIA DE CHANCHITO',
    'PRESENCIA DE FUMAGINA',
    'RACIMO SIN FORMA',
    'CONDICION DE RACIMO',
    'DAÑO MECANICO',
    'DESCOLE',
  ];

  static const CartillaFieldRules _decimalRules = CartillaFieldRules(
    minValue: 0,
  );

  static const CartillaFieldRules _pautaRules = CartillaFieldRules(
    required: true,
    copyOnPlus1: true,
  );

  static const List<String> decimalKeys = [
    kRaLongRacimo,
    kRaNTotalBayas,
    kRsLongRacimo,
    kRsNTotalBayas,
    kRatLongRacimo,
    kRatNTotalBayas,
    kRpLongRacimo,
    kRpNTotalBayas,
    kRpaLongRacimo,
    kRpaNTotalBayas,
  ];

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
          key: kControlCalidad,
          label: '2. Control de Calidad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasResponsableInspeccion,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kSupervisor,
          label: '3. Supervisor',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasSupervisor,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kOperario1,
          label: '4. Operario 1',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasOperario,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kOperario2,
          label: '5. Operario 2',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasOperario,
        ),
        CartillaFieldConfig(
          key: kVariedad,
          label: '6. Variedad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.variedades,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kHilera,
          label: '7. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
        CartillaFieldConfig(
          key: kPlanta,
          label: '8. Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
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
      key: 'racimo_alado',
      title: 'RACIMO ALADO',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kRaPautaRaleo,
          label: '9. RA-PAUTA RALEO',
          type: CartillaFieldType.shortText,
          rules: _pautaRules,
        ),
        CartillaFieldConfig(
          key: kRaLongRacimo,
          label: '10. RA-LONG.RACIMO',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRaNTotalBayas,
          label: '11. RA-N.TOTAL BAYAS',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRaUvillas,
          label: '12. RA-UVILLAS',
          type: CartillaFieldType.dropdown,
          staticOptions: siNoOptions,
        ),
        CartillaFieldConfig(
          key: kRaResultado,
          label: '13. RA-RESULTADO',
          type: CartillaFieldType.dropdown,
          staticOptions: resultadoOptions,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'racimo_semi_alado',
      title: 'RACIMOS SEMI ALADO',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kRsPautaRaleo,
          label: '14. RS-PAUTA RALEO',
          type: CartillaFieldType.shortText,
          rules: _pautaRules,
        ),
        CartillaFieldConfig(
          key: kRsLongRacimo,
          label: '15. RS-LONG.RACIMO',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRsNTotalBayas,
          label: '16. RS-N.TOTAL BAYAS',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRsUvillas,
          label: '17. RS-UVILLAS',
          type: CartillaFieldType.dropdown,
          staticOptions: siNoOptions,
        ),
        CartillaFieldConfig(
          key: kRsResultado,
          label: '18. RS-RESULTADO',
          type: CartillaFieldType.dropdown,
          staticOptions: resultadoOptions,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'racimo_tubado',
      title: 'RACIMOS A TUBADO',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kRatPautaRaleo,
          label: '19. RAT-PAUTA RALEO',
          type: CartillaFieldType.shortText,
          rules: _pautaRules,
        ),
        CartillaFieldConfig(
          key: kRatLongRacimo,
          label: '20. RAT-LONG.RACIMO',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRatNTotalBayas,
          label: '21. RAT-N.TOTAL BAYAS',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRatUvillas,
          label: '22. RAT-UVILLAS',
          type: CartillaFieldType.dropdown,
          staticOptions: siNoOptions,
        ),
        CartillaFieldConfig(
          key: kRatResultado,
          label: '23. RAT-RESULTADO',
          type: CartillaFieldType.dropdown,
          staticOptions: resultadoOptions,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'racimo_pequeno',
      title: 'RACIMOS PEQUEÑO',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kRpPautaRaleo,
          label: '24. RP-PAUTA RALEO',
          type: CartillaFieldType.shortText,
          rules: _pautaRules,
        ),
        CartillaFieldConfig(
          key: kRpLongRacimo,
          label: '25. RP-LONG.RACIMO',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRpNTotalBayas,
          label: '26. RP-N.TOTAL BAYAS',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRpUvillas,
          label: '27. RP-UVILLAS',
          type: CartillaFieldType.dropdown,
          staticOptions: siNoOptions,
        ),
        CartillaFieldConfig(
          key: kRpResultado,
          label: '28. RP-RESULTADO',
          type: CartillaFieldType.dropdown,
          staticOptions: resultadoOptions,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'racimo_pampano',
      title: 'RACIMOS PÁMPANO',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kRpaPautaRaleo,
          label: '29. RPA-PAUTA RALEO',
          type: CartillaFieldType.shortText,
          rules: _pautaRules,
        ),
        CartillaFieldConfig(
          key: kRpaLongRacimo,
          label: '30. RPA-LONG.RACIMO',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRpaNTotalBayas,
          label: '31. RPA-N.TOTAL BAYAS',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kRpaUvillas,
          label: '32. RPA-UVILLAS',
          type: CartillaFieldType.dropdown,
          staticOptions: siNoOptions,
        ),
        CartillaFieldConfig(
          key: kRpaResultado,
          label: '33. RPA-RESULTADO',
          type: CartillaFieldType.dropdown,
          staticOptions: resultadoOptions,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'observaciones',
      title: 'OBSERVACIONES',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kObservaciones,
          label: '34. Observaciones',
          type: CartillaFieldType.longText,
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
          label: '35. FOTO 1',
          type: CartillaFieldType.photo,
          photoIndex: 1,
        ),
        CartillaFieldConfig(
          key: 'foto2',
          label: '36. FOTO 2',
          type: CartillaFieldType.photo,
          photoIndex: 2,
        ),
        CartillaFieldConfig(
          key: 'foto3',
          label: '37. FOTO 3',
          type: CartillaFieldType.photo,
          photoIndex: 3,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
