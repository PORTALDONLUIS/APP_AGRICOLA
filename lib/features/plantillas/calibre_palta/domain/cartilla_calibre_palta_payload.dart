import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaCalibrePaltaPayload
    extends CartillaMapHeaderPayloadBase<CartillaCalibrePaltaPayload> {
  final int payloadVersion;

  const CartillaCalibrePaltaPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaCalibrePaltaPayload.empty() => CartillaCalibrePaltaPayload(
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
      'supervisor': null,
      'preCalibre': 0,
      'cal8': 0,
      'cal9': 0,
      'cal10': 0,
      'cal11': 0,
      'cal12': 0,
      'cal13': 0,
      'cal14': 0,
      'cal15': 0,
      'cal16': 0,
      'cal17': 0,
      'cal18': 0,
      'cal19': 0,
      'cal20': 0,
      'cal21': 0,
      'cal22': 0,
      'cal23': 0,
      'cal24': 0,
      'cal25': 0,
      'cal26': 0,
      'cal27': 0,
      'cal28': 0,
      'cal29': 0,
      'cal30': 0,
      'cal31': 0,
      'cal32': 0,
      'observaciones': null,
    },
  );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toMap() => toJson();

  factory CartillaCalibrePaltaPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaCalibrePaltaPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaCalibrePaltaPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaCalibrePaltaPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
