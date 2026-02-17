import 'dart:convert';
import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaFloracionCuajaPayload
    extends CartillaMapHeaderPayloadBase<CartillaFloracionCuajaPayload> {
  final int payloadVersion;

  const CartillaFloracionCuajaPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaFloracionCuajaPayload.empty() =>
      CartillaFloracionCuajaPayload(
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
          'cantidadMuestras': null,
          'hilera': null,
          'planta': null,
          'caliptraHinchada': 0,
          'p10': 0,
          'p20': 0,
          'p30': 0,
          'p40': 0,
          'p50': 0,
          'p60': 0,
          'p70': 0,
          'p80': 0,
          'p90': 0,
          'p100': 0,
          'cuaja': 0,
          'caliptraPct': 0.0,
          'floracionPct': 0.0,
          'cuajaPct': 0.0,
          'sumFloracion': 0.0,
          'totalRacimos': 0.0,
          'observaciones': null,
        },
      );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaFloracionCuajaPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaFloracionCuajaPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaFloracionCuajaPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaFloracionCuajaPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
