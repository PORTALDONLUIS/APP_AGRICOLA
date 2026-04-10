import 'package:flutter/material.dart';

/// Etiqueta compacta sobre el pin de registros en el mapa.
/// Una sola línea con elipsis; el círculo del pin va en coordenadas fijas en el [Stack]
/// del [Marker], así que al crecer el texto este badge debe colocarse con
/// `Positioned(bottom: …)` para que solo crezca hacia arriba.
class RegistroMapIdBadge extends StatelessWidget {
  const RegistroMapIdBadge({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 118),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
