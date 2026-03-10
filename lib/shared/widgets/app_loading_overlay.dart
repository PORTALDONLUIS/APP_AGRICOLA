import 'package:flutter/material.dart';

import '../../app/theme/donluis_theme.dart';

/// Overlay reutilizable para mostrar un loading de pantalla completa
/// bloqueando la interacción del usuario.
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.loading,
    required this.child,
    this.message,
  });

  /// Cuando es true, muestra el overlay encima del [child].
  final bool loading;

  /// Contenido principal de la pantalla.
  final Widget child;

  /// Mensaje opcional bajo el spinner.
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (!loading) return child;

    final textTheme = Theme.of(context).textTheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        // Bloquea la interacción y oscurece suavemente el fondo.
        const ModalBarrier(
          dismissible: false,
          color: Colors.black38,
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.80),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      DonLuisColors.accent,
                    ),
                    backgroundColor: Colors.white.withOpacity(0.20),
                  ),
                ),
                if ((message ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

