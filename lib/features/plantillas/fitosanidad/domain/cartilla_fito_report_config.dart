import '../../../cartillas/domain/report/cartilla_report_config.dart';
import 'cartilla_fito_config.dart';

final cartillaFitoReportConfig = CartillaReportConfig(
  templateKey: CartillaFitoConfig.templateKeyStatic,
  title: 'FITOSANIDAD',
  dailyReport: true,
  transposeMetrics: true,
  allowedEstados: const ['borrador', 'pendienteSync', 'enviado', 'error'],
  groupBy: [
    ReportGroupByConfig(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaFitoConfig.kLoteId}',
    ),
  ],
  columns: [
    ReportColumnConfig.dimension(
      key: 'lote',
      label: 'Lote',
      path: 'header.${CartillaFitoConfig.kLoteId}',
    ),
    ReportColumnConfig.metric(
      key: 'totalMuestras',
      label: 'Total de Muestras',
      path: 'header.${CartillaFitoConfig.kLoteId}',
      aggregation: ReportAggregationType.countRows,
      format: 'int',
    ),
    _scaleBy(
      sourceKey: 'totalMuestras',
      key: '_denTotalX4',
      factor: 4,
      hidden: true,
    ),
    _scaleBy(
      sourceKey: 'totalMuestras',
      key: '_denTotalX100',
      factor: 100,
      hidden: true,
    ),
    _scaleBy(
      sourceKey: '_denTotalX100',
      key: '_denTotalX400',
      factor: 4,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumThripsBroteNroIndividuo',
      path: CartillaFitoConfig.kThripsBroteNroIndividuo,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumThripsBroteNroBrote',
      path: CartillaFitoConfig.kThripsBroteNroBrote,
      hidden: true,
    ),
    _promMetric(
      'promThripsBrote',
      'Prom.THRIPS BROTE',
      '_sumThripsBroteNroIndividuo',
    ),
    _percentMetric(
      'porcThripsBrote',
      '%THRIPS BROTE',
      '_sumThripsBroteNroBrote',
    ),
    _sumMetric(
      key: '_sumPulgonBroteNroBrote',
      path: CartillaFitoConfig.kPulgonBroteNroBrote,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumPulgonBroteGrado',
      path: CartillaFitoConfig.kPulgonBroteGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countPulgonBroteGrado',
      path: CartillaFitoConfig.kPulgonBroteGrado,
      hidden: true,
    ),
    _percentMetric('porcPulgon', '%PULGON', '_sumPulgonBroteNroBrote'),
    _gradMetric(
      'gradPulgon',
      'Grad.PULGON',
      '_sumPulgonBroteGrado',
      '_countPulgonBroteGrado',
    ),
    _sumMetric(
      key: '_sumOidiumHojasNroHojas',
      path: CartillaFitoConfig.kOidiumHojasNroHojas,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumOidiumHojasGrado',
      path: CartillaFitoConfig.kOidiumHojasGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countOidiumHojasGrado',
      path: CartillaFitoConfig.kOidiumHojasGrado,
      hidden: true,
    ),
    _percentMetric(
      'porcOidiumHojas',
      '%OIDIUM HOJAS',
      '_sumOidiumHojasNroHojas',
    ),
    _gradMetric(
      'gradOidiumHojas',
      'Grad.OIDIUM HOJAS',
      '_sumOidiumHojasGrado',
      '_countOidiumHojasGrado',
    ),
    _sumMetric(
      key: '_sumMildiumHojasNroHojas',
      path: CartillaFitoConfig.kMildiumHojasNroHojas,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumMildiumHojasGrado',
      path: CartillaFitoConfig.kMildiumHojasGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countMildiumHojasGrado',
      path: CartillaFitoConfig.kMildiumHojasGrado,
      hidden: true,
    ),
    _percentMetric(
      'porcMildiumHojas',
      '%MILDIUM-HOJAS',
      '_sumMildiumHojasNroHojas',
    ),
    _gradMetric(
      'gradMildiumHojas',
      'Grad.MILDIUM-HOJAS',
      '_sumMildiumHojasGrado',
      '_countMildiumHojasGrado',
    ),
    _sumMetric(
      key: '_sumAranitaRojaHojasNroHoja',
      path: CartillaFitoConfig.kAranitaRojaHojasNroHoja,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumAranitaRojaHojasGrado',
      path: CartillaFitoConfig.kAranitaRojaHojasGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countAranitaRojaHojasGrado',
      path: CartillaFitoConfig.kAranitaRojaHojasGrado,
      hidden: true,
    ),
    _percentMetric(
      'porcAranitaRoja',
      '%ARAÑITA ROJA',
      '_sumAranitaRojaHojasNroHoja',
    ),
    _gradMetric(
      'gradAranitaRoja',
      'Grad.ARAÑITA ROJA',
      '_sumAranitaRojaHojasGrado',
      '_countAranitaRojaHojasGrado',
    ),
    _sumMetric(
      key: '_sumLepLcNroHojas',
      path: CartillaFitoConfig.kLepidopterosHojasLarvasChicasNroHojas,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumLepLcIndividuo',
      path: CartillaFitoConfig.kLepidopterosHojasLarvasChicasIndividuo,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumLepLgNroHojas',
      path: CartillaFitoConfig.kLepidopterosHojasLarvasGrandesNroHojas,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumLepLgIndividuo',
      path: CartillaFitoConfig.kLepidopterosHojasLarvasGrandesIndividuo,
      hidden: true,
    ),
    _promMetricPerPlant(
      'promLcLepHojas',
      'Prom.LC LEPIDOPTEROS HOJAS',
      '_sumLepLcIndividuo',
    ),
    _percentMetric(
      'porcLcLepHojas',
      '%LC LEPIDOPTEROS HOJAS',
      '_sumLepLcNroHojas',
    ),
    _promMetricPerPlant(
      'promLgLepHojas',
      'Prom.LG LEPIDOPTEROS HOJAS',
      '_sumLepLgIndividuo',
    ),
    _percentMetric(
      'porcLgLepHojas',
      '%LG LEPIDOPTEROS HOJAS',
      '_sumLepLgNroHojas',
    ),
    _sumMetric(
      key: '_sumEumLcNroHojas',
      path: CartillaFitoConfig.kEumorphaHojasLarvasChicasNroHojas,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumEumLcIndividuo',
      path: CartillaFitoConfig.kEumorphaHojasLarvasChicasIndividuo,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumEumLgNroHojas',
      path: CartillaFitoConfig.kEumorphaHojasLarvasGrandesNroHojas,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumEumLgIndividuo',
      path: CartillaFitoConfig.kEumorphaHojasLarvasGrandesIndividuo,
      hidden: true,
    ),
    _promMetricPerPlant(
      'promLcEumorphaVitis',
      'Prom.LC EUMORPHA VITIS',
      '_sumEumLcIndividuo',
    ),
    _percentMetric(
      'porcLcEumorphaVitis',
      '%LC EUMORPHA VITIS',
      '_sumEumLcNroHojas',
    ),
    _promMetricPerPlant(
      'promLgEumorphaVitis',
      'Prom.LG EUMORPHA-VITIS',
      '_sumEumLgIndividuo',
    ),
    _percentMetric(
      'porcLgEumorphaVitis',
      '%LG EUMORPHA-VITIS',
      '_sumEumLgNroHojas',
    ),
    _sumMetric(
      key: '_sumAcaroHialinoNroHoja',
      path: CartillaFitoConfig.kAcaroHialinoHojasNroHoja,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumAcaroHialinoGrado',
      path: CartillaFitoConfig.kAcaroHialinoHojasGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countAcaroHialinoGrado',
      path: CartillaFitoConfig.kAcaroHialinoHojasGrado,
      hidden: true,
    ),
    _percentMetric(
      'porcAcaroHialino',
      '%ACARO HIALINO',
      '_sumAcaroHialinoNroHoja',
    ),
    _gradMetric(
      'gradAcaroHialino',
      'Grad.ACARO HIALINO',
      '_sumAcaroHialinoGrado',
      '_countAcaroHialinoGrado',
    ),
    _sumMetric(
      key: '_sumFiloxeraNroHoja',
      path: CartillaFitoConfig.kFiloxeraHojasNroHoja,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumFiloxeraNroAgallas',
      path: CartillaFitoConfig.kFiloxeraHojasNroAgallas,
      hidden: true,
    ),
    _promMetric('promFiloxera', 'Prom.FILOXERA', '_sumFiloxeraNroAgallas'),
    _percentMetric('porcFiloxera', '%FILOXERA', '_sumFiloxeraNroHoja'),
    _sumMetric(
      key: '_sumPseudococusHojasNroHojas',
      path: CartillaFitoConfig.kPseudococusHojasNroHojas,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumPseudococusHojasNroIndividuo',
      path: CartillaFitoConfig.kPseudococusHojasNroIndividuo,
      hidden: true,
    ),
    _promMetric(
      'promPseudococcusHojas',
      'Prom.PSEUDOCOCCUS HOJAS',
      '_sumPseudococusHojasNroIndividuo',
    ),
    _percentMetric(
      'porcPseudococcusHojas',
      '%PSEUDOCOCCUS HOJAS',
      '_sumPseudococusHojasNroHojas',
    ),
    _sumMetric(
      key: '_sumMoscaBlancaNroHoja',
      path: CartillaFitoConfig.kMoscaBlancaHojasNroHoja,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumMoscaBlancaGrado',
      path: CartillaFitoConfig.kMoscaBlancaHojasGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countMoscaBlancaGrado',
      path: CartillaFitoConfig.kMoscaBlancaHojasGrado,
      hidden: true,
    ),
    _percentMetric(
      'porcMoscaBlanca',
      '%MOSCA BLANCA',
      '_sumMoscaBlancaNroHoja',
    ),
    _gradMetric(
      'gradMoscaBlanca',
      'Grad.MOSCA BLANCA',
      '_sumMoscaBlancaGrado',
      '_countMoscaBlancaGrado',
    ),
    _sumMetric(
      key: '_sumScolytusTallo',
      path: CartillaFitoConfig.kScolytusTalloTotalZonaPorPlanta,
      hidden: true,
    ),
    _promMetric(
      'promScolytusTallo',
      'Prom.SCOLYTUS TALLO',
      '_sumScolytusTallo',
    ),
    _percentMetric('porcScolytusTallo', '%SCOLYTUS TALLO', '_sumScolytusTallo'),
    _sumMetric(
      key: '_sumPseudococcusTallo',
      path: CartillaFitoConfig.kPseudococcusTalloTotalZonaPorPlanta,
      hidden: true,
    ),
    _promMetric(
      'promPseudococusTallo',
      'Prom.PSEUDOCOCCUS TALLO',
      '_sumPseudococcusTallo',
    ),
    _percentMetric(
      'porcPseudococusTallo',
      '%PSEUDOCOCCUS TALLO',
      '_sumPseudococcusTallo',
    ),
    _sumMetric(
      key: '_sumQueresaNroHojas',
      path: CartillaFitoConfig.kQueresaHojasNroHojas,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumQueresaNroIndividuo',
      path: CartillaFitoConfig.kQueresaHojasNroIndividuo,
      hidden: true,
    ),
    _promMetric('promQueresa', 'Prom.QUERESA', '_sumQueresaNroIndividuo'),
    _percentMetric('porcQueresa', '%QUERESA', '_sumQueresaNroHojas'),
    _sumMetric(
      key: '_sumThripsFloresNroRacimos',
      path: CartillaFitoConfig.kThripsFloresNroRacimos,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumThripsFloresNroIndividuo',
      path: CartillaFitoConfig.kThripsFloresNroIndividuo,
      hidden: true,
    ),
    _promMetric(
      'promTripsFlor',
      'Prom.TRIPS FLOR',
      '_sumThripsFloresNroIndividuo',
    ),
    _percentMetric(
      'porcTripsFlor',
      '%TRIPS FLOR',
      '_sumThripsFloresNroRacimos',
    ),
    _sumMetric(
      key: '_sumBotrytisFloresNroRacimos',
      path: CartillaFitoConfig.kBotrytisFloresNroRacimos,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumBotrytisFloresGrado',
      path: CartillaFitoConfig.kBotrytisFloresGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countBotrytisFloresGrado',
      path: CartillaFitoConfig.kBotrytisFloresGrado,
      hidden: true,
    ),
    _percentMetric(
      'porcBotrytisFlores',
      '%BOTRYTIS-FLORES',
      '_sumBotrytisFloresNroRacimos',
    ),
    _gradMetric(
      'gradBotrytisFlores',
      'Grad.BOTRYTIS-FLORES',
      '_sumBotrytisFloresGrado',
      '_countBotrytisFloresGrado',
    ),
    _sumMetric(
      key: '_sumPseudococusFrutosNroRacimos',
      path: CartillaFitoConfig.kPseudococusFrutoNroRacimos,
      hidden: true,
    ),
    _promMetric(
      'promPseudococusFrutos',
      'Prom.PSEUDOCOCCUS-RACIMOS',
      '_sumPseudococusFrutosNroRacimos',
    ),
    _percentMetric(
      'porcPseudococusFrutos',
      '%PSEUDOCOCCUS-RACIMOS',
      '_sumPseudococusFrutosNroRacimos',
    ),
    _sumMetric(
      key: '_sumOidiumFrutosNroRacimos',
      path: CartillaFitoConfig.kOidiumFrutosNroRacimos,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumOidiumFrutosGrado',
      path: CartillaFitoConfig.kOidiumFrutosGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countOidiumFrutosGrado',
      path: CartillaFitoConfig.kOidiumFrutosGrado,
      hidden: true,
    ),
    _percentMetric(
      'porcOidiumFrutos',
      '%OIDIUM-RACIMOS',
      '_sumOidiumFrutosNroRacimos',
    ),
    _gradMetric(
      'gradOidiumFrutos',
      'Grad.OIDIUM-RACIMOS',
      '_sumOidiumFrutosGrado',
      '_countOidiumFrutosGrado',
    ),
    _sumMetric(
      key: '_sumMildiuFrutosNroRacimos',
      path: CartillaFitoConfig.kMildiuFrutosNroRacimos,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumMildiuFrutosGrado',
      path: CartillaFitoConfig.kMildiuFrutosGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countMildiuFrutosGrado',
      path: CartillaFitoConfig.kMildiuFrutosGrado,
      hidden: true,
    ),
    _percentMetric(
      'porcMildiuFrutos',
      '%MILDIU-RACIMOS',
      '_sumMildiuFrutosNroRacimos',
    ),
    _gradMetric(
      'gradMildiuFrutos',
      'Grad.MILDIU-RACIMOS',
      '_sumMildiuFrutosGrado',
      '_countMildiuFrutosGrado',
    ),
    _sumMetric(
      key: '_sumBotrytisFrutosNroRacimos',
      path: CartillaFitoConfig.kBotrytisFrutosNroRacimos,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumBotrytisFrutosGrado',
      path: CartillaFitoConfig.kBotrytisFrutosGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countBotrytisFrutosGrado',
      path: CartillaFitoConfig.kBotrytisFrutosGrado,
      hidden: true,
    ),
    _percentMetric(
      'porcBotrytisFrutos',
      '%BOTRYTIS-RACIMOS',
      '_sumBotrytisFrutosNroRacimos',
    ),
    _gradMetric(
      'gradBotrytisFrutos',
      'Grad.BOTRYTIS-RACIMOS',
      '_sumBotrytisFrutosGrado',
      '_countBotrytisFrutosGrado',
    ),
    _sumMetric(
      key: '_sumPudricionAcidasFrutosNroRacimos',
      path: CartillaFitoConfig.kPudricionAcidasFrutosNroRacimos,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumPudricionAcidasFrutosGrado',
      path: CartillaFitoConfig.kPudricionAcidasFrutosGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countPudricionAcidasFrutosGrado',
      path: CartillaFitoConfig.kPudricionAcidasFrutosGrado,
      hidden: true,
    ),
    _promMetric(
      'promPudricionAcidasFrutos',
      'Prom.PUDRICION ACIDAS-RACIMOS',
      '_sumPudricionAcidasFrutosNroRacimos',
    ),
    _gradMetric(
      'gradPudricionAcidasFrutos',
      'Grad.PUDRICION ACIDAS-RACIMOS',
      '_sumPudricionAcidasFrutosGrado',
      '_countPudricionAcidasFrutosGrado',
    ),
    _sumMetric(
      key: '_sumPaloNegroFrutosNroRacimos',
      path: CartillaFitoConfig.kPaloNegroFrutosNroRacimos,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumPaloNegroFrutosGrado',
      path: CartillaFitoConfig.kPaloNegroFrutosGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countPaloNegroFrutosGrado',
      path: CartillaFitoConfig.kPaloNegroFrutosGrado,
      hidden: true,
    ),
    _promMetric(
      'promPaloNegro',
      'Prom.PALO NEGRO',
      '_sumPaloNegroFrutosNroRacimos',
    ),
    _gradMetric(
      'gradPaloNegro',
      'Grad.PALO NEGRO',
      '_sumPaloNegroFrutosGrado',
      '_countPaloNegroFrutosGrado',
    ),
    _sumMetric(
      key: '_sumDanoAvesFrutosNroRacimos',
      path: CartillaFitoConfig.kDanoAvesFrutosNroRacimos,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumDanoAvesFrutosGrado',
      path: CartillaFitoConfig.kDanoAvesFrutosGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countDanoAvesFrutosGrado',
      path: CartillaFitoConfig.kDanoAvesFrutosGrado,
      hidden: true,
    ),
    _promMetric(
      'promDanoAves',
      'Prom.DAÑO DE AVES',
      '_sumDanoAvesFrutosNroRacimos',
    ),
    _gradMetric(
      'gradDanoAves',
      'Grad.DAÑO DE AVES',
      '_sumDanoAvesFrutosGrado',
      '_countDanoAvesFrutosGrado',
    ),
    _sumMetric(
      key: '_sumPartidurasFrutosNroRacimos',
      path: CartillaFitoConfig.kPartidurasFrutosNroRacimos,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumPartidurasFrutosGrado',
      path: CartillaFitoConfig.kPartidurasFrutosGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countPartidurasFrutosGrado',
      path: CartillaFitoConfig.kPartidurasFrutosGrado,
      hidden: true,
    ),
    _promMetric(
      'promPartiduras',
      'Prom.PARTIDURAS',
      '_sumPartidurasFrutosNroRacimos',
    ),
    _gradMetric(
      'gradPartiduras',
      'Grad.PARTIDURAS',
      '_sumPartidurasFrutosGrado',
      '_countPartidurasFrutosGrado',
    ),
    _sumMetric(
      key: '_sumCarachaFrutosNroRacimos',
      path: CartillaFitoConfig.kCarachaFrutosNroRacimos,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumCarachaFrutosGrado',
      path: CartillaFitoConfig.kCarachaFrutosGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countCarachaFrutosGrado',
      path: CartillaFitoConfig.kCarachaFrutosGrado,
      hidden: true,
    ),
    _promMetric('promCaracha', 'Prom.CARACHA', '_sumCarachaFrutosNroRacimos'),
    _gradMetric(
      'gradCaracha',
      'Grad.CARACHA',
      '_sumCarachaFrutosGrado',
      '_countCarachaFrutosGrado',
    ),
    _sumMetric(
      key: '_sumColapsoFrutosNroRacimos',
      path: CartillaFitoConfig.kColapsoFrutosNroRacimos,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumColapsoFrutosGrado',
      path: CartillaFitoConfig.kColapsoFrutosGrado,
      hidden: true,
    ),
    _countNonZeroMetric(
      key: '_countColapsoFrutosGrado',
      path: CartillaFitoConfig.kColapsoFrutosGrado,
      hidden: true,
    ),
    _promMetric('promColapso', 'Prom.COLAPSO', '_sumColapsoFrutosNroRacimos'),
    _gradMetric(
      'gradColapso',
      'Grad.COLAPSO',
      '_sumColapsoFrutosGrado',
      '_countColapsoFrutosGrado',
    ),
    _sumMetric(
      key: '_sumEmpoaskaHojasNroHojas',
      path: CartillaFitoConfig.kEmpoaskaHojasNroHojas,
      hidden: true,
    ),
    _sumMetric(
      key: '_sumEmpoaskaHojasNroIndividuo',
      path: CartillaFitoConfig.kEmpoaskaHojasNroIndividuo,
      hidden: true,
    ),
    _promMetric(
      'promEmpoaska',
      'Prom.EMPOASKA',
      '_sumEmpoaskaHojasNroIndividuo',
    ),
    _percentMetric('porcEmpoaska', '%EMPOASKA', '_sumEmpoaskaHojasNroHojas'),
  ],
);

