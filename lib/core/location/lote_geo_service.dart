import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/drift/daos/master/lotes_dao.dart';
import '../../app/providers.dart';
import 'geo_utils.dart';

class LoteGeoService {
  final LotesDao _lotesDao;

  LoteGeoService(this._lotesDao);

  /// Detecta el lote que contiene el punto (lat, lon) usando bbox + WKT.
  Future<dynamic> detectLoteByLocation({
    required double lat,
    required double lon,
  }) async {
    final candidates =
        await _lotesDao.findCandidatesByBbox(lat: lat, lon: lon);
    if (candidates.isEmpty) return null;

    for (final lote in candidates) {
      final wkt = lote.geomWkt;
      if (wkt == null || wkt.isEmpty) continue;
      final ring = parseWktPolygon(wkt);
      if (ring.isEmpty) continue;
      if (pointInPolygon(lon, lat, ring)) {
        return lote;
      }
    }
    return null;
  }
}

/// Provider de servicio de detección de lote por GPS.
final loteGeoServiceProvider = Provider<LoteGeoService>((ref) {
  // Reutiliza el mismo AppDatabase que el resto de la app.
  final db = ref.read(appDbProvider);
  return LoteGeoService(LotesDao(db));
});

