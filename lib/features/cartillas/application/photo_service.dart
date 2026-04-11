import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoCaptureResult {
  final int slot;
  final String localPath;
  final DateTime createdAt;

  PhotoCaptureResult({
    required this.slot,
    required this.localPath,
    required this.createdAt,
  });
}

class PhotoService {
  final ImagePicker _picker;

  PhotoService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Nombre único por captura (evita colisiones entre usuarios, registros o reemplazos).
  static String _uniqueFileName(int slot) {
    final t = DateTime.now().microsecondsSinceEpoch;
    final r = Random().nextInt(1 << 30);
    return 's${slot}_${t}_$r.jpg';
  }

  /// Carpeta estable por [userId] y [localId] del registro:
  /// `{docs}/cartillas/user_{userId}/reg_{localId}/`
  ///
  /// Cada foto es un archivo nuevo (nombre único); la relación con el campo sigue en
  /// `body.fotos[].slot` + `localPath` en el payload.
  Future<PhotoCaptureResult?> captureToSlot({
    required int localId,
    required int slot,
    int userId = 0,
    int imageQuality = 85,
  }) async {
    final cam = await Permission.camera.request();
    debugPrint('CAM PERMISSION => $cam');
    if (!cam.isGranted) return null;

    final XFile? shot = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
    );
    debugPrint('SHOT => ${shot?.path}');

    if (shot == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final safeUser = userId < 0 ? 0 : userId;
    final folder = Directory('${dir.path}/cartillas/user_$safeUser/reg_$localId');
    await folder.create(recursive: true);

    final targetPath = '${folder.path}/${_uniqueFileName(slot)}';

    await File(shot.path).copy(targetPath);

    return PhotoCaptureResult(
      slot: slot,
      localPath: targetPath,
      createdAt: DateTime.now().toUtc(),
    );
  }

  /// Borra el archivo indicado en el payload; si no existe o no hay ruta, intenta el
  /// esquema antiguo `cartillas/{localId}/foto_{slot}.jpg`.
  Future<void> deletePhoto({
    required int localId,
    required int slot,
    String? localPath,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    var removed = false;

    if (localPath != null && localPath.isNotEmpty) {
      final f = File(localPath);
      if (await f.exists()) {
        await f.delete();
        removed = true;
      }
    }

    if (!removed) {
      final legacy = File('${dir.path}/cartillas/$localId/foto_$slot.jpg');
      if (await legacy.exists()) {
        await legacy.delete();
      }
    }
  }

}
