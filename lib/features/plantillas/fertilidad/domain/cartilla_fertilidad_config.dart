import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaFertilidadConfig implements CartillaFormConfig {
  // ========= Identidad =========
  static const String _templateKey = 'cartilla_fertilidad';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  // ========= Keys =========
  // ✅ HEADER
  static const String kLoteId = 'loteId';
  static const String kCampaniaId = 'campaniaId';

  // ✅ BODY (cabecera funcional)
  static const String kEvaluacion = 'evaluacion';
  static const String kTipoCargador = 'tipoCargador';
  static const String kNumeroCargador = 'numeroCargador';

  // ✅ BODY (Yema i)
  static const String kY1Numero = 'yema1_numero';
  static const String kY1Parametros = 'yema1_parametros';
  static const String kY1CatYema = 'yema1_catYema';

  static const String kY2Numero = 'yema2_numero';
  static const String kY2Parametros = 'yema2_parametros';
  static const String kY2CatYema = 'yema2_catYema';

  static const String kY3Numero = 'yema3_numero';
  static const String kY3Parametros = 'yema3_parametros';
  static const String kY3CatYema = 'yema3_catYema';

  static const String kY4Numero = 'yema4_numero';
  static const String kY4Parametros = 'yema4_parametros';
  static const String kY4CatYema = 'yema4_catYema';

  static const String kY5Numero = 'yema5_numero';
  static const String kY5Parametros = 'yema5_parametros';
  static const String kY5CatYema = 'yema5_catYema';

  static const String kY6Numero = 'yema6_numero';
  static const String kY6Parametros = 'yema6_parametros';
  static const String kY6CatYema = 'yema6_catYema';

  static const String kY7Numero = 'yema7_numero';
  static const String kY7Parametros = 'yema7_parametros';
  static const String kY7CatYema = 'yema7_catYema';

  // ✅ BODY (final)
  static const String kObservaciones = 'observaciones';

  // Fotos (5)
  static const String kFoto1 = 'foto1';
  static const String kFoto2 = 'foto2';
  static const String kFoto3 = 'foto3';
  static const String kFoto4 = 'foto4';
  static const String kFoto5 = 'foto5';

  // ========= Header keys =========
  static const Set<String> _headerKeys = {
    kLoteId,
    kCampaniaId,
  };

  @override
  Set<String> get headerKeys => _headerKeys;

  // ========= Opciones estáticas (según manual) =========
  static const List<String> _campaniaOptions = [
    'CAMP2026',
  ];

  static const List<String> _evaluacionOptions = [
    'I ACARO-FERTILIDAD',
    'II ACARO-FERTILIDAD-MADURES',
    'III FERTILIDAD-MADURES',
  ];

  static const List<String> _tipoCargadorOptions = [
    'CARGADOR DEBIL',
    'CARGADOR NORMAL',
    'CARGADOR VIGOROSO',
  ];

  // Lista de parámetros (estática)
  static const List<String> _parametrosOptions = [
    'FF',
    'FG',
    'F',
    'FP',
    'V',
    'VI',
    'A',
    'FA',
    'N',
    'FN',
    'S',
  ];

  // CAT/YEMA: depende de 3. Evaluación (manual).
  // — I ACARO-FERTILIDAD: sin opciones
  // — II ACARO-FERTILIDAD-MADURES y III FERTILIDAD-MADURES: M, I
  static const List<String> _catYemaOptions = [
    'M',
    'I',
  ];

  /// Claves body de todos los dropdowns CAT/YEMA (yema 1..7).
  static const Set<String> catYemaFieldKeys = {
    kY1CatYema,
    kY2CatYema,
    kY3CatYema,
    kY4CatYema,
    kY5CatYema,
    kY6CatYema,
    kY7CatYema,
  };

  /// Opciones visibles para CAT/YEMA según la evaluación seleccionada.
  static List<String> catYemaOptionsForEvaluacion(String? evaluacionRaw) {
    final e = (evaluacionRaw ?? '').toString().trim();
    if (e.startsWith('II') || e.startsWith('III')) {
      return const ['M', 'I'];
    }
    return const [];
  }

  // Interface obliga esto
  static const List<String> _etapas = [];
  @override
  List<String> get etapaFenologicaOptions => _etapas;

  // ========= (+1) replicables =========
  // Manual: (+1) replica Lote, Campaña, Evaluación, Tipo Cargador.
  static const Set<String> _plusOneHeaderKeys = {
    kLoteId,
    kCampaniaId,
  };

  static const Set<String> _plusOneBodyKeys = {
    kEvaluacion,
    kTipoCargador,
  };

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
          key: kCampaniaId,
          label: '2. Campaña',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kEvaluacion,
          label: '3. Evaluación',
          type: CartillaFieldType.dropdown,
          staticOptions: _evaluacionOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kTipoCargador,
          label: '4. Seleccionar tipo de cargador',
          type: CartillaFieldType.dropdown,
          staticOptions: _tipoCargadorOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kNumeroCargador,
          label: '5. Número de cargador',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, maxDigits: 2, minValue: 0),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'yema_1',
      title: 'YEMA 1',
      fields: [
        CartillaFieldConfig(
          key: kY1Numero,
          label: '6. 1. Número de yema',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kY1Parametros,
          label: '7. 1. Parámetros',
          type: CartillaFieldType.dropdown,
          staticOptions: _parametrosOptions,
        ),
        CartillaFieldConfig(
          key: kY1CatYema,
          label: '8. 1. Cat/yema',
          type: CartillaFieldType.dropdown,
          staticOptions: _catYemaOptions,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'yema_2',
      title: 'YEMA 2',
      fields: [
        CartillaFieldConfig(
          key: kY2Numero,
          label: '9. 2. Número de yema',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kY2Parametros,
          label: '10. 2. Parámetros',
          type: CartillaFieldType.dropdown,
          staticOptions: _parametrosOptions,
        ),
        CartillaFieldConfig(
          key: kY2CatYema,
          label: '11. 2. Cat/yema',
          type: CartillaFieldType.dropdown,
          staticOptions: _catYemaOptions,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'yema_3',
      title: 'YEMA 3',
      fields: [
        CartillaFieldConfig(
          key: kY3Numero,
          label: '12. 3. Número de yema',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kY3Parametros,
          label: '13. 3. Parámetros',
          type: CartillaFieldType.dropdown,
          staticOptions: _parametrosOptions,
        ),
        CartillaFieldConfig(
          key: kY3CatYema,
          label: '14. 3. Cat/yema',
          type: CartillaFieldType.dropdown,
          staticOptions: _catYemaOptions,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'yema_4',
      title: 'YEMA 4',
      fields: [
        CartillaFieldConfig(
          key: kY4Numero,
          label: '15. 4. Número de yema',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kY4Parametros,
          label: '16. 4. Parámetros',
          type: CartillaFieldType.dropdown,
          staticOptions: _parametrosOptions,
        ),
        CartillaFieldConfig(
          key: kY4CatYema,
          label: '17. 4. Cat/yema',
          type: CartillaFieldType.dropdown,
          staticOptions: _catYemaOptions,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'yema_5',
      title: 'YEMA 5',
      fields: [
        CartillaFieldConfig(
          key: kY5Numero,
          label: '18. 5. Número de yema',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kY5Parametros,
          label: '19. 5. Parámetros',
          type: CartillaFieldType.dropdown,
          staticOptions: _parametrosOptions,
        ),
        CartillaFieldConfig(
          key: kY5CatYema,
          label: '20. 5. Cat/yema',
          type: CartillaFieldType.dropdown,
          staticOptions: _catYemaOptions,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'yema_6',
      title: 'YEMA 6',
      fields: [
        CartillaFieldConfig(
          key: kY6Numero,
          label: '21. 6. Número de yema',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kY6Parametros,
          label: '22. 6. Parámetros',
          type: CartillaFieldType.dropdown,
          staticOptions: _parametrosOptions,
        ),
        CartillaFieldConfig(
          key: kY6CatYema,
          label: '23. 6. Cat/yema',
          type: CartillaFieldType.dropdown,
          staticOptions: _catYemaOptions,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'yema_7',
      title: 'YEMA 7',
      fields: [
        CartillaFieldConfig(
          key: kY7Numero,
          label: '24. 7. Número de yema',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kY7Parametros,
          label: '25. 7. Parámetros',
          type: CartillaFieldType.dropdown,
          staticOptions: _parametrosOptions,
        ),
        CartillaFieldConfig(
          key: kY7CatYema,
          label: '26. 7. Cat/yema',
          type: CartillaFieldType.dropdown,
          staticOptions: _catYemaOptions,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'final',
      title: 'OBSERVACIONES Y FOTOS',
      fields: [
        CartillaFieldConfig(
          key: kObservaciones,
          label: '27. Observaciones',
          type: CartillaFieldType.longText,
        ),
        // Nota: tipo foto depende de tu enum real. Si tu proyecto usa PhotoSlotField,
        // cambia type a tu tipo de foto (ej: CartillaFieldType.photoSlot / photo).
        CartillaFieldConfig(
          key: kFoto1,
          label: '28. Foto 1',
          type: CartillaFieldType.photo,
        ),
        CartillaFieldConfig(
          key: kFoto2,
          label: '29. Foto 2',
          type: CartillaFieldType.photo,
        ),
        CartillaFieldConfig(
          key: kFoto3,
          label: '30. Foto 3',
          type: CartillaFieldType.photo,
        ),
        CartillaFieldConfig(
          key: kFoto4,
          label: '31. Foto 4',
          type: CartillaFieldType.photo,
        ),
        CartillaFieldConfig(
          key: kFoto5,
          label: '32. Foto 5',
          type: CartillaFieldType.photo,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
