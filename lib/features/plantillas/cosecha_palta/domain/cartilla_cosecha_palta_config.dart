import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaCosechaPaltaConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_cosecha_palta';
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
  static const String kOperador = 'operador';
  static const String kSupervisor = 'supervisor';
  static const String kNroFrutoEvaluados = 'nroFrutoEvaluados';

  static const String kDanoBichoCesto = 'danoBichoCesto';
  static const String kAusenciaPedunculo = 'ausenciaPedunculo';
  static const String kPedunculoLargo = 'pedunculoLargo';
  static const String kDanoMecanico = 'danoMecanico';
  static const String kDanoGolpe = 'danoGolpe';
  static const String kFumagina = 'fumagina';
  static const String kLenticelosis = 'lenticelosis';
  static const String kQuemaduraSol = 'quemaduraSol';
  static const String kFrutoDeforme = 'frutoDeforme';
  static const String kViracionColor = 'viracionColor';
  static const String kPresenciaQueresas = 'presenciaQueresas';
  static const String kDanoTrips = 'danoTrips';
  static const String kSombreamiento = 'sombreamiento';
  static const String kDanoRoedor = 'danoRoedor';
  static const String kSumbloth = 'sumbloth';
  static const String kQuimera = 'quimera';
  static const String kRameado = 'rameado';
  static const String kFrutoBarro = 'frutoBarro';
  static const String kFrutosDeshidratados = 'frutosDeshidratados';
  static const String kPreCalibre = 'preCalibre';
  static const String kFrutoExcretaAves = 'frutoExcretaAves';

  static const String kObservaciones = 'observaciones';
  static const String kConDefectos = 'conDefectos';
  static const String kSinDefectos = 'sinDefectos';

  static const Set<String> _headerKeys = {kLoteId, kCampaniaId};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {kLoteId, kCampaniaId};

  static const Set<String> _plusOneBodyKeys = {
    kVariedad,
    kOperador,
    kSupervisor,
  };

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static const List<String> defectCounterKeys = [
    kDanoBichoCesto,
    kAusenciaPedunculo,
    kPedunculoLargo,
    kDanoMecanico,
    kDanoGolpe,
    kFumagina,
    kLenticelosis,
    kQuemaduraSol,
    kFrutoDeforme,
    kViracionColor,
    kPresenciaQueresas,
    kDanoTrips,
    kSombreamiento,
    kDanoRoedor,
    kSumbloth,
    kQuimera,
    kRameado,
    kFrutoBarro,
    kFrutosDeshidratados,
    kPreCalibre,
    kFrutoExcretaAves,
  ];

  static const CartillaFieldRules _counterRules = CartillaFieldRules(
    required: true,
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
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kOperador,
          label: '3. Seleccionar Operador',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasOperario,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kSupervisor,
          label: '4. Seleccionar Supervisor',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasSupervisor,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kNroFrutoEvaluados,
          label: '5. Nro Fruto Evaluados',
          type: CartillaFieldType.intReadOnly,
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
      key: 'defectos_1',
      title: 'DEFECTOS 1',
      fields: [
        CartillaFieldConfig(
          key: kDanoBichoCesto,
          label: '6. Daño por Bicho del Cesto',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kAusenciaPedunculo,
          label: '7. Ausencia de Pedunculo',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kPedunculoLargo,
          label: '8. Pedunculo largo',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kDanoMecanico,
          label: '9. Daño mecanico',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kDanoGolpe,
          label: '10. Daño por golpe',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kFumagina,
          label: '11. Fumagina',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kLenticelosis,
          label: '12. Lenticelosis',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kQuemaduraSol,
          label: '13. Quemadura de sol',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kFrutoDeforme,
          label: '14. Fruto deforme',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kViracionColor,
          label: '15. Viracion de color',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'defectos_2',
      title: 'DEFECTOS 2',
      fields: [
        CartillaFieldConfig(
          key: kPresenciaQueresas,
          label: '16. Presencia de Queresas',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kDanoTrips,
          label: '17. Daño por Trips',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kSombreamiento,
          label: '18. Sombreamiento',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kDanoRoedor,
          label: '19. Daño por roedor',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kSumbloth,
          label: '20. Sumbloth',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kQuimera,
          label: '21. Quimera',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kRameado,
          label: '22. Rameado',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kFrutoBarro,
          label: '23. Fruto con barro',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kFrutosDeshidratados,
          label: '24. Frutos Deshidratados',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kPreCalibre,
          label: '25. Pre calibre',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kFrutoExcretaAves,
          label: '26. Fruto con excreta de aves',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'resumen',
      title: 'RESUMEN',
      fields: [
        CartillaFieldConfig(
          key: kObservaciones,
          label: '27. Observaciones',
          type: CartillaFieldType.longText,
        ),
        CartillaFieldConfig(
          key: kConDefectos,
          label: '28. Con Defectos',
          type: CartillaFieldType.decimalReadOnly,
        ),
        CartillaFieldConfig(
          key: kSinDefectos,
          label: '29. Sin Defectos',
          type: CartillaFieldType.decimalReadOnly,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
