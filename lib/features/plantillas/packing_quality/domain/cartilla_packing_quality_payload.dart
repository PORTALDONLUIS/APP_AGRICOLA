import 'dart:convert';
import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaPackingQualityPayload
    extends CartillaMapHeaderPayloadBase<CartillaPackingQualityPayload> {
  final int payloadVersion;
  const CartillaPackingQualityPayload({
    this.payloadVersion = 1,
    required super.header,
    required super.body,
  });
  Map<String, dynamic> toJson() => {
    'payloadVersion': payloadVersion,
    'header': header,
    'body': body,
  };
  String toJsonString() => jsonEncode(toJson());
  factory CartillaPackingQualityPayload.fromJsonString(String raw) {
    final j = (jsonDecode(raw) as Map?)?.cast<String, dynamic>() ?? {};
    return CartillaPackingQualityPayload(
      payloadVersion: (j['payloadVersion'] as int?) ?? 1,
      header: (j['header'] as Map?)?.cast<String, dynamic>() ?? {},
      body: (j['body'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }
  @override
  CartillaPackingQualityPayload copyWith({
    int? payloadVersion,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
  }) => CartillaPackingQualityPayload(
    payloadVersion: payloadVersion ?? this.payloadVersion,
    header: header ?? Map<String, dynamic>.from(this.header),
    body: body ?? Map<String, dynamic>.from(this.body),
  );
}
