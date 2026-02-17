import 'package:donluis_forms/features/plantillas/brix/domain/cartilla_brix_config.dart';
import 'package:donluis_forms/features/plantillas/calibre_bayas/domain/cartilla_calibre_bayas_config.dart';
import 'package:donluis_forms/features/plantillas/clasificacion_cargadores/domain/cartilla_clasificacion_cargadores_config.dart';
import 'package:donluis_forms/features/plantillas/conteo_cargadores/domain/cartilla_conteo_cargadores_config.dart';
import 'package:donluis_forms/features/plantillas/conteo_racimos/domain/cartilla_conteo_racimos_config.dart';
import 'package:donluis_forms/features/plantillas/engome/domain/cartilla_engome_config.dart';
import 'package:donluis_forms/features/plantillas/fertilidad/domain/cartilla_fertilidad_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../plantillas/brix/presentation/providers/cartilla_brix_form_provider.dart';
import '../../plantillas/calibre_bayas/presentation/providers/cartilla_calibre_bayas_form_provider.dart';
import '../../plantillas/clasificacion_cargadores/presentation/providers/cartilla_clasificacion_cargadores_form_provider.dart';
import '../../plantillas/conteo_cargadores/presentation/providers/cartilla_conteo_cargadores_form_provider.dart';
import '../../plantillas/conteo_racimos/presentation/providers/cartilla_conteo_racimos_form_provider.dart';
import '../../plantillas/engome/presentation/providers/cartilla_engome_form_provider.dart';
import '../../plantillas/fertilidad/presentation/providers/cartilla_fertilidad_form_provider.dart';
import '../../plantillas/fitosanidad/domain/cartilla_fito_config.dart';
import '../../plantillas/fitosanidad/presentation/providers/cartilla_fito_form_provider.dart';
import '../../plantillas/floracion_cuaja/domain/cartilla_floracion_cuaja_config.dart';
import '../../plantillas/floracion_cuaja/providers/cartilla_floracion_cuaja_form_provider.dart';
import '../../plantillas/long_brote_racimo/domain/cartilla_long_brote_racimo_config.dart';
import '../../plantillas/long_brote_racimo/presentation/providers/cartilla_long_brote_racimo_form_provider.dart';
import 'cartilla_form_config.dart';

// Brotación (ajusta ruta si tu carpeta es diferente)
import '../../plantillas/brotacion/domain/cartilla_brotacion_config.dart';
import '../../plantillas/brotacion/providers/cartilla_brotacion_form_provider.dart';

/// Binding = (config + providers) por templateKey
class CartillaBinding {
  final CartillaFormConfig config;

  /// watchState(ref, localId) => state (dinámico)
  final dynamic Function(WidgetRef ref, int localId) watchState;

  /// readNotifier(ref, localId) => notifier (dinámico)
  final dynamic Function(WidgetRef ref, int localId) readNotifier;

  const CartillaBinding({
    required this.config,
    required this.watchState,
    required this.readNotifier,
  });
}

class CartillaRegistry {
  static CartillaFormConfig resolve(String templateKey) {
    return resolveBinding(templateKey).config;
  }

  static CartillaBinding resolveBinding(String templateKey) {
    switch (templateKey) {
      case 'cartilla_fito':
        return CartillaBinding(
          config: CartillaFitoConfig(),
          watchState: (ref, localId) => ref.watch(cartillaFitoFormProvider(localId)),
          readNotifier: (ref, localId) => ref.read(cartillaFitoFormProvider(localId).notifier),
        );

    // ✅ Brotación soporta underscore y guión (elige 1 estándar en BD, pero aquí aceptamos ambos)
      case 'cartilla_brotacion':
      case 'cartilla-brotacion':
        return CartillaBinding(
          config: CartillaBrotacionConfig(),
          watchState: (ref, localId) => ref.watch(cartillaBrotacionFormProvider(localId)),
          readNotifier: (ref, localId) => ref.read(cartillaBrotacionFormProvider(localId).notifier),
        );

      case 'cartilla_long_brote_racimo':
      case 'cartilla-long-brote-racimo':
        return CartillaBinding(
          config: CartillaLongBroteRacimoConfig(),
          watchState: (ref, localId) =>
              ref.watch(cartillaLongBroteRacimoFormProvider(localId)),
          readNotifier: (ref, localId) =>
              ref.read(cartillaLongBroteRacimoFormProvider(localId).notifier),
        );

      case 'cartilla_conteo_racimos':
      case 'cartilla-conteo-racimos':
        return CartillaBinding(
          config: CartillaConteoRacimosConfig(),
          watchState: (ref, localId) =>
              ref.watch(cartillaConteoRacimosFormProvider(localId)),
          readNotifier: (ref, localId) =>
              ref.read(cartillaConteoRacimosFormProvider(localId).notifier),
        );

      case 'cartilla_floracion_cuaja':
      case 'cartilla-floracion-cuaja':
        return CartillaBinding(
          config: CartillaFloracionCuajaConfig(),
          watchState: (ref, localId) =>
              ref.watch(cartillaFloracionCuajaFormProvider(localId)),
          readNotifier: (ref, localId) =>
              ref.read(cartillaFloracionCuajaFormProvider(localId).notifier),
        );

      case 'cartilla_calibre_bayas':
      case 'cartilla-calibre-bayas':
        return CartillaBinding(
          config: CartillaCalibreBayasConfig(),
          watchState: (ref, localId) =>
              ref.watch(cartillaCalibreBayasFormProvider(localId)),
          readNotifier: (ref, localId) =>
              ref.read(cartillaCalibreBayasFormProvider(localId).notifier),
        );

      case 'cartilla_engome':
      case 'cartilla-engome':
        return CartillaBinding(
          config: CartillaEngomeConfig(),
          watchState: (ref, localId) =>
              ref.watch(cartillaEngomeFormProvider(localId)),
          readNotifier: (ref, localId) =>
              ref.read(cartillaEngomeFormProvider(localId).notifier),
        );

      case 'cartilla_brix':
      case 'cartilla-brix':
        return CartillaBinding(
          config: CartillaBrixConfig(),
          watchState: (ref, localId) =>
              ref.watch(cartillaBrixFormProvider(localId)),
          readNotifier: (ref, localId) =>
              ref.read(cartillaBrixFormProvider(localId).notifier),
        );

      case 'cartilla_clasificacion_cargadores':
      case 'cartilla-clasificacion-cargadores':
        return CartillaBinding(
          config: CartillaClasificacionCargadoresConfig(),
          watchState: (ref, localId) =>
              ref.watch(cartillaClasificacionCargadoresFormProvider(localId)),
          readNotifier: (ref, localId) =>
              ref.read(cartillaClasificacionCargadoresFormProvider(localId).notifier),
        );

      case 'cartilla_conteo_cargadores':
      case 'cartilla-conteo-cargadores':
        return CartillaBinding(
          config: CartillaConteoCargadoresConfig(),
          watchState: (ref, localId) =>
              ref.watch(cartillaConteoCargadoresFormProvider(localId)),
          readNotifier: (ref, localId) =>
              ref.read(cartillaConteoCargadoresFormProvider(localId).notifier),
        );

      case 'cartilla_fertilidad':
      case 'cartilla-fertilidad':
        return CartillaBinding(
          config: CartillaFertilidadConfig(),
          watchState: (ref, localId) =>
              ref.watch(cartillaFertilidadFormProvider(localId)),
          readNotifier: (ref, localId) =>
              ref.read(cartillaFertilidadFormProvider(localId).notifier),
        );



      default:
        throw Exception('Plantilla no registrada: $templateKey');
    }
  }
}
