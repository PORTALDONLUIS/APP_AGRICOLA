import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';

/// `true` si el header ya tiene coordenadas de muestreo persistibles.
bool headerHasSamplingLatLon(Map<String, dynamic> header) {
  double? asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  final lat = asDouble(header['lat']);
  final lon = asDouble(header['lon']);
  return lat != null &&
      lon != null &&
      lat.isFinite &&
      lon.isFinite;
}

mixin GeoSaveMixin {
  /// Adjunta GPS al header para guardado.
  ///
  /// Si [force] es `false` (por defecto) y el header ya tiene `lat`/`lon`
  /// válidos, **no** sobrescribe (ubicación de muestreo fija tras el primer
  /// guardado). Con [force] `true` siempre mezcla la posición actual si hay fix.
  Future<Map<String, dynamic>> attachGeo(
    Ref ref,
    Map<String, dynamic> header, {
    bool force = false,
  }) async {
    if (!force && headerHasSamplingLatLon(header)) {
      return header;
    }

    final geo = await ref.read(locationServiceProvider).tryGetHeaderGeo();

    if (geo == null) return header;

    return {
      ...header,
      ...geo,
    };
  }
}
