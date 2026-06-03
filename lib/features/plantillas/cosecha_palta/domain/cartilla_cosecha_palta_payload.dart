import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaCosechaPaltaPayload
    extends CartillaMapHeaderPayloadBase<CartillaCosechaPaltaPayload> {
  final int payloadVersion;

  const CartillaCosechaPaltaPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaCosechaPaltaPayload.empty() => CartillaCosechaPaltaPayload(
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
      'operador': null,
      'supervisor': null,
      'nroFrutoEvaluados': 100,
      'danoBichoCesto': 0,
      'ausenciaPedunculo': 0,
      'pedunculoLargo': 0,
      'danoMecanico': 0,
      'danoGolpe': 0,
      'fumagina': 0,
      'lenticelosis': 0,
      'quemaduraSol': 0,
      'frutoDeforme': 0,
      'viracionColor': 0,
      'presenciaQueresas': 0,
      'danoTrips': 0,
      'sombreamiento': 0,
      'danoRoedor': 0,
      'sumbloth': 0,
      'quimera': 0,
      'rameado': 0,
      'frutoBarro': 0,
      'frutosDeshidratados': 0,
      'preCalibre': 0,
      'frutoExcretaAves': 0,
      'observaciones': null,
      'conDefectos': 0.0,
      'sinDefectos': 0.0,
    },
  );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toMap() => toJson();

  factory CartillaCosechaPaltaPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaCosechaPaltaPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaCosechaPaltaPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaCosechaPaltaPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
