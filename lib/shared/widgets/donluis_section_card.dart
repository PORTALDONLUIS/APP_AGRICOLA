import 'package:flutter/material.dart';
import '../../app/theme/donluis_theme.dart';

/// Card para secciones (ej. "DATOS GENERALES", "PAUTA") con encabezado, icono opcional y contenido expandible.
class DonLuisSectionCard extends StatefulWidget {
  const DonLuisSectionCard({
    super.key,
    required this.title,
    this.icon,
    required this.child,
    this.initiallyExpanded = true,
  });

  final String title;
  final IconData? icon;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<DonLuisSectionCard> createState() => _DonLuisSectionCardState();
}

class _DonLuisSectionCardState extends State<DonLuisSectionCard>
    with AutomaticKeepAliveClientMixin {
  late bool _expanded;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 22,
                        color: DonLuisColors.primary,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DonLuisColors.primary.withOpacity(0.95),
                        ) ?? const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D21),
                        ),
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: DonLuisColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}
