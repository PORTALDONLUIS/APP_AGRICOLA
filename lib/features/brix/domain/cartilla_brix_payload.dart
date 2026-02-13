import 'dart:convert';

import '../../cartillas/domain/cartilla_map_header_payload_base.dart';


class CartillaBrixPayload extends CartillaMapHeaderPayloadBase<CartillaBrixPayload> {
  final int payloadVersion;

  const CartillaBrixPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaBrixPayload.empty() => CartillaBrixPayload(
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
      'cantidadMuestras': null,
      'fenologia': null,
      'detalleFenologia': null,
      'corresponde': null,
      'hilera': null,
      'planta': null,

      // Medición BRIX (conteos)
      'brix5': 0,
      'brix5_5': 0,
      'brix6': 0,
      'brix6_5': 0,
      'brix7': 0,
      'brix7_5': 0,
      'brix8': 0,
      'brix8_5': 0,
      'brix9': 0,
      'brix9_5': 0,
      'brix10': 0,
      'brix10_5': 0,
      'brix11': 0,
      'brix11_5': 0,
      'brix12': 0,
      'brix12_5': 0,
      'brix13': 0,
      'brix13_5': 0,
      'brix14': 0,
      'brix14_5': 0,
      'brix15': 0,
      'brix15_5': 0,
      'brix16': 0,
      'brix16_5': 0,
      'brix17': 0,
      'brix17_5': 0,
      'brix18': 0,
      'brix18_5': 0,
      'brix19': 0,
      'brix19_5': 0,
      'brix20': 0,
      'brix20_5': 0,
      'brix21': 0,
      'brix21_5': 0,
      'brix22': 0,
      'brix22_5': 0,
      'brix23': 0,
      'brix23_5': 0,

      // Calculados
      'totalBayasEvaluadas': 0.0,
      'promBrixPlanta': 0.0,
    },
  );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaBrixPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaBrixPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaBrixPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaBrixPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
