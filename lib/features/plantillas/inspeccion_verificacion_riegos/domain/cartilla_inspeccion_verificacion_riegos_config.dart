import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class InspectionCheckGroup {
  final String key;
  final String title;
  final List<String> options;
  final int? photoIndex;
  final String? photoLabel;

  const InspectionCheckGroup(
    this.key,
    this.title,
    this.options, {
    this.photoIndex,
    this.photoLabel,
  });
}

// Alias interno para mantener compacta la definición de todos los grupos.
typedef _CheckGroup = InspectionCheckGroup;

/// Inspección de instalaciones y condiciones de riego.
///
/// Cada grupo es selección múltiple: el proveedor guarda una matriz paralela
/// con SI/NO para todos sus ítems, incluso cuando el usuario no los marca.
class CartillaInspeccionVerificacionRiegosConfig
    implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_inspeccion_verificacion_riegos';
  static const int _payloadVersion = 1;

  static const String templateKeyStatic = _templateKey;
  static const int payloadVersionStatic = _payloadVersion;

  static const String kFecha = 'fecha';
  static const String kSede = 'sede';
  static const String kFundo = 'fundo';
  static const String kPozo = 'pozo';
  static const String kResponsableArea = 'responsableArea';
  static const String kObservaciones = 'observaciones';
  static const String kFirmaControlCalidad = 'firmaControlCalidad';
  static const String kSupervisor = 'supervisor';
  static const String kFirmaSupervisor = 'firmaSupervisor';
  static const String kNotApplicableSections = 'notApplicableSections';

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  @override
  Set<String> get headerKeys => const {};

  @override
  List<String> get etapaFenologicaOptions => const [];

  @override
  Set<String> get plusOneReplicableHeaderKeys => const {};

  @override
  Set<String> get plusOneReplicableBodyKeys => const {kSede, kFundo};

  static const _sedes = [
    'Sociedad Agrícola Don Luis S. A.',
    'Agroindustria Campo Verde S. A. C.',
    'Inversiones AJS S. A. C.',
  ];
  static const _fundos = [
    'LA FLORESTA',
    'CHAVALINA',
    'OLAECHEA',
    'CERRO BLANCO',
    'LIMONCILLO',
    'CAYETANO',
    'GALINDITO',
    'LA ANGOSTURA',
    'CABILDO',
    'CHURRUTINA',
  ];
  static const _responsablesArea = [
    'ALVIN GOMEZ PALAMINO',
    'JESSICA HERNANDEZ UCHUYA',
  ];
  static const _pozos = [
    'IRHS2 - CABILDO',
    'IRHS3 - LA FLORESTA',
    'IRHS7 - TOLEDO',
    'IRHS20 - SANTA CRUZ',
    'IRHS62 - CAYETANO',
    'IRHS30 - LA ALTURA',
    'IRHS32 - LA BORDA',
    'IRHS25 - GALINDITO',
    'IRHS42 - CHAVALINA',
    'IRHS12 - OLAECHEA',
    'IRHS38 - CERRO BLANCO',
    'IRHS11O - LIMONCILLO',
    'IRHS44 - CERRO BLANCO 03',
    'IRHS17 - PANELES',
    'IRHS154 - CASETA LANGOSTURA',
    'CH1 - CHURRUTINA',
  ];

  static const _fertilizanteGroups = [
    InspectionCheckGroup('fertilizanteLetreros', 'LETREROS', [
      'Letrero de identificación de pozo',
      'Cartel de procedimiento en caso de emergencias (<10m)',
      'Letrero - Personal autorizado',
      'Letrero - Números de emergencia',
    ]),
    _CheckGroup('fertilizanteIperc', 'IPERc', [
      'IPERc publicado para conocimiento del operario',
      'Se encuentra en buen estado',
      'Se encuentra actualizado',
    ]),
    _CheckGroup('fertilizanteIluminacion', 'ILUMINACIÓN', [
      'Cuenta con iluminación', 'La iluminación es la adecuada',
      'Los fluorescentes están rotulados ante rotura',
      'Cuenta con luces de emergencia interna',
      'Cuenta con luces de emergencia externa',
      'Las luces de emergencia se encuentran señalizadas',
    ]),
    _CheckGroup('fertilizanteAlarma', 'ALARMA', [
      'Cuenta con un sistema de alarma cercana',
      'El sistema de alarma está señalizada',
      'Los fluorescentes están rotulados ante rotura', 'Se encuentra operativa',
    ]),
    _CheckGroup('fertilizanteExtintor', 'EXTINTOR', [
      'Presencia del extintor', 'El extintor se encuentra vigente',
      'Se encuentra operativo', 'Presenta precinto de seguridad',
      'Cuenta con señalización', 'Ubicada en un lugar adecuado (no >1.5m, ni a 0m)',
      'Colocar el número de extintor en observaciones',
      'Cuenta con cartilla de verificación', 'Cuenta con fecha de revisión',
    ]),
    _CheckGroup('fertilizanteBotiquin', 'BOTIQUÍN', [
      'Presencia de botiquín', 'Cuenta con check list (incluye tijera)',
      'Está implementado de acuerdo a su check list', 'Rotulación de botiquín',
      'No se evidencia insumos poco comunes', 'Insumos se encuentran vigentes',
    ]),
    _CheckGroup('fertilizanteLavaojos', 'LAVAOJOS', [
      'Presencia de lavaojos', 'Cuenta con agua al momento de la inspección',
      'Presión adecuada', 'Altura adecuada para el operario',
      'Es de fácil acceso (trayecto no interrumpido)', 'Rotulación del lavaojos',
      'Preguntar ¿cada cuánto cambian el agua?',
    ]),
    _CheckGroup('fertilizanteDerrames', 'CONTROL DE DERRAMES', [
      'Kit ante derrames para líquidos (mochila)',
      'Kit ante derrames para sólidos (tradicional)',
      'Parihuelas de plástico o de madera forrada con plástico',
      'Los productos sólidos están sobre parihuelas',
      'Existe un espacio entre la parihuela y la pared',
      'Cuenta con un reborde de contención',
      'El reborde de contención puede contener el 110% del envase de mayor volumen',
      'No se evidencia derrames de productos', 'Presencia de señalización',
      'Utensilios del kit antiderrame evidencia uso exclusivo para esta zona',
      'Presencia de procedimientos descritos y flujograma',
    ]),
    _CheckGroup('fertilizanteTableros', 'TABLEROS ELÉCTRICOS', [
      'Los tableros se encuentran en buen estado',
      'Las puertas de los tableros se cierran correctamente',
      'Los tableros eléctricos se encuentran enumerados',
      'Las cajas de llave térmica cuentan con tapa',
      'Presencia de señalización sobre riesgo eléctrico', 'Conexiones eléctricas expuestas',
    ]),
    _CheckGroup('fertilizanteEquipos', 'EQUIPOS', [
      'Las bombas se encuentran en buenas condiciones',
      'Los ejes y poleas móviles cuentan con cobertores de seguridad',
      'No se evidencian cables expuestos o con pegas',
    ]),
    _CheckGroup('fertilizanteTanques', 'TANQUES DE FERTILIZACIÓN', [
      'Los tanques se encuentran en buen estado',
      'La altura de los tanques no dificulta la labor del operario',
      'Cuentan con escaleras para facilitar la labor del operario (N/A si la pregunta anterior es positiva)',
      'Los tanques se encuentran enumerados', 'Presencia de obstáculos alrededor del tanque',
    ]),
    _CheckGroup('fertilizanteBaldes', 'BALDES Y JARRAS', [
      'Los utensilios de medición se encuentran calibrados',
      'Todos los elementos de mezcla se encuentran señalizados de acuerdo a su utilización y peligro',
      'Presencia de un espacio donde se coloquen y almacenen en forma ordenada sin presencia de derrames',
      'Señalización del espacio de utensilios',
    ]),
    _CheckGroup('fertilizanteEnvases', 'ENVASES VACÍOS', [
      'Los envases vacíos se encuentran en una zona señalizada',
      'No se almacena envases vacíos de más de un día',
      'Presencia de residuo de producto fitosanitario en los envases vacíos',
      'Se evidencia triple lavado de acuerdo al procedimiento',
      'Se visualiza señalización sobre procedimiento de triple lavado de envases de productos fitosanitarios',
    ]),
    _CheckGroup('fertilizanteEpps', 'EPPS', [
      'El personal usa su EPP (guantes, botas, orejeras, traje, mascarilla, lentes)',
      'Almacenamiento adecuado (lugar/mascarillas en bolsas herméticas)',
      'Señalización de área de almacenamiento',
      'Procedimiento descrito sobre el uso adecuado de EPPs y flujograma',
    ]),
    _CheckGroup('fertilizanteDucha', 'DUCHA DE EMERGENCIAS', [
      'Cuenta con ducha de emergencia', 'La ducha de emergencia está operativa',
      'Se encuentra señalizada',
    ]),
    _CheckGroup('fertilizanteProductos', 'PRODUCTOS QUÍMICOS E INSUMOS GENERALES', [
      'Enlistar en observaciones todos los productos encontrados al momento de la inspección',
      'Presencia de las fichas técnicas de los productos a utilizar',
      'Presencia de las hojas de seguridad de todos los productos',
      'Los productos se encuentran en sus envases originales y/o cuentan con etiquetas con la información del producto',
      'Almacenamiento adecuado, uso de parihuelas de plástico, andamios de material no absorbente',
      'Procedimiento adecuado sobre el uso de los productos encontrados',
    ]),
    _CheckGroup('fertilizanteHerramientas', 'HERRAMIENTAS', [
      'Cuentan con una zona de herramientas, señalizada',
      'Si cuentan con materiales punzocortantes estos cuentan con cobertores',
    ]),
    _CheckGroup('fertilizanteTecho', 'TECHO', [
      'Se encuentra en buenas condiciones', 'Es de material tipo impermeable',
    ]),
    _CheckGroup('fertilizanteConexiones', 'CONEXIONES', [
      'No se evidencia conexiones eléctricas peligrosas (interior, exterior, ruta al pozo)',
    ]),
    _CheckGroup('fertilizanteEvacuacion', 'EVACUACIÓN', [
      'Cuenta con mapa de evacuación',
      'Cuenta con señalizaciones de emergencia (evacuación, zona segura, etc.)',
      'Las señalizaciones se encuentran en buen estado',
    ]),
    _CheckGroup('fertilizanteAguaPotable', 'AGUA POTABLE', [
      'El operario cuenta con un punto de agua cercano', 'El área se encuentra debidamente señalizada',
    ]),
    _CheckGroup('fertilizanteLavamanos', 'LAVAMANOS', [
      'Cuentan con una estación de lavado de manos', 'El área se encuentra debidamente señalizada',
    ]),
    _CheckGroup('fertilizanteLimpieza', 'LIMPIEZA', [
      'Orden y limpieza en el interior del pozo', 'Implementos de limpieza solo exclusivo para el área',
    ]),
  ];

  static const _lavadoManos = _CheckGroup('lavadoManos', 'VERIFICACIÓN', [
    'Tienen un procedimiento visible del correcto lavado de manos',
    'El procedimiento se encuentra en buen estado', 'El procedimiento está en un lugar estratégico',
    'La infraestructura del andamio está en buen estado',
    'El dispensador de agua se encuentra limpio (sin presencia de restos de insectos, hojas, entre otros)',
    'Cuenta con jabón líquido', 'El jabón líquido es inoloro', 'El jabón líquido está rotulado',
    'Cuenta con alcohol en gel', 'Cuenta con papel toalla', 'Cuenta con tacho de basura',
    'El tacho de basura cuenta con tapa', 'Tacho de basura tiene bolsa negra',
    'El tacho de basura está rotulado', 'Cuenta con lavamanos (tina)',
  ]);
  static const _dispensador = _CheckGroup('dispensadorAgua', 'VERIFICACIÓN', [
    'Cuenta con un dispensador de agua potable', 'El dispensador está rotulado',
    'Cuenta con vasos descartables', 'El área de vasos limpios se encuentra rotulado',
    'Cuenta con tacho para vasos usados', 'El contenedor de vasos sucios se encuentra rotulado',
  ]);
  static const _piscinaGroups = [
    _CheckGroup('piscinaSeguridad', 'SEGURIDAD', ['Cercado seguro de todo el área', 'Puerta cerrada con seguro'], photoIndex: 8, photoLabel: 'Foto - Seguridad'),
    _CheckGroup('piscinaLetreros', 'LETREROS', ['Letrero de ingreso de personal autorizado', 'Letrero de riesgo de ahogamiento', 'Letrero prohibido el paso'], photoIndex: 9, photoLabel: 'Foto - Letreros'),
    _CheckGroup('piscinaImplementos', 'IMPLEMENTOS', ['Presencia de cuerdas con boyas en la piscina', 'Presencia de chaleco salvavida', 'Presencia de soga salvavidas', 'Presencia de aro salvavidas'], photoIndex: 10, photoLabel: 'Foto - Implementos'),
    _CheckGroup('piscinaSostenibilidad', 'SOSTENIBILIDAD', ['La piscina se encuentra cubierta', 'La piscina no evidencia restos de algas verdes', 'La zona perimetral de la piscina cuenta con cobertura vegetal (zona de amortiguamiento)', 'Cuenta con letreros de zona de no aplicación'], photoIndex: 11, photoLabel: 'Foto - Sostenibilidad'),
  ];
  static const _pozoGroups = [
    _CheckGroup('pozoLetrero', 'LETRERO', ['Letrero de identificación de área', 'Letrero - Personal autorizado'], photoIndex: 12, photoLabel: 'Foto - Letrero'),
    _CheckGroup('pozoExtintor', 'EXTINTOR', ['El extintor se encuentra vigente', 'Se encuentra operativo', 'Presenta precinto de seguridad', 'Cuenta con señalización', 'Ubicada en un lugar adecuado', 'Colocar el número de extintor en observaciones', 'Cuenta con cartilla de verificación', 'Cuenta con fecha de revisión'], photoIndex: 13, photoLabel: 'Foto - Extintor'),
    _CheckGroup('pozoTableros', 'TABLEROS ELÉCTRICOS', ['Los tableros se encuentran en buen estado', 'Las puertas de los tableros se cierran correctamente', 'Los tableros eléctricos se encuentran enumerados'], photoIndex: 14, photoLabel: 'Foto - Tableros'),
    _CheckGroup('pozoIluminacion', 'ILUMINACIÓN', ['Cuenta con iluminación', 'La iluminación es la adecuada', 'Los fluorescentes están rotulados ante rotura', 'Cuenta con luces de emergencia interna', 'Cuenta con luces de emergencia externa', 'Las luces de emergencia se encuentran señalizadas'], photoIndex: 15, photoLabel: 'Foto - Iluminación'),
    _CheckGroup('pozoConexiones', 'CONEXIONES', ['No se evidencia conexiones eléctricas peligrosas'], photoIndex: 16, photoLabel: 'Foto - Conexiones'),
    _CheckGroup('pozoLimpieza', 'LIMPIEZA', ['Orden y limpieza en el interior del pozo'], photoIndex: 17, photoLabel: 'Foto - Limpieza'),
  ];
  static const _rebombeoGroups = [
    _CheckGroup('rebombeoLetrero', 'LETRERO', ['Letrero de identificación de área', 'Letrero - Personal autorizado']),
    _CheckGroup('rebombeoExtintor', 'EXTINTOR', ['Presencia del extintor', 'El extintor se encuentra vigente', 'Se encuentra operativo', 'Presenta precinto de seguridad', 'Cuenta con señalización', 'Ubicada en un lugar adecuado', 'Colocar el número de extintor en observaciones', 'Cuenta con cartilla de verificación', 'Cuenta con fecha de revisión']),
    _CheckGroup('rebombeoTableros', 'TABLEROS ELÉCTRICOS', ['Los tableros se encuentran en buen estado', 'Las puertas de los tableros se cierran correctamente', 'Los tableros eléctricos se encuentran enumerados']),
    _CheckGroup('rebombeoIluminacion', 'ILUMINACIÓN', ['Cuenta con iluminación', 'La iluminación es la adecuada', 'Los fluorescentes están rotulados ante rotura', 'Cuenta con luces de emergencia interna', 'Cuenta con luces de emergencia externa', 'Las luces de emergencia se encuentran señalizadas']),
    _CheckGroup('rebombeoConexiones', 'CONEXIONES', ['No se evidencia conexiones eléctricas peligrosas']),
    _CheckGroup('rebombeoLimpieza', 'LIMPIEZA', ['Orden y limpieza en el interior del pozo']),
  ];
  static const _vestuario = _CheckGroup('zonaVestuario', 'VERIFICACIÓN', [
    'Cuenta con letrero de personal autorizado', 'Cuenta con flujograma en el ingreso',
    'Cuenta con zona de ropa limpia y zona de ropa sucia', 'No hay contaminación cruzada',
    'Cuenta con duchas', 'Las duchas brindan la privacidad al usuario',
    'El área cuenta con iluminación', 'Cuentan con un área donde lavan sus EPPs',
    'Los EPPs están correctamente almacenados', 'Hay un espacio para colocar sus EPPs',
  ]);

  static CartillaFieldConfig _groupField(InspectionCheckGroup group) => CartillaFieldConfig(
    key: group.key, label: group.title, type: CartillaFieldType.multiSelectChips,
    staticOptions: group.options,
  );

  static List<CartillaFieldConfig> _groupFields(List<InspectionCheckGroup> groups) => [
    for (final group in groups) ...[
      _groupField(group),
      if (group.photoIndex != null) CartillaFieldConfig(key: '${group.key}Foto', label: group.photoLabel ?? 'Foto', type: CartillaFieldType.photo, photoIndex: group.photoIndex),
    ],
  ];

  static final List<InspectionCheckGroup> allCheckGroups = [
    ..._fertilizanteGroups, _lavadoManos, _dispensador, ..._piscinaGroups,
    ..._pozoGroups, ..._rebombeoGroups, _vestuario,
  ];

  static const Set<String> notApplicableSectionKeys = {
    'area_fertilizante',
    'estacion_lavado_manos',
    'dispensador_agua',
    'piscina',
    'pozo',
    'zona_rebombeo',
    'zona_vestuario',
  };

  static String sectionForCheckGroup(String groupKey) {
    if (groupKey.startsWith('fertilizante')) return 'area_fertilizante';
    if (groupKey == 'lavadoManos') return 'estacion_lavado_manos';
    if (groupKey == 'dispensadorAgua') return 'dispensador_agua';
    if (groupKey.startsWith('piscina')) return 'piscina';
    if (groupKey.startsWith('pozo')) return 'pozo';
    if (groupKey.startsWith('rebombeo')) return 'zona_rebombeo';
    if (groupKey == 'zonaVestuario') return 'zona_vestuario';
    return '';
  }

  static final List<CartillaSectionConfig> _sections = [
    const CartillaSectionConfig(key: 'datos_generales', title: 'DATOS GENERALES', fields: [
      CartillaFieldConfig(key: kFecha, label: 'Fecha', type: CartillaFieldType.date, rules: CartillaFieldRules(required: true, readOnly: true)),
      CartillaFieldConfig(key: kSede, label: 'Sede', type: CartillaFieldType.dropdown, staticOptions: _sedes, rules: CartillaFieldRules(required: true, copyOnPlus1: true)),
      CartillaFieldConfig(key: kFundo, label: 'Fundo', type: CartillaFieldType.dropdown, staticOptions: _fundos, rules: CartillaFieldRules(required: true, copyOnPlus1: true)),
      CartillaFieldConfig(key: kPozo, label: 'Zona de Riego', type: CartillaFieldType.dropdown, staticOptions: _pozos, rules: CartillaFieldRules(required: true)),
      CartillaFieldConfig(key: kResponsableArea, label: 'Responsable de área', type: CartillaFieldType.dropdown, staticOptions: _responsablesArea, rules: CartillaFieldRules(required: true)),
    ]),
    CartillaSectionConfig(key: 'area_fertilizante', title: 'ÁREA DE MANEJO DE FERTILIZANTE', fields: [
      ..._groupFields(_fertilizanteGroups),
      const CartillaFieldConfig(key: 'foto2', label: 'Foto 2', type: CartillaFieldType.photo, photoIndex: 1),
      const CartillaFieldConfig(key: kObservaciones, label: 'Observaciones', type: CartillaFieldType.longText),
      const CartillaFieldConfig(key: 'fotoObservaciones', label: 'Foto - Observaciones', type: CartillaFieldType.photo, photoIndex: 2),
      const CartillaFieldConfig(key: 'foto3', label: 'Foto 3', type: CartillaFieldType.photo, photoIndex: 3),
    ]),
    CartillaSectionConfig(key: 'estacion_lavado_manos', title: 'ESTACIONES DE LAVADO DE MANOS', fields: [
      _groupField(_lavadoManos),
      const CartillaFieldConfig(key: 'lavadoObservaciones', label: 'Observaciones', type: CartillaFieldType.longText),
      const CartillaFieldConfig(key: 'lavadoFoto1', label: 'Foto 1', type: CartillaFieldType.photo, photoIndex: 4),
      const CartillaFieldConfig(key: 'lavadoFoto2', label: 'Foto 2', type: CartillaFieldType.photo, photoIndex: 5),
      const CartillaFieldConfig(key: 'lavadoFoto3', label: 'Foto 3', type: CartillaFieldType.photo, photoIndex: 6),
    ]),
    CartillaSectionConfig(key: 'dispensador_agua', title: 'DISPENSADOR DE AGUA', fields: [
      _groupField(_dispensador),
      const CartillaFieldConfig(key: 'dispensadorObservaciones', label: 'Observaciones', type: CartillaFieldType.longText),
      const CartillaFieldConfig(key: 'dispensadorFoto1', label: 'Foto 1', type: CartillaFieldType.photo, photoIndex: 7),
      const CartillaFieldConfig(key: 'dispensadorFoto2', label: 'Foto 2', type: CartillaFieldType.photo, photoIndex: 18),
      const CartillaFieldConfig(key: 'dispensadorFoto3', label: 'Foto 3', type: CartillaFieldType.photo, photoIndex: 19),
    ]),
    CartillaSectionConfig(key: 'piscina', title: 'PISCINA', fields: _groupFields(_piscinaGroups)),
    CartillaSectionConfig(key: 'pozo', title: 'POZO', fields: _groupFields(_pozoGroups)),
    CartillaSectionConfig(key: 'zona_rebombeo', title: 'ZONA DE REBOMBEO', fields: _groupFields(_rebombeoGroups)),
    CartillaSectionConfig(key: 'zona_vestuario', title: 'ZONA DE VESTUARIO', fields: [_groupField(_vestuario)]),
    const CartillaSectionConfig(key: 'firmas', title: 'FIRMAS', initiallyExpanded: false, fields: [
      CartillaFieldConfig(key: kFirmaControlCalidad, label: 'Firma Responsable de Inspección', type: CartillaFieldType.signaturePad, rules: CartillaFieldRules(required: true)),
      CartillaFieldConfig(key: kSupervisor, label: 'Responsable de Zona', type: CartillaFieldType.longText, rules: CartillaFieldRules(required: true)),
      CartillaFieldConfig(key: kFirmaSupervisor, label: 'Firma Responsable de Zona', type: CartillaFieldType.signaturePad, rules: CartillaFieldRules(required: true)),
    ]),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
