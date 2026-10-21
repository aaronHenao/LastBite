import 'package:flutter/material.dart';

import 'package:lastbite/core/responsive/responsive_container.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/core/widgets/boton_volver.dart';
import 'package:lastbite/l10n/app_localizations.dart';
import 'package:lastbite/l10n/traducciones.dart';

/// Tema de la ayuda. Cada pantalla abre la ayuda en el suyo.
enum SeccionAyuda { despensa, agregar, recetas, alertas, compartir, cuenta }

typedef _Pregunta = ({String pregunta, String respuesta});

/// Ayuda y preguntas frecuentes.
///
/// La evaluacion heuristica dejo "Ayuda y documentacion" en 27/100: no habia
/// opcion de ayuda, ni preguntas frecuentes, ni nada orientado a resolver un
/// problema. Y en la prueba con expresiones faciales el usuario nuevo mostro
/// tristeza desde los primeros segundos: la app no se explicaba sola.
///
/// Se abre desde el boton "?" de cada pantalla con la seccion de esa pantalla
/// ya desplegada, para que la respuesta quede a un toque.
class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key, this.seccion});

  /// Seccion que se muestra desplegada al abrir.
  final SeccionAyuda? seccion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final paleta = context.paleta;
    final t = context.t;

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
              Text(t.ayudaTitulo, style: textTheme.displaySmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                t.ayudaDescripcion,
                style: textTheme.bodyMedium?.copyWith(color: paleta.apagado),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(t.ayudaPrimerosPasos, style: AppTextStyles.rotulo(context)),
              const SizedBox(height: AppSpacing.md),
              for (final (indice, paso) in [
                t.ayudaPaso1,
                t.ayudaPaso2,
                t.ayudaPaso3,
              ].indexed)
                _Paso(numero: indice + 1, texto: paso),
              const SizedBox(height: AppSpacing.xl),
              Text(t.ayudaPreguntas, style: AppTextStyles.rotulo(context)),
              const SizedBox(height: AppSpacing.md),
              for (final s in SeccionAyuda.values)
                _Seccion(
                  titulo: _titulo(t, s),
                  preguntas: _preguntas(t, s),
                  abierta: s == seccion,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _titulo(L10n t, SeccionAyuda seccion) => switch (seccion) {
  SeccionAyuda.despensa => t.ayudaSeccionDespensa,
  SeccionAyuda.agregar => t.ayudaSeccionAgregar,
  SeccionAyuda.recetas => t.ayudaSeccionRecetas,
  SeccionAyuda.alertas => t.ayudaSeccionAlertas,
  SeccionAyuda.compartir => t.ayudaSeccionCompartir,
  SeccionAyuda.cuenta => t.ayudaSeccionCuenta,
};

List<_Pregunta> _preguntas(L10n t, SeccionAyuda seccion) => switch (seccion) {
  SeccionAyuda.despensa => [
    (pregunta: t.ayudaDespensaP1, respuesta: t.ayudaDespensaR1),
    (pregunta: t.ayudaDespensaP2, respuesta: t.ayudaDespensaR2),
    (pregunta: t.ayudaDespensaP3, respuesta: t.ayudaDespensaR3),
  ],
  SeccionAyuda.agregar => [
    (pregunta: t.ayudaAgregarP1, respuesta: t.ayudaAgregarR1),
    (pregunta: t.ayudaAgregarP2, respuesta: t.ayudaAgregarR2),
  ],
  SeccionAyuda.recetas => [
    (pregunta: t.ayudaRecetasP1, respuesta: t.ayudaRecetasR1),
    (pregunta: t.ayudaRecetasP2, respuesta: t.ayudaRecetasR2),
    (pregunta: t.ayudaRecetasP3, respuesta: t.ayudaRecetasR3),
    (pregunta: t.ayudaRecetasP4, respuesta: t.ayudaRecetasR4),
  ],
  SeccionAyuda.alertas => [
    (pregunta: t.ayudaAlertasP1, respuesta: t.ayudaAlertasR1),
    (pregunta: t.ayudaAlertasP2, respuesta: t.ayudaAlertasR2),
  ],
  SeccionAyuda.compartir => [
    (pregunta: t.ayudaCompartirP1, respuesta: t.ayudaCompartirR1),
    (pregunta: t.ayudaCompartirP2, respuesta: t.ayudaCompartirR2),
  ],
  SeccionAyuda.cuenta => [
    (pregunta: t.ayudaCuentaP1, respuesta: t.ayudaCuentaR1),
    (pregunta: t.ayudaCuentaP2, respuesta: t.ayudaCuentaR2),
  ],
};

class _Paso extends StatelessWidget {
  const _Paso({required this.numero, required this.texto});

  final int numero;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: paleta.marcaSuave,
            child: Text(
              '$numero',
              style: textTheme.labelLarge?.copyWith(color: paleta.marca),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(texto, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.titulo,
    required this.preguntas,
    required this.abierta,
  });

  final String titulo;
  final List<_Pregunta> preguntas;
  final bool abierta;

  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: paleta.superficie,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: abierta
                ? paleta.marca.withValues(alpha: 0.5)
                : paleta.contorno,
          ),
        ),
        // Material transparente: sin el, la tinta del ExpansionTile queda
        // debajo del fondo decorado.
        child: Material(
          type: MaterialType.transparency,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: abierta,
              title: Text(titulo, style: textTheme.titleMedium),
              childrenPadding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final p in preguntas) ...[
                  Text(
                    p.pregunta,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    p.respuesta,
                    style: textTheme.bodyMedium?.copyWith(
                      color: paleta.apagado,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
