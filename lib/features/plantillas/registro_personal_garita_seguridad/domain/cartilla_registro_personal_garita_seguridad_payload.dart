import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaRegistroPersonalGaritaSeguridadPayload
    extends
        CartillaMapHeaderPayloadBase<
          CartillaRegistroPersonalGaritaSeguridadPayload
        > {
  final int payloadVersion;

  const CartillaRegistroPersonalGaritaSeguridadPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaRegistroPersonalGaritaSeguridadPayload.empty() =>
      CartillaRegistroPersonalGaritaSeguridadPayload(
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
          'dni': null,
          'apellidosNombres': null,
          'visitante': 'NO',
          'transportista': 'NO',
          'motivo': null,
          'fundo': null,
          'area': null,
          'tipoVehiculo': null,
          'licencia': 'NO',
          'soat': 'NO',
          'placa': null,
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

  factory CartillaRegistroPersonalGaritaSeguridadPayload.fromJsonString(
    String raw,
  ) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaRegistroPersonalGaritaSeguridadPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaRegistroPersonalGaritaSeguridadPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaRegistroPersonalGaritaSeguridadPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
