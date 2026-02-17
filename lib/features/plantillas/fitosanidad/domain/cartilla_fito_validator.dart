import '../../../cartillas/domain/cartilla_payload_accessors.dart';

class CartillaFitoValidator {
  const CartillaFitoValidator();

  /// Valida la cartilla de Fitosanidad
  /// Usa SOLO body para campos del formulario
  /// Header queda reservado a contexto BD
  List<String> validate(CartillaPayloadAccessors payload) {
    final errors = <String>[];

    // ===============================
    // Campos de FORMULARIO (BODY)
    // ===============================

    final etapaFenologicaId = payload.getBodyValue('etapaFenologicaId');
    final hilera = payload.getBodyValue('hilera');
    final planta = payload.getBodyValue('planta');
    final nMuestras = payload.getBodyValue('nMuestras');
    final nBrotes = payload.getBodyValue('nBrotes');

    // Etapa fenológica
    if (etapaFenologicaId == null || etapaFenologicaId.toString().isEmpty) {
      errors.add('Debe seleccionar la etapa fenológica');
    }

    // Hilera
    if (hilera == null) {
      errors.add('Debe ingresar la hilera');
    }

    // Planta
    if (planta == null) {
      errors.add('Debe ingresar la planta');
    }

    // Número de muestras
    if (nMuestras == null || (nMuestras is num && nMuestras <= 0)) {
      errors.add('Debe ingresar el número de muestras');
    }

    // Número de brotes
    if (nBrotes == null || (nBrotes is num && nBrotes <= 0)) {
      errors.add('Debe ingresar el número de brotes');
    }

    // ===============================
    // Validación de fotos (si aplica)
    // ===============================
    final fotos = payload.getBodyValue('fotos');
    if (fotos is List && fotos.isEmpty) {
      errors.add('Debe registrar al menos una foto');
    }

    return errors;
  }
}
