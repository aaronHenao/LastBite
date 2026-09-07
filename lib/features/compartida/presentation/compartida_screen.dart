import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/responsive/responsive.dart';
import 'package:lastbite/core/responsive/responsive_container.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/core/widgets/boton_volver.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';

import '../domain/despensa_compartida.dart';
import 'compartida_provider.dart';
import 'widgets/miembro_tile.dart';

class DespensaCompartidaScreen extends ConsumerWidget {
  const DespensaCompartidaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDespensa = ref.watch(despensaCompartidaProvider);
    final uid = ref.watch(firebaseUserProvider).valueOrNull?.uid;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 700,
          child: ListView(
            // El padding lateral es fijo: ResponsiveContainer ya acota el
            // ancho en tablet y web.
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              const BotonVolver(),
              const SizedBox(height: 12),
              asyncDespensa.when(
                loading: () => Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                    child: CircularProgressIndicator(color: context.paleta.marca),
                  ),
                ),
                error: (e, _) => _MensajeError(mensaje: '$e'),
                data: (despensa) {
                  if (despensa == null || uid == null) {
                    return const _SinDespensa();
                  }
                  return _ConDespensa(despensa: despensa, uid: uid);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _MensajeError extends StatelessWidget {
  const _MensajeError({required this.mensaje});
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Text(
          mensaje,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.paleta.vencido),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- sin despensa

class _SinDespensa extends ConsumerWidget {
  const _SinDespensa();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final anchoAmplio = Responsive.isTabletOrWeb(context);

    final acciones = [
      _AccionCard(
        icono: CupertinoIcons.house_alt,
        titulo: 'Crear despensa',
        descripcion:
            'Genera un código para que tu familia se una a tu despensa.',
        principal: true,
        onTap: () => _dialogoCrear(context, ref),
      ),
      _AccionCard(
        icono: CupertinoIcons.person_badge_plus,
        titulo: 'Unirme con código',
        descripcion: 'Ya tienes un código de 6 caracteres de tu familia.',
        principal: false,
        onTap: () => _dialogoUnirse(context, ref),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Despensa compartida', style: textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          'Comparte una sola despensa con tu familia: los productos, las '
          'alertas y las recetas son los mismos para todos.',
          style: textTheme.bodyMedium?.copyWith(color: context.paleta.apagado),
        ),
        const SizedBox(height: 24),
        if (anchoAmplio)
          // IntrinsicHeight acota la altura: 'stretch' sola pide infinito
          // dentro de un ListView.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: acciones[0]),
                const SizedBox(width: 12),
                Expanded(child: acciones[1]),
              ],
            ),
          )
        else ...[
          acciones[0],
          const SizedBox(height: 12),
          acciones[1],
        ],
        const SizedBox(height: 24),
        const _NotaUnaDespensa(),
      ],
    );
  }
}

