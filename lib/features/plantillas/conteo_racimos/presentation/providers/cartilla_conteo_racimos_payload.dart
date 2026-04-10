// lib/features/conteo_racimos/domain/cartilla_conteo_racimos_payload.dart

import 'dart:convert';

import '../../../../cartillas/domain/cartilla_map_header_payload_base.dart';


class CartillaConteoRacimosPayload
    extends CartillaMapHeaderPayloadBase<CartillaConteoRacimosPayload> {
  final int payloadVersion;

  const CartillaConteoRacimosPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaConteoRacimosPayload.empty() => const CartillaConteoRacimosPayload(
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

      'racimo_simple_1': 0,
      'racimo_doble_1': 0,

      'total_sd': 0.0,

      'racimo_indefinido': 0,
      'racimo_corrido': 0,

      'total': 0.0,

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

  factory CartillaConteoRacimosPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaConteoRacimosPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaConteoRacimosPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaConteoRacimosPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
