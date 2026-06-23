import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaPreraleoPayload
    extends CartillaMapHeaderPayloadBase<CartillaPreraleoPayload> {
  final int payloadVersion;

  const CartillaPreraleoPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaPreraleoPayload.empty() => CartillaPreraleoPayload(
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
      'variedad': null,
      'hilera': null,
      'planta': null,
      'supervisor': null,
      'operario1': null,
      'operario2': null,
      'racimoGrandeLong': null,
      'racimoGrandeNPisos': null,
      'racimoGrandeObservaciones': null,
      'racimoPequenoLong': null,
      'racimoPequenoNPisos': null,
      'racimoPequenoObservaciones': null,
      'conteo': 0,
      'racimosPreRaleados': 0,
      'racimosNoPreRaleados': 0,
      'totalRacimos': 0,
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

  factory CartillaPreraleoPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaPreraleoPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaPreraleoPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaPreraleoPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
