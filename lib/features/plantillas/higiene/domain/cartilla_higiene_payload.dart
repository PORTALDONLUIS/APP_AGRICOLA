import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaHigienePayload
    extends CartillaMapHeaderPayloadBase<CartillaHigienePayload> {
  final int payloadVersion;

  const CartillaHigienePayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaHigienePayload.empty() => CartillaHigienePayload(
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
      'responsableArea': null,
      'supervisor': null,
      'personalEvaluadoDni': null,
      'personalEvaluadoNombres': null,
      'cabelloProtegido': 'NO',
      'condicionBarba': null,
      'condicionUnas': null,
      'condicionManos': null,
      'vestimentaAdecuada': 'NO',
      'presentaAlhajas': 'NO',
      'presenciaMaquillaje': 'NO',
      'comportamiento': null,
      'observaciones': null,
      'fotos': <Map<String, dynamic>>[],
      'foto1': null,
      'foto2': null,
      'foto3': null,
      'firmaControlCalidad': null,
      'firmaSupervisor': null,
    },
  );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toMap() => toJson();

  factory CartillaHigienePayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaHigienePayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaHigienePayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaHigienePayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
