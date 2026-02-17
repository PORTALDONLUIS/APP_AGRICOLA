import 'dart:convert';
import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaEngomePayload
    extends CartillaMapHeaderPayloadBase<CartillaEngomePayload> {
  final int payloadVersion;

  const CartillaEngomePayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaEngomePayload.empty() => CartillaEngomePayload(
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
      'corresponde': null,
      'cantidadMuestras': null,
      'hilera': null,
      'planta': null,

      'verdeNRacPlanta': 0,
      'engomeNRacPlanta': 0,

      // Calculado
      'pintaTotalRacPlanta': 0.0,
    },
  );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaEngomePayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaEngomePayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaEngomePayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaEngomePayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
