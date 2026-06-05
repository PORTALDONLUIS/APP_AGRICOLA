import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaMovilidadesCosechaConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_movilidades_cosecha';
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
  static const String kSector = 'sector';
  static const String kCantidadCajas = 'cantidadCajas';
  static const String kVariedad = 'variedad';
  static const String kSupervisor = 'supervisor';
  static const String kSerieGuia = 'serieGuia';
  static const String kNroGuia = 'nroGuia';
  static const String kHoraInicioCarga = 'horaInicioCarga';
  static const String kTipoContenedor = 'tipoContenedor';
  static const String kNroPrecinto = 'nroPrecinto';
  static const String kNombreProveedor = 'nombreProveedor';
  static const String kChofer = 'chofer';
  static const String kMarca = 'marca';
  static const String kPlaca = 'placa';
  static const String kPiso = 'piso';
  static const String kTecho = 'techo';
  static const String kPared = 'pared';
  static const String kToldo = 'toldo';
  static const String kInsumosLimpieza = 'insumosLimpieza';
  static const String kVerificacionCamion = 'verificacionCamion';
  static const String kObservaciones = 'observaciones';
  static const String kFinHoraCarga = 'finHoraCarga';

  static const Set<String> _headerKeys = {kLoteId, kCampaniaId};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {kLoteId, kCampaniaId};

  static const Set<String> _plusOneBodyKeys = {
    kFecha,
    kSector,
    kVariedad,
    kSupervisor,
  };

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static const List<String> _contenedorOptions = ['JABAS', 'BINES'];
  static const List<String> _limpiezaOptions = [
    'PRESENCIA DE ABERTURAS',
    'LIMPIEZA',
  ];
  static const List<String> _insumosOptions = [
    'ESCOBILLON',
    'AGUA',
    'DESINFECTANTE',
  ];
  static const List<String> _verificacionOptions = ['APTO', 'NO APTO'];

  static const List<CartillaSectionConfig> _sections = [
    CartillaSectionConfig(
      key: 'datos_generales',
      title: 'DATOS GENERALES',
      fields: [
        CartillaFieldConfig(
          key: kFecha,
          label: '1. Fecha',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kSector,
          label: '2. Sector',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kLoteId,
          label: '3. Lote',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCantidadCajas,
          label: '4. Cantidad Cajas',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kVariedad,
          label: '5. Variedad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.variedades,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kSupervisor,
          label: '6. Seleccionar Supervisor',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasSupervisor,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
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
      key: 'datos_guia',
      title: 'DATOS DE LA GUIA',
      fields: [
        CartillaFieldConfig(
          key: kSerieGuia,
          label: '7. Serie Guia',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kNroGuia,
          label: '8. Nro. Guia',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kHoraInicioCarga,
          label: '9. Hora de Inicio Carga',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'tipo_contenedor',
      title: 'TIPO DE CONTENEDOR',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kTipoContenedor,
          label: '10. Tipo de contenedor',
          type: CartillaFieldType.dropdown,
          staticOptions: _contenedorOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kNroPrecinto,
          label: '11. Nro de Precinto',
          type: CartillaFieldType.shortText,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'datos_camion',
      title: 'DATOS DEL CAMION',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kNombreProveedor,
          label: '1. Nombre del Proveedor',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kChofer,
          label: '2. Chofer',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kMarca,
          label: '3. Marca',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kPlaca,
          label: '4. Placa',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'estado_limpieza',
      title: 'ESTADO Y LIMPIEZA DEL CAMION',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kPiso,
          label: '5. Piso',
          type: CartillaFieldType.multiSelectChips,
          staticOptions: _limpiezaOptions,
        ),
        CartillaFieldConfig(
          key: kTecho,
          label: '6. Techo',
          type: CartillaFieldType.multiSelectChips,
          staticOptions: _limpiezaOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kPared,
          label: '7. Pared',
          type: CartillaFieldType.multiSelectChips,
          staticOptions: _limpiezaOptions,
        ),
        CartillaFieldConfig(
          key: kToldo,
          label: '8. Toldo',
          type: CartillaFieldType.multiSelectChips,
          staticOptions: _limpiezaOptions,
        ),
        CartillaFieldConfig(
          key: kInsumosLimpieza,
          label: '9. Insumos que se empleo para limpieza',
          type: CartillaFieldType.multiSelectChips,
          staticOptions: _insumosOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kVerificacionCamion,
          label: '10. Verificación del Camión',
          type: CartillaFieldType.dropdown,
          staticOptions: _verificacionOptions,
          rules: CartillaFieldRules(required: true),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'observacion',
      title: 'OBSERVACION',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kObservaciones,
          label: '11. Observaciones',
          type: CartillaFieldType.longText,
        ),
        CartillaFieldConfig(
          key: kFinHoraCarga,
          label: '12. Fin Hora de Carga',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true),
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
          label: '13. FOTO 1',
          type: CartillaFieldType.photo,
          photoIndex: 1,
        ),
        CartillaFieldConfig(
          key: 'foto2',
          label: '14. FOTO 2',
          type: CartillaFieldType.photo,
          photoIndex: 2,
        ),
        CartillaFieldConfig(
          key: 'foto3',
          label: '15. FOTO 3',
          type: CartillaFieldType.photo,
          photoIndex: 3,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
