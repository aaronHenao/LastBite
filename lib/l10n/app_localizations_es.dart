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
  String get recetasBuscar => 'Escribe un ingrediente o plato y pulsa buscar';

  @override
  String get recetasGenerando => 'La IA está preparando más recetas…';

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

  @override
  String get accionDeshacer => 'Deshacer';

  @override
  String get cuentaAyuda => 'Ayuda';

  @override
  String get accesoListaCompras => 'Lista de compras';

  @override
  String get accesoCompartida => 'Compartida';

  @override
  String get accesoBuscar => 'Buscar';

  @override
  String get ayudaTitulo => 'Ayuda';

  @override
  String get ayudaDescripcion =>
      'Cómo usar LastBite y respuestas a las dudas más comunes.';

  @override
  String get ayudaAbrir => 'Abrir ayuda';

  @override
  String get ayudaPrimerosPasos => 'PRIMEROS PASOS';

  @override
  String get ayudaPaso1 =>
      'Agrega lo que tienes en casa: escanea el código de barras o escríbelo a mano.';

  @override
  String get ayudaPaso2 =>
      'Revisa tu despensa: arriba quedan los productos que vencen primero.';

  @override
  String get ayudaPaso3 =>
      'Cocina con las recetas sugeridas y marca lo que usaste como consumido para sumar alimentos salvados.';

  @override
  String get ayudaPreguntas => 'PREGUNTAS FRECUENTES';

  @override
  String get ayudaSeccionDespensa => 'Despensa';

  @override
  String get ayudaSeccionAgregar => 'Agregar productos';

  @override
  String get ayudaSeccionRecetas => 'Recetas';

  @override
  String get ayudaSeccionAlertas => 'Alertas';

  @override
  String get ayudaSeccionCompartir => 'Despensa compartida y lista de compras';

  @override
  String get ayudaSeccionCuenta => 'Búsqueda, cuenta y ajustes';

  @override
  String get ayudaDespensaP1 => '¿Cómo marco que usé un producto?';

  @override
  String get ayudaDespensaR1 =>
      'Tócalo en la despensa y elige «Marcar como consumido». Suma a tus alimentos salvados y al ahorro del mes. Si te equivocas, toca «Deshacer» en el aviso que aparece abajo.';

  @override
  String get ayudaDespensaP2 => '¿Qué significan los días de cada producto?';

  @override
  String get ayudaDespensaR2 =>
      'Son los días que le quedan antes de vencer. «Próximos a vencer» agrupa los que vencen en 3 días o menos; los vencidos se marcan en rojo.';

  @override
  String get ayudaDespensaP3 => '¿Cómo se calcula el ahorro?';

  @override
  String get ayudaDespensaR3 =>
      'Es un estimado: lo que consumiste antes de que se venciera, multiplicado por un precio promedio de su categoría.';

  @override
  String get ayudaAgregarP1 => '¿Qué hago si el código de barras no aparece?';

  @override
  String get ayudaAgregarR1 =>
      'LastBite te pasa al ingreso manual. Escribe el nombre, elige la categoría y guarda.';

  @override
  String get ayudaAgregarP2 => '¿Quién elige la fecha de vencimiento?';

  @override
  String get ayudaAgregarR2 =>
      'La app propone una según la categoría del producto. Cámbiala antes de guardar si el empaque dice otra.';

  @override
  String get ayudaRecetasP1 => '¿Qué significa el porcentaje de cada receta?';

  @override
  String get ayudaRecetasR1 =>
      'Es la parte de los ingredientes que ya tienes. Los básicos (sal, pimienta, aceite y agua) cuentan como disponibles. En el detalle cada ingrediente dice «Tienes», «Básico» o «Falta».';

  @override
  String get ayudaRecetasP2 =>
      '¿Por qué las recetas no cambian cuando cambio la despensa?';

  @override
  String get ayudaRecetasR2 =>
      'Para que no pierdas la que estabas mirando. Cuando tu despensa cambia aparece un aviso con el botón «Actualizar recetas».';

  @override
  String get ayudaRecetasP3 => '¿Por qué tardan en aparecer?';

  @override
  String get ayudaRecetasR3 =>
      'Las genera una IA a partir de tu despensa y puede tardar unos segundos. La primera aparece apenas está lista.';

  @override
  String get ayudaRecetasP4 => '¿Qué pasa al tocar «Ya la cociné»?';

  @override
  String get ayudaRecetasR4 =>
      'Eliges qué productos se terminaron y se marcan como consumidos. Puedes deshacerlo desde el aviso.';

  @override
  String get ayudaAlertasP1 => '¿Cuándo aparece una alerta?';

  @override
  String get ayudaAlertasR1 =>
      'Cuando un producto está por vencer o ya venció. Las alertas quedan guardadas hasta que las borres.';

  @override
  String get ayudaAlertasP2 => 'No me llegan las notificaciones';

  @override
  String get ayudaAlertasR2 =>
      'Revisa que LastBite tenga permiso de notificaciones en los ajustes de tu teléfono.';

  @override
  String get ayudaCompartirP1 => '¿Cómo comparto la despensa con mi familia?';

  @override
  String get ayudaCompartirR1 =>
      'Toca «Compartida» en la despensa y crea una despensa. Pasa el código a quien quieras sumar: esa persona toca «Unirme con código» y lo escribe.';

  @override
  String get ayudaCompartirP2 => '¿Dónde está la lista de compras?';

  @override
  String get ayudaCompartirR2 =>
      'En «Lista de compras», arriba en la despensa. Al consumir o eliminar un producto, LastBite te ofrece agregarlo.';

  @override
  String get ayudaCuentaP1 => '¿Cómo busco un producto?';

  @override
  String get ayudaCuentaR1 =>
      'Toca «Buscar» en la despensa. No hace falta escribir el nombre exacto: da igual el orden de las palabras, las tildes y un error de tipeo.';

  @override
  String get ayudaCuentaP2 =>
      '¿Cómo cambio el tamaño del texto, el tema o el idioma?';

  @override
  String get ayudaCuentaR2 =>
      'En el menú de tu cuenta, «Accesibilidad». Ahí también puedes restablecer todo a como venía.';

  @override
  String despensaSalvado(String nombre) {
    return 'Salvaste $nombre.';
  }

  @override
  String despensaSalvadoYEnLista(String nombre) {
    return 'Salvaste $nombre. Quedó en tu lista de compras.';
  }

  @override
  String despensaEliminado(String nombre) {
    return 'Quitaste $nombre de la despensa.';
  }

  @override
  String despensaEliminadoYEnLista(String nombre) {
    return 'Quitaste $nombre de la despensa. Quedó en tu lista de compras.';
  }

  @override
  String get recetasBuscando =>
      'Buscando recetas con lo que tienes. Puede tardar unos segundos.';

  @override
  String get recetasDespensaCambio =>
      'Tu despensa cambió. Estas recetas se quedan hasta que decidas actualizarlas.';

  @override
  String get recetasActualizar => 'Actualizar recetas';

  @override
  String recetasFaltan(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Faltan $cantidad',
      one: 'Falta 1',
    );
    return '$_temp0';
  }

  @override
  String recetasTienesDeTotal(int disponibles, int total) {
    return 'Tienes $disponibles de $total ingredientes';
  }

  @override
  String get recetasIngredienteTienes => 'Tienes';

  @override
  String get recetasIngredienteBasico => 'Básico';

  @override
  String get recetasIngredienteFalta => 'Falta';

  @override
  String get recetasBasicosNota =>
      '«Básico» es sal, pimienta, aceite o agua: se asume que los tienes en casa.';

  @override
  String get recetasIngredientes => 'INGREDIENTES';

  @override
  String get recetasPreparacion => 'PREPARACIÓN';

  @override
  String agregarGuardadoVence(String nombre, int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$nombre quedó en tu despensa. Vence en $dias días.',
      one: '$nombre quedó en tu despensa. Vence mañana.',
      zero: '$nombre quedó en tu despensa. Vence hoy.',
    );
    return '$_temp0';
  }

  @override
  String get ajustesRestablecer => 'Restablecer ajustes';

  @override
  String get ajustesRestablecerAyuda =>
      'Vuelve el tamaño del texto, el contraste, el movimiento, el tema y el idioma a como venían. Tus productos, listas y alertas no se tocan.';

  @override
  String get ajustesRestablecerPregunta => '¿Restablecer los ajustes?';

  @override
  String get ajustesRestablecerAccion => 'Restablecer';

  @override
  String get ajustesRestablecidos => 'Los ajustes volvieron a como venían.';

  @override
  String consultaSinResultados(String busqueda) {
    return 'No encontramos «$busqueda»';
  }

  @override
  String get consultaSinResultadosDescripcion =>
      'Prueba con otra palabra. No hace falta escribir el nombre exacto ni poner tildes.';

  @override
  String get despensaConsumir => 'Marcar como consumido';

  @override
  String get despensaConsumirAyuda => 'Suma a tus alimentos salvados';

  @override
  String get despensaEliminar => 'Eliminar';

  @override
  String get despensaEliminarAyuda => 'No suma a alimentos salvados';

  @override
  String get despensaListaPregunta => '¿Añadir a lista de compras?';

  @override
  String despensaListaDescripcion(String nombre) {
    return 'Agregar $nombre a tu lista para la próxima compra.';
  }

  @override
  String get despensaListaNo => 'No, gracias';

  @override
  String get despensaListaSi => 'Añadir';

  @override
  String get recetasYaLaCocine => 'Ya la cociné';

  @override
  String get categoriaVerdura => 'Verdura';

  @override
  String get categoriaFruta => 'Fruta';

  @override
  String get categoriaHierba => 'Hierba';

  @override
  String get categoriaCarne => 'Carne';

  @override
  String get categoriaPollo => 'Pollo';

  @override
  String get categoriaPescado => 'Pescado';

  @override
  String get categoriaHuevo => 'Huevo';

  @override
  String get categoriaLeche => 'Leche';

  @override
  String get categoriaYogur => 'Yogur';

  @override
  String get categoriaQueso => 'Queso';

  @override
  String get categoriaMantequilla => 'Mantequilla';

  @override
  String get categoriaPan => 'Pan';

  @override
  String get categoriaEmbutido => 'Embutido';

  @override
  String get categoriaJugo => 'Jugo';

  @override
  String get categoriaGrano => 'Grano';

  @override
  String get categoriaConserva => 'Conserva';

  @override
  String get categoriaCereal => 'Cereal';

  @override
  String get categoriaOtro => 'Otro';

  @override
  String get unidadUnidad => 'unidad';

  @override
  String get unidadCucharada => 'cda';

  @override
  String get unidadTaza => 'taza';

  @override
  String cantidadUnidades(String numero, num cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'unidades',
      one: 'unidad',
    );
    return '$numero $_temp0';
  }

  @override
  String cantidadTazas(String numero, num cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'tazas',
      one: 'taza',
    );
    return '$numero $_temp0';
  }

  @override
  String cantidadCucharadas(String numero) {
    return '$numero cda';
  }

  @override
  String get temaAutomaticoAccion => 'Tema: automático. Toca para cambiar.';

  @override
  String get temaClaroAccion => 'Tema: claro. Toca para cambiar.';

  @override
  String get temaOscuroAccion => 'Tema: oscuro. Toca para cambiar.';

  @override
  String get cuentaPerfilAyuda => 'Ver perfil y lista de compras';

  @override
  String get cuentaCompartidaAyuda => 'Crea una o únete con un código';

  @override
  String get cuentaConsultaRapidaAyuda => 'Buscar productos de tu despensa';

  @override
  String get cuentaAccesibilidadAyuda =>
      'Tamaño de texto, contraste y movimiento';

  @override
  String despensaAhorroMes(DateTime mes) {
    final intl.DateFormat mesDateFormat = intl.DateFormat.MMMM(localeName);
    final String mesString = mesDateFormat.format(mes);

    return 'Ahorro estimado de $mesString';
  }

  @override
  String get despensaAhorroVacio =>
      'Consume un producto antes de que venza para empezar a sumar';

  @override
  String get despensaAhorroNota =>
      'Estimado según precios promedio por categoría';

  @override
  String get agregarCantidadEjemplo => 'Ej: 1';

  @override
  String get alertasRotulo => 'ALERTAS';

  @override
  String get alertasTitulo => 'Caducidad y recetas';

  @override
  String get alertasNota =>
      'Las alertas se mantienen hasta que decidas borrarlas.';

  @override
  String get alertasBorrarTodo => 'Borrar todo';

  @override
  String get alertasBorrarPregunta => 'Borrar todas las alertas';

  @override
  String get alertasBorrarDescripcion =>
      'Esta acción elimina las alertas actuales. Las nuevas se generan cuando corresponda.';

  @override
  String get alertasEliminadas => 'Alertas eliminadas';

  @override
  String alertaDescartada(String producto) {
    return 'Alerta de $producto descartada';
  }

  @override
  String get alertaDescartarCorto => 'Descartar';

  @override
  String get alertaDescartarTooltip => 'Descartar alerta';

  @override
  String get alertaRecetaSugerida => 'RECETA SUGERIDA';

  @override
  String get alertaTituloAviso5 => 'Primer aviso';

  @override
  String get alertaTituloAviso3 => 'Aviso crítico';

  @override
  String get alertaTituloAviso1 => 'Último día';

  @override
  String get alertaTituloVencido => 'Producto vencido';

  @override
  String alertaMensajeAviso5(String producto) {
    return 'Tu $producto vence en 5 días. Ten cuidado.';
  }

  @override
  String alertaMensajeAviso3(String producto) {
    return 'Tu $producto vence en 3 días. Te sugerimos una receta.';
  }

  @override
  String alertaMensajeAviso1(String producto) {
    return 'Tu $producto vence mañana. Aprovéchalo hoy.';
  }

  @override
  String alertaMensajeVencido(String producto) {
    return 'Tu $producto ya venció. Retíralo de la despensa.';
  }

  @override
  String get notifCanal => 'Alertas de vencimiento';

  @override
  String get notifCanalDescripcion =>
      'Notificaciones de productos próximos a vencer';

  @override
  String notifVenceManana(String producto) {
    return '$producto vence mañana';
  }

  @override
  String get notifVenceMananaConReceta =>
      'Aprovéchalo hoy: toca para ver una receta sugerida.';

  @override
  String get notifVenceMananaSinReceta =>
      'Es tu último día para usarlo. ¡No lo desperdicies!';

  @override
  String notifVenceEn3(String producto) {
    return '$producto vence en 3 días';
  }

  @override
  String get notifVenceEn3Cuerpo =>
      'Planifica una receta antes de que sea tarde.';

  @override
  String notifVencido(String producto) {
    return '$producto ya venció';
  }

  @override
  String get notifVencidoCuerpo => 'Retíralo de tu despensa.';

  @override
  String get authBienvenido => 'Bienvenido a';

  @override
  String get authCorreo => 'Correo electrónico';

  @override
  String get authCorreoEjemplo => 'tu@correo.com';

  @override
  String get authContrasena => 'Contraseña';

  @override
  String get authConfirmarContrasena => 'Confirmar contraseña';

  @override
  String get authIniciarSesion => 'Iniciar sesión';

  @override
  String get authOContinua => 'o continúa con';

  @override
  String get authContinuarGoogle => 'Continuar con Google';

  @override
  String get authSinCuentaPregunta => '¿No tienes cuenta? ';

  @override
  String get authRegistrate => 'Regístrate';

  @override
  String get authCreaCuenta => 'Crea tu cuenta';

  @override
  String get authCreaCuentaAyuda => 'Empieza a salvar tus alimentos';

  @override
  String get authNombre => 'Nombre';

  @override
  String get authNombreEjemplo => 'Tu nombre';

  @override
  String get authCrearCuenta => 'Crear cuenta';

  @override
  String get authCompletaCampos => 'Completa todos los campos.';

  @override
  String get authContrasenasNoCoinciden => 'Las contraseñas no coinciden.';

  @override
  String get authContrasenaCorta =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get authCredencialesIncorrectas => 'Correo o contraseña incorrectos.';

  @override
  String get authCorreoRegistrado => 'Este correo ya está registrado.';

  @override
  String get authCorreoInvalido => 'El correo no es válido.';

  @override
  String get authSinCuenta => 'No existe una cuenta con este correo.';

  @override
  String get authContrasenaIncorrecta => 'Contraseña incorrecta.';

  @override
  String get authDemasiadosIntentos =>
      'Demasiados intentos. Espera un momento.';

  @override
  String get authSinConexion => 'Sin conexión a internet.';

  @override
  String get authVentanaBloqueada =>
      'El navegador bloqueó la ventana de Google. Permite ventanas emergentes.';

  @override
  String authErrorDesconocido(String codigo) {
    return 'No pudimos completar el acceso. Código: $codigo';
  }

  @override
  String get compartidaMiembroSinNombre => 'Miembro';

  @override
  String compartidaTu(String nombre) {
    return '$nombre (tú)';
  }

  @override
  String get compartidaAdmin => 'ADMIN';

  @override
  String get compartidaEliminarMiembro => 'Eliminar miembro';

  @override
  String compartidaErrorLargoCodigo(int largo) {
    return 'El código debe tener $largo caracteres.';
  }

  @override
  String get compartidaErrorCodigoInexistente =>
      'No existe una despensa con ese código.';

  @override
  String get compartidaErrorNoExiste => 'La despensa ya no existe.';

  @override
  String get compartidaErrorUnicoMiembro =>
      'Eres el único miembro. Elimina la despensa en vez de salir.';

  @override
  String get compartidaErrorElegirAdmin =>
      'Elige a quién le dejas la administración antes de salir.';

  @override
  String get compartidaErrorAdminInvalido =>
      'El nuevo administrador debe ser otro miembro de la despensa.';

  @override
  String get compartidaErrorSoloAdminMiembros =>
      'Solo el administrador puede eliminar miembros.';

  @override
  String get compartidaErrorAdminNoSeElimina =>
      'El administrador no puede eliminarse a sí mismo.';

  @override
  String get compartidaErrorSoloAdminEliminar =>
      'Solo el administrador puede eliminar la despensa.';

  @override
  String get compartidaErrorYaPerteneces =>
      'Ya perteneces a una despensa compartida. Sal de ella primero.';

  @override
  String get compartidaErrorSinCodigo =>
      'No se pudo generar un código. Intenta de nuevo.';

  @override
  String get compartidaErrorSinSesion => 'Debes iniciar sesión.';

  @override
  String get compartidaErrorDesconocido => 'Algo salió mal. Intenta de nuevo.';

  @override
  String get escanerPermisoTitulo => 'Permiso de cámara requerido';

  @override
  String get escanerPermisoDescripcion =>
      'Necesitamos acceso a la cámara para escanear el código de barras.';

  @override
  String get escanerEntendido => 'Entendido';

  @override
  String get escanerTitulo => 'Escanear producto';

  @override
  String get escanerApagarFlash => 'Apagar flash';

  @override
  String get escanerEncenderFlash => 'Encender flash';

  @override
  String get escanerCambiarCamara => 'Cambiar cámara';

  @override
  String get escanerPermisoDenegado => 'Permiso de cámara denegado';

  @override
  String get escanerNoInicia => 'No se pudo iniciar la cámara';

  @override
  String get escanerAlinea => 'Alinea el código de barras dentro del marco';

  @override
  String get nutricionalRotulo => 'PERFIL NUTRICIONAL';

  @override
  String get nutricionalTitulo => 'Preferencias de recetas';

  @override
  String get nutricionalTipoUsuario => 'Tipo de usuario';

  @override
  String get nutricionalSinPreferencia => 'Sin preferencia';

  @override
  String get nutricionalDeportista => 'Deportista';

  @override
  String get nutricionalPlan => 'Plan nutricional';

  @override
  String get nutricionalObjetivo => 'Objetivo nutricional';

  @override
  String get nutricionalSinObjetivo => 'Sin objetivo específico';

  @override
  String get nutricionalPerderPeso => 'Perder peso';

  @override
  String get nutricionalMantenerPeso => 'Mantener peso';

  @override
  String get nutricionalGanarPeso => 'Ganar peso';

  @override
  String get nutricionalAlimentacion => 'Tipo de alimentación';

  @override
  String get nutricionalOmnivora => 'Omnívora';

  @override
  String get nutricionalVegetariana => 'Vegetariana';

  @override
  String get nutricionalVegana => 'Vegana';

  @override
  String get nutricionalOtra => 'Otra';

  @override
  String get nutricionalRestricciones => 'Restricciones alimentarias';

  @override
  String get nutricionalRestriccionesEjemplo => 'Ej. cerdo, mariscos';

  @override
  String get nutricionalAlergias => 'Alergias o intolerancias';

  @override
  String get nutricionalAlergiasEjemplo => 'Ej. maní, gluten';

  @override
  String get nutricionalGuardar => 'Guardar perfil';

  @override
  String get nutricionalErrorGuardar =>
      'No se pudo guardar el perfil. Revisa tu conexión e intenta de nuevo.';

  @override
  String get nutricionalGuardado => 'Perfil nutricional guardado';

  @override
  String get consultaTitulo => 'Consulta rápida';

  @override
  String get consultaBuscar => 'Buscar producto';

  @override
  String get consultaErrorCarga => 'No pudimos cargar tus productos.';

  @override
  String get consultaVacia =>
      'Tu despensa está vacía. Agrega productos para consultarlos aquí.';

  @override
  String get consultaCantidad => 'Cantidad';

  @override
  String get consultaFechaCaducidad => 'Fecha de vencimiento';

  @override
  String get consultaEstado => 'Estado';

  @override
  String get consultaEstadoVencido => 'Vencido';

  @override
  String get consultaEstadoPorVencer => 'Próximo a vencer';

  @override
  String get consultaEstadoVigente => 'En buen estado';

  @override
  String get recetasErrorFaltaClave =>
      'Falta la clave de la IA. Ejecuta la app con --dart-define-from-file=env.json.';

  @override
  String get recetasErrorRespuestaVacia =>
      'La IA respondió vacío. Intenta de nuevo.';

  @override
  String get recetasErrorTiempo =>
      'La IA tardó demasiado en responder. Intenta de nuevo.';

  @override
  String get recetasErrorSinConexion =>
      'No hay conexión con el servicio de recetas. Revisa tu internet.';

  @override
  String get recetasErrorClave => 'La clave de la IA no es válida o expiró.';

  @override
  String get recetasErrorCreditos =>
      'Se agotaron los créditos del servicio de IA.';

  @override
  String get recetasErrorModeloInexistente =>
      'El modelo de IA configurado no existe.';

  @override
  String get recetasErrorModeloRetirado =>
      'El modelo de IA configurado fue retirado por NVIDIA.';

  @override
  String get recetasErrorDemasiadas =>
      'Demasiadas consultas a la IA. Espera un momento.';

  @override
  String get recetasErrorServicio =>
      'El servicio de IA no está disponible ahora mismo.';

  @override
  String get recetasErrorSinRecetas =>
      'La IA no devolvió recetas válidas. Intenta de nuevo.';

  @override
  String get recetasErrorFormato =>
      'La IA respondió en un formato inesperado. Intenta de nuevo.';

  @override
  String get recetasErrorIncompleta =>
      'La respuesta de la IA llegó incompleta. Intenta de nuevo.';

  @override
  String get recetasErrorDetalle =>
      'El detalle de esta receta ya no está disponible. Actualiza las sugerencias para generar una nueva.';

  @override
  String get recetasErrorSinIngredientes =>
      'No hay ingredientes válidos para buscar recetas.';

  @override
  String get recetasErrorDesconocido => 'No se pudieron generar recetas.';

  @override
  String get recetasErrorDetalleCarga =>
      'No pudimos cargar la preparación. Revisa tu conexión.';

  @override
  String get recetasOrdenDesayuno => 'Es temprano: primero las de desayuno';

  @override
  String get recetasOrdenPrincipal => 'Primero los platos fuertes';

  @override
  String get recetasOrdenSemana => 'Es día de semana: primero las más rápidas';

  @override
  String get recetasOrdenFinde =>
      'Es fin de semana: hay tiempo para algo más elaborado';

  @override
  String recetasMatch(int porcentaje) {
    return '$porcentaje% match';
  }

  @override
  String recetasLikes(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad me gusta',
      one: '1 me gusta',
    );
    return '$_temp0';
  }

  @override
  String get accionCerrar => 'Cerrar';
}
