import 'package:flutter/material.dart';

class FormRegistry {
  /// Mapa oficial: TEMPLATE_KEY_NORMALIZADO -> RUTA
  /// OJO: las keys aquí van en lower_snake_case
  static const Map<String, String> routesByTemplate = {
    'plantas': '/forms/plantas',
    'cartilla_fito': '/fitosanidad/cartilla-fito',
    'cartilla_brotacion': '/fitosanidad/cartilla-brotacion',
    'cartilla_long_brote_racimo': '/fitosanidad/cartilla-long-brote-racimo',
    'cartilla_conteo_racimos': '/fitosanidad/cartilla-conteo-racimos',
    'cartilla_preraleo': '/fitosanidad/cartilla-preraleo',
    'cartilla_pre_raleo': '/fitosanidad/cartilla-preraleo',
    'cartilla_raleo': '/fitosanidad/cartilla-raleo',
    'cartilla_floracion_cuaja': '/fitosanidad/cartilla-floracion-cuaja',
    'cartilla_calibre_bayas': '/fitosanidad/cartilla-calibre-bayas',
    'cartilla_calibre_palta': '/fitosanidad/cartilla-calibre-palta',
    'cartilla_engome': '/fitosanidad/cartilla-engome',
    'cartilla_brix': '/fitosanidad/cartilla-brix',
    'cartilla_brix_moscatel': '/fitosanidad/cartilla-brix-moscatel',
    'cartilla_clasificacion_cargadores':
        '/fitosanidad/cartilla-clasificacion-cargadores',
    'cartilla_conteo_cargadores': '/fitosanidad/cartilla-conteo-cargadores',
    'cartilla_fertilidad': '/fitosanidad/cartilla-fertilidad',
    'cartilla_labor_desbrote': '/fitosanidad/cartilla-labor-desbrote',
    'cartilla_supervision_labor': '/fitosanidad/cartilla-supervision-labor',
    'cartilla_poda': '/fitosanidad/cartilla-poda',
    'cartilla_podas': '/fitosanidad/cartilla-poda',
    'cartilla_higiene': '/fitosanidad/cartilla-higiene',
    'cartilla_cosecha_palta': '/fitosanidad/cartilla-cosecha-palta',
    'cartilla_portabin_carretas': '/fitosanidad/cartilla-portabin-carretas',
    'cartilla_movilidades_cosecha': '/fitosanidad/cartilla-movilidades-cosecha',
    'cartilla_packing_recepcion': '/fitosanidad/cartilla-packing-recepcion',
    'cartilla_packing_cajas': '/fitosanidad/cartilla-packing-cajas',
    'cartilla_packing_descarte_calidad':
        '/fitosanidad/cartilla-packing-descarte-calidad',
  };

  /// Normaliza cualquier código que venga de BD:
  /// - lower
  /// - trim
  /// - '-' -> '_'
  static String _normalize(String templateKey) {
    return templateKey.trim().toLowerCase().replaceAll('-', '_');
  }

  /// Devuelve la ruta correspondiente al template
  static String routeFor(String templateKey) {
    final key = _normalize(templateKey);
    debugPrint('routeFor=$key');
    return routesByTemplate[key] ?? '/forms/not-implemented';
  }
}