class _NotaUnaDespensa extends StatelessWidget {
  const _NotaUnaDespensa();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.paleta.marcaSuave.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.paleta.contorno),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.info_circle,
            size: 18,
            color: context.paleta.apagado,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Solo puedes estar en una despensa a la vez: la tuya personal o '
              'una compartida.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.paleta.apagado),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccionCard extends StatelessWidget {
  const _AccionCard({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.principal,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final bool principal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: principal
              ? context.paleta.marca.withValues(alpha: 0.12)
              : context.paleta.superficie,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: principal
                ? context.paleta.marca.withValues(alpha: 0.35)
                : context.paleta.contorno,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icono,
              size: 26,
              color: principal ? context.paleta.marca : context.paleta.marca,
            ),
            const SizedBox(height: 12),
            Text(titulo, style: textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              descripcion,
              style: textTheme.bodySmall?.copyWith(color: context.paleta.apagado),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- con despensa

class _ConDespensa extends ConsumerWidget {
  const _ConDespensa({required this.despensa, required this.uid});

  final DespensaCompartida despensa;
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final esAdmin = despensa.esAdmin(uid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(despensa.nombre, style: textTheme.displaySmall),
        const SizedBox(height: 6),
        Text(
          esAdmin
              ? 'Eres el administrador de esta despensa.'
              : 'Administrada por ${despensa.miembro(despensa.adminUid)?.nombre ?? 'otro miembro'}.',
          style: textTheme.bodySmall?.copyWith(color: context.paleta.apagado),
        ),
        const SizedBox(height: 20),
        _CodigoCard(codigo: despensa.codigo),
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(
              CupertinoIcons.person_2,
              size: 16,
              color: context.paleta.marca,
            ),
            const SizedBox(width: 8),
            Text(
              'MIEMBROS (${despensa.miembros.length})',
              style: textTheme.titleSmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: context.paleta.apagado,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MiembrosGrid(despensa: despensa, uid: uid, esAdmin: esAdmin),
        const SizedBox(height: 28),
        if (esAdmin) ...[
          // El admin tambien puede irse: le deja la administracion a otro
          // miembro en vez de destruir la despensa de todos.
          if (despensa.miembros.length > 1) ...[
            _BotonPeligro(
              icono: CupertinoIcons.square_arrow_left,
              texto: 'Salir y ceder la administración',
              onTap: () => _confirmarSalirComoAdmin(context, ref, despensa, uid),
            ),
            const SizedBox(height: 10),
          ],
          _BotonPeligro(
            icono: CupertinoIcons.delete,
            texto: 'Eliminar despensa',
            onTap: () => _confirmarEliminar(context, ref, despensa),
          ),
        ] else
          _BotonPeligro(
            icono: CupertinoIcons.square_arrow_left,
            texto: 'Salir de la despensa',
            onTap: () => _confirmarSalir(context, ref, despensa),
          ),
      ],
    );
  }
}

class _CodigoCard extends StatelessWidget {
  const _CodigoCard({required this.codigo});
  final String codigo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final apretado = Responsive.isMobile(context);

    final etiqueta = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CÓDIGO DE INVITACIÓN',
          style: textTheme.labelSmall?.copyWith(color: context.paleta.apagado),
        ),
        const SizedBox(height: 6),
        Text(
          codigo,
          style: textTheme.displayMedium?.copyWith(
            letterSpacing: 6,
            color: context.paleta.marca,
          ),
        ),
      ],
    );

    final boton = FilledButton.icon(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: codigo));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código copiado')),
        );
      },
      style: FilledButton.styleFrom(backgroundColor: context.paleta.marca),
      icon: const Icon(CupertinoIcons.doc_on_doc, size: 16),
      label: const Text('Copiar'),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.paleta.marcaSuave,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.paleta.contorno),
      ),
      child: apretado
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                etiqueta,
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: boton),
              ],
            )
          : Row(
              children: [
                Expanded(child: etiqueta),
                boton,
              ],
            ),
    );
  }
}

class _MiembrosGrid extends ConsumerWidget {
  const _MiembrosGrid({
    required this.despensa,
    required this.uid,
    required this.esAdmin,
  });

  final DespensaCompartida despensa;
  final String uid;
  final bool esAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columnas = Responsive.gridColumns(context).clamp(1, 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        const espacio = 12.0;
        final ancho = columnas == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - espacio * (columnas - 1)) / columnas;

