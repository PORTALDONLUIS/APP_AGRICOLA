import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaBrixMoscatelPayload
    extends CartillaMapHeaderPayloadBase<CartillaBrixMoscatelPayload> {
  final int payloadVersion;

  const CartillaBrixMoscatelPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaBrixMoscatelPayload.empty() => CartillaBrixMoscatelPayload(
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
          'hilera': null,
          'planta': null,
          'variedad': 'MOSCATEL',
          'corresponde': null,
          'brixSsc': null,
        },
      );

  Map<String, dynamic> toJson() => {
        'payloadVersion': payloadVersion,
        'header': header,
        'body': body,
      };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaBrixMoscatelPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaBrixMoscatelPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaBrixMoscatelPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaBrixMoscatelPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}