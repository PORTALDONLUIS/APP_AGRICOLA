import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../master/presentation/master_providers.dart';
import '../templates/presentation/templates_page.dart';
import '../../app/providers.dart';

class SplashSyncPage extends ConsumerStatefulWidget {
  const SplashSyncPage({super.key});

  @override
  ConsumerState<SplashSyncPage> createState() => _SplashSyncPageState();
}

class _SplashSyncPageState extends ConsumerState<SplashSyncPage> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(masterSyncControllerProvider);

    // ✅ disparar 1 sola vez
    if (!_started) {
      _started = true;
      debugPrint('🟦 SplashSyncPage ENTER');
      Future.microtask(() async {
        debugPrint('🟦 SplashSyncPage START SYNC');
        await ref.read(masterSyncControllerProvider.notifier).runInitialSyncIfNeeded();

        // Sincronizar también las plantillas asignadas del usuario actual
        final userId = ref.read(currentUserIdProvider);
        await ref.read(templatesNotifierProvider.notifier).sync(userId);

        debugPrint('🟦 SplashSyncPage END SYNC');
      });
    }

    // ✅ cuando termina, pasamos a Templates sin Navigator (flujo estable)
    if (!st.loading && st.done) {
      return const TemplatesPage();
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(st.loading ? 'Sincronizando campañas, lotes y plantillas...' : 'Entrando...'),
              if (st.error != null) ...[
                const SizedBox(height: 10),
                Text(
                  'No se pudo sincronizar. Se usará data local.\n${st.error}',
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
