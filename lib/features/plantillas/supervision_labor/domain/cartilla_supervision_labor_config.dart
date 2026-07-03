import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaSupervisionLaborConfig implements CartillaFormConfig {
  static const String _templateKey = 'cartilla_supervision_labor';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  static const String kLoteId = 'loteId';
  static const String kCampaniaId = 'campaniaId';

  static const String kSupervisor = 'supervisor';
  static const String kSector = 'sector';
  static const String kHoraInicio = 'horaInicio';
  static const String kHoraFinal = 'horaFinal';
  static const String kFecha = 'fecha';
  static const String kActividadId = 'actividadId';
  static const String kActividadNombre = 'actividadNombre';
  static const String kLaborId = 'laborId';
  static const String kLaborNombre = 'laborNombre';
  static const String kLabor = 'labor';
  static const String kCosto = 'costo';
  static const String kRendimiento = 'rendimiento';

  static const String kTotalPlantasORacimos = 'totalPlantasORacimos';
  static const String kRendimientoPromedioJornal = 'rendimientoPromedioJornal';
  static const String kNumeroTrabajadores = 'numeroTrabajadores';
  static const String kFirmaSupervisor = 'firmaSupervisor';
  static const String kFirmaProduccion = 'firmaProduccion';
  static const String kObservaciones = 'observaciones';

  static String kNombre(int i) => 'trabajador${i}_nombre';
  static String kPersonaId(int i) => 'trabajador${i}_personaId';
  static String kDni(int i) => 'trabajador${i}_dni';
  static String kFirmaEntrada(int i) => 'trabajador${i}_firmaEntrada';
  static String kHilera(int i) => 'trabajador${i}_hilera';
  static String kPlantasInicio(int i) => 'trabajador${i}_plantasInicio';
  static String kPlantasFinal(int i) => 'trabajador${i}_plantasFinal';
  static String kSubtotal(int i) => 'trabajador${i}_subtotal';
  static String kPlantasRechazadas(int i) =>
      'trabajador${i}_plantasRacimoRechazado';
  static String kTotal(int i) => 'trabajador${i}_total';
  static String kFirmaSalida(int i) => 'trabajador${i}_firmaSalida';
  static String kHoraSalida(int i) => 'trabajador${i}_horaSalida';
  static String kMotivoSalida(int i) => 'trabajador${i}_motivoSalida';
  static String kObservacionSalida(int i) => 'trabajador${i}_observacionSalida';

  static const Set<String> _headerKeys = {kLoteId, kCampaniaId};

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _laborOptions = [
    'PODA',
    'DESBROTE',
    'RALEO',
    'AMARRE',
    'LIMPIEZA',
    'COSECHA',
    'OTRO',
  ];

  static const List<String> motivoSalidaOptions = [
    'SALIDA POR SALUD.',
    'POR CUMPLIMIENTO DE TAREO',
    'NO CUMPLE.',
  ];

  static const List<String> _etapas = [];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  static const Set<String> _plusOneHeaderKeys = {kLoteId, kCampaniaId};

  static const Set<String> _plusOneBodyKeys = {
    kSupervisor,
    kSector,
    kActividadId,
    kActividadNombre,
    kLaborId,
    kLaborNombre,
    kLabor,
    kHoraInicio,
    kHoraFinal,
    kFecha,
    kCosto,
    kRendimiento,
  };

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  static final List<CartillaSectionConfig> _sections = [
    const CartillaSectionConfig(
      key: 'cabecera',
      title: 'CABECERA DE SUPERVISIÓN',
      fields: [
        CartillaFieldConfig(
          key: kSupervisor,
          label: 'Supervisor',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasSupervisor,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kSector,
          label: 'Sector',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kHoraInicio,
          label: 'Hora inicio',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kLoteId,
          label: 'Lote',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kHoraFinal,
          label: 'Hora final',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kFecha,
          label: 'Fecha',
          type: CartillaFieldType.shortText,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kActividadNombre,
          label: 'Tipo de labor',
          type: CartillaFieldType.dropdown,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kLabor,
          label: 'Labor',
          type: CartillaFieldType.dropdown,
          staticOptions: _laborOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCampaniaId,
          label: 'Campaña',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCosto,
          label: 'Costo',
          type: CartillaFieldType.decimalNumber,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kRendimiento,
          label: 'Rendimiento',
          type: CartillaFieldType.decimalNumber,
          rules: CartillaFieldRules(copyOnPlus1: true),
        ),
      ],
    ),
    for (var i = 1; i <= 6; i++) _trabajadorSection(i),
    const CartillaSectionConfig(
      key: 'resumen',
      title: 'RESUMEN Y APROBACIÓN',
      fields: [
        CartillaFieldConfig(
          key: kTotalPlantasORacimos,
          label: 'Total plantas o racimos',
          type: CartillaFieldType.decimalReadOnly,
        ),
        CartillaFieldConfig(
          key: kRendimientoPromedioJornal,
          label: 'Rendimiento promedio jornal',
          type: CartillaFieldType.decimalReadOnly,
        ),
        CartillaFieldConfig(
          key: kNumeroTrabajadores,
          label: 'N° trabajadores',
          type: CartillaFieldType.decimalReadOnly,
        ),
        CartillaFieldConfig(
          key: kFirmaSupervisor,
          label: 'V°B° Supervisor',
          type: CartillaFieldType.signaturePad,
        ),
        CartillaFieldConfig(
          key: kFirmaProduccion,
          label: 'V°B° Producción',
          type: CartillaFieldType.signaturePad,
        ),
        CartillaFieldConfig(
          key: kObservaciones,
          label: 'Observaciones',
          type: CartillaFieldType.longText,
        ),
      ],
    ),
  ];

  static CartillaSectionConfig _trabajadorSection(int i) {
    return CartillaSectionConfig(
      key: 'trabajador_$i',
      title: 'TRABAJADOR $i',
      fields: [
        CartillaFieldConfig(
          key: kNombre(i),
          label: 'Apellidos y nombres',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.personasJornal,
        ),
        CartillaFieldConfig(
          key: kDni(i),
          label: 'DNI',
          type: CartillaFieldType.intNumber,
        ),
        CartillaFieldConfig(
          key: kFirmaEntrada(i),
          label: 'Firma entrada',
          type: CartillaFieldType.signaturePad,
        ),
        CartillaFieldConfig(
          key: kHilera(i),
          label: 'Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(maxDigits: 3),
        ),
        CartillaFieldConfig(
          key: kPlantasInicio(i),
          label: 'Plantas inicio',
          type: CartillaFieldType.intNumber,
        ),
        CartillaFieldConfig(
          key: kPlantasFinal(i),
          label: 'Plantas final',
          type: CartillaFieldType.intNumber,
        ),
        CartillaFieldConfig(
          key: kSubtotal(i),
          label: 'Subtotal',
          type: CartillaFieldType.decimalReadOnly,
        ),
        CartillaFieldConfig(
          key: kPlantasRechazadas(i),
          label: 'Plantas / racimo rechazado',
          type: CartillaFieldType.intNumber,
        ),
        CartillaFieldConfig(
          key: kTotal(i),
          label: 'Total',
          type: CartillaFieldType.decimalReadOnly,
        ),
        CartillaFieldConfig(
          key: kFirmaSalida(i),
          label: 'Firma salida',
          type: CartillaFieldType.signaturePad,
        ),
      ],
    );
  }

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
