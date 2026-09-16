import 'package:donluis_forms/app/router/app_router.dart';
import 'package:donluis_forms/app/theme/donluis_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/splash/splash_sync_page.dart';
import 'providers.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/splash/splash_page.dart';
import '../core/update/app_update_dialog.dart';
import '../core/update/app_update_service.dart';

class DonLuisApp extends ConsumerStatefulWidget {
  const DonLuisApp({super.key});

  @override
  ConsumerState<DonLuisApp> createState() => _DonLuisAppState();
}

class _DonLuisAppState extends ConsumerState<DonLuisApp> {
  bool _showSplash = true;
  final _updateService = AppUpdateService();
  bool _checkingUpdate = false;

  Future<void> _finishSplash() async {
    if (_checkingUpdate) return;
    _checkingUpdate = true;
    final result = await _updateService.check();
    if (!mounted) return;

    if (result == AppUpdateResult.optional ||
        result == AppUpdateResult.mandatory) {
      await showDialog<void>(
        context: context,
        barrierDismissible: result != AppUpdateResult.mandatory,
        builder: (_) => AppUpdateDialog(
          service: _updateService,
          mandatory: result == AppUpdateResult.mandatory,
        ),
      );
    }
    if (mounted) setState(() => _showSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    Widget screen;
    if (_showSplash) {
      screen = SplashPage(onFinish: _finishSplash);
    } else {
      screen = auth.loggedIn ? const SplashSyncPage() : const LoginPage();

      // screen = auth.loggedIn ? const TemplatesPage() : const LoginPage();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: donluisTheme,
      home: screen,
      onGenerateRoute: onGenerateAppRoute,
    );
  }
}
