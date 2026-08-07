import '../../raleo/domain/cartilla_raleo_config.dart';

/// RALEO MEJORA conserva exactamente la estructura, reglas y campos de RALEO.
/// Solo cambia su identidad para que sus registros se almacenen por separado.
class CartillaRaleoMejoraConfig extends CartillaRaleoConfig {
  static const String templateKeyStatic = 'cartilla_raleo_mejora';

  @override
  String get templateKey => templateKeyStatic;
}
