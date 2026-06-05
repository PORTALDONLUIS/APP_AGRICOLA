import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaPortabinCarretasConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_portabin_carretas';
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
  static const String kSupervisor = 'supervisor';
  static const String kTipoContenedor = 'tipoContenedor';
  static const String kNroBinJabas = 'nroBinJabas';
  static const String kOperario = 'operario';
  static const String kPiso = 'piso';
  static const String kMallaToldo = 'mallaToldo';
  static const String kInsumosLimpieza = 'insumosLimpieza';
  static const String kVerificacion = 'verificacion';
  static const String kAccionesCorrectivas = 'accionesCorrectivas';

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
    kSupervisor,
    kOperario,
  };

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static const List<String> _contenedorOptions = ['JABAS', 'BINES'];
  static const List<String> _limpiezaOptions = [
    'PRESENCIA DE ABERTURAS',
    'LIMPIO',
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
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kLoteId,
          label: '2. Lote',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kSector,
          label: '3. Sector',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kSupervisor,
          label: '4. Supervisor',
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
      key: 'datos_portabin',
      title: 'DATOS DEL PORTABIN/CARRETA',
      fields: [
        CartillaFieldConfig(
          key: kTipoContenedor,
          label: '5. Tipo de Contenedor',
          type: CartillaFieldType.dropdown,
          staticOptions: _contenedorOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kNroBinJabas,
          label: '6. N° de Bin/Jabas',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(minValue: 0),
        ),
        CartillaFieldConfig(
          key: kOperario,
          label: '7. Operario',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasOperario,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'limpieza',
      title: 'LIMPIEZA PORTABIN/CARRETA',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kPiso,
          label: '8. Piso',
          type: CartillaFieldType.multiSelectChips,
          staticOptions: _limpiezaOptions,
        ),
        CartillaFieldConfig(
          key: kMallaToldo,
          label: '9. Malla/Toldo',
          type: CartillaFieldType.multiSelectChips,
          staticOptions: _limpiezaOptions,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'insumos_verificacion',
      title: 'INSUMOS Y VERIFICACION',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kInsumosLimpieza,
          label: '10. Insumos que se empleó para limpieza',
          type: CartillaFieldType.multiSelectChips,
          staticOptions: _insumosOptions,
        ),
        CartillaFieldConfig(
          key: kVerificacion,
          label: '11. Verificación de la Portabin/Carreta',
          type: CartillaFieldType.dropdown,
          staticOptions: _verificacionOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kAccionesCorrectivas,
          label: '12. Acciones correctivas',
          type: CartillaFieldType.longText,
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
          label: '13. Foto 1',
          type: CartillaFieldType.photo,
          photoIndex: 1,
        ),
        CartillaFieldConfig(
          key: 'foto2',
          label: '14. Foto 2',
          type: CartillaFieldType.photo,
          photoIndex: 2,
        ),
        CartillaFieldConfig(
          key: 'foto3',
          label: '15. Foto 3',
          type: CartillaFieldType.photo,
          photoIndex: 3,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
