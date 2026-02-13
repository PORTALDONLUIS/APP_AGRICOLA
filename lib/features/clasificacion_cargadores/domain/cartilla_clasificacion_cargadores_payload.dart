import 'dart:convert';
import '../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaClasificacionCargadoresPayload
    extends CartillaMapHeaderPayloadBase<CartillaClasificacionCargadoresPayload> {
  final int payloadVersion;

  const CartillaClasificacionCargadoresPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaClasificacionCargadoresPayload.empty() =>
      CartillaClasificacionCargadoresPayload(
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
          'evaluacion': null,
          'variedad': null,
          'hilera': null,
          'planta': null,

          // Primer alambre
          'p_debiles_456': 0,
          'p_normales_789': 0,
          'p_vigoroso_10111213': 0,

          // Segundo alambre
          's_debiles_456': 0,
          's_normales_789': 0,
          's_vigoroso_10111213': 0,

          // Tercer alambre
          't_debiles_456': 0,
          't_normales_789': 0,
          't_vigoroso_10111213': 0,

          // Calculado
          'total': 0.0,

          'observaciones': null,
        },
      );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaClasificacionCargadoresPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaClasificacionCargadoresPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaClasificacionCargadoresPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaClasificacionCargadoresPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
