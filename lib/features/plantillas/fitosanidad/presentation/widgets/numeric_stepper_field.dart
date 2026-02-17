import 'package:flutter/material.dart';

class NumericStepperField extends StatelessWidget {
  final String label;
  final double value;
  final double step;
  final double min;
  final double? max;
  final String? suffix;
  final ValueChanged<double> onChanged;

  const NumericStepperField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 0.5,
    this.min = 0,
    this.max,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final canDec = value > min;
    final canInc = max == null ? true : value < max!;

    final text = value.toStringAsFixed(value % 1 == 0 ? 0 : 1);

    Widget circleButton({
      required IconData icon,
      required bool enabled,
      required VoidCallback onTap,
    }) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : 0.4,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled ? onTap : null,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surfaceVariant,
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(
              icon,
              size: 18,
              color: enabled ? cs.onSurfaceVariant : cs.outline,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        // Label izquierda
        Expanded(
          child: Text(
            '$label${suffix != null ? " ($suffix)" : ""}',
            style: theme.textTheme.bodyMedium,
          ),
        ),

        // Botón -
        circleButton(
          icon: Icons.remove,
          enabled: canDec,
          onTap: () {
            var next = value - step;
            if (next < min) next = min;
            onChanged(next);
          },
        ),

        const SizedBox(width: 8),

        // Valor
        SizedBox(
          width: 56,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Botón +
        circleButton(
          icon: Icons.add,
          enabled: canInc,
          onTap: () {
            var next = value + step;
            if (max != null && next > max!) next = max!;
            onChanged(next);
          },
        ),
      ],
    );
  }
}
