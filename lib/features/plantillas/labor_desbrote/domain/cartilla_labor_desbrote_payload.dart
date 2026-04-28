import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaLaborDesbrotePayload
    extends CartillaMapHeaderPayloadBase<CartillaLaborDesbrotePayload> {
  final int payloadVersion;

  const CartillaLaborDesbrotePayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaLaborDesbrotePayload.empty() => CartillaLaborDesbrotePayload(
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
      'operario1Id': null,
      'operario2Id': null,
      'supervisorId': null,
      'variedad': null,
      'hilera': null,
      'planta': null,

      'pitonBrote': 0,
      'cargadores': 0,
      'materialViejo': 0,
      'totalBrotes': 0.0,

      'piton': 0,
      'racimoSimple': 0,
      'racimoDoble': 0,
      'totalSimpleDoble': 0.0,
      'racimoIndefinido': 0,

      'observaciones': null,
      'fotos': <Map<String, dynamic>>[],
      'foto1': null,
      'foto2': null,
    },
  );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaLaborDesbrotePayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaLaborDesbrotePayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaLaborDesbrotePayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaLaborDesbrotePayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
