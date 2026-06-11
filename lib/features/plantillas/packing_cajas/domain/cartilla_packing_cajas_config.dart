import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaPackingCajasConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_packing_cajas';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const String kFechaRecepcion = 'fechaRecepcion';
  static const String kFechaProceso = 'fechaProceso';
  static const String kTipoEnvase = 'tipoEnvase';
  static const String kTipoPresentacion = 'tipoPresentacion';
  static const String kCategoria = 'categoria';

  static const String kPallet1Calibre10 = 'pallet1Calibre10';
  static const String kPallet1Calibre12 = 'pallet1Calibre12';
  static const String kPallet1Calibre14 = 'pallet1Calibre14';
  static const String kPallet1Calibre16 = 'pallet1Calibre16';
  static const String kPallet1Calibre18 = 'pallet1Calibre18';
  static const String kPallet1Calibre20 = 'pallet1Calibre20';
  static const String kPallet1Calibre22 = 'pallet1Calibre22';
  static const String kPallet1Calibre24 = 'pallet1Calibre24';
  static const String kPallet1Calibre26 = 'pallet1Calibre26';
  static const String kPallet1Calibre28 = 'pallet1Calibre28';
  static const String kPallet1Calibre30 = 'pallet1Calibre30';
  static const String kPallet1Calibre32 = 'pallet1Calibre32';
  static const String kPallet1SinCalibre = 'pallet1SinCalibre';

  static const String kPallet2Calibre10 = 'pallet2Calibre10';
  static const String kPallet2Calibre12 = 'pallet2Calibre12';
  static const String kPallet2Calibre14 = 'pallet2Calibre14';
  static const String kPallet2Calibre16 = 'pallet2Calibre16';
  static const String kPallet2Calibre18 = 'pallet2Calibre18';
  static const String kPallet2Calibre20 = 'pallet2Calibre20';
  static const String kPallet2Calibre22 = 'pallet2Calibre22';
  static const String kPallet2Calibre24 = 'pallet2Calibre24';
  static const String kPallet2Calibre26 = 'pallet2Calibre26';
  static const String kPallet2Calibre28 = 'pallet2Calibre28';
  static const String kPallet2Calibre30 = 'pallet2Calibre30';
  static const String kPallet2Calibre32 = 'pallet2Calibre32';
  static const String kPallet2SinCalibre = 'pallet2SinCalibre';

  static const Set<String> _headerKeys = {};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {};

  static const Set<String> _plusOneBodyKeys = {
    kFechaRecepcion,
    kFechaProceso,
    kTipoEnvase,
    kCategoria,
  };

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static const List<String> tipoEnvaseOptions = ['CARTON', 'PLASTICO'];
  static const List<String> tipoPresentacionOptions = ['4 KG', '10 KG'];
  static const List<String> categoriaOptions = ['CAT 1', 'CAT 2', 'CAT 3'];

  static const List<String> palletCounterKeys = [
    kPallet1Calibre10,
    kPallet1Calibre12,
    kPallet1Calibre14,
    kPallet1Calibre16,
    kPallet1Calibre18,
    kPallet1Calibre20,
    kPallet1Calibre22,
    kPallet1Calibre24,
    kPallet1Calibre26,
    kPallet1Calibre28,
    kPallet1Calibre30,
    kPallet1Calibre32,
    kPallet1SinCalibre,
    kPallet2Calibre10,
    kPallet2Calibre12,
    kPallet2Calibre14,
    kPallet2Calibre16,
    kPallet2Calibre18,
    kPallet2Calibre20,
    kPallet2Calibre22,
    kPallet2Calibre24,
    kPallet2Calibre26,
    kPallet2Calibre28,
    kPallet2Calibre30,
    kPallet2Calibre32,
    kPallet2SinCalibre,
  ];

  static const CartillaFieldRules _counterRules = CartillaFieldRules(
    minValue: 0,
  );

  static const List<CartillaFieldConfig> _pallet1Fields = [
    CartillaFieldConfig(
      key: kPallet1Calibre10,
      label: '6. CALIBRE 10',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet1Calibre12,
      label: '7. CALIBRE 12',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet1Calibre14,
      label: '8. CALIBRE 14',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet1Calibre16,
      label: '9. CALIBRE 16',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet1Calibre18,
      label: '10. CALIBRE 18',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet1Calibre20,
      label: '11. CALIBRE 20',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet1Calibre22,
      label: '12. CALIBRE 22',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet1Calibre24,
      label: '13. CALIBRE 24',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet1Calibre26,
      label: '14. CALIBRE 26',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet1Calibre28,
      label: '15. CALIBRE 28',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet1Calibre30,
      label: '16. CALIBRE 30',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet1Calibre32,
      label: '17. CALIBRE 32',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet1SinCalibre,
      label: '18. SIN CALIBRE',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
  ];

  static const List<CartillaFieldConfig> _pallet2Fields = [
    CartillaFieldConfig(
      key: kPallet2Calibre10,
      label: '19. CALIBRE 10',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet2Calibre12,
      label: '20. CALIBRE 12',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet2Calibre14,
      label: '21. CALIBRE 14',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet2Calibre16,
      label: '22. CALIBRE 16',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet2Calibre18,
      label: '23. CALIBRE 18',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet2Calibre20,
      label: '24. CALIBRE 20',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet2Calibre22,
      label: '25. CALIBRE 22',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet2Calibre24,
      label: '26. CALIBRE 24',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet2Calibre26,
      label: '27. CALIBRE 26',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet2Calibre28,
      label: '28. CALIBRE 28',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet2Calibre30,
      label: '29. CALIBRE 30',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet2Calibre32,
      label: '30. CALIBRE 32',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
    CartillaFieldConfig(
      key: kPallet2SinCalibre,
      label: '31. SIN CALIBRE',
      type: CartillaFieldType.stepperInt,
      rules: _counterRules,
    ),
  ];

  static const List<CartillaSectionConfig> _sections = [
    CartillaSectionConfig(
      key: 'datos_generales',
      title: 'DATOS GENERALES',
      fields: [
        CartillaFieldConfig(
          key: kFechaRecepcion,
          label: '1. Fecha de Recepción',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kFechaProceso,
          label: '2. Fecha de Proceso',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kTipoEnvase,
          label: '3. Tipo de Envase',
          type: CartillaFieldType.dropdown,
          staticOptions: tipoEnvaseOptions,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kTipoPresentacion,
          label: '4. Tipo Presentación',
          type: CartillaFieldType.dropdown,
          staticOptions: tipoPresentacionOptions,
        ),
        CartillaFieldConfig(
          key: kCategoria,
          label: '5. Categorías',
          type: CartillaFieldType.dropdown,
          staticOptions: categoriaOptions,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'pallets_procesados_1',
      title: 'PALLETS PROCESADOS 1',
      initiallyExpanded: false,
      fields: _pallet1Fields,
    ),
    CartillaSectionConfig(
      key: 'pallets_procesados_2',
      title: 'PALLETS PROCESADOS 2',
      initiallyExpanded: false,
      fields: _pallet2Fields,
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
