import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaFitoPayload extends CartillaMapHeaderPayloadBase<CartillaFitoPayload> {
  final int payloadVersion;

  const CartillaFitoPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });

  factory CartillaFitoPayload.empty() => CartillaFitoPayload(
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
          'etapaFenologica': null,
          'hilera': null,
          'planta': null,
          'nMuestras': null,
          'nBrotesHojasRacimo': null,

          'thripsBrote_nroBrote': 0,
          'thripsBrote_nroIndividuo': 0,

          'pulgonBrote_nroBrote': 0,
          'pulgonBrote_grado': 0,

          'oidiumHojas_nroHojas': 0,
          'oidiumHojas_grado': 0,

          'mildiumHojas_nroHojas': 0,
          'mildiumHojas_grado': 0,

          'aranitaRojaHojas_nroHoja': 0,
          'aranitaRojaHojas_grado': 0,

          'lepidopterosHojas_larvasChicasNroHojas': 0,
          'lepidopterosHojas_larvasChicasIndividuo': null,
          'lepidopterosHojas_larvasGrandesNroHojas': 0,
          'lepidopterosHojas_larvasGrandesIndividuo': null,

          'eumorphaHojas_larvasChicasNroHojas': 0,
          'eumorphaHojas_larvasChicasIndividuo': null,
          'eumorphaHojas_larvasGrandesNroHojas': 0,
          'eumorphaHojas_larvasGrandesIndividuo': null,

          'acaroHialinoHojas_nroHoja': 0,
          'acaroHialinoHojas_grado': 0,

          'filoxeraHojas_nroHoja': 0,
          'filoxeraHojas_nroAgallas': null,

          'pseudococusHojas_nroHojas': 0,
          'pseudococusHojas_nroIndividuo': null,

          'moscaBlancaHojas_nroHoja': 0,
          'moscaBlancaHojas_grado': 0,

          'scolytusTallo_totalZonaPorPlanta': 0,
          'pseudococcusTallo_totalZonaPorPlanta': 0,

          'queresaHojas_nroHojas': 0,
          'queresaHojas_nroIndividuo': 0,

          'thripsFlores_nroRacimos': 0,
          'thripsFlores_nroIndividuo': 0,

          'botrytisFlores_nroRacimos': 0,
          'botrytisFlores_grado': 0,

          'pseudococusFruto_nroRacimos': 0,

          'oidiumFrutos_nroRacimos': 0,
          'oidiumFrutos_grado': 0,

          'mildiuFrutos_nroRacimos': 0,
          'mildiuFrutos_grado': 0,

          'botrytisFrutos_nroRacimos': 0,
          'botrytisFrutos_grado': 0,

          'pudricionAcidasFrutos_nroRacimos': 0,
          'pudricionAcidasFrutos_grado': 0,

          'paloNegroFrutos_nroRacimos': 0,
          'paloNegroFrutos_grado': 0,

          'danoAvesFrutos_nroRacimos': 0,
          'danoAvesFrutos_grado': 0,

          'partidurasFrutos_nroRacimos': 0,
          'partidurasFrutos_grado': 0,

          'carachaFrutos_nroRacimos': 0,
          'carachaFrutos_grado': 0,

          'colapsoFrutos_nroRacimos': 0,
          'colapsoFrutos_grado': 0,

          'empoaskaHojas_nroHojas': 0,
          'empoaskaHojas_nroIndividuo': 0,

          'observaciones': null,
          'foto1': null,
          'foto2': null,
          'foto3': null,
          'foto4': null,
          'foto5': null,
          'foto6': null,
          'foto7': null,
          'foto8': null,
          'foto9': null,
          'foto10': null,
        },
      );

  Map<String, dynamic> toJson() => {
        'payloadVersion': payloadVersion,
        'header': header,
        'body': body,
      };

  String toJsonString() => jsonEncode(toJson());

  factory CartillaFitoPayload.fromJsonString(String raw) {
    final json = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaFitoPayload(
      payloadVersion: (json['payloadVersion'] as int?) ?? 1,
      header: (json['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (json['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  CartillaFitoPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaFitoPayload(
      payloadVersion: payloadVersion ?? this.payloadVersion,
      header: header ?? Map<String, dynamic>.from(this.header),
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}

/// Entrada de la lista `fotos` en body (p. ej. widgets que listan adjuntos por slot).
class CartillaFitoFotoRef {
  final int slot;
  final int? attachmentLocalId;
  final String? localPath;

  const CartillaFitoFotoRef({
    required this.slot,
    this.attachmentLocalId,
    this.localPath,
  });

  factory CartillaFitoFotoRef.fromMap(Map<String, dynamic> map) {
    return CartillaFitoFotoRef(
      slot: (map['slot'] as num).toInt(),
      attachmentLocalId: (map['attachmentLocalId'] as num?)?.toInt(),
      localPath: map['localPath'] as String?,
    );
  }
}