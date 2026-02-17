import 'dart:convert';
import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaConteoCargadoresPayload
    extends CartillaMapHeaderPayloadBase<CartillaConteoCargadoresPayload> {
  final int payloadVersion;

  const CartillaConteoCargadoresPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaConteoCargadoresPayload.empty() =>
      CartillaConteoCargadoresPayload(
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
          'hilera': null,
          'planta': null,
          'corresponde': null,
          'numeroCargadores': 0,
          'observaciones': null,
        },
      );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaConteoCargadoresPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaConteoCargadoresPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaConteoCargadoresPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaConteoCargadoresPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
