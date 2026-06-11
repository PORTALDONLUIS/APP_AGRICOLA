import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaPackingRecepcionConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_packing_recepcion';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const String kLoteId = 'loteId';
  static const String kCampaniaId = 'campaniaId';
  static const String kFecha = 'fecha';
  static const String kVariedad = 'variedad';
  static const String kNroGuia = 'nroGuia';
  static const String kTotalBinesPorGuia = 'totalBinesPorGuia';
  static const String kSector = 'sector';
  static const String kNBines = 'nBines';
  static const String kPesoTotalBines = 'pesoTotalBines';
  static const String kPesoNeto = 'pesoNeto';
  static const String kPesoPorBin = 'pesoPorBin';

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

  static const Set<String> _plusOneBodyKeys = {kFecha, kVariedad, kSector};

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

  static const _defectSources = [
    (key: kDanoBichoCesto, label: '11. Daño por Bicho del Cesto'),
    (key: kAusenciaPedunculo, label: '12. Ausencia de Pedunculo'),
    (key: kPedunculoLargo, label: '13. Pedunculo largo'),
    (key: kDanoMecanico, label: '14. Daño mecanico'),
    (key: kDanoGolpe, label: '15. Daño por golpe'),
    (key: kHeridaAbierta, label: '16. Herida abierta'),
    (key: kFumagina, label: '17. Fumagina'),
    (key: kLenticelosis, label: '18. Lenticelosis'),
    (key: kQuemaduraSol, label: '19. Quemadura de sol'),
    (key: kFrutoDeforme, label: '20. Fruto deforme'),
    (key: kViracionColor, label: '21. Viracion de color'),
    (key: kPresenciaQueresas, label: '22. Presencia de Queresas'),
    (key: kDanoOxidya, label: '23. Daño por Oxidya'),
    (key: kDanoTrips, label: '24. Daño por Trips'),
    (key: kSombreamiento, label: '25. Sombreamiento'),
    (key: kGrietas, label: '26. Grietas'),
    (key: kFrutoRusset, label: '27. Fruto con Russet'),
    (key: kFrutoRoce, label: '28. Fruto con roce'),
    (key: kDanoRoedor, label: '29. Daño por roedor'),
    (key: kSumbloth, label: '30. Sumbloth'),
    (key: kQuimera, label: '31. Quimera'),
    (key: kRameado, label: '32. Rameado'),
    (key: kFrutoBarro, label: '33. Fruto con barro'),
    (key: kFrutosDeshidratados, label: '34. Frutos Deshidratados'),
    (key: kPreCalibre, label: '35. Pre-calibre'),
    (key: kSobremadurez, label: '36. Sobremadurez'),
    (key: kPepaSuelta, label: '37. Pepa suelta'),
    (key: kFrutoExcretaAves, label: '38. Fruto con excreta de aves'),
    (key: kContactoSuelo, label: '39. Contacto con el suelo'),
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
    const CartillaSectionConfig(
      key: 'datos_generales',
      title: 'DATOS GENERALES',
      fields: [
        CartillaFieldConfig(
          key: kFecha,
          label: '1. Fecha',
          type: CartillaFieldType.date,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kLoteId,
          label: '2. Lote',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kVariedad,
          label: '3. Variedad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.variedades,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kNroGuia,
          label: '4. Nro. Guia',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kTotalBinesPorGuia,
          label: '5. TOTAL DE BINES POR GUIA',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kSector,
          label: '6. Sector',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kNBines,
          label: '7. N DE BINES',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kPesoTotalBines,
          label: '8. PESO / TOTAL DE BINES',
          type: CartillaFieldType.decimalNumber,
        ),
        CartillaFieldConfig(
          key: kPesoNeto,
          label: '9. PESO NETO',
          type: CartillaFieldType.decimalNumber,
        ),
        CartillaFieldConfig(
          key: kPesoPorBin,
          label: '10. PESO / POR BIN',
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
    const CartillaSectionConfig(
      key: 'observacion',
      title: 'OBSERVACION',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kObservacion,
          label: '40. Observacion',
          type: CartillaFieldType.longText,
        ),
      ],
    ),
    const CartillaSectionConfig(
      key: 'fotos',
      title: 'FOTOS',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: 'foto1',
          label: '41. FOTO 1',
          type: CartillaFieldType.photo,
          photoIndex: 1,
        ),
        CartillaFieldConfig(
          key: 'foto2',
          label: '42. FOTO 2',
          type: CartillaFieldType.photo,
          photoIndex: 2,
        ),
        CartillaFieldConfig(
          key: 'foto3',
          label: '43. FOTO 3',
          type: CartillaFieldType.photo,
          photoIndex: 3,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