        return Wrap(
          spacing: espacio,
          runSpacing: espacio,
          children: [
            for (final miembro in despensa.miembros)
              SizedBox(
                width: ancho,
                child: MiembroTile(
                  miembro: miembro,
                  esAdminDelMiembro: despensa.esAdmin(miembro.uid),
                  esYo: miembro.uid == uid,
                  onExpulsar: esAdmin && miembro.uid != uid
                      ? () => _confirmarExpulsar(context, ref, despensa, miembro)
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BotonPeligro extends StatelessWidget {
  const _BotonPeligro({
    required this.icono,
    required this.texto,
    required this.onTap,
  });

  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.paleta.vencido,
          side: BorderSide(color: context.paleta.vencido.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icono, size: 18),
        label: Text(texto),
      ),
    );
  }
}

// ------------------------------------------------------------------- dialogos

Future<void> _dialogoCrear(BuildContext context, WidgetRef ref) async {
  final nombre = await showDialog<String>(
    context: context,
    builder: (dialogContext) => const _DialogoTexto(
      titulo: 'Crear despensa familiar',
      descripcion:
          'Ponle un nombre. Después compartes el código con tu familia.',
      inicial: 'Despensa familiar',
      hint: 'Nombre de la despensa',
      textoBoton: 'Crear',
    ),
  );
  if (nombre == null || !context.mounted) return;

  final migrar = await _preguntarMigracion(context, ref);
  if (migrar == null || !context.mounted) return;

  await _ejecutar(
    context,
    () => ref.read(compartidaProvider.notifier).crear(
      nombre: nombre,
      migrar: migrar,
    ),
    exito: 'Despensa creada',
  );
}

Future<void> _dialogoUnirse(BuildContext context, WidgetRef ref) async {
  final codigo = await showDialog<String>(
    context: context,
    builder: (dialogContext) => const _DialogoTexto(
      titulo: 'Unirme a una despensa',
      descripcion: 'Escribe el código de 6 caracteres que te compartieron.',
      hint: 'ABC123',
      textoBoton: 'Unirme',
      mayusculas: true,
      maxLength: 6,
    ),
  );
  if (codigo == null || !context.mounted) return;

  // Se valida el codigo antes de preguntar por la migracion: si no existe la
  // despensa, no tiene sentido que el usuario decida sobre sus productos.
  final despensaId = await ref.read(buscarPorCodigoProvider(codigo).future);
  if (!context.mounted) return;
  if (despensaId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: context.paleta.vencido,
        content: Text('No existe una despensa con ese código.'),
      ),
    );
    return;
  }

  final migrar = await _preguntarMigracion(context, ref);
  if (migrar == null || !context.mounted) return;

  await _ejecutar(
    context,
    () => ref.read(compartidaProvider.notifier).unirse(
      codigo: codigo,
      migrar: migrar,
    ),
    exito: 'Te uniste a la despensa',
  );
}

/// Devuelve true/false segun lo que elija el usuario, o null si cancela.
/// Si no tiene productos personales no hay nada que preguntar.
Future<bool?> _preguntarMigracion(BuildContext context, WidgetRef ref) async {
  // refresh y no read: el conteo cacheado de un intento anterior haria
  // desaparecer el dialogo aunque si haya productos que migrar.
  final cantidad = await ref.refresh(productosPersonalesCountProvider.future);
  if (!context.mounted) return null;
  if (cantidad == 0) return false;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: context.paleta.marcaSuave,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Migrar tus productos',
        style: TextStyle(color: context.paleta.tinta, fontWeight: FontWeight.w800),
      ),
      content: Text(
        'Tienes $cantidad producto${cantidad == 1 ? '' : 's'} en tu despensa '
        'personal. ¿Quieres moverlos a la despensa compartida? Si no, se '
        'quedan en tu despensa personal y volverás a verlos cuando salgas.',
        style: TextStyle(color: context.paleta.apagado),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(
            'Cancelar',
            style: TextStyle(color: context.paleta.apagado),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(
            'No migrar',
            style: TextStyle(color: context.paleta.apagado),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: FilledButton.styleFrom(backgroundColor: context.paleta.marca),
          child: const Text('Migrar'),
        ),
      ],
    ),
  );
}

