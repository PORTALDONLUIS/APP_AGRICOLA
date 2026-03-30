// lib/features/conteo_racimos/domain/cartilla_conteo_racimos_config.dart

import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaConteoRacimosConfig implements CartillaFormConfig {
  static const String templateKeyStatic = 'cartilla_conteo_racimos';
  static const int payloadVersionStatic = 1;

  // ===== Header mínimo estándar (como Brotación) =====
  static const String kCampaniaId = 'campaniaId';
  static const String kLoteId = 'loteId';
  static const String kLat = 'lat';
  static const String kLon = 'lon';
  static const String kFechaEjecucion = 'fechaEjecucion';

  // ===== Body keys (propias de la cartilla) =====
  static const String kVariedad = 'variedad';

  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';

  // Racimos (dos pares según el manual: 6-7 y 8-9) :contentReference[oaicite:5]{index=5}
  static const String kRacimoSimple1 = 'racimo_simple_1';
  static const String kRacimoDoble1  = 'racimo_doble_1';
  static const String kRacimoSimple2 = 'racimo_simple_2';
  static const String kRacimoDoble2  = 'racimo_doble_2';

  // Calculados
  static const String kTotalSD = 'total_sd'; // 10
  static const String kRacimoIndefinido = 'racimo_indefinido'; // 11
  static const String kRacimoCorrido    = 'racimo_corrido';    // 12
  static const String kTotal            = 'total';             // 13

  static const String kObservaciones = 'observaciones'; // 14

  @override
  String get templateKey => templateKeyStatic;

  @override
  int get payloadVersion => payloadVersionStatic;

  // ✅ HeaderKeys SOLO lo estructural (Brotación estándar)
  @override
  Set<String> get headerKeys => {
    kCampaniaId,
    kLoteId,
    kLat,
    kLon,
    kFechaEjecucion,
  };

  // Campañas: el manual dice que se inicia con 2026 :contentReference[oaicite:6]{index=6}
  static const List<String> _campanias = ['CAMP2026'];

  static const List<String> _variedadOptions = [
    'AUTUMN CRIPS',
    'MOSCATEL',
    'SWEET GLOBE',
    'SUGRA 56',
  ];


  @override
  List<String> get etapaFenologicaOptions => const [];

  // ✅ +1 replica Lote, Variedad, Campaña :contentReference[oaicite:7]{index=7}
  @override
  Set<String> get plusOneReplicableHeaderKeys => {
    kCampaniaId,
    kLoteId,
    kLat,
    kLon, // opcional; si no quieres, quítalo
  };

  @override
  Set<String> get plusOneReplicableBodyKeys => {
    kVariedad,
  };

  @override
  List<CartillaSectionConfig> get sections => [
    CartillaSectionConfig(
      key: 'datos_generales',
      title: 'DATOS GENERALES',
      fields: const [
        // 1) Lote: lista de lotes, obligatorio y replicable con +1 :contentReference[oaicite:8]{index=8}
        CartillaFieldConfig(
          key: kLoteId,
          label: '1. Lote',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),

        // 2) Variedad: lista desplegable dependiente del Lote, obligatorio y replicable con +1 :contentReference[oaicite:9]{index=9}
        // Nota: el "depende del lote" se resuelve con tu provider de variedades.
        CartillaFieldConfig(
          key: kVariedad,
          label: '2. Variedad',
          type: CartillaFieldType.dropdown,
          // Si ya tienes un catalogSource para variedades, úsalo aquí.
          // catalogSource: CartillaCatalogSource.variedades,
          staticOptions: _variedadOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),

        // 3) Campaña: estático, obligatorio y replicable con +1 :contentReference[oaicite:10]{index=10}
        CartillaFieldConfig(
          key: kCampaniaId,
          label: '3. Campaña',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),

        // 4) Hilera: entero, 2 cifras, obligatorio :contentReference[oaicite:11]{index=11}
        CartillaFieldConfig(
          key: kHilera,
          label: '4. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),

        // 5) Nro de Planta: entero, 3 cifras, obligatorio :contentReference[oaicite:12]{index=12}
        CartillaFieldConfig(
          key: kPlanta,
          label: '5. Nro. de Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'racimos',
      title: 'RACIMOS',
      fields: const [
        // 6-7: Racimo Simple/Doble (obligatorios, stepper) :contentReference[oaicite:13]{index=13}
        CartillaFieldConfig(
          key: kRacimoSimple1,
          label: '6. Racimo Simple',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kRacimoDoble1,
          label: '7. Racimo Doble',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),

        // 8-9: segundo par (obligatorios, stepper) :contentReference[oaicite:14]{index=14}
        CartillaFieldConfig(
          key: kRacimoSimple2,
          label: '8. Racimo Simple',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kRacimoDoble2,
          label: '9. Racimo Doble',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),

        // 10: Total S+D (decimal, fórmula) :contentReference[oaicite:15]{index=15}
        CartillaFieldConfig(
          key: kTotalSD,
          label: '10. Total S + D',
          type: CartillaFieldType.decimalReadOnly,
        ),

        // 11-12: obligatorios stepper :contentReference[oaicite:16]{index=16}
        CartillaFieldConfig(
          key: kRacimoIndefinido,
          label: '11. Racimo Indefinido',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),
        CartillaFieldConfig(
          key: kRacimoCorrido,
          label: '12. Racimo Corrido',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),

        // 13: Total (decimal, fórmula) :contentReference[oaicite:17]{index=17}
        CartillaFieldConfig(
          key: kTotal,
          label: '13. Total',
          type: CartillaFieldType.decimalReadOnly,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'obs',
      title: 'OBSERVACIONES',
      fields: const [
        CartillaFieldConfig(
          key: kObservaciones,
          label: '14. Observaciones',
          type: CartillaFieldType.longText,
          rules: CartillaFieldRules(required: false),
        ),
      ],
    ),
  ];
}
