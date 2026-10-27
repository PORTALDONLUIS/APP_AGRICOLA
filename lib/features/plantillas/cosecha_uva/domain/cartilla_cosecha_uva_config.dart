import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaCosechaUvaConfig implements CartillaFormConfig {
  static const templateKeyStatic = 'cartilla_cosecha_uva';
  static const payloadVersionStatic = 1;
  @override
  String get templateKey => templateKeyStatic;
  @override
  int get payloadVersion => payloadVersionStatic;
  @override
  Set<String> get headerKeys => const {'loteId', 'campaniaId'};
  @override
  List<String> get etapaFenologicaOptions => const [];
  @override
  Set<String> get plusOneReplicableHeaderKeys => headerKeys;
  @override
  Set<String> get plusOneReplicableBodyKeys => const {
    'operario',
    'codigoLimpiador',
    'supervisor',
    'variedad',
  };
  @override
  List<CartillaSectionConfig> get sections => const [
    CartillaSectionConfig(
      key: 'datos_generales',
      title: 'DATOS GENERALES',
      fields: [
        CartillaFieldConfig(
          key: 'loteId',
          label: 'Lote',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: 'campaniaId',
          label: 'Campaña',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: 'fecha',
          label: 'Fecha',
          type: CartillaFieldType.date,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: 'operario',
          label: 'Operario',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasOperario,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: 'codigoLimpiador',
          label: 'Código del limpiador',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: 'supervisor',
          label: 'Supervisor',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasSupervisor,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: 'variedad',
          label: 'Variedad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.variedades,
          rules: CartillaFieldRules(readOnly: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: 'hora',
          label: 'Hora',
          type: CartillaFieldType.time,
          rules: CartillaFieldRules(required: true),
        ),
        CartillaFieldConfig(
          key: 'temperatura',
          label: 'Temperatura',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'clasificacion_racimos',
      title: 'CLASIFICACIÓN DE RACIMOS',
      fields: [
        CartillaFieldConfig(
          key: 'conformados',
          label: 'Racimos conformados',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'pampanos',
          label: 'Pámpanos',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'semipaludos',
          label: 'Semipaludos',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'paludos',
          label: 'Paludos',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'totalRacimos',
          label: 'Total de racimos',
          type: CartillaFieldType.intReadOnly,
          rules: CartillaFieldRules(readOnly: true),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'clasificacion_color',
      title: 'CLASIFICACIÓN DE COLOR',
      fields: [
        CartillaFieldConfig(
          key: 'verde',
          label: 'Verde',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'cremoso',
          label: 'Cremoso',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'ambar',
          label: 'Ámbar',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'totalRacimosColor',
          label: 'Total de racimos',
          type: CartillaFieldType.intReadOnly,
          rules: CartillaFieldRules(readOnly: true),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'bayas_defectuosas',
      title: 'N.º DE BAYAS DEFECTUOSAS',
      fields: [
        CartillaFieldConfig(
          key: 'pudricion',
          label: 'Pudrición',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'partiduras',
          label: 'Partiduras',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'mediaLuna',
          label: 'Media luna',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'oidium',
          label: 'Oidium',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'danoMecanico',
          label: 'Daño mecánico',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'racimos_defectuosos',
      title: 'N.º DE RACIMOS DEFECTUOSOS',
      fields: [
        CartillaFieldConfig(
          key: 'chanchitoBlanco',
          label: 'Chanchito blanco',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'paloNegro',
          label: 'Palo negro',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'presenciaPolvo',
          label: 'Presencia de polvo',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'presenciaAranaTela',
          label: 'Presencia de araña y tela',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'bayasAcuosas',
          label: 'Bayas acuosas',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'golpeSol',
          label: 'Golpe de sol',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'raquisLignificado',
          label: 'Raquis lignificado',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'pediceloNecrosado',
          label: 'Pedicelo necrosado',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'russet',
          label: 'Russet',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'descalibre',
          label: 'Descalibre',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
        CartillaFieldConfig(
          key: 'colapso',
          label: 'Colapso',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            minValue: 0,
            maxValue: 999999,
            maxDigits: 6,
          ),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'evidencias',
      title: 'DATOS COMPLEMENTARIOS Y EVIDENCIAS',
      fields: [
        CartillaFieldConfig(
          key: 'restosVegetales',
          label: 'Presencia de restos vegetales',
          type: CartillaFieldType.multiSelectChips,
          staticOptions: ['ZARCILLO', 'HOJAS'],
          rules: CartillaFieldRules(),
        ),
        CartillaFieldConfig(
          key: 'observaciones',
          label: 'Observaciones',
          type: CartillaFieldType.longText,
          rules: CartillaFieldRules(),
        ),
        CartillaFieldConfig(
          key: 'foto1',
          label: 'FOTO 1',
          type: CartillaFieldType.photo,
          photoIndex: 1,
          rules: CartillaFieldRules(),
        ),
        CartillaFieldConfig(
          key: 'foto2',
          label: 'FOTO 2',
          type: CartillaFieldType.photo,
          photoIndex: 2,
          rules: CartillaFieldRules(),
        ),
        CartillaFieldConfig(
          key: 'foto3',
          label: 'FOTO 3',
          type: CartillaFieldType.photo,
          photoIndex: 3,
          rules: CartillaFieldRules(),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'resumen',
      title: 'RESUMEN DE LA MUESTRA',
      fields: [
        CartillaFieldConfig(
          key: 'racimosConDefectos',
          label: 'Racimos con defectos (suma de incidencias)',
          type: CartillaFieldType.intReadOnly,
          rules: CartillaFieldRules(readOnly: true),
        ),
        CartillaFieldConfig(
          key: 'racimosSinDefectos',
          label: 'Racimos sin defectos',
          type: CartillaFieldType.intReadOnly,
          rules: CartillaFieldRules(readOnly: true),
        ),
        CartillaFieldConfig(
          key: 'porcentajeConDefectos',
          label: 'Racimos con defectos (%)',
          type: CartillaFieldType.decimalReadOnly,
          rules: CartillaFieldRules(readOnly: true),
        ),
        CartillaFieldConfig(
          key: 'porcentajeSinDefectos',
          label: 'Racimos sin defectos (%)',
          type: CartillaFieldType.decimalReadOnly,
          rules: CartillaFieldRules(readOnly: true),
        ),
        CartillaFieldConfig(
          key: 'totalBayasDefectuosas',
          label: 'Total de bayas defectuosas',
          type: CartillaFieldType.intReadOnly,
          rules: CartillaFieldRules(readOnly: true),
        ),
        CartillaFieldConfig(
          key: 'restosVegetalesSiNo',
          label: 'Restos vegetales: SI / NO',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(readOnly: true),
        ),
      ],
    ),
  ];
}
