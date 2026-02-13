import 'dart:convert';

import '../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaFertilidadPayload
    extends CartillaMapHeaderPayloadBase<CartillaFertilidadPayload> {
  final int payloadVersion;

  const CartillaFertilidadPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaFertilidadPayload.empty() => CartillaFertilidadPayload(
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
      'evaluacion': null,
      'tipoCargador': null,
      'numeroCargador': null,

      // Yema 1..7 (por defecto 1..7 como “fijo sugerido”)
      'yema1_numero': 1,
      'yema1_parametros': null,
      'yema1_catYema': null,

      'yema2_numero': 2,
      'yema2_parametros': null,
      'yema2_catYema': null,

      'yema3_numero': 3,
      'yema3_parametros': null,
      'yema3_catYema': null,

      'yema4_numero': 4,
      'yema4_parametros': null,
      'yema4_catYema': null,

      'yema5_numero': 5,
      'yema5_parametros': null,
      'yema5_catYema': null,

      'yema6_numero': 6,
      'yema6_parametros': null,
      'yema6_catYema': null,

      'yema7_numero': 7,
      'yema7_parametros': null,
      'yema7_catYema': null,

      'observaciones': null,

      // Fotos (guardar path/local ref según tu motor)
      'foto1': null,
      'foto2': null,
      'foto3': null,
      'foto4': null,
      'foto5': null,
    },
  );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaFertilidadPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaFertilidadPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaFertilidadPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaFertilidadPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
