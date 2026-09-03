import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaDescargaRacimosPayload
    extends CartillaMapHeaderPayloadBase<CartillaDescargaRacimosPayload> {
  final int payloadVersion;

  const CartillaDescargaRacimosPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaDescargaRacimosPayload.empty() =>
      const CartillaDescargaRacimosPayload(
        header: {
          'plantillaId': null,
          'userId': null,
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
          'totalRacimo': 0,
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

  factory CartillaDescargaRacimosPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaDescargaRacimosPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaDescargaRacimosPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) => CartillaDescargaRacimosPayload(
    payloadVersion: payloadVersion ?? this.payloadVersion,
    header: header ?? Map<String, dynamic>.from(this.header),
    body: body ?? Map<String, dynamic>.from(this.body),
  );
}
