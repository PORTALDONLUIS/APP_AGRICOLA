import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaPackingCajasPayload
    extends CartillaMapHeaderPayloadBase<CartillaPackingCajasPayload> {
  final int payloadVersion;

  const CartillaPackingCajasPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaPackingCajasPayload.empty() => CartillaPackingCajasPayload(
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
      'fechaRecepcion': null,
      'fechaProceso': null,
      'tipoEnvase': null,
      'tipoPresentacion': null,
      'categoria': null,
      'pallet1Calibre10': 0,
      'pallet1Calibre12': 0,
      'pallet1Calibre14': 0,
      'pallet1Calibre16': 0,
      'pallet1Calibre18': 0,
      'pallet1Calibre20': 0,
      'pallet1Calibre22': 0,
      'pallet1Calibre24': 0,
      'pallet1Calibre26': 0,
      'pallet1Calibre28': 0,
      'pallet1Calibre30': 0,
      'pallet1Calibre32': 0,
      'pallet1SinCalibre': 0,
      'pallet2Calibre10': 0,
      'pallet2Calibre12': 0,
      'pallet2Calibre14': 0,
      'pallet2Calibre16': 0,
      'pallet2Calibre18': 0,
      'pallet2Calibre20': 0,
      'pallet2Calibre22': 0,
      'pallet2Calibre24': 0,
      'pallet2Calibre26': 0,
      'pallet2Calibre28': 0,
      'pallet2Calibre30': 0,
      'pallet2Calibre32': 0,
      'pallet2SinCalibre': 0,
    },
  );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toMap() => toJson();

  factory CartillaPackingCajasPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaPackingCajasPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaPackingCajasPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaPackingCajasPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
