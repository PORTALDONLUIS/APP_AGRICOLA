import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaPackingRecepcionPayload
    extends CartillaMapHeaderPayloadBase<CartillaPackingRecepcionPayload> {
  final int payloadVersion;

  const CartillaPackingRecepcionPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaPackingRecepcionPayload.empty() =>
      CartillaPackingRecepcionPayload(
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
          'variedad': null,
          'nroGuia': null,
          'totalBinesPorGuia': null,
          'sector': null,
          'nBines': null,
          'pesoTotalBines': null,
          'pesoNeto': null,
          'pesoPorBin': 0.0,
          'danoBichoCesto': 0,
          'ausenciaPedunculo': 0,
          'pedunculoLargo': 0,
          'danoMecanico': 0,
          'danoGolpe': 0,
          'heridaAbierta': 0,
          'fumagina': 0,
          'lenticelosis': 0,
          'quemaduraSol': 0,
          'frutoDeforme': 0,
          'viracionColor': 0,
          'presenciaQueresas': 0,
          'danoOxidya': 0,
          'danoTrips': 0,
          'sombreamiento': 0,
          'grietas': 0,
          'frutoRusset': 0,
          'frutoRoce': 0,
          'danoRoedor': 0,
          'sumbloth': 0,
          'quimera': 0,
          'rameado': 0,
          'frutoBarro': 0,
          'frutosDeshidratados': 0,
          'preCalibre': 0,
          'sobremadurez': 0,
          'pepaSuelta': 0,
          'frutoExcretaAves': 0,
          'contactoSuelo': 0,
          'observacion': null,
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

  factory CartillaPackingRecepcionPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaPackingRecepcionPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaPackingRecepcionPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaPackingRecepcionPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
