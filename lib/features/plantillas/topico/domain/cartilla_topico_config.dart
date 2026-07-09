import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaTopicoConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_topico';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const String kLoteId = 'loteId';
  static const String kPacienteId = 'pacienteId';
  static const String kPacienteNombre = 'pacienteNombre';
  static const String kEmpresa = 'empresa';
  static const String kCultivo = 'cultivo';
  static const String kDni = 'dni';
  static const String kPlanilla = 'planilla';
  static const String kGenero = 'genero';
  static const String kCargo = 'cargo';
  static const String kArea = 'area';
  static const String kConsulta = 'consulta';
  static const String kMedicamento = 'medicamento';
  static const String kAptitud = 'aptitud';
  static const String kTipoAtencion = 'tipoAtencion';
  static const String kDiagnosticoObservacion = 'diagnosticoObservacion';
  static const String kFirma = 'firma';

  static const Set<String> _headerKeys = {kLoteId};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {kLoteId};
  static const Set<String> _plusOneBodyKeys = {
    kEmpresa,
    kCultivo,
    kTipoAtencion,
  };

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static const List<String> aptitudOptions = ['APTO', 'NO APTO'];
  static const List<String> tipoAtencionOptions = ['INCIDENTE', 'ACCIDENTE'];

  static const List<CartillaSectionConfig> _sections = [
    CartillaSectionConfig(
      key: 'datos_paciente',
      title: 'DATOS DEL PACIENTE',
      fields: [
        CartillaFieldConfig(
          key: kPacienteId,
          label: 'Paciente',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.topicoPacientes,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kPacienteNombre,
          label: 'Paciente nombre',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(readOnly: true),
        ),
        CartillaFieldConfig(
          key: kEmpresa,
          label: 'Empresa',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.topicoEmpresas,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kLoteId,
          label: 'Fundo GPS',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCultivo,
          label: 'Cultivo',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.cultivos,
          rules: CartillaFieldRules(readOnly: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kDni,
          label: 'DNI',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(readOnly: true),
        ),
        CartillaFieldConfig(
          key: kPlanilla,
          label: 'Planilla',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(readOnly: true),
        ),
        CartillaFieldConfig(
          key: kGenero,
          label: 'Genero',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(readOnly: true),
        ),
        CartillaFieldConfig(
          key: kCargo,
          label: 'Cargo',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(readOnly: true),
        ),
        CartillaFieldConfig(
          key: kArea,
          label: 'Area',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(readOnly: true),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'atencion',
      title: 'ATENCION',
      fields: [
        CartillaFieldConfig(
          key: kConsulta,
          label: 'Consulta',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.topicoConsultas,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kMedicamento,
          label: 'Medicamentos',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.topicoMedicamentos,
        ),
        CartillaFieldConfig(
          key: kAptitud,
          label: 'Aptitud',
          type: CartillaFieldType.dropdown,
          staticOptions: aptitudOptions,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: kTipoAtencion,
          label: 'Tipo de atencion',
          type: CartillaFieldType.dropdown,
          staticOptions: tipoAtencionOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kDiagnosticoObservacion,
          label: 'Diagnostico / observacion',
          type: CartillaFieldType.longText,
        ),
        CartillaFieldConfig(
          key: kFirma,
          label: 'Firma',
          type: CartillaFieldType.signaturePad,
          rules: CartillaFieldRules(required: true),
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
