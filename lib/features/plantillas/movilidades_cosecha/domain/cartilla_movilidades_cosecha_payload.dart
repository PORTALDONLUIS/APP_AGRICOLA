import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaMovilidadesCosechaPayload
    extends CartillaMapHeaderPayloadBase<CartillaMovilidadesCosechaPayload> {
  final int payloadVersion;

  const CartillaMovilidadesCosechaPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaMovilidadesCosechaPayload.empty() =>
      CartillaMovilidadesCosechaPayload(
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
          'cantidadCajas': null,
          'variedad': null,
          'supervisor': null,
          'serieGuia': null,
          'nroGuia': null,
          'horaInicioCarga': null,
          'tipoContenedor': null,
          'nroPrecinto': null,
          'nombreProveedor': null,
          'chofer': null,
          'marca': null,
          'placa': null,
          'piso': <String>[],
          'techo': <String>[],
          'pared': <String>[],
          'toldo': <String>[],
          'insumosLimpieza': <String>[],
          'verificacionCamion': null,
          'observaciones': null,
          'finHoraCarga': null,
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

  factory CartillaMovilidadesCosechaPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaMovilidadesCosechaPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaMovilidadesCosechaPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaMovilidadesCosechaPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
