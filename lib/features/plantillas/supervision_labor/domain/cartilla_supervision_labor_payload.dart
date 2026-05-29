import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaSupervisionLaborPayload
    extends CartillaMapHeaderPayloadBase<CartillaSupervisionLaborPayload> {
  final int payloadVersion;

  const CartillaSupervisionLaborPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaSupervisionLaborPayload.empty() =>
      CartillaSupervisionLaborPayload(
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
          'supervisor': null,
          'sector': null,
          'horaInicio': null,
          'horaFinal': null,
          'fecha': null,
          'labor': null,
          for (var i = 1; i <= 6; i++) ...{
            'trabajador${i}_nombre': null,
            'trabajador${i}_dni': null,
            'trabajador${i}_firmaEntrada': null,
            'trabajador${i}_hilera': null,
            'trabajador${i}_plantasInicio': null,
            'trabajador${i}_plantasFinal': null,
            'trabajador${i}_subtotal': 0.0,
            'trabajador${i}_plantasRacimoRechazado': 0,
            'trabajador${i}_total': 0.0,
            'trabajador${i}_firmaSalida': null,
          },
          'totalPlantasORacimos': 0.0,
          'rendimientoPromedioJornal': 0.0,
          'numeroTrabajadores': 0.0,
          'firmaSupervisor': null,
          'firmaProduccion': null,
          'observaciones': null,
        },
      );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaSupervisionLaborPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};

    return CartillaSupervisionLaborPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaSupervisionLaborPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaSupervisionLaborPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
