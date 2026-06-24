import 'package:donluis_forms/features/plantillas/brotacion/domain/cartilla_brotacion_report_config.dart';
import 'package:donluis_forms/features/cartillas/domain/report/cartilla_report_config.dart';
import 'package:donluis_forms/features/plantillas/brotacion/domain/cartilla_brotacion_config.dart';
import 'package:donluis_forms/features/plantillas/conteo_racimos/domain/cartilla_conteo_racimos_config.dart';
import 'package:donluis_forms/features/plantillas/conteo_racimos/domain/cartilla_conteo_racimos_report_config.dart';
import 'package:donluis_forms/features/plantillas/cosecha_palta/domain/cartilla_cosecha_palta_config.dart';
import 'package:donluis_forms/features/plantillas/cosecha_palta/domain/cartilla_cosecha_palta_report_config.dart';
import 'package:donluis_forms/features/plantillas/fitosanidad/domain/cartilla_fito_config.dart';
import 'package:donluis_forms/features/plantillas/fitosanidad/domain/cartilla_fito_report_config.dart';
import 'package:donluis_forms/features/plantillas/floracion_cuaja/domain/cartilla_floracion_cuaja_config.dart';
import 'package:donluis_forms/features/plantillas/floracion_cuaja/domain/cartilla_floracion_cuaja_report_config.dart';
import 'package:donluis_forms/features/plantillas/labor_desbrote/domain/cartilla_labor_desbrote_config.dart';
import 'package:donluis_forms/features/plantillas/labor_desbrote/domain/cartilla_labor_desbrote_report_config.dart';
import 'package:donluis_forms/features/plantillas/long_brote_racimo/domain/cartilla_long_brote_racimo_config.dart';
import 'package:donluis_forms/features/plantillas/long_brote_racimo/domain/cartilla_long_brote_racimo_report_config.dart';
import 'package:donluis_forms/features/plantillas/poda/domain/cartilla_poda_config.dart';
import 'package:donluis_forms/features/plantillas/poda/domain/cartilla_poda_report_config.dart';
import 'package:donluis_forms/features/plantillas/raleo/domain/cartilla_raleo_config.dart';
import 'package:donluis_forms/features/plantillas/raleo/domain/cartilla_raleo_report_config.dart';

class CartillaReportRegistry {
  static CartillaReportConfig resolve(String templateKey, {String? reportKey}) {
    final configs = resolveAll(templateKey);
    if (reportKey == null || reportKey.isEmpty) {
      return configs.first;
    }

    return configs.firstWhere(
      (config) => config.reportKey == reportKey,
      orElse: () => throw UnsupportedError(
        'No report config for $templateKey / $reportKey',
      ),
    );
  }

  static List<CartillaReportConfig> resolveAll(String templateKey) {
    final key = _normalize(templateKey);
    if (key == CartillaLongBroteRacimoConfig.templateKeyStatic) {
      return cartillaLongBroteRacimoReportConfigs;
    }
    return [_resolveSingle(key, templateKey)];
  }

  static CartillaReportConfig _resolveSingle(String key, String templateKey) {
    switch (key) {
      case CartillaBrotacionConfig.templateKeyStatic:
        return cartillaBrotacionReportConfig;

      case CartillaConteoRacimosConfig.templateKeyStatic:
        return cartillaConteoRacimosReportConfig;

      case CartillaFloracionCuajaConfig.templateKeyStatic:
        return cartillaFloracionCuajaReportConfig;

      case CartillaCosechaPaltaConfig.templateKeyStatic:
        return cartillaCosechaPaltaReportConfig;

      case CartillaFitoConfig.templateKeyStatic:
      case 'cartilla_fitosanidad':
        return cartillaFitoReportConfig;

      case CartillaLaborDesbroteConfig.templateKeyStatic:
        return cartillaLaborDesbroteReportConfig;

      case CartillaPodaConfig.templateKeyStatic:
        return cartillaPodaReportConfig;

      case CartillaRaleoConfig.templateKeyStatic:
        return cartillaRaleoReportConfig;

      default:
        throw UnsupportedError('No report config for $templateKey');
    }
  }

  static CartillaReportConfig? tryResolve(
    String templateKey, {
    String? reportKey,
  }) {
    try {
      return resolve(templateKey, reportKey: reportKey);
    } on UnsupportedError {
      return null;
    }
  }

  static List<CartillaReportConfig> tryResolveAll(String templateKey) {
    try {
      return resolveAll(templateKey);
    } on UnsupportedError {
      return const [];
    }
  }

  static String _normalize(String templateKey) {
    return templateKey.trim().toLowerCase().replaceAll('-', '_');
  }
}
