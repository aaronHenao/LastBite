import 'package:flutter/material.dart';
import 'package:lastbite/l10n/traducciones.dart';

/// Confirma una accion sobre los datos y ofrece revertirla.
///
/// La evaluacion heuristica marco que no habia forma de deshacer: un toque
/// equivocado en "Eliminar" o "Marcar como consumido" no tenia vuelta. Cada
/// accion que cambia la despensa termina en este aviso, que dice que paso y
/// deja deshacerlo durante unos segundos.
///
/// Usa los colores del tema del SnackBar: estan medidos para contraste en
/// claro y oscuro, cosa que un fondo de marca con texto blanco no cumple.
void mostrarAvisoDeshacer(
  BuildContext context, {
  required String mensaje,
  required VoidCallback onDeshacer,
}) {
  ScaffoldMessenger.of(context)
    // Reemplaza el aviso anterior: en cola, el "Deshacer" llegaria tarde.
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(mensaje),
        // Con accion, el SnackBar se queda hasta que lo cierren a mano. Este
        // tiene que irse solo: deshacer es una opcion, no una pregunta.
        persist: false,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: context.t.accionDeshacer,
          onPressed: onDeshacer,
        ),
      ),
    );
}
