import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaLongBroteRacimoPayload
    extends CartillaMapHeaderPayloadBase<CartillaLongBroteRacimoPayload> {
  final int payloadVersion;

  const CartillaLongBroteRacimoPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaLongBroteRacimoPayload.empty() => const CartillaLongBroteRacimoPayload(
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
      // Campos propios (van aquí)
      'cantidadMuestras': null,
      'hilera': null,
      'planta': null,
      'corresponde': null,
      'observaciones': null,
      'fotos': <Map<String, dynamic>>[],
      'total_brote_evaluado': 0.0,
      'prom_long_x_planta_brote': 0.0,
    },
  );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaLongBroteRacimoPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaLongBroteRacimoPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaLongBroteRacimoPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaLongBroteRacimoPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
