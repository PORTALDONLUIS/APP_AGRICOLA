import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'app/app.dart';
import 'core/log/file_logger.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await FileLogger.init();

      FlutterError.onError = (FlutterErrorDetails details) {
        FileLogger.logError(
          details.exceptionAsString(),
          details.exception,
          details.stack,
        );
        FlutterError.presentError(details);
      };

      runApp(const ProviderScope(child: DonLuisApp()));
    },
    (error, stackTrace) {
      FileLogger.logError('Async error', error, stackTrace);
    },
  );
}

/*
import 'package:flutter/material.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/splash_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() {
  runApp(const ProviderScope(child: DonLuisApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(next: const LoginPage()),
    );
  }
}*/

