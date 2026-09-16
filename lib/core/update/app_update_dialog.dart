import 'package:flutter/material.dart';

import 'app_update_service.dart';

class AppUpdateDialog extends StatefulWidget {
  const AppUpdateDialog({
    super.key,
    required this.service,
    required this.mandatory,
  });

  final AppUpdateService service;
  final bool mandatory;

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  double? _progress;
  String? _error;
  bool _readyToInstall = false;

  @override
  Widget build(BuildContext context) {
    final update = widget.service.info!;
    return PopScope(
      canPop: !widget.mandatory && _progress == null,
      child: AlertDialog(
        icon: const Icon(Icons.system_update_alt_rounded, size: 42),
        title: Text(
          widget.mandatory ? 'Actualización requerida' : 'Nueva actualización',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versión ${update.latestVersion}'
              '${update.fileSizeBytes > 0 ? ' • ${update.sizeLabel}' : ''}',
            ),
            if (update.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(update.releaseNotes),
            ],
            if (_progress != null) ...[
              const SizedBox(height: 18),
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 6),
              Text('Descargando ${(_progress! * 100).toStringAsFixed(0)}%'),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
        actions: [
          if (!widget.mandatory && _progress == null && !_readyToInstall)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Más tarde'),
            ),
          FilledButton.icon(
            onPressed: _progress != null
                ? null
                : _readyToInstall
                ? _install
                : _download,
            icon: Icon(
              _readyToInstall ? Icons.install_mobile : Icons.download_rounded,
            ),
            label: Text(_readyToInstall ? 'Instalar' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _download() async {
    setState(() {
      _progress = 0;
      _error = null;
    });
    try {
      await widget.service.download(
        onProgress: (value) {
          if (mounted) setState(() => _progress = value);
        },
      );
      if (mounted) {
        setState(() {
          _progress = null;
          _readyToInstall = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _progress = null;
          _error = 'No se pudo descargar la actualización. Intenta nuevamente.';
        });
      }
    }
  }

  Future<void> _install() async {
    final opened = await widget.service.install();
    if (!opened && mounted) {
      setState(() => _error = 'No se pudo abrir el instalador de Android.');
    }
  }
}
