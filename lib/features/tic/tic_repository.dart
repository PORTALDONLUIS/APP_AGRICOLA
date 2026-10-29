import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/providers.dart';

final ticRepositoryProvider = Provider<TicRepository>(
  (ref) => TicRepository(
    ref.read(dioClientProvider).dio,
    ref.read(secureStorageProvider),
    ref.watch(currentUserIdProvider),
    currentUserId: () => ref.read(currentUserIdProvider),
  ),
);
final ticDraftsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => ref.watch(ticRepositoryProvider).drafts(),
    );
final ticCatalogProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) => ref.watch(ticRepositoryProvider).catalog(),
);

String ticId() {
  final random = Random.secure();
  final b = List<int>.generate(16, (_) => random.nextInt(256));
  b[6] = (b[6] & 15) | 64;
  b[8] = (b[8] & 63) | 128;
  final s = b.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
  return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
}

String ticError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['error'] is String) return data['error'] as String;
    if (error.response?.statusCode == 403) {
      return 'No tienes habilitadas estas cartillas o la sesión venció.';
    }
    return 'No se pudo confirmar la operación. El borrador se conserva. Revisa la conexión y verifica antes de reintentar.';
  }
  return error is FormatException
      ? error.message
      : 'No se pudo completar la operación. El borrador se conserva.';
}

class TicRepository {
  TicRepository(this.dio, this.storage, this.userId, {this.currentUserId});
  final int Function()? currentUserId;
  void checkSession() {
    if (currentUserId != null && currentUserId!() != userId) {
      throw const FormatException(
        'Cambió la cuenta de la app. Abre nuevamente Asignaciones TIC.',
      );
    }
  }

