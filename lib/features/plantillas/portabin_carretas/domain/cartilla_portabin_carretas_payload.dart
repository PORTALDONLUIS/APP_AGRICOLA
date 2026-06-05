import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaPortabinCarretasPayload
    extends CartillaMapHeaderPayloadBase<CartillaPortabinCarretasPayload> {
  final int payloadVersion;

  const CartillaPortabinCarretasPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaPortabinCarretasPayload.empty() =>
      CartillaPortabinCarretasPayload(
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
          'fecha': null,
          'sector': null,
          'supervisor': null,
          'tipoContenedor': null,
          'nroBinJabas': null,
          'operario': null,
          'piso': <String>[],
          'mallaToldo': <String>[],
          'insumosLimpieza': <String>[],
          'verificacion': null,
          'accionesCorrectivas': null,
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

  factory CartillaPortabinCarretasPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaPortabinCarretasPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaPortabinCarretasPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaPortabinCarretasPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
