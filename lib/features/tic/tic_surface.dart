import 'package:flutter/material.dart';

/// Colores explícitos solo para las cartillas TIC y sus diálogos.
class TicSurface extends StatelessWidget {
  const TicSurface({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const ink = Colors.black;
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(bodyColor: ink, displayColor: ink),
        listTileTheme: theme.listTileTheme.copyWith(
          textColor: ink,
          selectedColor: ink,
          iconColor: Colors.black87,
          titleTextStyle: const TextStyle(
            color: ink,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          subtitleTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        expansionTileTheme: theme.expansionTileTheme.copyWith(
          textColor: ink,
          collapsedTextColor: ink,
          iconColor: Colors.black87,
          collapsedIconColor: Colors.black87,
        ),
        popupMenuTheme: theme.popupMenuTheme.copyWith(
          color: Colors.white,
          textStyle: const TextStyle(color: ink, fontSize: 16),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: ink),
        child: child,
      ),
    );
  }
}

class TicScaffold extends StatelessWidget {
  const TicScaffold({super.key, this.appBar, this.body});
  final PreferredSizeWidget? appBar;
  final Widget? body;
  @override
  Widget build(BuildContext context) => TicSurface(
    child: Scaffold(appBar: appBar, body: body),
  );
}

class TicDialog extends StatelessWidget {
  const TicDialog({
    super.key,
    this.icon,
    this.title,
    this.content,
    this.actions,
  });
  final Widget? icon, title, content;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => TicSurface(
    child: AlertDialog(
      backgroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(color: Colors.black, fontSize: 16),
      icon: icon,
      title: title,
      content: content,
      actions: actions,
    ),
  );
}

class TicSafeArea extends StatelessWidget {
  const TicSafeArea({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      TicSurface(child: SafeArea(child: child));
}
