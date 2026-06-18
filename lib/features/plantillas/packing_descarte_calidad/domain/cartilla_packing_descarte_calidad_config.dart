import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaPackingDescarteCalidadConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_packing_descarte_calidad';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const String kLoteId = 'loteId';
  static const String kCampaniaId = 'campaniaId';
  static const String kFechaRecepcion = 'fechaRecepcion';
  static const String kFechaProceso = 'fechaProceso';
  static const String kVariedad = 'variedad';
  static const String kDescartePesoNetoTotal = 'descartePesoNetoTotal';
  static const String kPorcentajeDescarte = 'porcentajeDescarte';

  static const String kGuia1NroGuia = 'guia1NroGuia';
  static const String kGuia1NBines = 'guia1NBines';
  static const String kGuia1PesoNeto = 'guia1PesoNeto';
  static const String kGuia2NroGuia = 'guia2NroGuia';
  static const String kGuia2NBines = 'guia2NBines';
  static const String kGuia2PesoNeto = 'guia2PesoNeto';
  static const String kGuia3NroGuia = 'guia3NroGuia';
  static const String kGuia3NBines = 'guia3NBines';
  static const String kGuia3PesoNeto = 'guia3PesoNeto';
  static const String kGuia4NroGuia = 'guia4NroGuia';
  static const String kGuia4NBines = 'guia4NBines';
  static const String kGuia4PesoNeto = 'guia4PesoNeto';
  static const String kNBinesTotal = 'nBinesTotal';
  static const String kPesoNetoTotal = 'pesoNetoTotal';

  static const String kDanoBichoCesto = 'danoBichoCesto';
  static const String kAusenciaPedunculo = 'ausenciaPedunculo';
  static const String kPedunculoLargo = 'pedunculoLargo';
  static const String kDanoMecanico = 'danoMecanico';
  static const String kDanoGolpe = 'danoGolpe';
  static const String kHeridaAbierta = 'heridaAbierta';
  static const String kFumagina = 'fumagina';
  static const String kLenticelosis = 'lenticelosis';
  static const String kQuemaduraSol = 'quemaduraSol';
  static const String kFrutoDeforme = 'frutoDeforme';
  static const String kViracionColor = 'viracionColor';
  static const String kPresenciaQueresas = 'presenciaQueresas';
  static const String kDanoOxidya = 'danoOxidya';
  static const String kDanoTrips = 'danoTrips';
  static const String kSombreamiento = 'sombreamiento';
  static const String kGrietas = 'grietas';
  static const String kFrutoRusset = 'frutoRusset';
  static const String kFrutoRoce = 'frutoRoce';
  static const String kDanoRoedor = 'danoRoedor';
  static const String kSumbloth = 'sumbloth';
  static const String kQuimera = 'quimera';
  static const String kRameado = 'rameado';
  static const String kFrutoBarro = 'frutoBarro';
  static const String kFrutosDeshidratados = 'frutosDeshidratados';
  static const String kPreCalibre = 'preCalibre';
  static const String kSobremadurez = 'sobremadurez';
  static const String kPepaSuelta = 'pepaSuelta';
  static const String kFrutoExcretaAves = 'frutoExcretaAves';
  static const String kContactoSuelo = 'contactoSuelo';
  static const String kObservacion = 'observacion';

  static const Set<String> _headerKeys = {kLoteId, kCampaniaId};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {kLoteId, kCampaniaId};

  static const Set<String> _plusOneBodyKeys = {kFechaRecepcion, kVariedad};

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static const List<String> guideBinesKeys = [
    kGuia1NBines,
    kGuia2NBines,
    kGuia3NBines,
    kGuia4NBines,
  ];

  static const List<String> guidePesoNetoKeys = [
    kGuia1PesoNeto,
    kGuia2PesoNeto,
    kGuia3PesoNeto,
    kGuia4PesoNeto,
  ];

  static const List<String> defectCounterKeys = [
    kDanoBichoCesto,
    kAusenciaPedunculo,
    kPedunculoLargo,
    kDanoMecanico,
    kDanoGolpe,
    kHeridaAbierta,
    kFumagina,
    kLenticelosis,
    kQuemaduraSol,
    kFrutoDeforme,
    kViracionColor,
    kPresenciaQueresas,
    kDanoOxidya,
    kDanoTrips,
    kSombreamiento,
    kGrietas,
    kFrutoRusset,
    kFrutoRoce,
    kDanoRoedor,
    kSumbloth,
    kQuimera,
    kRameado,
    kFrutoBarro,
    kFrutosDeshidratados,
    kPreCalibre,
    kSobremadurez,
    kPepaSuelta,
    kFrutoExcretaAves,
    kContactoSuelo,
  ];

  static const CartillaFieldRules _counterRules = CartillaFieldRules(
    minValue: 0,
  );

  static const CartillaFieldRules _decimalRules = CartillaFieldRules(
    minValue: 0,
  );

  static const _defectSources = [
    (key: kDanoBichoCesto, label: '21. Daño por Bicho del Cesto'),
    (key: kAusenciaPedunculo, label: '22. Ausencia de Pedunculo'),
    (key: kPedunculoLargo, label: '23. Pedunculo largo'),
    (key: kDanoMecanico, label: '24. Daño mecanico'),
    (key: kDanoGolpe, label: '25. Daño por golpe'),
    (key: kHeridaAbierta, label: '26. Herida abierta'),
    (key: kFumagina, label: '27. Fumagina'),
    (key: kLenticelosis, label: '28. Lenticelosis'),
    (key: kQuemaduraSol, label: '29. Quemadura de sol'),
    (key: kFrutoDeforme, label: '30. Fruto deforme'),
    (key: kViracionColor, label: '31. Viracion de color'),
    (key: kPresenciaQueresas, label: '32. Presencia de Queresas'),
    (key: kDanoOxidya, label: '33. Daño por Oxidya'),
    (key: kDanoTrips, label: '34. Daño por Trips'),
    (key: kSombreamiento, label: '35. Sombreamiento'),
    (key: kGrietas, label: '36. Grietas'),
    (key: kFrutoRusset, label: '37. Fruto con Russet'),
    (key: kFrutoRoce, label: '38. Fruto con roce'),
    (key: kDanoRoedor, label: '39. Daño por roedor'),
    (key: kSumbloth, label: '40. Sumbloth'),
    (key: kQuimera, label: '41. Quimera'),
    (key: kRameado, label: '42. Rameado'),
    (key: kFrutoBarro, label: '43. Fruto con barro'),
    (key: kFrutosDeshidratados, label: '44. Frutos Deshidratados'),
    (key: kPreCalibre, label: '45. Pre-calibre'),
    (key: kSobremadurez, label: '46. Sobremadurez'),
    (key: kPepaSuelta, label: '47. Pepa suelta'),
    (key: kFrutoExcretaAves, label: '48. Fruto con excreta de aves'),
    (key: kContactoSuelo, label: '49. Contacto con el suelo'),
  ];

  static final List<CartillaFieldConfig> _defectFields = [
    for (final source in _defectSources)
      CartillaFieldConfig(
        key: source.key,
        label: source.label,
        type: CartillaFieldType.stepperInt,
        rules: _counterRules,
      ),
  ];

  static final List<CartillaSectionConfig> _sections = [
    CartillaSectionConfig(
      key: 'datos_generales',
      title: 'DATOS GENERALES',
      fields: [
        CartillaFieldConfig(
          key: kFechaRecepcion,
          label: '1. Fecha recepcion',
          type: CartillaFieldType.date,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kFechaProceso,
          label: '2. Fecha proceso',
          type: CartillaFieldType.date,
        ),
        CartillaFieldConfig(
          key: kLoteId,
          label: '3. Lote',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kVariedad,
          label: '4. Variedad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.variedades,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kDescartePesoNetoTotal,
          label: '5. DESCARTE PESO NETO TOTAL',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
        CartillaFieldConfig(
          key: kPorcentajeDescarte,
          label: '6. % DESCARTE',
          type: CartillaFieldType.decimalReadOnly,
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
      key: 'guia_1',
      title: 'GUIA 1',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kGuia1NroGuia,
          label: '7. Nro. Guia',
          type: CartillaFieldType.shortText,
        ),
        CartillaFieldConfig(
          key: kGuia1NBines,
          label: '8. N DE BINES (GUIA 1)',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kGuia1PesoNeto,
          label: '9. PESO NETO (GUIA 1)',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'guia_2',
      title: 'GUIA 2',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kGuia2NroGuia,
          label: '10. Nro. Guia',
          type: CartillaFieldType.shortText,
        ),
        CartillaFieldConfig(
          key: kGuia2NBines,
          label: '11. N DE BINES (GUIA 2)',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kGuia2PesoNeto,
          label: '12. PESO NETO (GUIA 2)',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'guia_3',
      title: 'GUIA 3',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kGuia3NroGuia,
          label: '13. Nro. Guia',
          type: CartillaFieldType.shortText,
        ),
        CartillaFieldConfig(
          key: kGuia3NBines,
          label: '14. N DE BINES (GUIA 3)',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kGuia3PesoNeto,
          label: '15. PESO NETO (GUIA 3)',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'guia_4',
      title: 'GUIA 4',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kGuia4NroGuia,
          label: '16. Nro. Guia',
          type: CartillaFieldType.shortText,
        ),
        CartillaFieldConfig(
          key: kGuia4NBines,
          label: '17. N DE BINES (GUIA 4)',
          type: CartillaFieldType.stepperInt,
          rules: _counterRules,
        ),
        CartillaFieldConfig(
          key: kGuia4PesoNeto,
          label: '18. PESO NETO (GUIA 4)',
          type: CartillaFieldType.decimalNumber,
          rules: _decimalRules,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'totales',
      title: 'TOTALES',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kNBinesTotal,
          label: '19. N DE BINES TOTAL',
          type: CartillaFieldType.intReadOnly,
        ),
        CartillaFieldConfig(
          key: kPesoNetoTotal,
          label: '20. PESO NETO TOTAL',
          type: CartillaFieldType.decimalReadOnly,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'defectos_1',
      title: 'PRINCIPALES DEFECTOS 1',
      initiallyExpanded: false,
      fields: [..._defectFields.take(15)],
    ),
    CartillaSectionConfig(
      key: 'defectos_2',
      title: 'PRINCIPALES DEFECTOS 2',
      initiallyExpanded: false,
      fields: [..._defectFields.skip(15)],
    ),
    CartillaSectionConfig(
      key: 'observacion',
      title: 'OBSERVACION',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kObservacion,
          label: '50. Observacion',
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
          label: '51. FOTO 1',
          type: CartillaFieldType.photo,
          photoIndex: 1,
        ),
        CartillaFieldConfig(
          key: 'foto2',
          label: '52. FOTO 2',
          type: CartillaFieldType.photo,
          photoIndex: 2,
        ),
        CartillaFieldConfig(
          key: 'foto3',
          label: '53. FOTO 3',
          type: CartillaFieldType.photo,
          photoIndex: 3,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
