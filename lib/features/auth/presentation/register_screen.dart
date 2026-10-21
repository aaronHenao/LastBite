import 'package:flutter/material.dart';
import 'package:lastbite/core/widgets/boton_volver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/responsive/responsive_container.dart';
import '../../../core/theme/app_theme.dart';
import 'package:lastbite/l10n/traducciones.dart';
import 'auth_provider.dart';
import 'mensaje_error_auth.dart';
import 'widgets/auth_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _cargando = false;
  String? _error;
  bool _verPassword = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (_nombreCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty) {
      setState(() => _error = context.t.authCompletaCampos);
      return;
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = context.t.authContrasenasNoCoinciden);
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      setState(() => _error = context.t.authContrasenaCorta);
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await ref
          .read(authServiceProvider)
          .registrar(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            nombre: _nombreCtrl.text,
          );
      //Limpia el stack completo para que _AuthGate tome control
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) setState(() => _error = mensajeErrorAuth(context.t, e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
          child: ResponsiveContainer(
            maxWidth: 500,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BotonVolver(),
                  const SizedBox(height: 24),

                  //header
                  Text(
                    context.t.authCreaCuenta,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: context.paleta.tinta,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.t.authCreaCuentaAyuda,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      color: context.paleta.apagado,
                    ),
                  ),
                  const SizedBox(height: 36),

                  //nombre
                  AuthField(
                    label: context.t.authNombre,
                    hint: context.t.authNombreEjemplo,
                    controller: _nombreCtrl,
                  ),
                  const SizedBox(height: 14),

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
                  const SizedBox(height: 14),

                  //confirmar password
                  AuthField(
                    label: context.t.authConfirmarContrasena,
                    hint: '••••••••',
                    controller: _confirmCtrl,
                    obscureText: !_verPassword,
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

                  //botón registro
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _cargando ? null : _registrar,
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
                              context.t.authCrearCuenta,
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