Future<void> _confirmarSalir(
  BuildContext context,
  WidgetRef ref,
  DespensaCompartida despensa,
) async {
  final ok = await _confirmar(
    context,
    titulo: 'Salir de la despensa',
    mensaje:
        'Volverás a tu despensa personal. Los productos que agregaste se '
        'quedan en la despensa compartida.',
    textoBoton: 'Salir',
  );
  if (ok != true || !context.mounted) return;

  await _ejecutar(
    context,
    () => ref.read(compartidaProvider.notifier).salir(despensa.id),
    exito: 'Saliste de la despensa',
  );
}

Future<void> _confirmarSalirComoAdmin(
  BuildContext context,
  WidgetRef ref,
  DespensaCompartida despensa,
  String uid,
) async {
  final candidatos = despensa.miembros.where((m) => m.uid != uid).toList();
  if (candidatos.isEmpty) return;

  final nuevoAdmin = await showDialog<String>(
    context: context,
    builder: (dialogContext) => _DialogoNuevoAdmin(candidatos: candidatos),
  );
  if (nuevoAdmin == null || !context.mounted) return;

  final nombre = despensa.miembro(nuevoAdmin)?.nombre ?? 'ese miembro';
  final ok = await _confirmar(
    context,
    titulo: 'Salir de la despensa',
    mensaje:
        '$nombre pasa a ser el administrador y vos volvés a tu despensa '
        'personal. Los productos que agregaste se quedan en la compartida.',
    textoBoton: 'Salir',
  );
  if (ok != true || !context.mounted) return;

  await _ejecutar(
    context,
    () => ref
        .read(compartidaProvider.notifier)
        .salir(despensa.id, nuevoAdminUid: nuevoAdmin),
    exito: 'Saliste de la despensa. Ahora administra $nombre.',
  );
}

class _DialogoNuevoAdmin extends StatefulWidget {
  const _DialogoNuevoAdmin({required this.candidatos});

  final List<MiembroDespensa> candidatos;

  @override
  State<_DialogoNuevoAdmin> createState() => _DialogoNuevoAdminState();
}

class _DialogoNuevoAdminState extends State<_DialogoNuevoAdmin> {
  late String _elegido = widget.candidatos.first.uid;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.paleta.marcaSuave,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        '¿Quién administra la despensa?',
        style: TextStyle(
          color: context.paleta.tinta,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quien elijas va a poder agregar y sacar miembros, y eliminar la '
            'despensa.',
            style: TextStyle(color: context.paleta.apagado, fontSize: 13),
          ),
          const SizedBox(height: 12),
          RadioGroup<String>(
            groupValue: _elegido,
            onChanged: (valor) => setState(() => _elegido = valor!),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final miembro in widget.candidatos)
                  RadioListTile<String>(
                    value: miembro.uid,
                    activeColor: context.paleta.marca,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      miembro.nombre,
                      style: TextStyle(
                        color: context.paleta.tinta,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: miembro.email == null
                        ? null
                        : Text(
                            miembro.email!,
                            style: TextStyle(
                              color: context.paleta.apagado,
                              fontSize: 12,
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: TextStyle(color: context.paleta.apagado),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _elegido),
          style: FilledButton.styleFrom(backgroundColor: context.paleta.marca),
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}

Future<void> _confirmarEliminar(
  BuildContext context,
  WidgetRef ref,
  DespensaCompartida despensa,
) async {
  final ok = await _confirmar(
    context,
    titulo: 'Eliminar despensa',
    mensaje:
        'Todos los miembros volverán a su despensa personal y los productos '
        'compartidos pasarán a la tuya. Esta acción no se puede deshacer.',
    textoBoton: 'Eliminar',
  );
  if (ok != true || !context.mounted) return;

  await _ejecutar(
    context,
    () => ref.read(compartidaProvider.notifier).eliminar(despensa.id),
    exito: 'Despensa eliminada',
  );
}

Future<void> _confirmarExpulsar(
  BuildContext context,
  WidgetRef ref,
  DespensaCompartida despensa,
  MiembroDespensa miembro,
) async {
  final ok = await _confirmar(
    context,
    titulo: 'Eliminar miembro',
    mensaje:
        '${miembro.nombre} volverá a su despensa personal y dejará de ver esta '
        'despensa.',
    textoBoton: 'Eliminar',
  );
  if (ok != true || !context.mounted) return;

  await _ejecutar(
    context,
    () => ref.read(compartidaProvider.notifier).expulsar(
      despensaId: despensa.id,
      userId: miembro.uid,
    ),
    exito: '${miembro.nombre} salió de la despensa',
  );
}

Future<bool?> _confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String textoBoton,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: context.paleta.marcaSuave,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        titulo,
        style: TextStyle(
          color: context.paleta.tinta,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Text(
        mensaje,
        style: TextStyle(color: context.paleta.apagado),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(
            'Cancelar',
            style: TextStyle(color: context.paleta.apagado),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: FilledButton.styleFrom(backgroundColor: context.paleta.vencido),
          child: Text(textoBoton),
        ),
      ],
    ),
  );
}

Future<void> _ejecutar(
  BuildContext context,
  Future<void> Function() accion, {
  required String exito,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context, rootNavigator: true);
  final colorError = context.paleta.vencido;

  // Bloquea la pantalla mientras dura la escritura en Firestore: sin esto no
  // hay senal de progreso y se puede tocar el boton dos veces.
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(color: context.paleta.marca),
      ),
    ),
  );

  try {
    await accion();
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(exito)));
  } catch (e) {
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(backgroundColor: colorError, content: Text('\$e')),
    );
  }
}

