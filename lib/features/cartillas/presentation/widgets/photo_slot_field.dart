import 'dart:io';

import 'package:flutter/material.dart';

class PhotoSlotField extends StatelessWidget {
  final int slot;
  final String? localPath;
  final VoidCallback onCapture;
  final VoidCallback onRemove;
  final bool readOnly;

  const PhotoSlotField({
    super.key,
    required this.slot,
    required this.localPath,
    required this.onCapture,
    required this.onRemove,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = (localPath != null && localPath!.isNotEmpty && File(localPath!).existsSync());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Foto_$slot', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),

            if (hasPhoto) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(localPath!),
                  // Misma ruta al "Reemplazar" => sin key nueva, Image.file reutiliza la imagen en caché.
                  key: ValueKey<String>(_fileVersionKey(localPath!)),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: readOnly ? null : onCapture,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Reemplazar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: readOnly ? null : onRemove,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Quitar'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: readOnly ? null : onCapture,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tomar foto'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Incluye mtime para que al sobrescribir el mismo path el preview se reconstruya.
String _fileVersionKey(String path) {
  try {
    final f = File(path);
    if (!f.existsSync()) return path;
    return '$path|${f.lastModifiedSync().millisecondsSinceEpoch}';
  } catch (_) {
    return path;
  }
}
