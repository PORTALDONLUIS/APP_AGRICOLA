import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';

mixin GeoSaveMixin {

  Future<Map<String, dynamic>> attachGeo(
      Ref ref,
      Map<String, dynamic> header,
      ) async {
    final geo = await ref.read(locationServiceProvider).tryGetHeaderGeo();

    if (geo == null) return header;

    return {
      ...header,
      ...geo,
    };
  }
}
