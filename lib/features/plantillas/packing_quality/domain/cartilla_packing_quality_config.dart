import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

/// Registro separado para las nuevas cartillas Packing Uva de Calidad.
class CartillaPackingQualityConfig implements CartillaFormConfig {
  CartillaPackingQualityConfig(this.templateKey);
  @override
  final String templateKey;
  @override
  int get payloadVersion => 1;

  static const keys = {
    'cartilla_packing_recepcion_uva_calidad',
    'cartilla_packing_abastecimiento_uva_calidad',
    'cartilla_packing_linea_uva_calidad',
    'cartilla_packing_paletizado_uva_calidad',
    'cartilla_packing_ingreso_planta_uva_calidad',
  };
  static const _headers = {'loteId', 'campaniaId'};
  @override
  Set<String> get headerKeys => _headers;
  @override
  List<String> get etapaFenologicaOptions => const [];
  @override
  Set<String> get plusOneReplicableHeaderKeys => _headers;
  @override
  Set<String> get plusOneReplicableBodyKeys => _repeat[templateKey] ?? const {};
  static const _repeat = {
    'cartilla_packing_recepcion_uva_calidad': {'fecha', 'variedad', 'sector'},
    'cartilla_packing_abastecimiento_uva_calidad': {'fecha', 'variedad'},
    'cartilla_packing_linea_uva_calidad': {
      'fecha',
      'variedad',
      'sector',
      'presentacion',
    },
    'cartilla_packing_paletizado_uva_calidad': {'variedad', 'calibre'},
    'cartilla_packing_ingreso_planta_uva_calidad': {
      'variedad',
      'tipo',
      'planta',
      'controlCalidad',
      'fundo',
      'codigoLugarProduccion',
    },
  };

  static CartillaFieldConfig _f(
    String key,
    String label,
    CartillaFieldType type, {
    bool required = false,
    int? min,
    List<String>? options,
    CartillaCatalogSource? catalog,
    bool copy = false,
    bool readOnly = false,
    String? depends,
    int? photo,
  }) => CartillaFieldConfig(
    key: key,
    label: label,
    type: type,
    catalogSource: catalog,
    staticOptions: options,
    dependsOnHeaderKey: depends,
    photoIndex: photo,
    rules: CartillaFieldRules(
      required: required,
      minValue: min,
      copyOnPlus1: copy,
      readOnly: readOnly,
    ),
  );
  static CartillaFieldConfig _text(
    String k,
    String l, {
    bool long = false,
    bool copy = false,
  }) => _f(
    k,
    l,
    long ? CartillaFieldType.longText : CartillaFieldType.shortText,
    copy: copy,
  );
  static CartillaFieldConfig _int(String k, String l, {bool counter = false}) =>
      _f(
        k,
        l,
        counter ? CartillaFieldType.stepperInt : CartillaFieldType.intNumber,
        min: 0,
      );
  static CartillaFieldConfig _dec(String k, String l) =>
      _f(k, l, CartillaFieldType.decimalNumber, min: 0);
  static CartillaFieldConfig _time(String k, String l) =>
      _f(k, l, CartillaFieldType.time);
  static CartillaFieldConfig _date(String k, String l, {bool copy = false}) =>
      _f(k, l, CartillaFieldType.date, required: true, copy: copy);
  static CartillaFieldConfig _lote() => _f(
    'loteId',
    'Lote',
    CartillaFieldType.dropdown,
    required: true,
    catalog: CartillaCatalogSource.lotes,
    copy: true,
  );
  static CartillaFieldConfig _campania() => _f(
    'campaniaId',
    'Campaña',
    CartillaFieldType.dropdown,
    required: true,
    catalog: CartillaCatalogSource.campanias,
    copy: true,
  );
  static CartillaFieldConfig _variedad() => _f(
    'variedad',
    'Variedad',
    CartillaFieldType.dropdown,
    required: true,
    catalog: CartillaCatalogSource.variedades,
    depends: 'loteId',
    copy: true,
    readOnly: true,
  );
  static CartillaSectionConfig _s(
    String key,
    String title,
    List<CartillaFieldConfig> fields, {
    bool expanded = false,
  }) => CartillaSectionConfig(
    key: key,
    title: title,
    fields: fields,
    initiallyExpanded: expanded,
  );
  static List<CartillaFieldConfig> _photos() => [
    _f('foto1', 'Foto 1', CartillaFieldType.photo, photo: 1),
    _f('foto2', 'Foto 2', CartillaFieldType.photo, photo: 2),
    _f('foto3', 'Foto 3', CartillaFieldType.photo, photo: 3),
  ];
  static List<CartillaSectionConfig> _tail() => [
    _s('observacion', 'OBSERVACIÓN', [
      _text('observaciones', 'Observaciones', long: true),
    ]),
    _s('fotos', 'EVIDENCIAS FOTOGRÁFICAS', _photos()),
  ];

