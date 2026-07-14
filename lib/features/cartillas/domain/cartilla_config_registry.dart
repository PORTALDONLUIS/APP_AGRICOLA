import 'package:donluis_forms/features/plantillas/brix/domain/cartilla_brix_config.dart';
import 'package:donluis_forms/features/plantillas/brix_moscatel/domain/cartilla_brix_moscatel_config.dart';
import 'package:donluis_forms/features/plantillas/calibre_bayas/domain/cartilla_calibre_bayas_config.dart';
import 'package:donluis_forms/features/plantillas/calibre_palta/domain/cartilla_calibre_palta_config.dart';
import 'package:donluis_forms/features/plantillas/clasificacion_cargadores/domain/cartilla_clasificacion_cargadores_config.dart';
import 'package:donluis_forms/features/plantillas/conteo_cargadores/domain/cartilla_conteo_cargadores_config.dart';
import 'package:donluis_forms/features/plantillas/conteo_racimos/domain/cartilla_conteo_racimos_config.dart';
import 'package:donluis_forms/features/plantillas/cosecha_palta/domain/cartilla_cosecha_palta_config.dart';
import 'package:donluis_forms/features/plantillas/engome/domain/cartilla_engome_config.dart';
import 'package:donluis_forms/features/plantillas/fertilidad/domain/cartilla_fertilidad_config.dart';
import 'package:donluis_forms/features/plantillas/fitosanidad/domain/cartilla_fito_config.dart';
import 'package:donluis_forms/features/plantillas/floracion_cuaja/domain/cartilla_floracion_cuaja_config.dart';
import 'package:donluis_forms/features/plantillas/higiene/domain/cartilla_higiene_config.dart';
import 'package:donluis_forms/features/plantillas/inspeccion_herramientas_epp/domain/cartilla_inspeccion_herramientas_epp_config.dart';
import 'package:donluis_forms/features/plantillas/labor_desbrote/domain/cartilla_labor_desbrote_config.dart';
import 'package:donluis_forms/features/plantillas/long_brote_racimo/domain/cartilla_long_brote_racimo_config.dart';
import 'package:donluis_forms/features/plantillas/movilidades_cosecha/domain/cartilla_movilidades_cosecha_config.dart';
import 'package:donluis_forms/features/plantillas/observaciones_campo/domain/cartilla_observaciones_campo_config.dart';
import 'package:donluis_forms/features/plantillas/packing_cajas/domain/cartilla_packing_cajas_config.dart';
import 'package:donluis_forms/features/plantillas/packing_descarte_calidad/domain/cartilla_packing_descarte_calidad_config.dart';
import 'package:donluis_forms/features/plantillas/packing_recepcion/domain/cartilla_packing_recepcion_config.dart';
import 'package:donluis_forms/features/plantillas/poda/domain/cartilla_poda_config.dart';
import 'package:donluis_forms/features/plantillas/portabin_carretas/domain/cartilla_portabin_carretas_config.dart';
import 'package:donluis_forms/features/plantillas/preraleo/domain/cartilla_preraleo_config.dart';
import 'package:donluis_forms/features/plantillas/raleo/domain/cartilla_raleo_config.dart';
import 'package:donluis_forms/features/plantillas/registro_motorizado_seguridad/domain/cartilla_registro_motorizado_seguridad_config.dart';
import 'package:donluis_forms/features/plantillas/registro_personal_garita_seguridad/domain/cartilla_registro_personal_garita_seguridad_config.dart';
import 'package:donluis_forms/features/plantillas/supervision_labor/domain/cartilla_supervision_labor_config.dart';
import 'package:donluis_forms/features/plantillas/topico/domain/cartilla_topico_config.dart';

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
      case 'cartilla_preraleo':
      case 'cartilla_pre_raleo':
        return CartillaPreraleoConfig();
      case 'cartilla_raleo':
        return CartillaRaleoConfig();
      case 'cartilla_floracion_cuaja':
        return CartillaFloracionCuajaConfig();
      case 'cartilla_calibre_bayas':
        return CartillaCalibreBayasConfig();
      case 'cartilla_calibre_palta':
        return CartillaCalibrePaltaConfig();
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
      case 'cartilla_supervision_labor':
        return CartillaSupervisionLaborConfig();
      case 'cartilla_poda':
      case 'cartilla_podas':
        return CartillaPodaConfig();
      case 'cartilla_higiene':
        return CartillaHigieneConfig();
      case 'cartilla_cosecha_palta':
        return CartillaCosechaPaltaConfig();
      case 'cartilla_portabin_carretas':
        return CartillaPortabinCarretasConfig();
      case 'cartilla_movilidades_cosecha':
        return CartillaMovilidadesCosechaConfig();
      case 'cartilla_packing_cajas':
        return CartillaPackingCajasConfig();
      case 'cartilla_packing_descarte_calidad':
        return CartillaPackingDescarteCalidadConfig();
      case 'cartilla_packing_recepcion':
        return CartillaPackingRecepcionConfig();
      case 'cartilla_registro_motorizado_seguridad':
        return CartillaRegistroMotorizadoSeguridadConfig();
      case 'cartilla_registro_personal_garita_seguridad':
        return CartillaRegistroPersonalGaritaSeguridadConfig();
      case 'catilla_topico':
      case 'cartilla_topico':
        return CartillaTopicoConfig();
      case 'cartilla_observaciones_campo':
        return CartillaObservacionesCampoConfig();
      case 'cartilla_inspeccion_herramientas_epp':
        return CartillaInspeccionHerramientasEppConfig();
      default:
        throw Exception('Plantilla no registrada: $templateKey');
    }
  }

  static String _normalize(String templateKey) {
    return templateKey.trim().toLowerCase().replaceAll('-', '_');
  }
}
