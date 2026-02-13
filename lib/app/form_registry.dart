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
    'cartilla_floracion_cuaja': '/fitosanidad/cartilla-floracion-cuaja',
    'cartilla_calibre_bayas': '/fitosanidad/cartilla-calibre-bayas',
    'cartilla_engome': '/fitosanidad/cartilla-engome',
    'cartilla_brix': '/fitosanidad/cartilla-brix',
    'cartilla_clasificacion_cargadores': '/fitosanidad/cartilla-clasificacion-cargadores',
    'cartilla_conteo_cargadores': '/fitosanidad/cartilla-conteo-cargadores',
    'cartilla_fertilidad': '/fitosanidad/cartilla-fertilidad',
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