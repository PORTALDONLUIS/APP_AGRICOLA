import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaRegistroMotorizadoSeguridadPayload
    extends
        CartillaMapHeaderPayloadBase<
          CartillaRegistroMotorizadoSeguridadPayload
        > {
  final int payloadVersion;

  const CartillaRegistroMotorizadoSeguridadPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaRegistroMotorizadoSeguridadPayload.empty() =>
      CartillaRegistroMotorizadoSeguridadPayload(
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
          'motivo': null,
          'fundo': null,
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

  factory CartillaRegistroMotorizadoSeguridadPayload.fromJsonString(
    String raw,
  ) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaRegistroMotorizadoSeguridadPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaRegistroMotorizadoSeguridadPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaRegistroMotorizadoSeguridadPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
