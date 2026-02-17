import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaCalibreBayasPayload
    extends CartillaMapHeaderPayloadBase<CartillaCalibreBayasPayload> {
  final int payloadVersion;

  const CartillaCalibreBayasPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaCalibreBayasPayload.empty() => CartillaCalibreBayasPayload(
    payloadVersion: 1,
    header: {
      // ✅ HEADER estándar (alineado a dbo.PlantillaRegistro)
      'plantillaId': null,
      'userId': null,
      'campaniaId': null,
      'loteId': null,
      'lat': null,
      'lon': null,
      'fechaEjecucion': null,
    },
    body: {
      // ✅ Datos generales
      'cantidadMuestras': null,
      'hilera': null,
      'planta': null,
      'corresponde': null,

      // ✅ Calibres (conteos)
      'mm0_5': 0,
      'mm1': 0,
      'mm1_5': 0,
      'mm2': 0,
      'mm2_5': 0,
      'mm3': 0,
      'mm3_5': 0,
      'mm4': 0,
      'mm4_5': 0,
      'mm5': 0,
      'mm5_5': 0,
      'mm6': 0,
      'mm6_5': 0,
      'mm7': 0,
      'mm7_5': 0,
      'mm8': 0,
      'mm8_5': 0,
      'mm9': 0,
      'mm9_5': 0,
      'mm10': 0,
      'mm10_5': 0,
      'mm11': 0,
      'mm11_5': 0,
      'mm12': 0,
      'mm12_5': 0,
      'mm13': 0,
      'mm13_5': 0,
      'mm14': 0,
      'mm14_5': 0,
      'mm15': 0,
      'mm15_5': 0,
      'mm16': 0,
      'mm16_5': 0,
      'mm17': 0,
      'mm17_5': 0,
      'mm18': 0,
      'mm18_5': 0,
      'mm19': 0,
      'mm19_5': 0,
      'mm20': 0,
      'mm20_5': 0,
      'mm21': 0,
      'mm21_5': 0,
      'mm22': 0,
      'mm22_5': 0,
      'mm23': 0,
      'mm23_5': 0,
      'mm24': 0,
      'mm24_5': 0,
      'mm25': 0,
      'mm25_5': 0,
      'mm26': 0,
      'mm26_5': 0,
      'mm27': 0,
      'mm27_5': 0,
      'mm28': 0,
      'mm28_5': 0,
      'mm29': 0,
      'mm29_5': 0,
      'mm30': 0,
      'mm30_5': 0,
      'mm31': 0,
      'mm31_5': 0,
      'mm32': 0,
      'mm32_5': 0,
      'mm33': 0,
      'mm33_5': 0,
      'mm34': 0,
      'mm34_5': 0,
      'mm35': 0,
      'mm35_5': 0,
      'mm36': 0,
      'mm36_5': 0,
      'mm37': 0,
      'mm37_5': 0,
      'mm38': 0,

      // ✅ Calculados
      'totalBayasEvaluadas': 0.0,
      'promCalibresPlanta': 0.0,
    },
  );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaCalibreBayasPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaCalibreBayasPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaCalibreBayasPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaCalibreBayasPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
