import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool _hidePassword = true;

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    // Colores inspirados en el logo (azul/verde con acento amarillo).
    const cBlue = Color(0xFF1E5AA8);
    const cBlue2 = Color(0xFF2F8ED9);
    const cGreen2 = Color(0xFF0F8A55);
    const cAccent = Color(0xFFF5C400);

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cBlue, cBlue2, cGreen2],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Sutiles "burbujas" para dar profundidad sin ensuciar.
              Positioned(
                top: -120,
                right: -90,
                child: _SoftBlob(color: Colors.white12, size: 260),
              ),
              Positioned(
                bottom: -140,
                left: -110,
                child: _SoftBlob(color: cAccent, size: 300),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ✅ LOGO (mejor práctica: asset + tamaño contenido)
                        // Coloca tu logo en: assets/images/don_luis_logo.png
                        // y decláralo en pubspec.yaml (abajo te dejo el snippet).
                        Center(
                          child: Container(
                            height: 96,
                            width: 96,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: Colors.white.withOpacity(0.28), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.20),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.asset(
                                'assets/images/LOGO_DONTEC.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                const Icon(Icons.eco_rounded, size: 44, color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),
                        Text(
                          'Bienvenido',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Inicia sesión para continuar',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.88),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Card principal (glass)
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.22),
                                blurRadius: 26,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _LabeledField(
                                label: 'Usuario',
                                child: TextField(
                                  controller: userCtrl,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.text,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration(
                                    hint: 'Ingresa tu usuario',
                                    icon: Icons.person_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _LabeledField(
                                label: 'Contraseña',
                                child: TextField(
                                  controller: passCtrl,
                                  textInputAction: TextInputAction.done,
                                  obscureText: _hidePassword,
                                  onSubmitted: (_) {
                                    if (!auth.loading) {
                                      ref.read(authProvider.notifier).login(
                                        userCtrl.text,
                                        passCtrl.text,
                                      );
                                    }
                                  },
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration(
                                    hint: 'Ingresa tu contraseña',
                                    icon: Icons.lock_rounded,
                                    suffix: IconButton(
                                      onPressed: () => setState(() => _hidePassword = !_hidePassword),
                                      icon: Icon(
                                        _hidePassword
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                      tooltip: _hidePassword ? 'Mostrar' : 'Ocultar',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              if (auth.error != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.withOpacity(0.35)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded, color: Colors.white),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          auth.error!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              SizedBox(
                                height: 48,
                                child: FilledButton(
                                  onPressed: auth.loading
                                      ? null
                                      : () => ref.read(authProvider.notifier).login(
                                    userCtrl.text,
                                    passCtrl.text,
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: cAccent,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
                                  ),
                                  child: auth.loading
                                      ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                      : const Text('Ingresar'),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),
                        Text(
                          '© Don Luis',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.75)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.white.withOpacity(0.65)),
    prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.85)),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white.withOpacity(0.10),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.24)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFF5C400), width: 1.6),
    ),
  );
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.92),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _SoftBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _SoftBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.14),
      ),
    );
  }
}
