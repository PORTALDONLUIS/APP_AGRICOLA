import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';
import 'cartilla_inspeccion_verificacion_riegos_config.dart';

class CartillaInspeccionVerificacionRiegosPayload
    extends CartillaMapHeaderPayloadBase<CartillaInspeccionVerificacionRiegosPayload> {
  final int payloadVersion;

  const CartillaInspeccionVerificacionRiegosPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaInspeccionVerificacionRiegosPayload.empty() {
    final selections = <String, dynamic>{
      for (final group in CartillaInspeccionVerificacionRiegosConfig.allCheckGroups)
        group.key: <String>[],
    };
    return CartillaInspeccionVerificacionRiegosPayload(
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
        'fecha': null,
        'sede': null,
        'fundo': null,
        'pozo': null,
        'responsableArea': null,
        ...selections,
        // Esta matriz contiene SI/NO de todos los puntos de inspección.
        'verificaciones': <String, dynamic>{},
        'observaciones': null,
        'lavadoObservaciones': null,
        'dispensadorObservaciones': null,
        'fotos': <Map<String, dynamic>>[],
        'firmaControlCalidad': null,
        'supervisor': null,
        'firmaSupervisor': null,
      },
    );
  }

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaInspeccionVerificacionRiegosPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaInspeccionVerificacionRiegosPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaInspeccionVerificacionRiegosPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) => CartillaInspeccionVerificacionRiegosPayload(
    payloadVersion: payloadVersion ?? this.payloadVersion,
    header: header ?? Map<String, dynamic>.from(this.header),
    body: body ?? Map<String, dynamic>.from(this.body),
  );
}
