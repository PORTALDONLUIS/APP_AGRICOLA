import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaObservacionesCampoPayload
    extends CartillaMapHeaderPayloadBase<CartillaObservacionesCampoPayload> {
  final int payloadVersion;

  const CartillaObservacionesCampoPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaObservacionesCampoPayload.empty() =>
      CartillaObservacionesCampoPayload(
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
        body: {
          'empresa': null,
          'fundo': null,
          'fecha': null,
          'hora': null,
          'supervisorPrevencionista': null,
          'responsable': null,
          'hallazgos': null,
          'categoriaRiesgo': null,
          'acciones': null,
          'recomendaciones': null,
          'fotos': <Map<String, dynamic>>[],
        },
      );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toMap() => toJson();

  factory CartillaObservacionesCampoPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaObservacionesCampoPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaObservacionesCampoPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaObservacionesCampoPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
