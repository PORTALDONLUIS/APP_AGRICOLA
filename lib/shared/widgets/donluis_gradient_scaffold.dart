import 'package:flutter/material.dart';
import '../../app/theme/donluis_theme.dart';

/// Scaffold con fondo degradado suave (identidad Don Luis) y body en superficie tipo card.
class DonLuisGradientScaffold extends StatelessWidget {
  const DonLuisGradientScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;

  static const BoxDecoration _gradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: DonLuisColors.gradientBackgroundColors,
      stops: DonLuisColors.gradientBackgroundStops,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: DonLuisColors.primary.withOpacity(0.12),
      // El AppBar se pinta sólido (por ejemplo, DonLuisAppBar).
      // El degradado queda solo en el body.
      appBar: appBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _gradientDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: DonLuisColors.surface.withOpacity(0.98),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: body ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
