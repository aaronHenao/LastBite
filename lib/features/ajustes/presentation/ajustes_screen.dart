import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lastbite/core/preferencias/preferencias.dart';
import 'package:lastbite/core/preferencias/preferencias_provider.dart';
import 'package:lastbite/core/responsive/responsive_container.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/core/widgets/boton_volver.dart';
import 'package:lastbite/l10n/app_localizations.dart';
import 'package:lastbite/l10n/traducciones.dart';

/// Ajustes de accesibilidad y apariencia.
///
/// Todo lo de aca existe tambien en el sistema operativo, pero no todo el
/// mundo sabe donde esta ni puede cambiarlo. Cada cambio se aplica al
/// instante y sobre esta misma pantalla, asi se ve el efecto antes de salir.
class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final paleta = context.paleta;
    final t = context.t;
    final prefs =
        ref.watch(preferenciasProvider).valueOrNull ?? const Preferencias();
    final notifier = ref.read(preferenciasProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 700,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              const BotonVolver(),
              const SizedBox(height: AppSpacing.md),
              Text(t.ajustesTitulo, style: textTheme.displaySmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                t.ajustesDescripcion,
                style: textTheme.bodyMedium?.copyWith(color: paleta.apagado),
              ),
              const SizedBox(height: AppSpacing.xl),

              _Seccion(
                titulo: t.ajustesTamanoTexto,
                descripcion: t.ajustesTamanoTextoAyuda,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final escala in Preferencias.escalasDisponibles)
                      RadioListTile<double>(
                        value: escala,
                        contentPadding: EdgeInsets.zero,
                        activeColor: paleta.marca,
                        title: Text(
                          _etiquetaEscala(t, escala),
                          // Cada opcion se muestra a su propio tamaño: se
                          // elige viendo, no imaginando.
                          style: textTheme.bodyLarge?.copyWith(
                            fontSize: 16 * escala,
                          ),
                        ),
                      ),
                  ],
                ),
                envolver: (hijos) => RadioGroup<double>(
                  groupValue: prefs.escalaTexto,
                  onChanged: (valor) =>
                      notifier.cambiarEscalaTexto(valor ?? 1.0),
                  child: hijos,
                ),
              ),

              _Seccion(
                titulo: t.ajustesContraste,
                descripcion: t.ajustesContrasteAyuda,
                child: SwitchListTile(
                  value: prefs.altoContraste,
                  onChanged: notifier.cambiarAltoContraste,
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: paleta.marca,
                  title: Text(t.ajustesAltoContraste, style: textTheme.titleMedium),
                ),
              ),

              _Seccion(
                titulo: t.ajustesMovimiento,
                descripcion: t.ajustesMovimientoAyuda,
                child: SwitchListTile(
                  value: prefs.reducirMovimiento,
                  onChanged: notifier.cambiarReducirMovimiento,
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: paleta.marca,
                  title: Text(
                    t.ajustesReducirMovimiento,
                    style: textTheme.titleMedium,
                  ),
                ),
              ),

              _Seccion(
                titulo: t.ajustesApariencia,
                descripcion: t.ajustesAparienciaAyuda,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final opcion in [
                      (
                        ThemeMode.system,
                        t.ajustesTemaAutomatico,
                        Icons.brightness_auto_rounded,
                      ),
                      (ThemeMode.light, t.ajustesTemaClaro, Icons.light_mode_rounded),
                      (ThemeMode.dark, t.ajustesTemaOscuro, Icons.dark_mode_rounded),
                    ])
                      RadioListTile<ThemeMode>(
                        value: opcion.$1,
                        contentPadding: EdgeInsets.zero,
                        activeColor: paleta.marca,
                        secondary: Icon(opcion.$3, color: paleta.apagado),
                        title: Text(opcion.$2, style: textTheme.titleMedium),
                      ),
                  ],
                ),
                envolver: (hijos) => RadioGroup<ThemeMode>(
                  groupValue: prefs.tema,
                  onChanged: (valor) =>
                      notifier.cambiarTema(valor ?? ThemeMode.system),
                  child: hijos,
                ),
              ),

              _Seccion(
                titulo: t.ajustesIdioma,
                descripcion: t.ajustesIdiomaAyuda,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile<String?>(
                      value: null,
                      contentPadding: EdgeInsets.zero,
                      activeColor: paleta.marca,
                      title: Text(
                        t.ajustesIdiomaAutomatico,
                        style: textTheme.titleMedium,
                      ),
                    ),
                    for (final idioma in Preferencias.idiomasDisponibles)
                      RadioListTile<String?>(
                        value: idioma.codigo,
                        contentPadding: EdgeInsets.zero,
                        activeColor: paleta.marca,
                        // Cada idioma se nombra en si mismo: quien busca
                        // "Português" no deberia tener que reconocerlo escrito
                        // en un idioma que no entiende.
                        title: Text(
                          idioma.nombre,
                          style: textTheme.titleMedium,
                        ),
                      ),
                  ],
                ),
                envolver: (hijos) => RadioGroup<String?>(
                  groupValue: prefs.idioma,
                  onChanged: notifier.cambiarIdioma,
                  child: hijos,
                ),
              ),

              const _NotaLector(),
              const SizedBox(height: AppSpacing.xl),
              _Restablecer(
                activo: !mapEquals(prefs.toMap(), const Preferencias().toMap()),
                onRestablecer: notifier.restablecer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _etiquetaEscala(L10n t, double valor) => switch (valor) {
  1.3 => t.ajustesEscalaGrande,
  1.6 => t.ajustesEscalaMasGrande,
  2.0 => t.ajustesEscalaMaxima,
  _ => t.ajustesEscalaNormal,
};

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.titulo,
    required this.descripcion,
    required this.child,
    this.envolver,
  });

  final String titulo;
  final String descripcion;
  final Widget child;
  final Widget Function(Widget)? envolver;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final paleta = context.paleta;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: paleta.superficie,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: paleta.contorno),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: AppTextStyles.rotulo(context)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              descripcion,
              style: textTheme.bodySmall?.copyWith(color: paleta.apagado),
            ),
            const SizedBox(height: AppSpacing.md),
            // Material transparente: sin el, los ListTile dentro de un
            // contenedor decorado pintan su tinta debajo del fondo y Flutter
            // avisa que la pulsacion queda invisible.
            Material(
              type: MaterialType.transparency,
              child: envolver?.call(child) ?? child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Vuelve a los valores de fabrica. La evaluacion marco que no habia forma de
/// hacerlo ni se decia que se pierde: la confirmacion lo explica antes, y
/// aclara que los datos no se tocan.
class _Restablecer extends StatelessWidget {
  const _Restablecer({required this.activo, required this.onRestablecer});

  /// Solo si algo difiere de fabrica: si no, el boton no haria nada.
  final bool activo;
  final Future<void> Function() onRestablecer;

  Future<void> _confirmar(BuildContext context) async {
    final t = context.t;
    final messenger = ScaffoldMessenger.of(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.ajustesRestablecerPregunta),
        content: Text(t.ajustesRestablecerAyuda),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.accionCancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.ajustesRestablecerAccion),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    await onRestablecer();
    messenger.showSnackBar(SnackBar(content: Text(t.ajustesRestablecidos)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final paleta = context.paleta;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t.ajustesRestablecerAyuda,
          style: textTheme.bodySmall?.copyWith(color: paleta.apagado),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: activo ? () => _confirmar(context) : null,
          icon: const Icon(Icons.restart_alt_rounded, size: 18),
          label: Text(context.t.ajustesRestablecer),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
          ),
        ),
      ],
    );
  }
}

class _NotaLector extends StatelessWidget {
  const _NotaLector();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final paleta = context.paleta;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: paleta.marcaSuave,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.record_voice_over_rounded, color: paleta.marca),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.t.ajustesLectorTitulo,
                  style: textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.t.ajustesLectorAyuda,
            style: textTheme.bodySmall?.copyWith(color: paleta.apagado),
          ),
        ],
      ),
    );
  }
}
