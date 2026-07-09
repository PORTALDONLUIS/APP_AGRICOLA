import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaTopicoPayload
    extends CartillaMapHeaderPayloadBase<CartillaTopicoPayload> {
  final int payloadVersion;

  const CartillaTopicoPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaTopicoPayload.empty() => CartillaTopicoPayload(
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
      'pacienteId': null,
      'pacienteNombre': null,
      'empresa': null,
      'cultivo': null,
      'dni': null,
      'planilla': null,
      'genero': null,
      'cargo': null,
      'area': null,
      'consulta': null,
      'medicamento': <Map<String, dynamic>>[],
      'aptitud': null,
      'tipoAtencion': null,
      'diagnosticoObservacion': null,
      'firma': null,
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

  factory CartillaTopicoPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaTopicoPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaTopicoPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaTopicoPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
