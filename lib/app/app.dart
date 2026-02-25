import 'package:donluis_forms/app/router/app_router.dart';
import 'package:donluis_forms/app/theme/donluis_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/splash/splash_sync_page.dart';
import 'providers.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/splash/splash_page.dart';

class DonLuisApp extends ConsumerStatefulWidget {
  const DonLuisApp({super.key});

  @override
  ConsumerState<DonLuisApp> createState() => _DonLuisAppState();
}

class _DonLuisAppState extends ConsumerState<DonLuisApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    Widget screen;
    if (_showSplash) {
      screen = SplashPage(
        onFinish: () => setState(() => _showSplash = false),
      );
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

