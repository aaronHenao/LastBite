import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/responsive/responsive_container.dart';
import '../../../core/theme/app_theme.dart';
import 'package:lastbite/l10n/traducciones.dart';
import 'auth_provider.dart';
import 'mensaje_error_auth.dart';
import 'register_screen.dart';
import 'widgets/auth_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _cargando = false;
  bool _cargandoGoogle = false;
  String? _error;
  bool _verPassword = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// True mientras corre cualquiera de las dos vias: sin esto se podian
  /// disparar dos autenticaciones simultaneas, porque cada boton miraba solo
  /// su propia bandera.
  bool get _autenticando => _cargando || _cargandoGoogle;

  Future<void> _login() async {
    if (_autenticando) return;
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = context.t.authCompletaCampos);
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await ref
          .read(authServiceProvider)
          .login(email: _emailCtrl.text, password: _passwordCtrl.text);
    } catch (e) {
      if (mounted) setState(() => _error = _mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _loginGoogle() async {
    if (_autenticando) return;
    setState(() {
      _cargandoGoogle = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).loginConGoogle();
    } catch (e) {
      if (mounted) setState(() => _error = _mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _cargandoGoogle = false);
    }
  }

  /// Cerrar la hoja de Google no es un error: [mensajeErrorAuth] devuelve
  /// null y no se muestra nada.
  String? _mensajeDeError(Object error) => mensajeErrorAuth(context.t, error);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ResponsiveContainer(
            maxWidth: 500,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //header
                    Text(
                      context.t.authBienvenido,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color: context.paleta.apagado,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Image.asset(
                      'lib/assets/images/letra3.PNG',
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),

                    //email
                    AuthField(
                      label: context.t.authCorreo,
                      hint: context.t.authCorreoEjemplo,
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    //password
                    AuthField(
                      label: context.t.authContrasena,
                      hint: '••••••••',
                      controller: _passwordCtrl,
                      obscureText: !_verPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: context.paleta.apagado,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _verPassword = !_verPassword),
                      ),
                    ),
                    const SizedBox(height: 20),

                    //error
                    if (_error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.paleta.vencido.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.paleta.vencido.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: context.paleta.vencido,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    //botón login
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _cargando ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: context.paleta.marca,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _cargando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                context.t.authIniciarSesion,
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    //divisor
                    Row(
                      children: [
                        Expanded(child: Divider(color: context.paleta.contorno)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            context.t.authOContinua,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.paleta.apagado,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: context.paleta.contorno)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    //botón Google
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _cargandoGoogle ? null : _loginGoogle,
                        icon: _cargandoGoogle
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.paleta.apagado,
                                ),
                              )
                            : Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: context.paleta.tinta,
                                ),
                              ),
                        label: Text(
                          context.t.authContinuarGoogle,
                          style: textTheme.titleMedium?.copyWith(
                            color: context.paleta.tinta,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: context.paleta.contorno),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    //ir a registro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.t.authSinCuentaPregunta,
                          style: TextStyle(
                            color: context.paleta.apagado,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                          child: Text(
                            context.t.authRegistrate,
                            style: TextStyle(
                              color: context.paleta.marca,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
