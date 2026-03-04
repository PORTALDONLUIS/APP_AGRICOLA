import 'package:flutter/material.dart';

import '../../app/theme/donluis_theme.dart';

/// AppBar corporativo Don Luis:
/// - Fondo azul sólido (primary)
/// - Íconos blancos
/// - Título con mayor jerarquía
/// - Sombra suave y separación visual con el contenido.
class DonLuisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DonLuisAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: DonLuisColors.primary,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.18),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      titleTextStyle: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ) ??
          const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
      title: DefaultTextStyle.merge(
        style: const TextStyle(
          color: Colors.white,
        ),
        child: title ?? const SizedBox.shrink(),
      ),
      toolbarHeight: 64,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withOpacity(0.18),
        ),
      ),
    );
  }
}

