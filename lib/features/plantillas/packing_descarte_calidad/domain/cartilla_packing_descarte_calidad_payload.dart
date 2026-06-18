import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaPackingDescarteCalidadPayload
    extends
        CartillaMapHeaderPayloadBase<CartillaPackingDescarteCalidadPayload> {
  final int payloadVersion;

  const CartillaPackingDescarteCalidadPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaPackingDescarteCalidadPayload.empty() =>
      CartillaPackingDescarteCalidadPayload(
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
          'variedad': null,
          'descartePesoNetoTotal': null,
          'porcentajeDescarte': 0.0,
          'guia1NroGuia': null,
          'guia1NBines': 0,
          'guia1PesoNeto': null,
          'guia2NroGuia': null,
          'guia2NBines': 0,
          'guia2PesoNeto': null,
          'guia3NroGuia': null,
          'guia3NBines': 0,
          'guia3PesoNeto': null,
          'guia4NroGuia': null,
          'guia4NBines': 0,
          'guia4PesoNeto': null,
          'nBinesTotal': 0,
          'pesoNetoTotal': 0.0,
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

  factory CartillaPackingDescarteCalidadPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaPackingDescarteCalidadPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaPackingDescarteCalidadPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaPackingDescarteCalidadPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}
