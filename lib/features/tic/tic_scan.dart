import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Un código llena la búsqueda; nunca abre enlaces ni confirma movimientos.
String ticScanText(String raw) => raw
    .replaceAll(RegExp(r'[\x00-\x1f]'), ' ')
    .trim()
    .substring(
      0,
      raw.replaceAll(RegExp(r'[\x00-\x1f]'), ' ').trim().length.clamp(0, 150),
    );
Future<String?> scanTicCode(BuildContext context) => Navigator.push<String>(
  context,
  MaterialPageRoute(builder: (_) => const TicScanPage()),
);

class TicScanPage extends StatefulWidget {
  const TicScanPage({super.key});
  @override
  State<TicScanPage> createState() => _TicScanPageState();
}

class _TicScanPageState extends State<TicScanPage> {
  bool returned = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      title: const Text('Leer QR o código de barras'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    body: Column(
      children: [
        Expanded(
          child: MobileScanner(
            // Sin controller externo: el plugin administra pausa, reanudación y cierre.
            tapToFocus: true,
            onDetect: (capture) {
              if (returned) return;
              for (final code in capture.barcodes) {
                final text = ticScanText(code.rawValue ?? '');
                if (text.isNotEmpty) {
                  returned = true;
                  Navigator.pop(context, text);
                  break;
                }
              }
            },
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.no_photography_outlined,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No se pudo abrir la cámara. Revisa el permiso de cámara; puedes continuar escribiendo el código.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Volver a búsqueda',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Apunta la cámara trasera al código. La lectura solo completa la búsqueda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}