  @override
  List<CartillaSectionConfig> get sections {
    switch (templateKey) {
      case 'cartilla_packing_abastecimiento_uva_calidad':
        return [
          _s('general', 'DATOS GENERALES', [
            _date('fecha', 'Fecha', copy: true),
            _campania(),
            _text('nroGuia', 'N.° de guía'),
            _int(
              'cantidadPaletIngresado',
              'Cantidad de palets ingresados',
              counter: true,
            ),
            _dec('pesoPaletIngresado', 'Peso de palets ingresados (kg)'),
            _lote(),
            _variedad(),
          ], expanded: true),
          _s('proceso', 'CONTROL DE GASIFICADO Y PRE FRÍO', [
            _time('horaInicioGasificado', 'Hora de inicio de gasificado'),
            _time('horaFinGasificado', 'Hora de fin de gasificado'),
            _time('horaPreFrio', 'Hora de pre frío'),
            _time('horaSalidaPreFrio', 'Hora de salida de pre frío'),
          ]),
          ..._tail(),
        ];
      case 'cartilla_packing_paletizado_uva_calidad':
        return [
          _s('general', 'DATOS GENERALES', [
            _text('nroGuia', 'N.° de guía'),
            _campania(),
            _lote(),
            _variedad(),
            _time('horaInicio', 'Hora de inicio'),
            _int(
              'numeroPalletsCompletos',
              'N.° de pallets completos',
              counter: true,
            ),
            _int('numeroPuchos', 'N.° de puchos'),
          ], expanded: true),
          _s('presentacion', 'PRESENTACIÓN', [
            _int('numeroCalibre', 'N.° de calibre'),
            _text('calibre', 'Calibre', copy: true),
            _int('numeroCajas', 'N.° de cajas'),
            _time('horaIngresoCamaraFrio', 'Hora de ingreso a cámara de frío'),
          ]),
          ..._tail(),
        ];
      case 'cartilla_packing_linea_uva_calidad':
        return [
          _s('general', 'DATOS GENERALES', [
            _text('nroGuia', 'N.° de guía'),
            _campania(),
            _lote(),
            _date('fecha', 'Fecha', copy: true),
            _variedad(),
            _text('sector', 'Sector', copy: true),
            _time('horaInicio', 'Hora de inicio'),
            _time('horaFinal', 'Hora final'),
            _text('presentacion', 'Presentación', copy: true),
            _text('pautas', 'Pautas', long: true),
            _text('observaciones', 'Observaciones', long: true),
            ..._photos(),
          ], expanded: true),
        ];
      case 'cartilla_packing_ingreso_planta_uva_calidad':
        return [
          _s('iniciales', 'DATOS INICIALES', [
            _f(
              'planta',
              'Planta',
              CartillaFieldType.dropdown,
              catalog: CartillaCatalogSource.packingPlanta,
              copy: true,
            ),
            _f(
              'controlCalidad',
              'Control de calidad',
              CartillaFieldType.dropdown,
              catalog: CartillaCatalogSource.packingControlCalidad,
              copy: true,
            ),
            _f(
              'codigoLugarProduccion',
              'Fundo y código de lugar de producción',
              CartillaFieldType.dropdown,
              catalog: CartillaCatalogSource.packingLugarProduccion,
              copy: true,
            ),
          ]),
          _s('fechas', 'FECHAS', [
            _date('cosecha', 'Cosecha'),
            _date('proceso', 'Proceso'),
          ]),
          _s('guia', 'DATOS DE LA GUÍA', [
            _text('serieGuia', 'Serie de guía'),
            _text('nroGuia', 'N.° de guía'),
          ]),
          _s('detalle', 'DETALLE', [_campania(), _lote(), _variedad()]),
          _s('envases', 'DATOS DE ENVASES COSECHADOS', [
            _f(
              'tipo',
              'Tipo',
              CartillaFieldType.dropdown,
              options: ['Jabas', 'Bines'],
            ),
            _int('cantidad', 'Cantidad'),
            _dec('pesoKg', 'Peso (kg)'),
          ]),
          _s('campo', 'DATOS CAMPO (KG)', [
            _dec('kilosIngresados', 'Kilos ingresados'),
          ]),
          ..._tail(),
        ];
      case 'cartilla_packing_recepcion_uva_calidad':
      default:
        return [
          _s('general', 'DATOS GENERALES', [
            _date('fecha', 'Fecha', copy: true),
            _campania(),
            _variedad(),
            _text('nroGuia', 'N.° de guía'),
            _int('totalPaletPorGuia', 'Total de palets por guía'),
            _text('sector', 'Sector', copy: true),
            _lote(),
            _int('numeroJabas', 'N.° de jabas'),
            _dec('pesoTotalJabas', 'Peso / total de jabas (kg)'),
            _dec('pesoNeto', 'Peso neto (kg)'),
            _dec('pesoBaya', 'Peso de baya (kg)'),
            _f(
              'pesoPorJaba',
              'Peso por jaba (kg)',
              CartillaFieldType.decimalReadOnly,
            ),
            _text('brix', 'Brix'),
            _dec('temperatura', 'Temperatura (°C)'),
          ], expanded: true),
          _s('defectos', 'PRINCIPALES DEFECTOS', [
            _dec('pudricion', 'Pudrición'),
            _int('deshidratacion', 'Deshidratación', counter: true),
            _dec('danoMecanico', 'Daño mecánico'),
            _int('chanchitoBlanco', 'Chanchito blanco', counter: true),
            _dec('oidium', 'Oidium'),
            _dec('paloNegro', 'Palo negro'),
            _int('presenciaPolvo', 'Presencia de polvo', counter: true),
            _int('presenciaArana', 'Presencia de araña', counter: true),
            _int('bayasAcuosas', 'Bayas acuosas', counter: true),
            _int('golpeSol', 'Golpe de sol', counter: true),
            _dec('russet', 'Russet'),
            _int('descalibre', 'Descalibre', counter: true),
          ]),
          ..._tail(),
          _s('complementarios', 'DATOS COMPLEMENTARIOS', [
            _dec('pesoMinimoRacimo', 'Peso mínimo de racimo (kg)'),
            _dec('pesoMaximoRacimo', 'Peso máximo de racimo (kg)'),
          ]),
        ];
    }
  }
}
