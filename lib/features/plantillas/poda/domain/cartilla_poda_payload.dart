import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';
import 'cartilla_poda_config.dart';

class CartillaPodaPayload
    extends CartillaMapHeaderPayloadBase<CartillaPodaPayload> {
  final int payloadVersion;

  const CartillaPodaPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaPodaPayload.empty() => CartillaPodaPayload(
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
          'podador': null,
          'supervisor': null,
          'pautaCargadores': 0,
          'pautaYemas': 0,
          'hilera': null,
          'planta': null,
          'pitones': null,
          'yemasPiton': null,
          'cargDer': null,
          'cargIzq': null,
          'totalCargadores': 0,
          'debil': null,
          'normal': null,
          'vigoroso': null,
          'totalConteo': 0,
          'totalYemas': 0,
          'cargDebilMin': null,
          'cargDebilMax': null,
          'cargNormalMin': null,
          'cargNormalMax': null,
          'cargVigorosoMin': null,
          'cargVigorosoMax': null,
          'tableados': null,
          'limpieza': null,
          'observacion': null,
          'fotos': <Map<String, dynamic>>[],
          'finalFotos': <Map<String, dynamic>>[],
          'foto1': null,
          for (int i = 1; i <= 50; i++) 'c$i': null,
          for (final key in CartillaPodaConfig.comparativeBodyKeys)
            CartillaPodaConfig.finalBodyKey(key): null,
        },
      );

  Map<String, dynamic> toJson() => {
        'payloadVersion': payloadVersion,
        'header': header,
        'body': body,
      };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaPodaPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaPodaPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaPodaPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaPodaPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
