import 'package:donluis_forms/features/plantillas/brix/domain/cartilla_brix_config.dart';
import 'package:donluis_forms/features/plantillas/brix_moscatel/domain/cartilla_brix_moscatel_config.dart';
import 'package:donluis_forms/features/plantillas/calibre_bayas/domain/cartilla_calibre_bayas_config.dart';
import 'package:donluis_forms/features/plantillas/clasificacion_cargadores/domain/cartilla_clasificacion_cargadores_config.dart';
import 'package:donluis_forms/features/plantillas/conteo_cargadores/domain/cartilla_conteo_cargadores_config.dart';
import 'package:donluis_forms/features/plantillas/conteo_racimos/domain/cartilla_conteo_racimos_config.dart';
import 'package:donluis_forms/features/plantillas/engome/domain/cartilla_engome_config.dart';
import 'package:donluis_forms/features/plantillas/fertilidad/domain/cartilla_fertilidad_config.dart';
import 'package:donluis_forms/features/plantillas/fitosanidad/domain/cartilla_fito_config.dart';
import 'package:donluis_forms/features/plantillas/floracion_cuaja/domain/cartilla_floracion_cuaja_config.dart';
import 'package:donluis_forms/features/plantillas/labor_desbrote/domain/cartilla_labor_desbrote_config.dart';
import 'package:donluis_forms/features/plantillas/long_brote_racimo/domain/cartilla_long_brote_racimo_config.dart';
import 'package:donluis_forms/features/plantillas/poda/domain/cartilla_poda_config.dart';

import '../../plantillas/brotacion/domain/cartilla_brotacion_config.dart';
import 'cartilla_form_config.dart';

class CartillaConfigRegistry {
  static CartillaFormConfig resolve(String templateKey) {
    switch (_normalize(templateKey)) {
      case 'cartilla_fito':
        return CartillaFitoConfig();
      case 'cartilla_brotacion':
        return CartillaBrotacionConfig();
      case 'cartilla_long_brote_racimo':
        return CartillaLongBroteRacimoConfig();
      case 'cartilla_conteo_racimos':
        return CartillaConteoRacimosConfig();
      case 'cartilla_floracion_cuaja':
        return CartillaFloracionCuajaConfig();
      case 'cartilla_calibre_bayas':
        return CartillaCalibreBayasConfig();
      case 'cartilla_engome':
        return CartillaEngomeConfig();
      case 'cartilla_brix':
        return CartillaBrixConfig();
      case 'cartilla_clasificacion_cargadores':
        return CartillaClasificacionCargadoresConfig();
      case 'cartilla_conteo_cargadores':
        return CartillaConteoCargadoresConfig();
      case 'cartilla_fertilidad':
        return CartillaFertilidadConfig();
      case 'cartilla_brix_moscatel':
        return CartillaBrixMoscatelConfig();
      case 'cartilla_labor_desbrote':
        return CartillaLaborDesbroteConfig();
      case 'cartilla_poda':
      case 'cartilla_podas':
        return CartillaPodaConfig();
      default:
        throw Exception('Plantilla no registrada: $templateKey');
    }
  }

  static String _normalize(String templateKey) {
    return templateKey.trim().toLowerCase().replaceAll('-', '_');
  }
}
