import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaBrixMoscatelConfig implements CartillaFormConfig {
  // ========= Identidad =========
  static const String _templateKey = 'cartilla_brix_moscatel';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  // ========= Keys =========
  // HEADER
  static const String kLoteId = 'loteId';
  static const String kCampaniaId = 'campaniaId';

  // BODY
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';
  static const String kVariedad = 'variedad';
  static const String kCorresponde = 'corresponde';
  static const String kBrixSsc = 'brixSsc';

  // ========= Header keys =========
  static const Set<String> _headerKeys = {
    kLoteId,
    kCampaniaId,
  };

  @override
  Set<String> get headerKeys => _headerKeys;

  // ========= Opciones estáticas =========
  static const List<String> _correspondeOptions = [
    'REPORDA',
    'PODA',
    'NINGUNO',
  ];

  // Interface obliga esto (no aplica)
  static const List<String> _etapas = [];
  @override
  List<String> get etapaFenologicaOptions => _etapas;

  /// Id en la tabla local de variedades cuya descripción es MOSCATEL (insensible a mayúsculas).
  static int? resolveVariedadMoscatelId(List<dynamic> rows) {
    for (final x in rows) {
      try {
        final m = (x as dynamic).toJson().cast<String, dynamic>();
        final desc = (m['descripcion'] ?? '').toString().trim().toUpperCase();
        if (desc == 'MOSCATEL') {
          final idRaw = m['id'];
          if (idRaw is int) return idRaw;
          return int.tryParse(idRaw.toString());
        }
      } catch (_) {}
    }
    return null;
  }

  // ========= (+1) replicables =========
  // Manual: replica Lote, Corresponde, Campaña y variedad (id desde catálogo).
  static const Set<String> _plusOneHeaderKeys = {
    kLoteId,
    kCampaniaId,
  };

  static const Set<String> _plusOneBodyKeys = {
    kCorresponde,
    kVariedad,
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
          key: kHilera,
          label: '2. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),
        CartillaFieldConfig(
          key: kPlanta,
          label: '3. Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
        CartillaFieldConfig(
          key: kVariedad,
          label: '4. Variedad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.variedades,
          rules: CartillaFieldRules(
            required: true,
            copyOnPlus1: true,
            readOnly: true,
          ),
        ),
        CartillaFieldConfig(
          key: kCorresponde,
          label: '5. Corresponde',
          type: CartillaFieldType.dropdown,
          staticOptions: _correspondeOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCampaniaId,
          label: '6. Campaña',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'medicion',
      title: 'MEDICIÓN',
      fields: [
        CartillaFieldConfig(
          key: kBrixSsc,
          label: '7. Brix - SSC',
          type: CartillaFieldType.decimalNumber,
          rules: CartillaFieldRules(required: true),
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}