import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaBrotacionConfig implements CartillaFormConfig {
  // ========= Identidad =========
  static const String _templateKey = 'cartilla_brotacion';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  // ========= Keys =========
  // ✅ HEADER estándar (solo lo estructural que quieres en header)
  static const String kLoteId = 'loteId'; // header
  static const String kCampaniaId = 'campaniaId'; // header (id campaña)

  // ✅ BODY (datos generales de esta cartilla)
  static const String kVariedad = 'variedad';
  static const String kCantidadMuestras = 'cantidadMuestras';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';
  static const String kCorresponde = 'corresponde';

  // BODY (brotación)
  static const String kYemaHinchada = 'yemaHinchada';
  static const String kBotonAlgodonoso = 'botonAlgodonoso';
  static const String kPuntaVerde = 'puntaVerde';
  static const String kHojasExtendidas = 'hojasExtendidas';
  static const String kYemasNecroticas = 'yemasNecroticas';
  static const String kTotalYemas = 'totalYemas';
  static const String kObservaciones = 'observaciones';

  // ========= Header keys (solo los que realmente viven en header) =========
  static const Set<String> _headerKeys = {
    kLoteId,
    kCampaniaId,
  };

  @override
  Set<String> get headerKeys => _headerKeys;

  // ========= Opciones estáticas =========
  static const List<String> _variedadOptions = [
    '01. AUTUMN CRIPS',
    '02. MOSCATEL',
    '03. SWEET GLOBE',
    '04. SUGRA 56',
  ];

  static const List<String> _correspondeOptions = [
    'PODA',
  ];

  // Interface obliga esto (en Brotación no aplica, devolvemos vacío)
  static const List<String> _etapas = [];
  @override
  List<String> get etapaFenologicaOptions => _etapas;

  // ========= (+1) replicables =========
  // Se replica: Lote, Campaña (header), Variedad/Cant.Muestras/Corresponde (body)
  static const Set<String> _plusOneHeaderKeys = {
    kLoteId,
    kCampaniaId,
  };

  static const Set<String> _plusOneBodyKeys = {
    kVariedad,
    kCantidadMuestras,
    kCorresponde,
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
        // ✅ LoteId es header (combo dinámico en UI si tu motor lo soporta)
        CartillaFieldConfig(
          key: kLoteId,
          label: '1. Lote',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),

        // ✅ Variedad va en BODY
        CartillaFieldConfig(
          key: kVariedad,
          label: '2. Variedad',
          type: CartillaFieldType.dropdown,
          staticOptions: _variedadOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),

        CartillaFieldConfig(
          key: kCantidadMuestras,
          label: '3. Cantidad de muestras',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),

        CartillaFieldConfig(
          key: kHilera,
          label: '4. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),

        CartillaFieldConfig(
          key: kPlanta,
          label: '5. Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),

        CartillaFieldConfig(
          key: kCorresponde,
          label: '6. Corresponde',
          type: CartillaFieldType.dropdown,
          staticOptions: _correspondeOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),

        // ✅ Campaña ahora es header.campaniaId (id campaña)
        // OJO: aquí NO ponemos staticOptions para permitir catálogo dinámico.
        CartillaFieldConfig(
          key: kCampaniaId,
          label: '7. Campaña',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'brotacion',
      title: 'BROTACION',
      fields: [
        CartillaFieldConfig(
          key: kYemaHinchada,
          label: '8. Cantidad Yema hinchada',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kBotonAlgodonoso,
          label: '9. Cantidad Botón algodonoso',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kPuntaVerde,
          label: '10. Cantidad Punta verde',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kHojasExtendidas,
          label: '11. Cantidad Hojas extendidas',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kYemasNecroticas,
          label: '12. Cantidad Yemas necróticas',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 0),
        ),

        CartillaFieldConfig(
          key: kTotalYemas,
          label: '13. Total de yemas',
          type: CartillaFieldType.intNumber,
        ),

        CartillaFieldConfig(
          key: kObservaciones,
          label: '14. Observaciones',
          type: CartillaFieldType.longText,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}