ReportColumnConfig _sumMetric({
  required String key,
  required String path,
  bool hidden = false,
}) {
  return ReportColumnConfig.metric(
    key: key,
    label: key,
    path: 'body.$path',
    aggregation: ReportAggregationType.sum,
    format: 'decimal2',
    hidden: hidden,
  );
}

ReportColumnConfig _countNonZeroMetric({
  required String key,
  required String path,
  bool hidden = false,
}) {
  return ReportColumnConfig.metric(
    key: key,
    label: key,
    path: 'body.$path',
    aggregation: ReportAggregationType.countNonZero,
    format: 'int',
    hidden: hidden,
  );
}

ReportColumnConfig _scaleBy({
  required String sourceKey,
  required String key,
  required int factor,
  bool hidden = false,
}) {
  return ReportColumnConfig.computed(
    key: key,
    label: key,
    computation: ReportComputationConfig.sumColumns(
      sourceColumnKeys: List<String>.filled(factor, sourceKey),
    ),
    format: 'decimal2',
    hidden: hidden,
  );
}

ReportColumnConfig _promMetric(String key, String label, String numeratorKey) {
  return ReportColumnConfig.computed(
    key: key,
    label: label,
    computation: ReportComputationConfig.percentage(
      numeratorColumnKey: numeratorKey,
      denominatorColumnKey: '_denTotalX400',
    ),
    format: 'decimal2',
  );
}

ReportColumnConfig _promMetricPerPlant(
  String key,
  String label,
  String numeratorKey,
) {
  return ReportColumnConfig.computed(
    key: key,
    label: label,
    computation: ReportComputationConfig.percentage(
      numeratorColumnKey: numeratorKey,
      denominatorColumnKey: '_denTotalX100',
    ),
    format: 'decimal2',
  );
}

ReportColumnConfig _percentMetric(
  String key,
  String label,
  String numeratorKey,
) {
  return ReportColumnConfig.computed(
    key: key,
    label: label,
    computation: ReportComputationConfig.percentage(
      numeratorColumnKey: numeratorKey,
      denominatorColumnKey: '_denTotalX4',
    ),
    format: 'percent2',
  );
}

ReportColumnConfig _gradMetric(
  String key,
  String label,
  String numeratorKey,
  String denominatorKey,
) {
  return ReportColumnConfig.computed(
    key: key,
    label: label,
    computation: ReportComputationConfig.divideColumns(
      numeratorColumnKey: numeratorKey,
      denominatorColumnKey: denominatorKey,
    ),
    format: 'decimal2',
  );
}
