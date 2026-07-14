import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaInspeccionHerramientasEppConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_inspeccion_herramientas_epp';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const String kEmpresa = 'empresa';
  static const String kFecha = 'fecha';
  static const String kHora = 'hora';
  static const String kResponsableArea = 'responsableArea';
  static const String kRecomendacionDescripcion1 = 'recomendacionDescripcion1';
  static const String kRecomendacionDescripcion2 = 'recomendacionDescripcion2';
  static const String kRecomendacionDescripcion3 = 'recomendacionDescripcion3';
  static const String kResponsableTurnoDni = 'responsableTurnoDni';
  static const String kResponsableTurnoNombre = 'responsableTurnoNombre';
  static const String kResponsableTurnoFirma = 'responsableTurnoFirma';
  static const String kEncargadoInspeccion = 'encargadoInspeccion';
  static const String kFirmaEncargado = 'firmaEncargado';

  static const Set<String> _headerKeys = {};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {};
  static const Set<String> _plusOneBodyKeys = {
    kEmpresa,
    kFecha,
    kHora,
    kResponsableTurnoDni,
    kResponsableTurnoNombre,
    kResponsableTurnoFirma,
    kEncargadoInspeccion,
    kFirmaEncargado,
  };

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static const List<String> empresaOptions = [
    'SOCIEDAD AGRICOLA DON LUIS S.A',
    'AGROINDUSTRIA CAMPOVERDE S.A.C',
    'INVERSIONES AJS S.A.C',
  ];

  static const List<String> siNoOptions = ['SI', 'NO'];

  static const List<String> _preguntas = [
    '¿Existe un encargado responsable?',
    '¿El operario tiene su equipo completo de protección personal y lo utiliza durante el trabajo?',
    '¿Se ha capacitado y adiestrado a los trabajadores en el almacenamiento?',
    '¿Las tareas se ejecutan bajo la supervisión de un responsable de la actividad?',
    '¿Se encuentra correctamente señalizado?',
    '¿El almacén cuenta con estanterías y/o repisas suficientes para el almacenamiento de materiales equipos y herramientas en obra? ¿Se encuentran empotrados los estantes?',
    '¿El almacén se encuentra limpio y ordenado?',
    '¿El almacén cuenta con extintor en buen estado y señalizado? ¿Qué tipo es?',
    '¿El almacén cuenta con buena edificación?',
    '¿Se usa medios mecánicos de manipulación y traslado, cuando las cargas son mayores a 25 kg?',
    '¿Se encuentran rotulados e identificados todo los productos y equipos de uso en terreno y estas cuantas con su hoja de seguridad?',
    '¿Se encuentran rotulados e identificados todo los productos y equipos de uso en terreno y estas cuantas con su hoja de seguridad?',
    '¿Cuenta con equipos de emergencia, botiquin de primeros auxilios, camilla, lava ojos?',
    '¿La instalación eléctrica se encuentra en buen estado?',
    '¿Las herramientas punzo-cortantes se encuentran con estuches de seguridad?',
    '¿Las herramientas punzo-cortantes se encuentran con estuches de seguridad?',
    '¿Se cuenta con Kit antiderrame?',
    '¿Se cuenta con Kit antiderrame?',
    '¿Los pasadizos se encuentran libres?',
    '¿Se encuentra con stock de herramientas?',
    '¿Se cuenta con procedimiento de trabajo seguro?',
    '¿Cuenta con iluminación adecuada?',
  ];

  static String preguntaKey(int i) => 'pregunta${i}Respuesta';
  static String observacionesKey(int i) => 'pregunta${i}Observaciones';
  static String descripcion1Key(int i) => 'pregunta${i}Descripcion1';
  static String descripcion2Key(int i) => 'pregunta${i}Descripcion2';

  static int foto1Index(int i) => ((i - 1) * 2) + 1;
  static int foto2Index(int i) => ((i - 1) * 2) + 2;
  static int recomendacionFotoIndex(int i) => 44 + i;

  static List<CartillaFieldConfig> _preguntaFields(int i, String pregunta) {
    return [
      CartillaFieldConfig(
        key: preguntaKey(i),
        label: '$i. $pregunta',
        type: CartillaFieldType.dropdown,
        staticOptions: siNoOptions,
      ),
      CartillaFieldConfig(
        key: observacionesKey(i),
        label: '$i. Observaciones',
        type: CartillaFieldType.longText,
      ),
      CartillaFieldConfig(
        key: 'pregunta${i}Foto1',
        label: '$i. Foto 1',
        type: CartillaFieldType.photo,
        photoIndex: foto1Index(i),
      ),
      CartillaFieldConfig(
        key: descripcion1Key(i),
        label: '$i. Descripción 1',
        type: CartillaFieldType.longText,
      ),
      CartillaFieldConfig(
        key: 'pregunta${i}Foto2',
        label: '$i. Foto 2',
        type: CartillaFieldType.photo,
        photoIndex: foto2Index(i),
      ),
      CartillaFieldConfig(
        key: descripcion2Key(i),
        label: '$i. Descripción 2',
        type: CartillaFieldType.longText,
      ),
    ];
  }

  static final List<CartillaSectionConfig> _preguntaSections = [
    for (var i = 1; i <= _preguntas.length; i++)
      CartillaSectionConfig(
        key: 'pregunta_$i',
        title: 'PREGUNTA $i',
        initiallyExpanded: i == 1,
        fields: _preguntaFields(i, _preguntas[i - 1]),
      ),
  ];

  static final List<CartillaSectionConfig> _sections = [
    const CartillaSectionConfig(
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
          key: kFecha,
          label: '2. Fecha',
          type: CartillaFieldType.date,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kHora,
          label: '3. Hora',
          type: CartillaFieldType.time,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kResponsableArea,
          label: '4. Responsable del Área',
          type: CartillaFieldType.longText,
          rules: CartillaFieldRules(required: true),
        ),
      ],
    ),
    ..._preguntaSections,
    CartillaSectionConfig(
      key: 'recomendaciones',
      title: 'RECOMENDACIONES',
      initiallyExpanded: false,
      fields: [
        for (var i = 1; i <= 3; i++) ...[
          CartillaFieldConfig(
            key: 'recomendacionFoto$i',
            label: 'Foto $i',
            type: CartillaFieldType.photo,
            photoIndex: recomendacionFotoIndex(i),
          ),
          CartillaFieldConfig(
            key: 'recomendacionDescripcion$i',
            label: 'Descripción $i',
            type: CartillaFieldType.longText,
          ),
        ],
      ],
    ),
    const CartillaSectionConfig(
      key: 'responsable_turno',
      title: 'RESPONSABLE DE TURNO',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kResponsableTurnoDni,
          label: 'DNI',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kResponsableTurnoNombre,
          label: 'Nombres y Apellidos',
          type: CartillaFieldType.longText,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kResponsableTurnoFirma,
          label: 'Firma Responsable',
          type: CartillaFieldType.signaturePad,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
      ],
    ),
    const CartillaSectionConfig(
      key: 'encargado_inspeccion',
      title: 'ENCARGADO DE INSPECCION',
      initiallyExpanded: false,
      fields: [
        CartillaFieldConfig(
          key: kEncargadoInspeccion,
          label: 'Encargado de Inspeccion',
          type: CartillaFieldType.longText,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kFirmaEncargado,
          label: 'Firma Encargado',
          type: CartillaFieldType.signaturePad,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
