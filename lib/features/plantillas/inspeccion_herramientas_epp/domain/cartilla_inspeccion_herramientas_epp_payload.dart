import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaInspeccionHerramientasEppPayload
    extends
        CartillaMapHeaderPayloadBase<CartillaInspeccionHerramientasEppPayload> {
  final int payloadVersion;

  const CartillaInspeccionHerramientasEppPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaInspeccionHerramientasEppPayload.empty() =>
      CartillaInspeccionHerramientasEppPayload(
        payloadVersion: 1,
        header: {
          'plantillaId': null,
          'userId': null,
          'campaniaId': null,
          'loteId': null,
          'lat': null,
          'lon': null,
          'fechaEjecucion': null,
        },
        body: _emptyBody(),
      );

  static Map<String, dynamic> _emptyBody() {
    return {
      'empresa': null,
      'fecha': null,
      'hora': null,
      'responsableArea': null,
      for (var i = 1; i <= 22; i++) ...{
        'pregunta${i}Respuesta': null,
        'pregunta${i}Observaciones': null,
        'pregunta${i}Descripcion1': null,
        'pregunta${i}Descripcion2': null,
      },
      'recomendacionDescripcion1': null,
      'recomendacionDescripcion2': null,
      'recomendacionDescripcion3': null,
      'responsableTurnoDni': null,
      'responsableTurnoNombre': null,
      'responsableTurnoFirma': null,
      'encargadoInspeccion': null,
      'firmaEncargado': null,
      'fotos': <Map<String, dynamic>>[],
    };
  }

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toMap() => toJson();

  factory CartillaInspeccionHerramientasEppPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaInspeccionHerramientasEppPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaInspeccionHerramientasEppPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaInspeccionHerramientasEppPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
