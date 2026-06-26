import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaRegistroMotorizadoSeguridadConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_registro_motorizado_seguridad';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const String kMotivo = 'motivo';
  static const String kFundo = 'fundo';
  static const String kFotoEvidencia = 'fotoEvidencia';
  static const String kFotoEvidencia2 = 'fotoEvidencia2';
  static const String kObservaciones = 'observaciones';

  static const Set<String> _headerKeys = {};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {};
  static const Set<String> _plusOneBodyKeys = {kMotivo, kFundo};

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static const List<String> motivoOptions = [
    'RONDA MOTORIZADA',
    'RONDA PIE',
    'RONDA SUPERVISION',
    'RONDA DE ENCARGATURA',
    'RONDA DE JEFATURA',
    'RONDA ALMACEN',
    'RONDA CCTV',
  ];

  static const List<String> fundoOptions = [
    'FLORESTA',
    'LA BORDA',
    'LA ANGOSTURA',
    'CHAVALINA I',
    'CHAVALINA II',
    'CHALINA III',
    'CERRO BLANCO I',
    'POZO 44',
    'LIMONCILLO',
    'CAYETANO',
    'OLACHEA',
    'CABILDO',
    'CHURRUTINA I',
    'CHURRUTINA II',
    'CHURRUTINA III',
    'CHURRUTINA IV',
    'CHURRUTINA V',
    'CHURRUTINA VI',
    'CHURRUTINA VII',
    'CHURRUTINA IX',
    'MATTA',
    'RONDA INTERNA',
    'RONDA EXTERNA',
    'CERRO VERDE',
    'RIZO',
  ];

  static const List<CartillaSectionConfig> _sections = [
    CartillaSectionConfig(
      key: 'datos_generales',
      title: 'DATOS GENERALES',
      fields: [
        CartillaFieldConfig(
          key: kMotivo,
          label: '1. Motivo',
          type: CartillaFieldType.dropdown,
          staticOptions: motivoOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kFundo,
          label: '2. Fundo',
          type: CartillaFieldType.dropdown,
          staticOptions: fundoOptions,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kFotoEvidencia,
          label: '3. Foto evidencia',
          type: CartillaFieldType.photo,
          photoIndex: 1,
        ),
        CartillaFieldConfig(
          key: kFotoEvidencia2,
          label: '4. Foto evidencia 2',
          type: CartillaFieldType.photo,
          photoIndex: 2,
        ),
        CartillaFieldConfig(
          key: kObservaciones,
          label: '5. Observaciones',
          type: CartillaFieldType.longText,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
