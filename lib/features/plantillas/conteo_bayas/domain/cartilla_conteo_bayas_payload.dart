import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaConteoBayasPayload
    extends CartillaMapHeaderPayloadBase<CartillaConteoBayasPayload> {
  final int payloadVersion;

  const CartillaConteoBayasPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaConteoBayasPayload.empty() => CartillaConteoBayasPayload(
    header: const {
      'plantillaId': null,
      'userId': null,
      'loteId': null,
      'lat': null,
      'lon': null,
      'fechaEjecucion': null,
    },
    body: {
      'fecha': null,
      'fundo': null,
      'hilera': null,
      'planta': null,
      'cantidadRacimos': 1,
      'tipoRacimo1': null,
      'numeroBayas1': 0,
      'promNumeroBayas': 0.0,
      'fotos': <Map<String, dynamic>>[],
    },
  );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaConteoBayasPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaConteoBayasPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaConteoBayasPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) => CartillaConteoBayasPayload(
    payloadVersion: payloadVersion ?? this.payloadVersion,
    header: header ?? Map<String, dynamic>.from(this.header),
    body: body ?? Map<String, dynamic>.from(this.body),
  );
}
