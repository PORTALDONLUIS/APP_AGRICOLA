import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import 'auth_notifier.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _hidePassword = true;
  bool _rememberCredentials = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final saved = await ref
        .read(loginCredentialsStoreProvider)
        .getSavedCredentials();
    if (!mounted || saved == null) return;
    setState(() {
      userCtrl.text = saved.username;
      passCtrl.text = saved.password;
      _rememberCredentials = true;
    });
  }

  void _submit(AuthState auth) {
    if (!auth.loading) {
      ref
          .read(authProvider.notifier)
          .login(
            userCtrl.text.trim(),
            passCtrl.text,
            rememberCredentials: _rememberCredentials,
          );
    }
  }

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final headerHeight = MediaQuery.sizeOf(context).height * .39;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      body: Stack(
        children: [
          SizedBox(
            height: headerHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/login_uvas.jpg', fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xCC1E5AA8), Color(0xE62F8ED9)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  const _LogoBadge(),
                  const SizedBox(height: 12),
                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ingresa para registrar tu trabajo de campo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .88),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .14),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: Color(0xFF1E4F91),
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Usa tus credenciales asignadas',
                          style: TextStyle(color: Color(0xFF6F8178)),
                        ),
                        const SizedBox(height: 24),
                        _LabeledField(
                          label: 'DNI o usuario',
                          child: TextField(
                            controller: userCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hint: 'Ingresa tu DNI',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _LabeledField(
                          label: 'Contraseña',
                          child: TextField(
                            controller: passCtrl,
                            textInputAction: TextInputAction.done,
                            obscureText: _hidePassword,
                            onSubmitted: (_) => _submit(auth),
                            decoration: _inputDecoration(
                              hint: 'Ingresa tu contraseña',
                              icon: Icons.lock_outline_rounded,
                              suffix: IconButton(
                                onPressed: () => setState(
                                  () => _hidePassword = !_hidePassword,
                                ),
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF5C7569),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberCredentials,
                              activeColor: const Color(0xFF1E5AA8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: auth.loading
                                  ? null
                                  : (value) => setState(
                                      () =>
                                          _rememberCredentials = value ?? false,
                                    ),
                            ),
                            GestureDetector(
                              onTap: auth.loading
                                  ? null
                                  : () => setState(
                                      () => _rememberCredentials =
                                          !_rememberCredentials,
                                    ),
                              child: const Text(
                                'Recordar credenciales',
                                style: TextStyle(
                                  color: Color(0xFF42698F),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (auth.error != null) ...[
                          const SizedBox(height: 8),
                          _LoginError(message: auth.error!),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: auth.loading
                                ? null
                                : () => _submit(auth),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1E5AA8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: .4,
                              ),
                            ),
                            child: auth.loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('INGRESAR'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '© Don Luis',
                    style: TextStyle(
                      color: Color(0xFF59718A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) => Container(
    height: 88,
    width: 88,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .22),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Image.asset('assets/images/LOGO_DONTEC.png', fit: BoxFit.contain),
  );
}

InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  const border = Color(0xFFD8E3DD);
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9AA9A2)),
    prefixIcon: Icon(icon, color: const Color(0xFF2F8ED9)),
    suffixIcon: suffix,
    filled: true,
    fillColor: const Color(0xFFF8FAF8),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: _fieldBorder(border),
    enabledBorder: _fieldBorder(border),
    focusedBorder: _fieldBorder(const Color(0xFF1E5AA8), width: 1.7),
  );
}

OutlineInputBorder _fieldBorder(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFF315B7A),
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      child,
    ],
  );
}

class _LoginError extends StatelessWidget {
  const _LoginError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9E7),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFC53126)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Color(0xFF9B281F),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
