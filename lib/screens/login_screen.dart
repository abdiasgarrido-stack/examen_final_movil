import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool showPass = false;
  String? error;

  //LOGIN
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      // Refresca datos del usuario
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tu correo no está verificado. Revisa tu bandeja.'),
          ),
        );
      }

      if (!mounted) return;
      context.go('/home');
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'Error de autenticación');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  //REGISTRO + EMAIL VERIFICACIÓN
  Future<void> _openRegisterSheet() async {
    final nameCtrl = TextEditingController();
    final mailCtrl = TextEditingController();
    final p1Ctrl = TextEditingController();
    final p2Ctrl = TextEditingController();
    final regKey = GlobalKey<FormState>();
    bool registering = false;
    String? regError;
    bool showP1 = false, showP2 = false;

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Form(
            key: regKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Crear cuenta', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 12),

                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa tu nombre'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: mailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Correo inválido'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: p1Ctrl,
                  obscureText: !showP1,
                  decoration: InputDecoration(
                    labelText: 'Contraseña (mín. 6)',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () => setS(() => showP1 = !showP1),
                      icon: Icon(
                        showP1 ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mínimo 6 caracteres'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: p2Ctrl,
                  obscureText: !showP2,
                  decoration: InputDecoration(
                    labelText: 'Repetir contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setS(() => showP2 = !showP2),
                      icon: Icon(
                        showP2 ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  validator: (v) => (v != p1Ctrl.text)
                      ? 'Las contraseñas no coinciden'
                      : null,
                ),
                if (regError != null) ...[
                  const SizedBox(height: 10),
                  Text(regError!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: registering
                      ? null
                      : () async {
                          if (!regKey.currentState!.validate()) return;
                          setS(() {
                            registering = true;
                            regError = null;
                          });
                          try {
                            final cred = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                  email: mailCtrl.text.trim(),
                                  password: p1Ctrl.text.trim(),
                                );

                            await cred.user?.updateDisplayName(
                              nameCtrl.text.trim(),
                            );
                            await cred.user?.sendEmailVerification();

                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Cuenta creada. Enviamos correo de verificación.',
                                  ),
                                ),
                              );
                            }
                            await FirebaseAuth.instance.signOut();
                          } on FirebaseAuthException catch (e) {
                            setS(
                              () => regError =
                                  e.message ?? 'No se pudo crear la cuenta',
                            );
                          } finally {
                            setS(() => registering = false);
                          }
                        },
                  icon: registering
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add),
                  label: const Text('Crear'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reset() async {
    if (emailCtrl.text.trim().isEmpty) {
      setState(() => error = 'Ingresa tu correo para recuperar la contraseña');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo de recuperación enviado')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'No se pudo enviar el correo');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primaryContainer, cs.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Login',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Correo inválido'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: passCtrl,
                        obscureText: !showPass,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => showPass = !showPass),
                            icon: Icon(
                              showPass
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Ingresa tu contraseña'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      if (error != null)
                        Text(error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: loading ? null : _login,
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Ingresar'),
                        ),
                      ),
                      TextButton(
                        onPressed: loading ? null : _reset,
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                      const Divider(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: loading ? null : _openRegisterSheet,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Crear cuenta nueva'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
