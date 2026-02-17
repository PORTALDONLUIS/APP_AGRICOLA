// lib/features/fitosanidad/domain/cartilla_fito_config.dart
//
// Config declarativa: Cartilla Fitosanidad (73 campos)
// ✅ ESTÁNDAR BROTACIÓN: header/body Map (motor genérico)
// ✅ headerKeys MINIMO (campania/lote/lat/lon/fechaEjecucion)
// ✅ todo lo demás vive en BODY


import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaFitoConfig implements CartillaFormConfig {
  // ========= Identidad =========
  static const String _templateKey = 'cartilla_fito';
  static const int _payloadVersion = 1;
  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  // ========= Keys =========
  // Header (mínimo estándar)
  static const String kCampaniaId = 'campaniaId';
  static const String kLoteId = 'loteId';
  static const String kLat = 'lat';
  static const String kLon = 'lon';
  static const String kFechaEjecucion = 'fechaEjecucion';

  // Body (campos propios de fitosanidad)
  static const String kEtapaFenologicaId = 'etapaFenologicaId';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';
  static const String kNMuestras = 'nMuestras';
  static const String kNBrotes = 'nBrotes';

  // ✅ HeaderKeys: SOLO lo estructural (para que el motor no pierda campos)
  static const Set<String> _headerKeys = {
    kCampaniaId,
    kLoteId,
    kLat,
    kLon,
    kFechaEjecucion,
  };

  @override
  Set<String> get headerKeys => _headerKeys;

  // ========= Etapa fenológica (static options) =========
  static const List<String> _etapas = [
    '01. Hojas Extendidasssss',
    '02. Racimo Visible',
    '03. Racimos Separados',
    '04. Boton Floral separado',
    '05. Inicio de Floración',
    '06. Floración',
    '07. Inicio de Cuaja',
    '08. Cuaja',
    '09. Crecimiento de Bayas',
    '10. Inicio de Engome',
    '11. Engome',
    '12. Inicio de Madurez',
    '13. Maduración',
    '14. Cosecha',
    '15. Post Cosecha',
    '16. Formacion',
  ];

  @override
  List<String> get etapaFenologicaOptions => _etapas;

  // ========= (+1) replicables =========
  // ✅ Header: copiar contexto (sin fechaEjecucion, se resetea)
  static const Set<String> _plusOneHeaderKeys = {
    kCampaniaId,
    kLoteId,
    kLat,
    kLon,
  };

  // ✅ Body: copiar SOLO lo que debe replicarse (según copyOnPlus1 de tu form)
  static const Set<String> _plusOneBodyKeys = {
    kEtapaFenologicaId,
    kNMuestras,
    kNBrotes,
  };

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  // ========= Sections =========
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
          key: kEtapaFenologicaId,
          label: '2. Etapa fenológica',
          type: CartillaFieldType.dropdown,
          staticOptions: _etapas,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCampaniaId,
          label: '3. Campaña',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kHilera,
          label: '4. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),
        CartillaFieldConfig(
          key: kPlanta,
          label: '5. Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'pauta',
      title: 'PAUTA',
      fields: [
        CartillaFieldConfig(
          key: kNMuestras,
          label: '6. N muestras',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kNBrotes,
          label: '7. N brotes-hojas-racimo',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 1, copyOnPlus1: true),
        ),
      ],
    ),

    // ====== Desde aquí tu body de 8..62 sigue igual (no lo toco) ======
    CartillaSectionConfig(
      key: 'thrips_brote',
      title: 'THRIPS-BROTE',
      fields: [
        CartillaFieldConfig(
          key: 'thrips_brote_1_nro_brote',
          label: '8. 1.Nro. Brote',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'thrips_brote_1_nro_individuo',
          label: '9. 1.Nro. Individuo',
          type: CartillaFieldType.stepperInt,
        ),
      ],
    ),

    // 👇 El resto de secciones/campos (PULGON, ARAÑA, MILDIU, etc.)
    // se queda exactamente como lo tienes en tu archivo original.

    CartillaSectionConfig(
      key: 'pulgon_brote',
      title: 'PULGON-BROTE',
      fields: [
        CartillaFieldConfig(
          key: 'pulgon_brote_2_nro_brote',
          label: '10. 2.Nro. Brote',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'pulgon_brote_2_grado',
          label: '11. 2.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 3),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'arana_roja_brote',
      title: 'ARAÑA ROJA-BROTE',
      fields: [
        CartillaFieldConfig(
          key: 'arana_roja_brote_3_grado',
          label: '12. 3.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 3),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'mildiu_brote',
      title: 'MILDIU-BROTE',
      fields: [
        CartillaFieldConfig(
          key: 'mildiu_brote_4_grado',
          label: '13. 4.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 4),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'botrytis_brote',
      title: 'BOTRYTIS-BROTE',
      fields: [
        CartillaFieldConfig(
          key: 'botrytis_brote_5_grado',
          label: '14. 5.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 3),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'oidio_brote',
      title: 'OIDIO-BROTE',
      fields: [
        CartillaFieldConfig(
          key: 'oidio_brote_6_nro_brote',
          label: '15. 6.Nro. Brote',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'oidio_brote_6_grado',
          label: '16. 6.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 4),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'acaro_yemas_brote',
      title: 'ACARO DE LAS YEMAS-BROTE',
      fields: [
        CartillaFieldConfig(
          key: 'acaro_yemas_brote_7_grado',
          label: '17. 7.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 3),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'fomopis_brote',
      title: 'FOMOPIS-BROTE',
      fields: [
        CartillaFieldConfig(
          key: 'fomopis_brote_8_grado',
          label: '18. 8.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 3),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'thrips_hoja',
      title: 'THRIPS-HOJA',
      fields: [
        CartillaFieldConfig(
          key: 'thrips_hoja_9_nro_hoja',
          label: '19. 9.Nro. Hoja',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'thrips_hoja_9_nro_individuo',
          label: '20. 9.Nro. Individuo',
          type: CartillaFieldType.stepperInt,
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'pulgon_hoja',
      title: 'PULGON-HOJA',
      fields: [
        CartillaFieldConfig(
          key: 'pulgon_hoja_10_nro_hoja',
          label: '21. 10.Nro. Hoja',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'pulgon_hoja_10_grado',
          label: '22. 10.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 3),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'chanchito_blanco_hoja',
      title: 'CHANCHITO BLANCO-HOJA',
      fields: [
        CartillaFieldConfig(
          key: 'chanchito_blanco_hoja_11_grado',
          label: '23. 11.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 3),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'arana_roja_hoja',
      title: 'ARAÑA ROJA-HOJA',
      fields: [
        CartillaFieldConfig(
          key: 'arana_roja_hoja_12_grado',
          label: '24. 12.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 3),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'mildiu_hoja',
      title: 'MILDIU-HOJA',
      fields: [
        CartillaFieldConfig(
          key: 'mildiu_hoja_13_grado',
          label: '25. 13.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 4),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'botrytis_hoja',
      title: 'BOTRYTIS-HOJA',
      fields: [
        CartillaFieldConfig(
          key: 'botrytis_hoja_14_grado',
          label: '26. 14.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 3),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'oidio_hoja',
      title: 'OIDIO-HOJA',
      fields: [
        CartillaFieldConfig(
          key: 'oidio_hoja_15_grado',
          label: '27. 15.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 4),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'lobesia_botrana_hoja',
      title: 'LOBESIA BOTRANA-HOJA',
      fields: [
        CartillaFieldConfig(
          key: 'lobesia_botrana_hoja_16_grado',
          label: '28. 16.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 4),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'lobesia_botrana_racimo',
      title: 'LOBESIA BOTRANA-RACIMO',
      fields: [
        CartillaFieldConfig(
          key: 'lobesia_botrana_racimo_17_grado',
          label: '29. 17.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 4),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'chanchito_blanco_racimo',
      title: 'CHANCHITO BLANCO-RACIMO',
      fields: [
        CartillaFieldConfig(
          key: 'chanchito_blanco_racimo_18_grado',
          label: '30. 18.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 3),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'pudricion_acida_racimo',
      title: 'PUDRICION ACIDA-RACIMO',
      fields: [
        CartillaFieldConfig(
          key: 'pudricion_acida_racimo_19_grado',
          label: '31. 19.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 3),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'botrytis_racimo',
      title: 'BOTRYTIS-RACIMO',
      fields: [
        CartillaFieldConfig(
          key: 'botrytis_racimo_20_grado',
          label: '32. 20.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 3),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'oidio_racimo',
      title: 'OIDIO-RACIMO',
      fields: [
        CartillaFieldConfig(
          key: 'oidio_racimo_21_grado',
          label: '33. 21.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 4),
        ),
      ],
    ),
    CartillaSectionConfig(
      key: 'mildiu_racimo',
      title: 'MILDIU-RACIMO',
      fields: [
        CartillaFieldConfig(
          key: 'mildiu_racimo_22_grado',
          label: '34. 22.Grado',
          type: CartillaFieldType.stepperInt,
          rules: CartillaFieldRules(minValue: 1, maxValue: 4),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'variedad',
      title: 'VARIEDAD',
      fields: [
        CartillaFieldConfig(
          key: 'variedad_23_flame',
          label: '35. 23.Flame',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'variedad_24_redglobe',
          label: '36. 24.RedGlobe',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'variedad_25_crimson',
          label: '37. 25.Crimson',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'variedad_26_sugraone',
          label: '38. 26.Sugraone',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'variedad_27_italia',
          label: '39. 27.Italia',
          type: CartillaFieldType.stepperInt,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'cubierta',
      title: 'CUBIERTA',
      fields: [
        CartillaFieldConfig(
          key: 'cubierta_28_malla',
          label: '40. 28.Malla',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'cubierta_29_manta',
          label: '41. 29.Manta',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'cubierta_30_sin_cubierta',
          label: '42. 30.Sin cubierta',
          type: CartillaFieldType.stepperInt,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'aplicacion',
      title: 'APLICACION',
      fields: [
        CartillaFieldConfig(
          key: 'aplicacion_31_foliar',
          label: '43. 31.Foliar',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'aplicacion_32_suelo',
          label: '44. 32.Suelo',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'aplicacion_33_fertirriego',
          label: '45. 33.Fertirriego',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'aplicacion_34_azufre',
          label: '46. 34.Azufre',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'aplicacion_35_sulfuroso',
          label: '47. 35.Sulfuroso',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'aplicacion_36_ambos',
          label: '48. 36.Ambos',
          type: CartillaFieldType.stepperInt,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'clima',
      title: 'CLIMA',
      fields: [
        CartillaFieldConfig(
          key: 'clima_37_humedo',
          label: '49. 37.Humedo',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'clima_38_seco',
          label: '50. 38.Seco',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'clima_39_variable',
          label: '51. 39.Variable',
          type: CartillaFieldType.stepperInt,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'suelo',
      title: 'SUELO',
      fields: [
        CartillaFieldConfig(
          key: 'suelo_40_arenoso',
          label: '52. 40.Arenoso',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'suelo_41_arcilloso',
          label: '53. 41.Arcilloso',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'suelo_42_sin_materia_organica',
          label: '54. 42.Sin materia organica',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'suelo_43_con_materia_organica',
          label: '55. 43.Con materia organica',
          type: CartillaFieldType.stepperInt,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'vigor',
      title: 'VIGOR',
      fields: [
        CartillaFieldConfig(
          key: 'vigor_44_bajo',
          label: '56. 44.Bajo',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'vigor_45_normal',
          label: '57. 45.Normal',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'vigor_46_alto',
          label: '58. 46.Alto',
          type: CartillaFieldType.stepperInt,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'produccion',
      title: 'PRODUCCION',
      fields: [
        CartillaFieldConfig(
          key: 'produccion_47_baja',
          label: '59. 47.Baja',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'produccion_48_normal',
          label: '60. 48.Normal',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'produccion_49_alta',
          label: '61. 49.Alta',
          type: CartillaFieldType.stepperInt,
        ),
        CartillaFieldConfig(
          key: 'produccion_50_sobre_produccion',
          label: '62. 50.Sobre produccion',
          type: CartillaFieldType.stepperInt,
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'observaciones_fotos',
      title: 'OBSERVACIONES / FOTOS',
      fields: [
        CartillaFieldConfig(
          key: 'observaciones',
          label: '63. Observaciones',
          type: CartillaFieldType.longText,
        ),
        CartillaFieldConfig(key: 'foto_1', label: '64. Foto_1', type: CartillaFieldType.photo, photoIndex: 1),
        CartillaFieldConfig(key: 'foto_2', label: '65. Foto_2', type: CartillaFieldType.photo, photoIndex: 2),
        CartillaFieldConfig(key: 'foto_3', label: '66. Foto_3', type: CartillaFieldType.photo, photoIndex: 3),
        CartillaFieldConfig(key: 'foto_4', label: '67. Foto_4', type: CartillaFieldType.photo, photoIndex: 4),
        CartillaFieldConfig(key: 'foto_5', label: '68. Foto_5', type: CartillaFieldType.photo, photoIndex: 5),
        CartillaFieldConfig(key: 'foto_6', label: '69. Foto_6', type: CartillaFieldType.photo, photoIndex: 6),
        CartillaFieldConfig(key: 'foto_7', label: '70. Foto_7', type: CartillaFieldType.photo, photoIndex: 7),
        CartillaFieldConfig(key: 'foto_8', label: '71. Foto_8', type: CartillaFieldType.photo, photoIndex: 8),
        CartillaFieldConfig(key: 'foto_9', label: '72. Foto_9', type: CartillaFieldType.photo, photoIndex: 9),
        CartillaFieldConfig(key: 'foto_10', label: '73. Foto_10', type: CartillaFieldType.photo, photoIndex: 10),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;

  // ===== helpers opcionales =====
  static List<CartillaFieldConfig> allFields() => _sections.expand((s) => s.fields).toList();

  static bool isPhotoKey(String key) => key.startsWith('foto_');
}