  final Dio dio;
  final FlutterSecureStorage storage;
  final int userId;
  static const root = '/api/tic/asignaciones';
  String key(String value) => 'tic.$userId.$value';
  Future<Map<String, dynamic>> get(
    String path, [
    Map<String, dynamic>? query,
  ]) async {
    checkSession();
    final response = await dio.get(
      '$root/$path/',
      queryParameters: query,
      options: Options(receiveTimeout: const Duration(seconds: 60)),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> catalog() async {
    try {
      final data = await get('catalogo');
      await storage.write(key: key('catalog'), value: jsonEncode(data));
      return data;
    } on DioException catch (e) {
      if ([401, 403].contains(e.response?.statusCode)) {
        await storage.delete(key: key('catalog'));
        rethrow;
      }
      final cache = await storage.read(key: key('catalog'));
      if (cache == null) rethrow;
      return {
        ...Map<String, dynamic>.from(jsonDecode(cache) as Map),
        'offline': true,
      };
    }
  }

  Future<Map<String, dynamic>> schema(
    String operation,
    String target, {
    String? type,
  }) => get('formulario', {
    'operacion': operation,
    'id': target,
    if (type != null) 'tipo': type,
  });
  String draftKey(String op, String target) => key('draft.$op.$target');
  Future<Map<String, dynamic>?> draft(String op, String target) async {
    final raw = await storage.read(key: draftKey(op, target));
    return raw == null
        ? null
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<List<Map<String, dynamic>>> drafts() async {
    final all = await storage.readAll();
    final rows = <Map<String, dynamic>>[];
    for (final item in all.entries.where(
      (e) => e.key.startsWith(key('draft.')),
    )) {
      final value = Map<String, dynamic>.from(jsonDecode(item.value) as Map);
      final suffix = item.key.substring(key('draft.').length).split('.');
      if (suffix.length == 2) {
        rows.add({
          'operation': suffix[0],
          'target': suffix[1],
          'title': (value['schema'] as Map?)?['title'] ?? suffix[0],
        });
      }
    }
    return rows;
  }

  Future<void> saveDraft(
    String op,
    String target,
    Map<String, dynamic> value,
  ) => storage.write(key: draftKey(op, target), value: jsonEncode(value));
  Future<void> clearDraft(String op, String target) =>
      storage.delete(key: draftKey(op, target));
  Future<Map<String, dynamic>> confirm(
    String op,
    String target,
    Map<String, dynamic> draft,
  ) async {
    checkSession();
    final data = FormData();
    final values = Map<String, dynamic>.from(draft['values'] as Map);
    if (op == 'equipo_nuevo' || op == 'componentes') {
      final computer =
          op == 'componentes' ||
          ['pc', 'laptop', 'servidor'].contains('${values['tipo']}');
      for (final kind in ['ram', 'disco']) {
        final count = computer
            ? (int.tryParse('${values['${kind}_cantidad'] ?? 0}') ?? 0).clamp(
                0,
                kind == 'ram' ? 64 : 16,
              )
            : 0;
        values['${kind}_cantidad'] = count;
        final fields = kind == 'ram'
            ? ['ram_capacidad', 'ram_tipo', 'ram_velocidad', 'ram_serie']
            : [
                'disco_capacidad',
                'disco_tipo_item',
                'disco_interfaz',
                'disco_serie',
              ];
        for (final name in fields) {
          values[name] = (values[name] as List? ?? []).take(count).toList();
        }
      }
    }
    values.addAll({
      'operacion': op,
      'destino': target,
      'operacion_id': draft['operationId'],
      'revision': draft['revision'],
    });
    for (final item in values.entries) {
      if (item.value is List) {
        for (final v in item.value as List) {
          data.fields.add(MapEntry(item.key, '$v'));
        }
      } else if (item.value == true) {
        data.fields.add(MapEntry(item.key, 'on'));
      } else if (item.value != false && item.value != null) {
        data.fields.add(MapEntry(item.key, '${item.value}'));
      }
    }
    final photos = Map<String, dynamic>.from(draft['photos'] as Map? ?? {});
    for (final entry in photos.entries) {
      final file = File('${entry.value}');
      if (!await file.exists()) {
        throw const FormatException(
          'Falta una foto del borrador. Vuelve a seleccionarla antes de confirmar.',
        );
      }
      data.files.add(
        MapEntry(entry.key, await MultipartFile.fromFile(file.path)),
      );
    }
    try {
      checkSession();
      final response = await dio.post(
        '$root/confirmar/',
        data: data,
        options: Options(
          receiveTimeout: const Duration(seconds: 65),
          sendTimeout: const Duration(seconds: 65),
        ),
      );
      final receipt = Map<String, dynamic>.from(response.data as Map);
      if (receipt['ok'] != true) {
        throw FormatException(
          '${receipt['error'] ?? 'La operación no fue confirmada.'}',
        );
      }
      return receipt;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409 ||
          e.response == null ||
          (e.response?.statusCode ?? 0) >= 500) {
        try {
          final receipt = await get('estado/${draft['operationId']}');
          if (receipt['ok'] != true) {
            rethrow;
          }
          if (e.response?.statusCode == 409) {
            receipt['messages'] = [
              ...(receipt['messages'] as List? ?? []),
              'Se recuperó una confirmación previa. Los cambios posteriores del borrador no se aplicaron; revisa el PDF y usa Corregir ficha si necesitas modificarlos.',
            ];
          }
          return receipt;
        } catch (_) {
          /* conserva el mismo identificador */
        }
      }
      rethrow;
    }
  }

  Future<void> sharePdf(
    String reference,
    String title, {
    Map<String, dynamic> query = const {},
  }) async {
    checkSession();
    if (reference.isEmpty) {
      throw const FormatException(
        'Este registro no tiene un documento confirmado para compartir.',
      );
    }
    final folder = await getTemporaryDirectory();
    final name = sha256
        .convert(utf8.encode('$userId:$reference:${jsonEncode(query)}'))
        .toString();
    final file = File('${folder.path}/DonTec_TIC_${userId}_$name.pdf');
    try {
      final response = await dio.get<List<int>>(
        '$root/pdf/$reference/',
        queryParameters: query,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      final bytes = response.data ?? [];
      if (bytes.length < 5 ||
          ascii.decode(bytes.take(5).toList(), allowInvalid: true) != '%PDF-') {
        throw const FormatException(
          'El servidor no devolvió un PDF válido. Revisa los filtros del reporte.',
        );
      }
      await file.writeAsBytes(bytes, flush: true);
    } on DioException catch (e) {
      if (e.response != null || !await file.exists()) rethrow;
    }
    checkSession();
    await Share.shareXFiles([
      XFile(file.path, mimeType: 'application/pdf'),
    ], text: 'DonTec · Asignaciones TIC\n$title');
  }
}
