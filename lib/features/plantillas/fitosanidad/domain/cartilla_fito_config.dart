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
  // HEADER
  static const String kLoteId = 'loteId';
  static const String kCampaniaId = 'campaniaId';

  // BODY - datos generales / pauta
  static const String kEtapaFenologica = 'etapaFenologica';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';
  static const String kNMuestras = 'nMuestras';
  static const String kNBrotesHojasRacimo = 'nBrotesHojasRacimo';

  // THRIPS-BROTE
  static const String kThripsBroteNroBrote = 'thripsBrote_nroBrote';
  static const String kThripsBroteNroIndividuo = 'thripsBrote_nroIndividuo';

  // PULGON-BROTE
  static const String kPulgonBroteNroBrote = 'pulgonBrote_nroBrote';
  static const String kPulgonBroteGrado = 'pulgonBrote_grado';

  // OIDIUM-HOJAS
  static const String kOidiumHojasNroHojas = 'oidiumHojas_nroHojas';
  static const String kOidiumHojasGrado = 'oidiumHojas_grado';

  // MILDIUM-HOJAS
  static const String kMildiumHojasNroHojas = 'mildiumHojas_nroHojas';
  static const String kMildiumHojasGrado = 'mildiumHojas_grado';

  // ARAÑITA ROJA-HOJAS
  static const String kAranitaRojaHojasNroHoja = 'aranitaRojaHojas_nroHoja';
  static const String kAranitaRojaHojasGrado = 'aranitaRojaHojas_grado';

  // LEPIDOPTEROS-HOJAS
  static const String kLepidopterosHojasLarvasChicasNroHojas =
      'lepidopterosHojas_larvasChicasNroHojas';
  static const String kLepidopterosHojasLarvasChicasIndividuo =
      'lepidopterosHojas_larvasChicasIndividuo';
  static const String kLepidopterosHojasLarvasGrandesNroHojas =
      'lepidopterosHojas_larvasGrandesNroHojas';
  static const String kLepidopterosHojasLarvasGrandesIndividuo =
      'lepidopterosHojas_larvasGrandesIndividuo';

  // EUMORPHA (VITIS)-HOJAS
  static const String kEumorphaHojasLarvasChicasNroHojas =
      'eumorphaHojas_larvasChicasNroHojas';
  static const String kEumorphaHojasLarvasChicasIndividuo =
      'eumorphaHojas_larvasChicasIndividuo';
  static const String kEumorphaHojasLarvasGrandesNroHojas =
      'eumorphaHojas_larvasGrandesNroHojas';
  static const String kEumorphaHojasLarvasGrandesIndividuo =
      'eumorphaHojas_larvasGrandesIndividuo';

  // ACARO HIALINO-HOJAS
  static const String kAcaroHialinoHojasNroHoja = 'acaroHialinoHojas_nroHoja';
  static const String kAcaroHialinoHojasGrado = 'acaroHialinoHojas_grado';

  // FILOXERA-HOJAS
  static const String kFiloxeraHojasNroHoja = 'filoxeraHojas_nroHoja';
  static const String kFiloxeraHojasNroAgallas = 'filoxeraHojas_nroAgallas';

  // PSEUDOCOCUS-HOJAS
  static const String kPseudococusHojasNroHojas = 'pseudococusHojas_nroHojas';
  static const String kPseudococusHojasNroIndividuo =
      'pseudococusHojas_nroIndividuo';

  // MOSCA BLANCA-HOJAS
  static const String kMoscaBlancaHojasNroHoja = 'moscaBlancaHojas_nroHoja';
  static const String kMoscaBlancaHojasGrado = 'moscaBlancaHojas_grado';

  // SCOLYTUS-TALLO
  static const String kScolytusTalloTotalZonaPorPlanta =
      'scolytusTallo_totalZonaPorPlanta';

  // PSEUDOCOCCUS-TALLO
  static const String kPseudococcusTalloTotalZonaPorPlanta =
      'pseudococcusTallo_totalZonaPorPlanta';

  // QUERESA-HOJAS
  static const String kQueresaHojasNroHojas = 'queresaHojas_nroHojas';
  static const String kQueresaHojasNroIndividuo = 'queresaHojas_nroIndividuo';

  // THRIPS-FLORES
  static const String kThripsFloresNroRacimos = 'thripsFlores_nroRacimos';
  static const String kThripsFloresNroIndividuo = 'thripsFlores_nroIndividuo';

  // BOTRYTIS-FLORES
  static const String kBotrytisFloresNroRacimos = 'botrytisFlores_nroRacimos';
  static const String kBotrytisFloresGrado = 'botrytisFlores_grado';

  // PSEUDOCOCUS-FRUTO
  static const String kPseudococusFrutoNroRacimos =
      'pseudococusFruto_nroRacimos';

  // OIDIUM-FRUTOS
  static const String kOidiumFrutosNroRacimos = 'oidiumFrutos_nroRacimos';
  static const String kOidiumFrutosGrado = 'oidiumFrutos_grado';

  // MILDIU-FRUTOS
  static const String kMildiuFrutosNroRacimos = 'mildiuFrutos_nroRacimos';
  static const String kMildiuFrutosGrado = 'mildiuFrutos_grado';

  // BOTRYTIS-FRUTOS
  static const String kBotrytisFrutosNroRacimos = 'botrytisFrutos_nroRacimos';
  static const String kBotrytisFrutosGrado = 'botrytisFrutos_grado';

  // PUDRICION ACIDAS-FRUTOS
  static const String kPudricionAcidasFrutosNroRacimos =
      'pudricionAcidasFrutos_nroRacimos';
  static const String kPudricionAcidasFrutosGrado =
      'pudricionAcidasFrutos_grado';

  // PALO NEGRO-FRUTOS
  static const String kPaloNegroFrutosNroRacimos =
      'paloNegroFrutos_nroRacimos';
  static const String kPaloNegroFrutosGrado = 'paloNegroFrutos_grado';

  // DAÑO DE AVES-FRUTOS
  static const String kDanoAvesFrutosNroRacimos = 'danoAvesFrutos_nroRacimos';
  static const String kDanoAvesFrutosGrado = 'danoAvesFrutos_grado';

  // PARTIDURAS-FRUTOS
  static const String kPartidurasFrutosNroRacimos =
      'partidurasFrutos_nroRacimos';
  static const String kPartidurasFrutosGrado = 'partidurasFrutos_grado';

  // CARACHA-FRUTOS
  static const String kCarachaFrutosNroRacimos = 'carachaFrutos_nroRacimos';
  static const String kCarachaFrutosGrado = 'carachaFrutos_grado';

  // COLAPSO-FRUTOS
  static const String kColapsoFrutosNroRacimos = 'colapsoFrutos_nroRacimos';
  static const String kColapsoFrutosGrado = 'colapsoFrutos_grado';

  // EMPOASKA-HOJAS
  static const String kEmpoaskaHojasNroHojas = 'empoaskaHojas_nroHojas';
  static const String kEmpoaskaHojasNroIndividuo = 'empoaskaHojas_nroIndividuo';

  // OBS / FOTOS
  static const String kObservaciones = 'observaciones';
  static const String kFoto1 = 'foto1';
  static const String kFoto2 = 'foto2';
  static const String kFoto3 = 'foto3';
  static const String kFoto4 = 'foto4';
  static const String kFoto5 = 'foto5';
  static const String kFoto6 = 'foto6';
  static const String kFoto7 = 'foto7';
  static const String kFoto8 = 'foto8';
  static const String kFoto9 = 'foto9';
  static const String kFoto10 = 'foto10';

  // ========= Header keys =========
  static const Set<String> _headerKeys = {
    kLoteId,
    kCampaniaId,
  };

  @override
  Set<String> get headerKeys => _headerKeys;

  static const List<String> _campaniaOptions = [
    'CAMP2026',
  ];

  static const List<String> _etapaFenologicaOptions = [
    '01. Hojas Extendidas',
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
  List<String> get etapaFenologicaOptions => _etapaFenologicaOptions;

  static const Set<String> _plusOneHeaderKeys = {
    kLoteId,
    kCampaniaId,
  };

  static const Set<String> _plusOneBodyKeys = {
    kEtapaFenologica,
    kNMuestras,
    kNBrotesHojasRacimo,
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
          key: kEtapaFenologica,
          label: '2. Etapa fenológica',
          type: CartillaFieldType.dropdown,
          staticOptions: _etapaFenologicaOptions,
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
          key: kNBrotesHojasRacimo,
          label: '7. N brotes-hojas-racimo',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 1, copyOnPlus1: true),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'thrips_brote',
      title: 'THRIPS-BROTE',
      fields: [
        CartillaFieldConfig(key: kThripsBroteNroBrote, label: '8. 1.Nro. Brote', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kThripsBroteNroIndividuo, label: '9. 1.Nro. Individuo', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'pulgon_brote',
      title: 'PULGON-BROTE',
      fields: [
        CartillaFieldConfig(key: kPulgonBroteNroBrote, label: '10. 2.Nro. Brote', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kPulgonBroteGrado, label: '11. 2.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'oidium_hojas',
      title: 'OIDIUM-HOJAS',
      fields: [
        CartillaFieldConfig(key: kOidiumHojasNroHojas, label: '12. 3.Nro. Hojas', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kOidiumHojasGrado, label: '13. 3.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'mildium_hojas',
      title: 'MILDIUM-HOJAS',
      fields: [
        CartillaFieldConfig(key: kMildiumHojasNroHojas, label: '14. 4.Nro. Hojas', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kMildiumHojasGrado, label: '15. 4.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'aranita_roja_hojas',
      title: 'ARAÑITA ROJA-HOJAS',
      fields: [
        CartillaFieldConfig(key: kAranitaRojaHojasNroHoja, label: '16. 5.Nro. Hoja', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kAranitaRojaHojasGrado, label: '17. 5.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'lepidopteros_hojas',
      title: 'LEPIDOPTEROS-HOJAS',
      fields: [
        CartillaFieldConfig(key: kLepidopterosHojasLarvasChicasNroHojas, label: '18. 6.Larvas chicas-Nro. Hojas', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kLepidopterosHojasLarvasChicasIndividuo, label: '19. 6.Larvas chicas-Individuo', type: CartillaFieldType.intNumber),
        CartillaFieldConfig(key: kLepidopterosHojasLarvasGrandesNroHojas, label: '20. 6.Larvas grandes-Nro. Hojas', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kLepidopterosHojasLarvasGrandesIndividuo, label: '21. 6.Larvas grandes-Individuo', type: CartillaFieldType.intNumber),
      ],
    ),

    CartillaSectionConfig(
      key: 'eumorpha_hojas',
      title: 'EUMORPHA (VITIS)-HOJAS',
      fields: [
        CartillaFieldConfig(key: kEumorphaHojasLarvasChicasNroHojas, label: '22. 7.Larvas chicas-Nro. Hojas', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kEumorphaHojasLarvasChicasIndividuo, label: '23. 7.Larvas chicas-Individuo', type: CartillaFieldType.intNumber),
        CartillaFieldConfig(key: kEumorphaHojasLarvasGrandesNroHojas, label: '24. 7.Larvas grandes-Nro. Hojas', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kEumorphaHojasLarvasGrandesIndividuo, label: '25. 7.Larvas grandes-Individuo', type: CartillaFieldType.intNumber),
      ],
    ),

    CartillaSectionConfig(
      key: 'acaro_hialino_hojas',
      title: 'ACARO HIALINO-HOJAS',
      fields: [
        CartillaFieldConfig(key: kAcaroHialinoHojasNroHoja, label: '26. 8.Nro. Hoja', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kAcaroHialinoHojasGrado, label: '27. 8.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'filoxera_hojas',
      title: 'FILOXERA-HOJAS',
      fields: [
        CartillaFieldConfig(key: kFiloxeraHojasNroHoja, label: '28. 9.Nro. Hoja', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kFiloxeraHojasNroAgallas, label: '29. 9.Nro.de Agallas', type: CartillaFieldType.intNumber),
      ],
    ),

    CartillaSectionConfig(
      key: 'pseudococus_hojas',
      title: 'PSEUDOCOCUS-HOJAS',
      fields: [
        CartillaFieldConfig(key: kPseudococusHojasNroHojas, label: '30. 10.Nro. Hojas', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kPseudococusHojasNroIndividuo, label: '31. 10.Nro. Individuo', type: CartillaFieldType.intNumber),
      ],
    ),

    CartillaSectionConfig(
      key: 'mosca_blanca_hojas',
      title: 'MOSCA BLANCA-HOJAS',
      fields: [
        CartillaFieldConfig(key: kMoscaBlancaHojasNroHoja, label: '32. 11.Nro. Hoja', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kMoscaBlancaHojasGrado, label: '33. 11.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'scolytus_tallo',
      title: 'SCOLYTUS-TALLO',
      fields: [
        CartillaFieldConfig(key: kScolytusTalloTotalZonaPorPlanta, label: '34. 12.Total de Zona-Por Planta', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'pseudococcus_tallo',
      title: 'PSEUDOCOCCUS-TALLO',
      fields: [
        CartillaFieldConfig(key: kPseudococcusTalloTotalZonaPorPlanta, label: '35. 13.Total de Zona-Por Planta', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'queresa_hojas',
      title: 'QUERESA-HOJAS',
      fields: [
        CartillaFieldConfig(key: kQueresaHojasNroHojas, label: '36. 14.Nro. Hojas', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kQueresaHojasNroIndividuo, label: '37. 14.Nro. Individuo', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'thrips_flores',
      title: 'THRIPS-FLORES',
      fields: [
        CartillaFieldConfig(key: kThripsFloresNroRacimos, label: '38. 15.Nro. Racimos (Flores)', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kThripsFloresNroIndividuo, label: '39. 15.Nro. Individuo', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'botrytis_flores',
      title: 'BOTRYTIS-FLORES',
      fields: [
        CartillaFieldConfig(key: kBotrytisFloresNroRacimos, label: '40. 16.Nro. Racimos (Flores)', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kBotrytisFloresGrado, label: '41. 16.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'pseudococus_fruto',
      title: 'PSEUDOCOCUS-FRUTO',
      fields: [
        CartillaFieldConfig(key: kPseudococusFrutoNroRacimos, label: '42. 17. Nro. Racimos', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'oidium_frutos',
      title: 'OIDIUM-FRUTOS',
      fields: [
        CartillaFieldConfig(key: kOidiumFrutosNroRacimos, label: '43. 18.Nro. Racimos', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kOidiumFrutosGrado, label: '44. 18.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'mildiu_frutos',
      title: 'MILDIU-FRUTOS',
      fields: [
        CartillaFieldConfig(key: kMildiuFrutosNroRacimos, label: '45. 19.Nro. Racimos', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kMildiuFrutosGrado, label: '46. 19.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'botrytis_frutos',
      title: 'BOTRYTIS-FRUTOS',
      fields: [
        CartillaFieldConfig(key: kBotrytisFrutosNroRacimos, label: '47. 20.Nro. Racimos', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kBotrytisFrutosGrado, label: '48. 20.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'pudricion_acidas_frutos',
      title: 'PUDRICION ACIDAS-FRUTOS',
      fields: [
        CartillaFieldConfig(key: kPudricionAcidasFrutosNroRacimos, label: '49. 21. Nro. Racimos', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kPudricionAcidasFrutosGrado, label: '50. 21.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'palo_negro_frutos',
      title: 'PALO NEGRO-FRUTOS',
      fields: [
        CartillaFieldConfig(key: kPaloNegroFrutosNroRacimos, label: '51. 22.Nro. Racimos', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kPaloNegroFrutosGrado, label: '52. 22.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'dano_aves_frutos',
      title: 'DAÑO DE AVES-FRUTOS',
      fields: [
        CartillaFieldConfig(key: kDanoAvesFrutosNroRacimos, label: '53. 23.Nro. Racimos', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kDanoAvesFrutosGrado, label: '54. 23.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'partiduras_frutos',
      title: 'PARTIDURAS-FRUTOS',
      fields: [
        CartillaFieldConfig(key: kPartidurasFrutosNroRacimos, label: '55. 24.Nro. Racimos', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kPartidurasFrutosGrado, label: '56. 24.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'caracha_frutos',
      title: 'CARACHA-FRUTOS',
      fields: [
        CartillaFieldConfig(key: kCarachaFrutosNroRacimos, label: '57. 25. Nro. Racimos', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kCarachaFrutosGrado, label: '58. 25.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'colapso_frutos',
      title: 'COLAPSO-FRUTOS',
      fields: [
        CartillaFieldConfig(key: kColapsoFrutosNroRacimos, label: '59. 26.Nro. Racimos', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kColapsoFrutosGrado, label: '60. 26.Grado', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'empoaska_hojas',
      title: 'EMPOASKA-HOJAS',
      fields: [
        CartillaFieldConfig(key: kEmpoaskaHojasNroHojas, label: '61. 23.Nro. HOJAS', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
        CartillaFieldConfig(key: kEmpoaskaHojasNroIndividuo, label: '62. 23.Nro. Individuo', type: CartillaFieldType.stepperInt, rules: CartillaFieldRules(minValue: 0)),
      ],
    ),

    CartillaSectionConfig(
      key: 'observaciones_fotos',
      title: 'OBSERVACIONES / FOTOS',
      fields: [
        CartillaFieldConfig(
          key: kObservaciones,
          label: '63. Observaciones',
          type: CartillaFieldType.longText,
        ),
        CartillaFieldConfig(key: kFoto1, label: '64. Foto_1', type: CartillaFieldType.photo),
        CartillaFieldConfig(key: kFoto2, label: '65. Foto_2', type: CartillaFieldType.photo),
        CartillaFieldConfig(key: kFoto3, label: '66. Foto_3', type: CartillaFieldType.photo),
        CartillaFieldConfig(key: kFoto4, label: '67. Foto_4', type: CartillaFieldType.photo),
        CartillaFieldConfig(key: kFoto5, label: '68. Foto_5', type: CartillaFieldType.photo),
        CartillaFieldConfig(key: kFoto6, label: '69. Foto_6', type: CartillaFieldType.photo),
        CartillaFieldConfig(key: kFoto7, label: '70. Foto_7', type: CartillaFieldType.photo),
        CartillaFieldConfig(key: kFoto8, label: '71. Foto_8', type: CartillaFieldType.photo),
        CartillaFieldConfig(key: kFoto9, label: '72. Foto_9', type: CartillaFieldType.photo),
        CartillaFieldConfig(key: kFoto10, label: '73. Foto_10', type: CartillaFieldType.photo),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}