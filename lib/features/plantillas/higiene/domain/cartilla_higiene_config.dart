import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaHigieneConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_higiene';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const String kLoteId = 'loteId';
  static const String kCampaniaId = 'campaniaId';

  static const String kControlCalidad = 'controlCalidad';
  static const String kResponsableArea = 'responsableArea';
  static const String kSupervisor = 'supervisor';
  static const String kPersonalEvaluadoDni = 'personalEvaluadoDni';
  static const String kPersonalEvaluadoNombres = 'personalEvaluadoNombres';
  static const String kCabelloProtegido = 'cabelloProtegido';
  static const String kCondicionBarba = 'condicionBarba';
  static const String kCondicionUnas = 'condicionUnas';
  static const String kCondicionManos = 'condicionManos';
  static const String kVestimentaAdecuada = 'vestimentaAdecuada';
  static const String kPresentaAlhajas = 'presentaAlhajas';
  static const String kPresenciaMaquillaje = 'presenciaMaquillaje';
  static const String kComportamiento = 'comportamiento';
  static const String kObservaciones = 'observaciones';
  static const String kFoto1 = 'foto1';
  static const String kFoto2 = 'foto2';
  static const String kFoto3 = 'foto3';
  static const String kFirmaControlCalidad = 'firmaControlCalidad';
  static const String kFirmaSupervisor = 'firmaSupervisor';

  static const Set<String> _headerKeys = {kLoteId, kCampaniaId};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _siNoOptions = ['SI', 'NO'];

  static const List<String> _responsableAreaOptions = [
    'JESSICA HERNANDEZ',
    'ALVIN GOMEZ',
    'FERNANDO ANDRADE',
  ];

  static const List<String> _condicionBarbaOptions = [
    'BARBA EXPUESTA',
    'BARBA TAPADA / SIN BARBA',
    'NO APLICA',
  ];

  static const List<String> _condicionUnasOptions = [
    'LARGAS',
    'SUCIAS',
    'EN BUENAS CONDICIONES',
    'CON ESMALTE',
  ];

  static const List<String> _condicionManosOptions = [
    'SUCIAS',
    'CON HERIDAS',
    'EN BUENAS CONDICIONES',
  ];

  static const List<String> _comportamientoOptions = [
    'BUENA',
    'REGULAR',
    'MALA',
  ];

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {kLoteId, kCampaniaId};

  static const Set<String> _plusOneBodyKeys = {
    kControlCalidad,
    kResponsableArea,
    kSupervisor,
  };

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

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
          key: kControlCalidad,
          label: '2. Seleccionar Responsable de Inspección',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasResponsableInspeccion,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kResponsableArea,
          label: '3. Responsable del Area',
          type: CartillaFieldType.dropdown,
          staticOptions: _responsableAreaOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kSupervisor,
          label: '4. Seleccionar Supervisor',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasSupervisor,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kPersonalEvaluadoDni,
          label: '5. Personal Evaluado - DNI',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 8),
        ),
        CartillaFieldConfig(
          key: kPersonalEvaluadoNombres,
          label: '5. Personal Evaluado - Apellidos y nombres',
          type: CartillaFieldType.longText,
          rules: CartillaFieldRules(required: true),
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
      key: 'higiene_personal',
      title: 'HIGIENE PERSONAL',
      fields: [
        CartillaFieldConfig(
          key: kCabelloProtegido,
          label: '6. Cabello protegido',
          type: CartillaFieldType.dropdown,
          staticOptions: _siNoOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kCondicionBarba,
          label: '7. Condicion de barba',
          type: CartillaFieldType.dropdown,
          staticOptions: _condicionBarbaOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kCondicionUnas,
          label: '8. Condicion de unas',
          type: CartillaFieldType.multiSelectChips,
          staticOptions: _condicionUnasOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kCondicionManos,
          label: '9. Condicion de manos',
          type: CartillaFieldType.multiSelectChips,
          staticOptions: _condicionManosOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kVestimentaAdecuada,
          label: '10. Vestimenta adecuada',
          type: CartillaFieldType.dropdown,
          staticOptions: _siNoOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kPresentaAlhajas,
          label: '11. Presenta alhajas',
          type: CartillaFieldType.dropdown,
          staticOptions: _siNoOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kPresenciaMaquillaje,
          label: '12. Presencia de maquillaje',
          type: CartillaFieldType.dropdown,
          staticOptions: _siNoOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kComportamiento,
          label: '13. Comportamiento',
          type: CartillaFieldType.dropdown,
          staticOptions: _comportamientoOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kObservaciones,
          label: '14. Observaciones',
          type: CartillaFieldType.longText,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'evidencias',
      title: 'EVIDENCIAS Y FIRMAS',
      fields: [
        CartillaFieldConfig(
          key: kFoto1,
          label: '15. Foto 1',
          type: CartillaFieldType.photo,
          photoIndex: 1,
        ),
        CartillaFieldConfig(
          key: kFoto2,
          label: '16. Foto 2',
          type: CartillaFieldType.photo,
          photoIndex: 2,
        ),
        CartillaFieldConfig(
          key: kFoto3,
          label: '17. Foto 3',
          type: CartillaFieldType.photo,
          photoIndex: 3,
        ),
        CartillaFieldConfig(
          key: kFirmaControlCalidad,
          label: '18. Control de Calidad - Firma',
          type: CartillaFieldType.signaturePad,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kFirmaSupervisor,
          label: '19. Supervisor - Firma',
          type: CartillaFieldType.signaturePad,
          rules: CartillaFieldRules(required: true),
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
