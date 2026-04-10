import 'package:donluis_forms/features/cartillas/presentation/cartilla_form_page.dart';
import 'package:flutter/material.dart';

import '../../features/cartillas/domain/cartilla_registry.dart';

Route<dynamic> onGenerateAppRoute(RouteSettings settings) {
  switch (settings.name) {

    case '/fitosanidad/cartilla-fito':
      final args = settings.arguments as Map<String, dynamic>;
      final localId = args['localId'] as int;
      final config = CartillaRegistry.resolve('cartilla_fito');
      return MaterialPageRoute(
        builder: (_) => CartillaFormPage(
          key: ValueKey<int>(localId),
          localId: localId,
          config: config,
        ),
        settings: settings,
      );

    case '/fitosanidad/cartilla-brotacion':
      final args = settings.arguments as Map<String, dynamic>;
      final localId = args['localId'] as int;
      final config = CartillaRegistry.resolve('cartilla_brotacion');
      return MaterialPageRoute(
        builder: (_) => CartillaFormPage(
          key: ValueKey<int>(localId),
          localId: localId,
          config: config,
        ),
        settings: settings,
      );

    case '/fitosanidad/cartilla-long-brote-racimo':
      final args = settings.arguments as Map<String, dynamic>;
      final localId = args['localId'] as int;
      final config = CartillaRegistry.resolve('cartilla_long_brote_racimo');
      return MaterialPageRoute(
        builder: (_) => CartillaFormPage(
          key: ValueKey<int>(localId),
          localId: localId,
          config: config,
        ),
        settings: settings,
      );

    case '/fitosanidad/cartilla-conteo-racimos':
      final args = settings.arguments as Map<String, dynamic>;
      final localId = args['localId'] as int;
      final config = CartillaRegistry.resolve('cartilla_conteo_racimos');
      return MaterialPageRoute(
        builder: (_) => CartillaFormPage(
          key: ValueKey<int>(localId),
          localId: localId,
          config: config,
        ),
        settings: settings,
      );

    case '/fitosanidad/cartilla-floracion-cuaja':
      final args = settings.arguments as Map<String, dynamic>;
      final localId = args['localId'] as int;
      final config = CartillaRegistry.resolve('cartilla_floracion_cuaja');
      return MaterialPageRoute(
        builder: (_) => CartillaFormPage(
          key: ValueKey<int>(localId),
          localId: localId,
          config: config,
        ),
        settings: settings,
      );

    case '/fitosanidad/cartilla-calibre-bayas':
      final args = settings.arguments as Map<String, dynamic>;
      final localId = args['localId'] as int;
      final config = CartillaRegistry.resolve('cartilla_calibre_bayas');
      return MaterialPageRoute(
        builder: (_) => CartillaFormPage(
          key: ValueKey<int>(localId),
          localId: localId,
          config: config,
        ),
        settings: settings,
      );

    case '/fitosanidad/cartilla-engome':
      final args = settings.arguments as Map<String, dynamic>;
      final localId = args['localId'] as int;
      final config = CartillaRegistry.resolve('cartilla_engome');
      return MaterialPageRoute(
        builder: (_) => CartillaFormPage(
          key: ValueKey<int>(localId),
          localId: localId,
          config: config,
        ),
        settings: settings,
      );

    case '/fitosanidad/cartilla-brix':
      final args = settings.arguments as Map<String, dynamic>;
      final localId = args['localId'] as int;
      final config = CartillaRegistry.resolve('cartilla_brix');
      return MaterialPageRoute(
        builder: (_) => CartillaFormPage(
          key: ValueKey<int>(localId),
          localId: localId,
          config: config,
        ),
        settings: settings,
      );

      case '/fitosanidad/cartilla-brix-moscatel':
      final args = settings.arguments as Map<String, dynamic>;
      final localId = args['localId'] as int;
      final config = CartillaRegistry.resolve('cartilla_brix_moscatel');
      return MaterialPageRoute(
        builder: (_) => CartillaFormPage(
          key: ValueKey<int>(localId),
          localId: localId,
          config: config,
        ),
        settings: settings,
      );


    case '/fitosanidad/cartilla-clasificacion-cargadores':
      final args = settings.arguments as Map<String, dynamic>;
      final localId = args['localId'] as int;
      final config = CartillaRegistry.resolve('cartilla_clasificacion_cargadores');
      return MaterialPageRoute(
        builder: (_) => CartillaFormPage(
          key: ValueKey<int>(localId),
          localId: localId,
          config: config,
        ),
        settings: settings,
      );

    case '/fitosanidad/cartilla-conteo-cargadores':
      final args = settings.arguments as Map<String, dynamic>;
      final localId = args['localId'] as int;
      final config = CartillaRegistry.resolve('cartilla_conteo_cargadores');
      return MaterialPageRoute(
        builder: (_) => CartillaFormPage(
          key: ValueKey<int>(localId),
          localId: localId,
          config: config,
        ),
        settings: settings,
      );

    case '/fitosanidad/cartilla-fertilidad':
      final args = settings.arguments as Map<String, dynamic>;
      final localId = args['localId'] as int;
      final config = CartillaRegistry.resolve('cartilla_fertilidad');
      return MaterialPageRoute(
        builder: (_) => CartillaFormPage(
          key: ValueKey<int>(localId),
          localId: localId,
          config: config,
        ),
        settings: settings,
      );

    case '/forms/not-implemented':
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Formulario no implementado')),
        ),
      );


    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Ruta no encontrada')),
          body: Center(child: Text('No existe la ruta: ${settings.name}')),
        ),
        settings: settings,
      );
  }
}
