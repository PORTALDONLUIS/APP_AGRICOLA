import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Datos publicados en version.json del repositorio oficial.
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.latestVersion,
    required this.buildNumber,
    required this.minimumBuild,
    required this.isMandatory,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.fileSizeBytes,
    required this.sha256,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) => AppUpdateInfo(
    latestVersion: json['latest_version'] as String? ?? '',
    buildNumber: (json['build_number'] as num?)?.toInt() ?? 0,
    minimumBuild: (json['minimum_build'] as num?)?.toInt() ?? 0,
    isMandatory: json['is_mandatory'] as bool? ?? false,
    releaseNotes: json['release_notes'] as String? ?? '',
    downloadUrl: json['download_url'] as String? ?? '',
    fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt() ?? 0,
    sha256: json['sha256'] as String? ?? '',
  );

  final String latestVersion;
  final int buildNumber;
  final int minimumBuild;
  final bool isMandatory;
  final String releaseNotes;
  final String downloadUrl;
  final int fileSizeBytes;
  final String sha256;

  String get sizeLabel =>
      '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

enum AppUpdateResult { unavailable, upToDate, optional, mandatory }

/// Actualización OTA aislada de las cartillas y la base de muestras.
class AppUpdateService {
  AppUpdateService({Dio? dio}) : _dio = dio ?? Dio();

  static const manifestUrl =
      'https://raw.githubusercontent.com/PORTALDONLUIS/app-agricola-releases/main/version.json';

  final Dio _dio;
  AppUpdateInfo? info;
  File? _downloadedApk;

  Future<AppUpdateResult> check() async {
    try {
      final response = await _dio.get<String>(
        manifestUrl,
        options: Options(
          headers: const {'Cache-Control': 'no-cache'},
          responseType: ResponseType.plain,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      if (response.statusCode != 200 || response.data == null) {
        return AppUpdateResult.unavailable;
      }
      final remote = AppUpdateInfo.fromJson(
        jsonDecode(response.data!) as Map<String, dynamic>,
      );
      if (remote.downloadUrl.trim().isEmpty || remote.buildNumber <= 0) {
        return AppUpdateResult.unavailable;
      }

      final current =
          int.tryParse((await PackageInfo.fromPlatform()).buildNumber) ?? 0;
      info = remote;
      if (current < remote.minimumBuild ||
          (remote.isMandatory && remote.buildNumber > current)) {
        return AppUpdateResult.mandatory;
      }
      return remote.buildNumber > current
          ? AppUpdateResult.optional
          : AppUpdateResult.upToDate;
    } catch (_) {
      return AppUpdateResult.unavailable;
    }
  }

  Future<void> download({
    required void Function(double progress) onProgress,
  }) async {
    final update = info;
    if (update == null) {
      throw StateError('No hay una actualización disponible.');
    }

    final directory =
        await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/donluis_forms_update.apk');
    if (await file.exists()) await file.delete();
    await _dio.download(
      update.downloadUrl,
      file.path,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );
    if (update.sha256.isNotEmpty) {
      final actualHash = sha256.convert(await file.readAsBytes()).toString();
      if (actualHash.toLowerCase() != update.sha256.toLowerCase()) {
        await file.delete();
        throw StateError('La verificación de seguridad del APK falló.');
      }
    }
    _downloadedApk = file;
  }

  Future<bool> install() async {
    final file = _downloadedApk;
    if (file == null || !await file.exists()) return false;
    return (await OpenFilex.open(file.path)).type == ResultType.done;
  }
}
