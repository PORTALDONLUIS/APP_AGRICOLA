/*
// lib/features/fitosanidad/domain/cartilla_fito_payload.dart
import '../../cartillas/domain/cartilla_map_payload_base.dart';
import '../../cartillas/domain/cartilla_header_v1.dart';

class CartillaFitoPayload extends CartillaMapPayloadBase<CartillaFitoPayload> {
  const CartillaFitoPayload({
    required super.header, // CartillaHeaderV1
    required super.body,   // Map<String, dynamic>
  });

  factory CartillaFitoPayload.empty({
    required int plantillaId,
    required int userId,
  }) {
    return CartillaFitoPayload(
      header: CartillaHeaderV1(
        plantillaId: plantillaId,
        userId: userId,
        campaniaId: null,
        loteId: null,
        lat: null,
        lon: null,
        fechaEjecucion: null,
      ),
      body: <String, dynamic>{
        // ✅ Todo lo específico va en body
        'etapaFenologicaId': null,
        'hilera': null,
        'planta': null,
        'nMuestras': null,
        'nBrotes': null,
        'observaciones': null,
        'fotos': <Map<String, dynamic>>[],
      },
    );
  }

  // Helpers (opcionales, para evitar errores en UI)
  String? get etapaFenologicaId => body['etapaFenologicaId'] as String?;
  int? get hilera => (body['hilera'] as num?)?.toInt();
  int? get planta => (body['planta'] as num?)?.toInt();
  int? get nMuestras => (body['nMuestras'] as num?)?.toInt();
  int? get nBrotes => (body['nBrotes'] as num?)?.toInt();
  String? get observaciones => body['observaciones'] as String?;

  List<CartillaFitoFotoRef> get fotos {
    final raw = body['fotos'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => CartillaFitoFotoRef.fromMap(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  CartillaFitoPayload upsertFoto({
    required int slot,
    required String localPath,
    int? attachmentLocalId,
  }) {
    final next = fotos.toList();
    final idx = next.indexWhere((f) => f.slot == slot);

    final ref = CartillaFitoFotoRef(
      slot: slot,
      localPath: localPath,
      attachmentLocalId: attachmentLocalId,
    );

    if (idx >= 0) {
      next[idx] = ref;
    } else {
      next.add(ref);
    }

    final newBody = Map<String, dynamic>.from(body);
    newBody['fotos'] = next.map((e) => e.toMap()).toList();

    return copyWith(body: newBody);
  }

  CartillaFitoPayload removeFoto(int slot) {
    final next = fotos.where((f) => f.slot != slot).toList();
    final newBody = Map<String, dynamic>.from(body);
    newBody['fotos'] = next.map((e) => e.toMap()).toList();
    return copyWith(body: newBody);
  }

  CartillaFitoFotoRef? fotoBySlot(int slot) {
    final list = fotos;
    final idx = list.indexWhere((f) => f.slot == slot);
    if (idx < 0) return null;
    return list[idx];
  }

  @override
  CartillaFitoPayload copyWith({
    CartillaHeaderV1? header,
    Map<String, dynamic>? body,
  }) {
    return CartillaFitoPayload(
      header: header ?? this.header,
      body: body ?? Map<String, dynamic>.from(this.body),
    );
  }
}

class CartillaFitoFotoRef {
  final int slot;
  final int? attachmentLocalId;
  final String? localPath;

  const CartillaFitoFotoRef({
    required this.slot,
    this.attachmentLocalId,
    this.localPath,
  });

  Map<String, dynamic> toMap() => {
    'slot': slot,
    'attachmentLocalId': attachmentLocalId,
    'localPath': localPath,
  };

  factory CartillaFitoFotoRef.fromMap(Map<String, dynamic> map) {
    return CartillaFitoFotoRef(
      slot: (map['slot'] as num).toInt(),
      attachmentLocalId: (map['attachmentLocalId'] as num?)?.toInt(),
      localPath: map['localPath'] as String?,
    );
  }
}
*/

// lib/features/fitosanidad/domain/cartilla_fito_payload.dart
import 'dart:convert';

import '../../../cartillas/domain/cartilla_map_header_payload_base.dart';

class CartillaFitoPayload extends CartillaMapHeaderPayloadBase<CartillaFitoPayload> {
  final int payloadVersion;

  const CartillaFitoPayload({
    this.payloadVersion = 1,
    required super.header, // Map<String, dynamic>
    required super.body,   // Map<String, dynamic>
  });

  /// ✅ ESTÁNDAR BROTACIÓN: payloadVersion + header/body (Map)
  factory CartillaFitoPayload.empty() => const CartillaFitoPayload(
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
      // ✅ Campos propios Fitosanidad (todo aquí)
      'etapaFenologicaId': null,
      'hilera': null,
      'planta': null,
      'nMuestras': null,
      'nBrotes': null,

      // ✅ textos / fotos (si los usas)
      'observaciones': null,
      'fotos': <Map<String, dynamic>>[],
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

  // Helpers (opcionales)
  String? get etapaFenologicaId => body['etapaFenologicaId'] as String?;
  int? get hilera => (body['hilera'] as num?)?.toInt();
  int? get planta => (body['planta'] as num?)?.toInt();
  int? get nMuestras => (body['nMuestras'] as num?)?.toInt();
  int? get nBrotes => (body['nBrotes'] as num?)?.toInt();
  String? get observaciones => body['observaciones'] as String?;

  List<CartillaFitoFotoRef> get fotos {
    final raw = body['fotos'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => CartillaFitoFotoRef.fromMap(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  CartillaFitoPayload upsertFoto({
    required int slot,
    required String localPath,
    int? attachmentLocalId,
  }) {
    final next = fotos.toList();
    final idx = next.indexWhere((f) => f.slot == slot);

    final ref = CartillaFitoFotoRef(
      slot: slot,
      localPath: localPath,
      attachmentLocalId: attachmentLocalId,
    );

    if (idx >= 0) {
      next[idx] = ref;
    } else {
      next.add(ref);
    }

    final newBody = Map<String, dynamic>.from(body);
    newBody['fotos'] = next.map((e) => e.toMap()).toList();

    return copyWith(body: newBody);
  }

  CartillaFitoPayload removeFoto(int slot) {
    final next = fotos.where((f) => f.slot != slot).toList();
    final newBody = Map<String, dynamic>.from(body);
    newBody['fotos'] = next.map((e) => e.toMap()).toList();
    return copyWith(body: newBody);
  }

  CartillaFitoFotoRef? fotoBySlot(int slot) {
    final list = fotos;
    final idx = list.indexWhere((f) => f.slot == slot);
    if (idx < 0) return null;
    return list[idx];
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

class CartillaFitoFotoRef {
  final int slot;
  final int? attachmentLocalId;
  final String? localPath;

  const CartillaFitoFotoRef({
    required this.slot,
    this.attachmentLocalId,
    this.localPath,
  });

  Map<String, dynamic> toMap() => {
    'slot': slot,
    'attachmentLocalId': attachmentLocalId,
    'localPath': localPath,
  };

  factory CartillaFitoFotoRef.fromMap(Map<String, dynamic> map) {
    return CartillaFitoFotoRef(
      slot: (map['slot'] as num).toInt(),
      attachmentLocalId: (map['attachmentLocalId'] as num?)?.toInt(),
      localPath: map['localPath'] as String?,
    );
  }
}

