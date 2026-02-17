import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaLongBroteRacimoConfig implements CartillaFormConfig {
  static const String templateKeyStatic = 'cartilla_long_brote_racimo';
  static const int payloadVersionStatic = 1;

  // Header mínimo estándar (como Brotación/Fito)
  static const String kCampaniaId = 'campaniaId';
  static const String kLoteId = 'loteId';
  static const String kLat = 'lat';
  static const String kLon = 'lon';
  static const String kFechaEjecucion = 'fechaEjecucion';

  // Campos propios (van a BODY)
  static const String kCantidadMuestras = 'cantidadMuestras';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';
  static const String kCorresponde = 'corresponde';

  static const String kTotalRacimoEvaluado = 'total_racimo_evaluado';
  static const String kPromLongPlantaRacimo = 'prom_long_x_planta_racimo';

  @override
  String get templateKey => templateKeyStatic;

  @override
  int get payloadVersion => payloadVersionStatic;

  // ✅ SOLO header estructural
  @override
  Set<String> get headerKeys => {
    kCampaniaId,
    kLoteId,
    kLat,
    kLon,
    kFechaEjecucion,
  };

  @override
  List<String> get etapaFenologicaOptions => const [];

  // ✅ +1: copia lo copiables del config
  // Header: se copia campania/lote + geo si quieres
  @override
  Set<String> get plusOneReplicableHeaderKeys => {
    kCampaniaId,
    kLoteId,
    kLat,
    kLon,
  };

  // Body: copiables según reglas (copyOnPlus1)
  @override
  Set<String> get plusOneReplicableBodyKeys => {
    kCantidadMuestras,
    kCorresponde,
  };

  @override
  List<CartillaSectionConfig> get sections => [
    // =====================
    // DATOS (visual)
    // =====================
    CartillaSectionConfig(
      key: 'header_visual',
      title: 'Datos de la Muestra',
      fields: const [
        CartillaFieldConfig(
          key: kLoteId,
          label: 'Lote',
          type: CartillaFieldType.dropdown,
          // Si tu motor soporta catalogSource, puedes habilitarlo:
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCantidadMuestras,
          label: 'Cantidad de Muestras',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true),
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
        CartillaFieldConfig(
          key: kCampaniaId,
          label: 'Campaña',
          type: CartillaFieldType.dropdown,
          staticOptions: ['2026'],
          // Si tu motor soporta catalogSource:
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCorresponde,
          label: 'Corresponde',
          type: CartillaFieldType.dropdown,
          staticOptions: ['REPORDA', 'PODA', 'NINGUNO'],
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
      ],
    ),

    // =====================
    // LONG.BROTE 1..120
    // =====================
    _sectionBrote('brote_1_25', 'LONG.BROTE 1 a 25cm', 1, 25),
    _sectionBrote('brote_26_50', 'LONG.BROTE 26 a 50cm', 26, 50),
    _sectionBrote('brote_51_75', 'LONG.BROTE 51 a 75cm', 51, 75),
    _sectionBrote('brote_76_100', 'LONG.BROTE 76 a 100cm', 76, 100),
    _sectionBrote('brote_101_120', 'LONG.BROTE 101 a 120cm', 101, 120),

    // =====================
    // LONG.RACIMO R1..R25
    // =====================
    _sectionRacimo('racimo_1_25', 'LONG.RACIMO 1 a 25cm', 1, 25),

    CartillaSectionConfig(
      key: 'calculos_racimo',
      title: 'CÁLCULOS RACIMO',
      fields: const [
        CartillaFieldConfig(
          key: kTotalRacimoEvaluado,
          label: '148. Total de racimo evaluado',
          type: CartillaFieldType.decimalReadOnly,
          rules: CartillaFieldRules(required: false),
        ),
        CartillaFieldConfig(
          key: kPromLongPlantaRacimo,
          label: '149. Prom. de long. x planta - RACIMO',
          type: CartillaFieldType.decimalReadOnly,
          rules: CartillaFieldRules(required: false),
        ),
      ],
    ),

  ];

  // Helpers internos (igual estilo que tu config actual)
  static CartillaSectionConfig _sectionBrote(
      String key,
      String title,
      int from,
      int to,
      ) {
    return CartillaSectionConfig(
      key: key,
      title: title,
      fields: List.generate(to - from + 1, (i) {
        final n = from + i;
        return CartillaFieldConfig(
          key: 'long_brote_$n',
          label: '$n CM',
          type: CartillaFieldType.stepperInt,
          rules: const CartillaFieldRules(minValue: 0),
        );
      }),
    );
  }

  static CartillaSectionConfig _sectionRacimo(
      String key,
      String title,
      int from,
      int to,
      ) {
    return CartillaSectionConfig(
      key: key,
      title: title,
      fields: List.generate(to - from + 1, (i) {
        final n = from + i;
        return CartillaFieldConfig(
          key: 'long_racimo_$n',
          label: 'R$n CM',
          type: CartillaFieldType.stepperInt,
          rules: const CartillaFieldRules(minValue: 0),
        );
      }),
    );
  }



}
