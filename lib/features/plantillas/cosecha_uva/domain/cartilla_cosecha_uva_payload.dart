import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaCosechaUvaPayload
    extends CartillaMapHeaderPayloadBase<CartillaCosechaUvaPayload> {
  final int payloadVersion;

  const CartillaCosechaUvaPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaCosechaUvaPayload.empty() => CartillaCosechaUvaPayload(
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
      'fecha': null,
      'operario': null,
      'codigoLimpiador': null,
      'supervisor': null,
      'variedad': null,
      'hora': null,
      'temperatura': null,
      'conformados': null,
      'pampanos': null,
      'semipaludos': null,
      'paludos': null,
      'totalRacimos': null,
      'verde': null,
      'cremoso': null,
      'ambar': null,
      'totalRacimosColor': null,
      'pudricion': null,
      'partiduras': null,
      'mediaLuna': null,
      'oidium': null,
      'danoMecanico': null,
      'chanchitoBlanco': null,
      'paloNegro': null,
      'presenciaPolvo': null,
      'presenciaAranaTela': null,
      'bayasAcuosas': null,
      'golpeSol': null,
      'raquisLignificado': null,
      'pediceloNecrosado': null,
      'russet': null,
      'descalibre': null,
      'colapso': null,
      'restosVegetales': <String>[],
      'observaciones': null,
      'racimosConDefectos': null,
      'racimosSinDefectos': null,
      'porcentajeConDefectos': null,
      'porcentajeSinDefectos': null,
      'totalBayasDefectuosas': null,
      'restosVegetalesSiNo': null,
      'fotos': <Map<String, dynamic>>[],
    },
  );

  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toMap() => toJson();

  factory CartillaCosechaUvaPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaCosechaUvaPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaCosechaUvaPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaCosechaUvaPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
