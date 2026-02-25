import 'package:flutter/material.dart';
import '../../app/theme/donluis_theme.dart';

/// Estado vacío reutilizable (ej. sin registros, sin plantillas).
class DonLuisEmptyState extends StatelessWidget {
  const DonLuisEmptyState({
    super.key,
    required this.message,
    this.submessage,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final String? submessage;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DonLuisColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: DonLuisColors.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: DonLuisColors.primary.withOpacity(0.9),
              ) ?? const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D21),
              ),
            ),
            if (submessage != null && submessage!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                submessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DonLuisColors.primary.withOpacity(0.6),
                ) ?? const TextStyle(fontSize: 14, color: Color(0xFF5C6268)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
