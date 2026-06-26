import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaRegistroPersonalGaritaSeguridadConfig
    implements CartillaFormConfig {
  static const String _templateKey =
      'cartilla_registro_personal_garita_seguridad';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const String kDni = 'dni';
  static const String kApellidosNombres = 'apellidosNombres';
  static const String kVisitante = 'visitante';
  static const String kTransportista = 'transportista';
  static const String kMotivo = 'motivo';
  static const String kFundo = 'fundo';
  static const String kArea = 'area';
  static const String kTipoVehiculo = 'tipoVehiculo';
  static const String kLicencia = 'licencia';
  static const String kFotoLicencia = 'fotoLicencia';
  static const String kSoat = 'soat';
  static const String kFotoSoat = 'fotoSoat';
  static const String kPlaca = 'placa';
  static const String kFotoVehiculo = 'fotoVehiculo';
  static const String kFotoEvidencia = 'fotoEvidencia';
  static const String kObservaciones = 'observaciones';

  static const Set<String> _headerKeys = {};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {};
  static const Set<String> _plusOneBodyKeys = {kMotivo, kFundo, kArea};

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static const List<String> siNoOptions = ['SI', 'NO'];
  static const List<String> motivoOptions = ['INGRESO', 'RETIRO'];
  static const List<String> tipoVehiculoOptions = [
    'AUTO',
    'CAMIONETA',
    'CAMION',
    'MOTO',
    'TRACTOR',
    'BICICLETA',
  ];

  static const List<String> fundoOptions = [
    'FLORESTA',
    'SANTA CRUZ',
    'TOLEDO',
    'CHAVALINA',
    'OLAECHEA',
    'CERRO BLANCO 1',
    'CERRO BLANCO 2',
    'CERRO BLANCO 3',
    'LIMONCILLO',
    'CAYETANO',
    'RIZO',
    'LA ANGOSTURA',
    'LA BORDA',
    'CABILDO',
  ];

  static const List<String> areaOptions = [
    'RRHH',
    'CONTABILIDAD',
    'TIC',
    'LOGISTICA',
    'GERENCIA',
    'SEGURIDAD',
    'PATRIMONIAL',
    'COSTOS',
    'ALMACEN',
    'ENFERMERIA',
    'PRODUCCION UVA - FERNANDO',
    'EVALUACIONES',
    'CALIDAD',
    'APLICACIONES',
    'RIEGO - JESSICA',
    'PRODUCCION PALTA',
  ];

  static const List<CartillaSectionConfig> _sections = [
    CartillaSectionConfig(
      key: 'datos_persona',
      title: 'DATOS DE PERSONA',
      fields: [
        CartillaFieldConfig(
          key: kDni,
          label: '1. DNI',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true, maxDigits: 8),
        ),
        CartillaFieldConfig(
          key: kApellidosNombres,
          label: 'Apellidos y nombres',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kVisitante,
          label: '2. Visitante',
          type: CartillaFieldType.dropdown,
          staticOptions: siNoOptions,
        ),
        CartillaFieldConfig(
          key: kTransportista,
          label: '3. Transportista',
          type: CartillaFieldType.dropdown,
          staticOptions: siNoOptions,
        ),
        CartillaFieldConfig(
          key: kMotivo,
          label: '4. Motivo',
          type: CartillaFieldType.dropdown,
          staticOptions: motivoOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kFundo,
          label: '5. Fundo',
          type: CartillaFieldType.dropdown,
          staticOptions: fundoOptions,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kArea,
          label: '6. Area',
          type: CartillaFieldType.dropdown,
          staticOptions: areaOptions,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'datos_vehiculo',
      title: 'DATOS DEL VEHICULO',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kTipoVehiculo,
          label: '7. Tipo de vehiculo',
          type: CartillaFieldType.dropdown,
          staticOptions: tipoVehiculoOptions,
        ),
        CartillaFieldConfig(
          key: kLicencia,
          label: '8. Licencia',
          type: CartillaFieldType.dropdown,
          staticOptions: siNoOptions,
        ),
        CartillaFieldConfig(
          key: kFotoLicencia,
          label: '9. Foto licencia',
          type: CartillaFieldType.photo,
          photoIndex: 1,
        ),
        CartillaFieldConfig(
          key: kSoat,
          label: '10. SOAT',
          type: CartillaFieldType.dropdown,
          staticOptions: siNoOptions,
        ),
        CartillaFieldConfig(
          key: kFotoSoat,
          label: '11. Foto SOAT',
          type: CartillaFieldType.photo,
          photoIndex: 2,
        ),
        CartillaFieldConfig(
          key: kPlaca,
          label: '12. Placa',
          type: CartillaFieldType.shortText,
        ),
        CartillaFieldConfig(
          key: kFotoVehiculo,
          label: '13. Foto vehiculo',
          type: CartillaFieldType.photo,
          photoIndex: 3,
        ),
        CartillaFieldConfig(
          key: kFotoEvidencia,
          label: '14. Foto evidencia',
          type: CartillaFieldType.photo,
          photoIndex: 4,
        ),
        CartillaFieldConfig(
          key: kObservaciones,
          label: '15. Observaciones',
          type: CartillaFieldType.longText,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
