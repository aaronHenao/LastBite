// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class L10nEs extends L10n {
  L10nEs([String locale = 'es']) : super(locale);

  @override
  String get appNombre => 'LastBite';

  @override
  String get navDespensa => 'Despensa';

  @override
  String get navAgregar => 'Agregar';

  @override
  String get navRecetas => 'Recetas';

  @override
  String get navAlertas => 'Alertas';

  @override
  String get accionVolver => 'Volver';

  @override
  String get accionReintentar => 'Reintentar';

  @override
  String get accionCancelar => 'Cancelar';

  @override
  String get accionAgregarProducto => 'Agregar producto';

  @override
  String get accionLimpiarBusqueda => 'Limpiar búsqueda';

  @override
  String get accionDetalleTecnico => 'Detalle técnico';

  @override
  String get cuentaMenu => 'Menú de cuenta';

  @override
  String get cuentaMia => 'Mi cuenta';

  @override
  String get cuentaPerfil => 'Perfil y lista de compras';

  @override
  String get cuentaCompartida => 'Despensa compartida';

  @override
  String get cuentaConsultaRapida => 'Consulta rápida';

  @override
  String get cuentaAccesibilidad => 'Accesibilidad';

  @override
  String get cuentaCerrarSesion => 'Cerrar sesión';

  @override
  String get despensaTitulo => 'Mi Despensa';

  @override
  String get despensaProductos => 'Productos';

  @override
  String get despensaSalvados => 'Salvados';

  @override
  String get despensaPorVencer => 'Por vencer';

  @override
  String get despensaProximosAVencer => 'PRÓXIMOS A VENCER';

  @override
  String get despensaEnBuenEstado => 'EN BUEN ESTADO';

  @override
  String get despensaVaciaTitulo => 'Tu despensa está vacía';

  @override
  String get despensaVaciaDescripcion =>
      'Agregá lo que tengas en casa y te avisamos antes de que se venza.';

  @override
  String get despensaErrorCarga => 'No pudimos cargar tu despensa.';

  @override
  String get estadoVencido => '¡Vencido!';

  @override
  String get estadoHoy => 'Hoy';

  @override
  String get estadoManana => 'Mañana';

  @override
  String estadoDias(int dias) {
    return '${dias}d';
  }

  @override
  String lectorProducto(
    String nombre,
    String cantidad,
    String categoria,
    String estado,
  ) {
    return '$nombre, $cantidad, $categoria, $estado';
  }

  @override
  String get lectorVenceHoy => 'vence hoy';

  @override
  String get lectorVenceManana => 'vence mañana';

  @override
  String lectorVenceEnDias(int dias) {
    return 'vence en $dias días';
  }

  @override
  String lectorVencidoHace(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'vencido hace $dias días',
      one: 'vencido hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get ajustesTitulo => 'Accesibilidad';

  @override
  String get ajustesDescripcion =>
      'Ajustá la app a cómo la necesitás usar. Todo se guarda en tu cuenta, así que te acompaña al teléfono y a la web.';

  @override
  String get ajustesTamanoTexto => 'TAMAÑO DEL TEXTO';

  @override
  String get ajustesTamanoTextoAyuda =>
      'Toda la app crece con este ajuste, no solo esta pantalla.';

  @override
  String get ajustesEscalaNormal => 'Normal';

  @override
  String get ajustesEscalaGrande => 'Grande';

  @override
  String get ajustesEscalaMasGrande => 'Más grande';

  @override
  String get ajustesEscalaMaxima => 'Máximo';

  @override
  String get ajustesContraste => 'CONTRASTE';

  @override
  String get ajustesContrasteAyuda =>
      'Sube el contraste al máximo y refuerza los bordes. Ayuda con baja visión y a plena luz del sol.';

  @override
  String get ajustesAltoContraste => 'Alto contraste';

  @override
  String get ajustesMovimiento => 'MOVIMIENTO';

  @override
  String get ajustesMovimientoAyuda =>
      'Apaga las transiciones. Útil si el movimiento en pantalla te marea o te distrae.';

  @override
  String get ajustesReducirMovimiento => 'Reducir movimiento';

  @override
  String get ajustesApariencia => 'APARIENCIA';

  @override
  String get ajustesAparienciaAyuda =>
      'Automático sigue el ajuste de tu dispositivo.';

  @override
  String get ajustesTemaAutomatico => 'Automático';

  @override
  String get ajustesTemaClaro => 'Claro';

  @override
  String get ajustesTemaOscuro => 'Oscuro';

  @override
  String get ajustesIdioma => 'IDIOMA';

  @override
  String get ajustesIdiomaAyuda =>
      'Automático usa el idioma de tu dispositivo.';

  @override
  String get ajustesIdiomaAutomatico => 'Automático';

  @override
  String get ajustesLectorTitulo => 'Lector de pantalla';

  @override
  String get ajustesLectorAyuda =>
      'La app está preparada para TalkBack y VoiceOver: cada producto se anuncia con su nombre, su cantidad y cuánto le queda. Se activa desde los ajustes de tu dispositivo, no desde aquí.';

  @override
  String alertaDescartar(String producto) {
    return 'Descartar alerta de $producto';
  }

  @override
  String get alertasVaciasTitulo => 'Todo bajo control';

  @override
  String get alertasVaciasDescripcion =>
      'Ningún producto de tu despensa está por vencerse. Te avisamos apenas alguno lo esté.';

  @override
  String get alertasErrorCarga => 'No pudimos cargar tus alertas.';

  @override
  String get compartidaTitulo => 'Despensa compartida';

  @override
  String get compartidaIntro =>
      'Comparte una sola despensa con tu familia: los productos, las alertas y las recetas son los mismos para todos.';

  @override
  String get compartidaCrear => 'Crear despensa';

  @override
  String get compartidaCrearAyuda =>
      'Genera un código para que tu familia se una a tu despensa.';

  @override
  String get compartidaUnirme => 'Unirme con código';

  @override
  String get compartidaUnirmeAyuda =>
      'Ya tienes un código de 6 caracteres de tu familia.';

  @override
  String get compartidaNotaUnaSola =>
      'Solo puedes estar en una despensa a la vez: la tuya personal o una compartida.';

  @override
  String get compartidaEresAdmin => 'Eres el administrador de esta despensa.';

  @override
  String compartidaAdministradaPor(String nombre) {
    return 'Administrada por $nombre.';
  }

  @override
  String get compartidaOtroMiembro => 'otro miembro';

  @override
  String get compartidaCodigoRotulo => 'CÓDIGO DE INVITACIÓN';

  @override
  String get compartidaCopiar => 'Copiar';

  @override
  String get compartidaCodigoCopiado => 'Código copiado';

  @override
  String compartidaMiembros(int cantidad) {
    return 'MIEMBROS ($cantidad)';
  }

  @override
  String get compartidaSalir => 'Salir de la despensa';

  @override
  String get compartidaSalirCeder => 'Salir y ceder la administración';

  @override
  String get compartidaEliminar => 'Eliminar despensa';

  @override
  String get compartidaCrearTitulo => 'Crear despensa familiar';

  @override
  String get compartidaCrearDescripcion =>
      'Ponle un nombre. Después compartes el código con tu familia.';

  @override
  String get compartidaNombreDefecto => 'Despensa familiar';

  @override
  String get compartidaNombrePlaceholder => 'Nombre de la despensa';

  @override
  String get compartidaAccionCrear => 'Crear';

  @override
  String get compartidaUnirmeTitulo => 'Unirme a una despensa';

  @override
  String get compartidaUnirmeDescripcion =>
      'Escribe el código de 6 caracteres que te compartieron.';

  @override
  String get compartidaAccionUnirme => 'Unirme';

  @override
  String get compartidaSinCodigo => 'No existe una despensa con ese código.';

  @override
  String get compartidaMigrarTitulo => 'Migrar tus productos';

  @override
  String compartidaMigrarDescripcion(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other:
          'Tienes $cantidad productos en tu despensa personal. ¿Querés moverlos a la despensa compartida? Si no, se quedan en tu despensa personal.',
      one:
          'Tienes 1 producto en tu despensa personal. ¿Querés moverlo a la despensa compartida? Si no, se queda en tu despensa personal.',
    );
    return '$_temp0';
  }

  @override
  String get compartidaMigrar => 'Migrar';

  @override
  String get compartidaNoMigrar => 'No migrar';

  @override
  String get compartidaEliminarDescripcion =>
      'Todos los miembros volverán a su despensa personal y los productos compartidos pasarán a la tuya. Esta acción no se puede deshacer.';

  @override
  String get compartidaEliminarAccion => 'Eliminar';

  @override
  String get compartidaExpulsarTitulo => 'Eliminar miembro';

  @override
  String compartidaExpulsarDescripcion(String nombre) {
    return '$nombre volverá a su despensa personal y dejará de ver esta despensa.';
  }

  @override
  String get compartidaSalirDescripcion =>
      'Volverás a tu despensa personal. Los productos que agregaste se quedan en la despensa compartida.';

  @override
  String get compartidaSalirAccion => 'Salir';

  @override
  String get compartidaNuevoAdminTitulo => '¿Quién administra la despensa?';

  @override
  String get compartidaNuevoAdminDescripcion =>
      'Quien elijas va a poder agregar y sacar miembros, y eliminar la despensa.';

  @override
  String get compartidaContinuar => 'Continuar';

  @override
  String compartidaCederDescripcion(String nombre) {
    return '$nombre pasa a ser el administrador y vos volvés a tu despensa personal. Los productos que agregaste se quedan en la compartida.';
  }

  @override
  String get compartidaCreada => 'Despensa creada';

  @override
  String get compartidaTeUniste => 'Te uniste a la despensa';

  @override
  String get compartidaSaliste => 'Saliste de la despensa';

  @override
  String compartidaSalisteConAdmin(String nombre) {
    return 'Saliste de la despensa. Ahora administra $nombre.';
  }

  @override
  String get compartidaEliminada => 'Despensa eliminada';

  @override
  String compartidaMiembroSalio(String nombre) {
    return '$nombre salió de la despensa';
  }

  @override
  String get perfilUsuario => 'Usuario';

  @override
  String perfilSalvados(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad alimentos salvados',
      one: '1 alimento salvado',
    );
    return '$_temp0';
  }

  @override
  String get perfilNutricional => 'Perfil nutricional';

  @override
  String get perfilNutricionalAyuda => 'Adapta las recetas a tus preferencias';

  @override
  String get perfilListaCompras => 'LISTA DE COMPRAS';

  @override
  String get perfilComprados => 'COMPRADOS';

  @override
  String get perfilLimpiarComprados => 'Limpiar comprados';

  @override
  String get perfilLimpiar => 'Limpiar';

  @override
  String get perfilLimpiarPregunta =>
      '¿Eliminar todos los productos marcados como comprados?';

  @override
  String get perfilListaVaciaTitulo => 'Tu lista de compras está vacía';

  @override
  String get perfilListaVaciaDescripcion =>
      'Los productos que consumas o elimines aparecerán aquí.';

  @override
  String perfilMarcarComprado(String nombre) {
    return 'Marcar $nombre como comprado';
  }

  @override
  String perfilConsumido(String fecha) {
    return 'Consumido: $fecha';
  }

  @override
  String perfilVencido(String fecha) {
    return 'Venció: $fecha';
  }

  @override
  String get perfilErrorLista => 'No pudimos cargar tu lista de compras.';

  @override
  String get recetasRotulo => 'MOTOR DE RECETAS';

  @override
  String get recetasTitulo => 'Residuo Cero';

  @override
  String get recetasBuscar => 'Buscar por nombre...';

  @override
  String get recetasSugeridas => 'RECETAS SUGERIDAS';

  @override
  String get recetasMenorTiempo => 'Menor tiempo';

  @override
  String get recetasOrdenarMenorTiempo => 'Ordenar por menor tiempo';

  @override
  String get recetasPriorizando => 'Priorizando ingredientes urgentes';

  @override
  String get recetasSinProductos => 'No hay productos en tu despensa';

  @override
  String get recetasSinUrgentes => 'No hay productos urgentes en tu despensa';

  @override
  String get recetasErrorCarga => 'No se pudieron cargar recetas';

  @override
  String get recetasSinResultados => 'Sin resultados';

  @override
  String recetasSinResultadosDescripcion(String busqueda) {
    return 'Ninguna receta coincide con \"$busqueda\".';
  }

  @override
  String get recetasSinSugerenciasTitulo => 'Todavía no hay sugerencias';

  @override
  String get recetasSinSugerenciasDescripcion =>
      'Agregá productos a tu despensa y te proponemos recetas que los aprovechen.';

  @override
  String get recetasBuscarDeNuevo => 'Buscar de nuevo';

  @override
  String get recetasCocinarTitulo => '¿Qué usaste por completo?';

  @override
  String get recetasCocinarDescripcion =>
      'Lo que marques sale de tu despensa y suma a tus alimentos salvados. Destildá lo que todavía te quede.';

  @override
  String get recetasSinCoincidencias =>
      'Ninguno de tus productos coincide con esta receta.';

  @override
  String get recetasConfirmar => 'Confirmar';

  @override
  String recetasSalvados(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad productos salvados. ¡Buen provecho!',
      one: '1 producto salvado. ¡Buen provecho!',
    );
    return '$_temp0';
  }

  @override
  String get agregarRotulo => 'AGREGAR ALIMENTO';

  @override
  String get agregarTitulo => 'Entrada Híbrida';

  @override
  String get agregarEscanear => 'Escanear';

  @override
  String get agregarManual => 'Manual';

  @override
  String get agregarApuntaCodigo => 'Apunta al código de barras';

  @override
  String get agregarTocaCamara => 'Tocá para abrir la cámara';

  @override
  String get agregarBuscando => 'Buscando el producto…';

  @override
  String agregarUltimoCodigo(String codigo) {
    return 'Último código: $codigo';
  }

  @override
  String get agregarNoEncontrado =>
      'Producto no encontrado. Ingrésalo manualmente.';

  @override
  String get agregarSinConexion =>
      'Sin conexión. No pudimos consultar el código.';

  @override
  String agregarGuardado(String nombre) {
    return '$nombre agregado a la despensa.';
  }

  @override
  String get agregarNombre => 'Nombre';

  @override
  String get agregarNombreProducto => 'Nombre del producto';

  @override
  String get agregarNombreEjemplo => 'Ej: Yogur griego';

  @override
  String get agregarCategoria => 'Selecciona una categoría';

  @override
  String get agregarElegirCategoria => 'Elige categoría';

  @override
  String get agregarCantidad => 'Cantidad';

  @override
  String get agregarUnidad => 'Unidad';

  @override
  String get agregarFecha => 'Fecha de vencimiento';

  @override
  String get agregarElegirFecha => 'Selecciona una fecha';

  @override
  String get agregarFechaRecomendada =>
      'Esta es la fecha de caducidad recomendada para este producto';

  @override
  String get agregarGuardar => 'Guardar producto';

  @override
  String get agregarFaltanCampos => 'Completa nombre y fecha.';

  @override
  String get agregarNombreVacio => 'El nombre no puede estar vacío.';

  @override
  String get agregarConfirmar => 'CONFIRMAR PRODUCTO';

  @override
  String get agregarAgregarADespensa => 'Agregar a mi despensa';
}
