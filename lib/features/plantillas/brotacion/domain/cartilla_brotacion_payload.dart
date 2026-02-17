import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';


class CartillaBrotacionPayload
    extends CartillaMapHeaderPayloadBase<CartillaBrotacionPayload> {
  final int payloadVersion;

  const CartillaBrotacionPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaBrotacionPayload.empty() => CartillaBrotacionPayload(
    payloadVersion: 1,
    header: {
      // ✅ HEADER estándar (alineado a dbo.PlantillaRegistro)
      'plantillaId': null,
      'userId': null,
      'campaniaId': null, // ✅ se usará este para el combo de campaña
      'loteId': null,     // ✅ se usará este para el combo de lote
      'lat': null,
      'lon': null,
      'fechaEjecucion': null,
    },
    body: {
      // ✅ Datos generales (body)
      'variedad': null,
      'cantidadMuestras': null,
      'hilera': null,
      'planta': null,
      'corresponde': null,

      // Campos propios de brotación
      'yemaHinchada': 0,
      'botonAlgodonoso': 0,
      'puntaVerde': 0,
      'hojasExtendidas': 0,
      'yemasNecroticas': 0,
      'totalYemas': 0,

      // texto
      'observaciones': null,
    },
  );


  /// Calcula totalYemas
  CartillaBrotacionPayload withComputedTotals() {
    int asInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

    final total = asInt(body['yemaHinchada']) +
        asInt(body['botonAlgodonoso']) +
        asInt(body['puntaVerde']) +
        asInt(body['hojasExtendidas']) +
        asInt(body['yemasNecroticas']);

    final newBody = Map<String, dynamic>.from(body);
    newBody['totalYemas'] = total;

    return copyWith(body: newBody);
  }

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toMap() => toJson();


  factory CartillaBrotacionPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaBrotacionPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaBrotacionPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaBrotacionPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