class _DialogoTexto extends StatefulWidget {
  const _DialogoTexto({
    required this.titulo,
    required this.descripcion,
    required this.hint,
    required this.textoBoton,
    this.inicial = '',
    this.mayusculas = false,
    this.maxLength,
  });

  final String titulo;
  final String descripcion;
  final String hint;
  final String textoBoton;
  final String inicial;
  final bool mayusculas;
  final int? maxLength;

  @override
  State<_DialogoTexto> createState() => _DialogoTextoState();
}

class _DialogoTextoState extends State<_DialogoTexto> {
  late final TextEditingController controller = TextEditingController(
    text: widget.inicial,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titulo = widget.titulo;
    final descripcion = widget.descripcion;
    final hint = widget.hint;
    final textoBoton = widget.textoBoton;
    final mayusculas = widget.mayusculas;
    final maxLength = widget.maxLength;

    return AlertDialog(
      backgroundColor: context.paleta.marcaSuave,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        titulo,
        style: TextStyle(
          color: context.paleta.tinta,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            descripcion,
            style: TextStyle(color: context.paleta.apagado, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            autofocus: true,
            maxLength: maxLength,
            textCapitalization: mayusculas
                ? TextCapitalization.characters
                : TextCapitalization.sentences,
            inputFormatters: mayusculas
                ? [UpperCaseTextFormatter()]
                : const [],
            style: TextStyle(
              color: context.paleta.tinta,
              fontWeight: FontWeight.w600,
              letterSpacing: mayusculas ? 4 : 0,
            ),
            decoration: InputDecoration(
              hintText: hint,
              counterText: '',
              filled: true,
              fillColor: context.paleta.superficie,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.paleta.contorno),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.paleta.contorno),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.paleta.marca),
              ),
            ),
            onSubmitted: (valor) => _enviar(context, valor),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: TextStyle(color: context.paleta.apagado),
          ),
        ),
        FilledButton(
          onPressed: () => _enviar(context, controller.text),
          style: FilledButton.styleFrom(backgroundColor: context.paleta.marca),
          child: Text(textoBoton),
        ),
      ],
    );
  }

  void _enviar(BuildContext context, String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) return;
    Navigator.pop(context, texto);
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => TextEditingValue(
    text: newValue.text.toUpperCase(),
    selection: newValue.selection,
  );
}
