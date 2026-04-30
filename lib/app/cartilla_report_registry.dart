import 'package:donluis_forms/features/plantillas/brotacion/domain/cartilla_brotacion_report_config.dart';
import 'package:donluis_forms/features/cartillas/domain/report/cartilla_report_config.dart';
import 'package:donluis_forms/features/plantillas/brotacion/domain/cartilla_brotacion_config.dart';
import 'package:donluis_forms/features/plantillas/labor_desbrote/domain/cartilla_labor_desbrote_config.dart';
import 'package:donluis_forms/features/plantillas/labor_desbrote/domain/cartilla_labor_desbrote_report_config.dart';
import 'package:donluis_forms/features/plantillas/poda/domain/cartilla_poda_config.dart';
import 'package:donluis_forms/features/plantillas/poda/domain/cartilla_poda_report_config.dart';
import 'package:flutter/material.dart';

class CartillaReportRegistry {
  static CartillaReportConfig resolve(String templateKey) {
    final key = _normalize(templateKey);
    debugPrint('CartillaReportRegistry.resolve=$key');
    switch (key) {
      case CartillaBrotacionConfig.templateKeyStatic:
        return cartillaBrotacionReportConfig;

      case CartillaLaborDesbroteConfig.templateKeyStatic:
        return cartillaLaborDesbroteReportConfig;

      case CartillaPodaConfig.templateKeyStatic:
        return cartillaPodaReportConfig;

      default:
        throw UnsupportedError('No report config for $templateKey');
    }
  }

  static CartillaReportConfig? tryResolve(String templateKey) {
    try {
      return resolve(templateKey);
    } on UnsupportedError {
      return null;
    }
  }

  static String _normalize(String templateKey) {
    return templateKey.trim().toLowerCase().replaceAll('-', '_');
  }
}
