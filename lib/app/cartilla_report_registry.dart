import 'package:donluis_forms/features/plantillas/brotacion/domain/cartilla_brotacion_report_config.dart';
import 'package:donluis_forms/features/cartillas/domain/report/cartilla_report_config.dart';
import 'package:donluis_forms/features/plantillas/brotacion/domain/cartilla_brotacion_config.dart';

class CartillaReportRegistry {
  static CartillaReportConfig resolve(String templateKey) {
    final key = _normalize(templateKey);
    switch (key) {
      case CartillaBrotacionConfig.templateKeyStatic:
        return cartillaBrotacionReportConfig;

      //case CartillaBrixConfig.templateKeyStatic:
        //return cartillaBrixReportConfig;

      default:
        throw UnsupportedError(
          'No report config for $templateKey',
        );
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