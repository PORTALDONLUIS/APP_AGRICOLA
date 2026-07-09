import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaObservacionesCampoConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_observaciones_campo';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const String kEmpresa = 'empresa';
  static const String kLoteId = 'loteId';
  static const String kFundo = 'fundo';
  static const String kFecha = 'fecha';
  static const String kHora = 'hora';
  static const String kSupervisorPrevencionista = 'supervisorPrevencionista';
  static const String kResponsable = 'responsable';
  static const String kHallazgos = 'hallazgos';
  static const String kFotoHallazgo = 'fotoHallazgo';
  static const String kCategoriaRiesgo = 'categoriaRiesgo';
  static const String kAcciones = 'acciones';
  static const String kFotoInmediata1 = 'fotoInmediata1';
  static const String kFotoInmediata2 = 'fotoInmediata2';
  static const String kRecomendaciones = 'recomendaciones';

  static const Set<String> _headerKeys = {kLoteId};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {kLoteId};
  static const Set<String> _plusOneBodyKeys = {kEmpresa, kFundo, kFecha, kHora};

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static const List<String> empresaOptions = [
    'SOCIEDAD AGRICOLA DON LUIS S.A',
    'AGROINDUSTRIA CAMPOVERDE S.A.C',
    'INVERSIONES AJS S.A.C',
  ];

  static const List<String> categoriaRiesgoOptions = [
    'RIESGO TRIVIAL',
    'RIESGO TOLERABLE',
    'RIESGO MODERADO',
    'RIESGO ALTO',
    'RIESGO MUY ALTO',
  ];

  static const List<CartillaSectionConfig> _sections = [
    CartillaSectionConfig(
      key: 'datos_generales',
      title: 'DATOS GENERALES',
      fields: [
        CartillaFieldConfig(
          key: kEmpresa,
          label: '1. Empresa',
          type: CartillaFieldType.dropdown,
          staticOptions: empresaOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kLoteId,
          label: '2. Lote',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kFundo,
          label: '3. Fundo',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(
            required: true,
            copyOnPlus1: true,
            readOnly: true,
          ),
        ),
        CartillaFieldConfig(
          key: kFecha,
          label: '4. Fecha',
          type: CartillaFieldType.date,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kHora,
          label: '5. Hora',
          type: CartillaFieldType.time,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kSupervisorPrevencionista,
          label: '6. Supervisor o prevencionista',
          type: CartillaFieldType.longText,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kResponsable,
          label: '7. Responsable',
          type: CartillaFieldType.longText,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'hallazgos',
      title: 'HALLAZGOS',
      fields: [
        CartillaFieldConfig(
          key: kHallazgos,
          label: '8. 1. Hallazgos',
          type: CartillaFieldType.longText,
        ),
        CartillaFieldConfig(
          key: kFotoHallazgo,
          label: '9. 1. Foto Hallazgo',
          type: CartillaFieldType.photo,
          photoIndex: 1,
        ),
        CartillaFieldConfig(
          key: kCategoriaRiesgo,
          label: '10. Categoria de riesgo',
          type: CartillaFieldType.dropdown,
          staticOptions: categoriaRiesgoOptions,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'acciones_inmediatas',
      title: 'ACCIONES INMEDIATAS',
      fields: [
        CartillaFieldConfig(
          key: kAcciones,
          label: '11. 2. Acciones',
          type: CartillaFieldType.longText,
        ),
        CartillaFieldConfig(
          key: kFotoInmediata1,
          label: '12. 2. Foto inmediata 1',
          type: CartillaFieldType.photo,
          photoIndex: 2,
        ),
        CartillaFieldConfig(
          key: kFotoInmediata2,
          label: '13. 2. Foto inmediata 2',
          type: CartillaFieldType.photo,
          photoIndex: 3,
        ),
        CartillaFieldConfig(
          key: kRecomendaciones,
          label: '14. Recomendaciones',
          type: CartillaFieldType.longText,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
