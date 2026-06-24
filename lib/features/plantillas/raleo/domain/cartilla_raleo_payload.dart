import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaRaleoPayload
    extends CartillaMapHeaderPayloadBase<CartillaRaleoPayload> {
  final int payloadVersion;

  const CartillaRaleoPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaRaleoPayload.empty() => CartillaRaleoPayload(
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
      'controlCalidad': null,
      'supervisor': null,
      'operario1': null,
      'operario2': null,
      'variedad': null,
      'hilera': null,
      'planta': null,
      'raPautaRaleo': null,
      'raLongRacimo': null,
      'raNTotalBayas': null,
      'raUvillas': null,
      'raResultado': null,
      'rsPautaRaleo': null,
      'rsLongRacimo': null,
      'rsNTotalBayas': null,
      'rsUvillas': null,
      'rsResultado': null,
      'ratPautaRaleo': null,
      'ratLongRacimo': null,
      'ratNTotalBayas': null,
      'ratUvillas': null,
      'ratResultado': null,
      'rpPautaRaleo': null,
      'rpLongRacimo': null,
      'rpNTotalBayas': null,
      'rpUvillas': null,
      'rpResultado': null,
      'rpaPautaRaleo': null,
      'rpaLongRacimo': null,
      'rpaNTotalBayas': null,
      'rpaUvillas': null,
      'rpaResultado': null,
      'observaciones': null,
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

  factory CartillaRaleoPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaRaleoPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaRaleoPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaRaleoPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
