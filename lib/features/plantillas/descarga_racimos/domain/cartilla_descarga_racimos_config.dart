import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaDescargaRacimosConfig implements CartillaFormConfig {
  static const String templateKeyStatic = 'cartilla_descarga_racimos';
  static const int payloadVersionStatic = 1;

  static const String kLoteId = 'loteId';
  static const String kOperario1Id = 'operario1Id';
  static const String kOperario2Id = 'operario2Id';
  static const String kSupervisorId = 'supervisorId';
  static const String kVariedad = 'variedad';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';
  static const String kTotalRacimo = 'totalRacimo';
  static const String kObservaciones = 'observaciones';
  static const String kFoto1 = 'foto1';
  static const String kFoto2 = 'foto2';

  @override
  String get templateKey => templateKeyStatic;

  @override
  int get payloadVersion => payloadVersionStatic;

  @override
  Set<String> get headerKeys => const {kLoteId};

  @override
  List<String> get etapaFenologicaOptions => const [];

  @override
  Set<String> get plusOneReplicableHeaderKeys => const {kLoteId};

  @override
  Set<String> get plusOneReplicableBodyKeys => const {kSupervisorId, kVariedad};

  @override
  List<CartillaSectionConfig> get sections => const [
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
          key: kOperario1Id,
          label: '2. Operario 1',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasOperario,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kOperario2Id,
          label: '3. Operario 2',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasOperario,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kSupervisorId,
          label: '4. Supervisor',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasSupervisor,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kVariedad,
          label: '5. Variedad',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.variedades,
          rules: CartillaFieldRules(
            required: true,
            readOnly: true,
            copyOnPlus1: true,
          ),
        ),
        CartillaFieldConfig(
          key: kHilera,
          label: '6. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            required: true,
            maxDigits: 3,
            copyOnPlus1: true,
          ),
        ),
        CartillaFieldConfig(
          key: kPlanta,
          label: '7. Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(
            required: true,
            maxDigits: 3,
            copyOnPlus1: true,
          ),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'total_racimo',
      title: 'TOTAL DE RACIMO',
      fields: [
        CartillaFieldConfig(
          key: kTotalRacimo,
          label: '8. Total T. Racimo',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(required: true, minValue: 0),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'observaciones_fotos',
      title: 'OBSERVACIONES / FOTOS',
      fields: [
        CartillaFieldConfig(
          key: kObservaciones,
          label: '9. Observaciones',
          type: CartillaFieldType.longText,
        ),
        CartillaFieldConfig(
          key: kFoto1,
          label: '10. FOTO 1',
          type: CartillaFieldType.photo,
          photoIndex: 1,
        ),
        CartillaFieldConfig(
          key: kFoto2,
          label: '11. FOTO 2',
          type: CartillaFieldType.photo,
          photoIndex: 2,
        ),
      ],
    ),
  ];
}
