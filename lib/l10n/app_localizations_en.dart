// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appNombre => 'LastBite';

  @override
  String get navDespensa => 'Pantry';

  @override
  String get navAgregar => 'Add';

  @override
  String get navRecetas => 'Recipes';

  @override
  String get navAlertas => 'Alerts';

  @override
  String get accionVolver => 'Back';

  @override
  String get accionReintentar => 'Retry';

  @override
  String get accionCancelar => 'Cancel';

  @override
  String get accionAgregarProducto => 'Add product';

  @override
  String get accionLimpiarBusqueda => 'Clear search';

  @override
  String get accionDetalleTecnico => 'Technical details';

  @override
  String get cuentaMenu => 'Account menu';

  @override
  String get cuentaMia => 'My account';

  @override
  String get cuentaPerfil => 'Profile and shopping list';

  @override
  String get cuentaCompartida => 'Shared pantry';

  @override
  String get cuentaConsultaRapida => 'Quick lookup';

  @override
  String get cuentaAccesibilidad => 'Accessibility';

  @override
  String get cuentaCerrarSesion => 'Sign out';

  @override
  String get despensaTitulo => 'My Pantry';

  @override
  String get despensaProductos => 'Products';

  @override
  String get despensaSalvados => 'Saved';

  @override
  String get despensaPorVencer => 'Expiring';

  @override
  String get despensaProximosAVencer => 'EXPIRING SOON';

  @override
  String get despensaEnBuenEstado => 'IN GOOD SHAPE';

  @override
  String get despensaVaciaTitulo => 'Your pantry is empty';

  @override
  String get despensaVaciaDescripcion =>
      'Add what you have at home and we\'ll warn you before it spoils.';

  @override
  String get despensaErrorCarga => 'We couldn\'t load your pantry.';

  @override
  String get estadoVencido => 'Expired!';

  @override
  String get estadoHoy => 'Today';

  @override
  String get estadoManana => 'Tomorrow';

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
  String get lectorVenceHoy => 'expires today';

  @override
  String get lectorVenceManana => 'expires tomorrow';

  @override
  String lectorVenceEnDias(int dias) {
    return 'expires in $dias days';
  }

  @override
  String lectorVencidoHace(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'expired $dias days ago',
      one: 'expired 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get ajustesTitulo => 'Accessibility';

  @override
  String get ajustesDescripcion =>
      'Set the app up the way you need to use it. Everything is saved to your account, so it follows you from phone to web.';

  @override
  String get ajustesTamanoTexto => 'TEXT SIZE';

  @override
  String get ajustesTamanoTextoAyuda =>
      'The whole app grows with this setting, not just this screen.';

  @override
  String get ajustesEscalaNormal => 'Normal';

  @override
  String get ajustesEscalaGrande => 'Large';

  @override
  String get ajustesEscalaMasGrande => 'Larger';

  @override
  String get ajustesEscalaMaxima => 'Largest';

  @override
  String get ajustesContraste => 'CONTRAST';

  @override
  String get ajustesContrasteAyuda =>
      'Raises contrast to the maximum and strengthens borders. Helps with low vision and in direct sunlight.';

  @override
  String get ajustesAltoContraste => 'High contrast';

  @override
  String get ajustesMovimiento => 'MOTION';

  @override
  String get ajustesMovimientoAyuda =>
      'Turns off transitions. Useful if on-screen movement makes you dizzy or distracts you.';

  @override
  String get ajustesReducirMovimiento => 'Reduce motion';

  @override
  String get ajustesApariencia => 'APPEARANCE';

  @override
  String get ajustesAparienciaAyuda => 'Automatic follows your device setting.';

  @override
  String get ajustesTemaAutomatico => 'Automatic';

  @override
  String get ajustesTemaClaro => 'Light';

  @override
  String get ajustesTemaOscuro => 'Dark';

  @override
  String get ajustesIdioma => 'LANGUAGE';

  @override
  String get ajustesIdiomaAyuda => 'Automatic uses your device language.';

  @override
  String get ajustesIdiomaAutomatico => 'Automatic';

  @override
  String get ajustesLectorTitulo => 'Screen reader';

  @override
  String get ajustesLectorAyuda =>
      'The app is ready for TalkBack and VoiceOver: every product is announced with its name, amount and how long it has left. You turn it on from your device settings, not from here.';

  @override
  String alertaDescartar(String producto) {
    return 'Dismiss alert for $producto';
  }

  @override
  String get alertasVaciasTitulo => 'All under control';

  @override
  String get alertasVaciasDescripcion =>
      'Nothing in your pantry is close to expiring. We\'ll let you know as soon as something is.';

  @override
  String get alertasErrorCarga => 'We couldn\'t load your alerts.';

  @override
  String get compartidaTitulo => 'Shared pantry';

  @override
  String get compartidaIntro =>
      'Share one pantry with your family: products, alerts and recipes are the same for everyone.';

  @override
  String get compartidaCrear => 'Create pantry';

  @override
  String get compartidaCrearAyuda =>
      'Generates a code so your family can join your pantry.';

  @override
  String get compartidaUnirme => 'Join with a code';

  @override
  String get compartidaUnirmeAyuda =>
      'You already have a 6-character code from your family.';

  @override
  String get compartidaNotaUnaSola =>
      'You can only be in one pantry at a time: your own or a shared one.';

  @override
  String get compartidaEresAdmin => 'You are the administrator of this pantry.';

  @override
  String compartidaAdministradaPor(String nombre) {
    return 'Managed by $nombre.';
  }

  @override
  String get compartidaOtroMiembro => 'another member';

  @override
  String get compartidaCodigoRotulo => 'INVITATION CODE';

  @override
  String get compartidaCopiar => 'Copy';

  @override
  String get compartidaCodigoCopiado => 'Code copied';

  @override
  String compartidaMiembros(int cantidad) {
    return 'MEMBERS ($cantidad)';
  }

  @override
  String get compartidaSalir => 'Leave the pantry';

  @override
  String get compartidaSalirCeder => 'Leave and hand over management';

  @override
  String get compartidaEliminar => 'Delete pantry';

  @override
  String get compartidaCrearTitulo => 'Create family pantry';

  @override
  String get compartidaCrearDescripcion =>
      'Give it a name. Then you share the code with your family.';

  @override
  String get compartidaNombreDefecto => 'Family pantry';

  @override
  String get compartidaNombrePlaceholder => 'Pantry name';

  @override
  String get compartidaAccionCrear => 'Create';

  @override
  String get compartidaUnirmeTitulo => 'Join a pantry';

  @override
  String get compartidaUnirmeDescripcion =>
      'Enter the 6-character code you were given.';

  @override
  String get compartidaAccionUnirme => 'Join';

  @override
  String get compartidaSinCodigo => 'There is no pantry with that code.';

  @override
  String get compartidaMigrarTitulo => 'Move your products';

  @override
  String compartidaMigrarDescripcion(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other:
          'You have $cantidad products in your own pantry. Move them to the shared one? If not, they stay where they are.',
      one:
          'You have 1 product in your own pantry. Move it to the shared one? If not, it stays where it is.',
    );
    return '$_temp0';
  }

  @override
  String get compartidaMigrar => 'Move';

  @override
  String get compartidaNoMigrar => 'Don’t move';

  @override
  String get compartidaEliminarDescripcion =>
      'Everyone goes back to their own pantry and the shared products move to yours. This cannot be undone.';

  @override
  String get compartidaEliminarAccion => 'Delete';

  @override
  String get compartidaExpulsarTitulo => 'Remove member';

  @override
  String compartidaExpulsarDescripcion(String nombre) {
    return '$nombre goes back to their own pantry and stops seeing this one.';
  }

  @override
  String get compartidaSalirDescripcion =>
      'You go back to your own pantry. The products you added stay in the shared one.';

  @override
  String get compartidaSalirAccion => 'Leave';

  @override
  String get compartidaNuevoAdminTitulo => 'Who manages the pantry?';

  @override
  String get compartidaNuevoAdminDescripcion =>
      'Whoever you pick can add and remove members, and delete the pantry.';

  @override
  String get compartidaContinuar => 'Continue';

  @override
  String compartidaCederDescripcion(String nombre) {
    return '$nombre becomes the administrator and you go back to your own pantry. The products you added stay in the shared one.';
  }

  @override
  String get compartidaCreada => 'Pantry created';

  @override
  String get compartidaTeUniste => 'You joined the pantry';

  @override
  String get compartidaSaliste => 'You left the pantry';

  @override
  String compartidaSalisteConAdmin(String nombre) {
    return 'You left the pantry. $nombre manages it now.';
  }

  @override
  String get compartidaEliminada => 'Pantry deleted';

  @override
  String compartidaMiembroSalio(String nombre) {
    return '$nombre left the pantry';
  }

  @override
  String get perfilUsuario => 'User';

  @override
  String perfilSalvados(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad foods saved',
      one: '1 food saved',
    );
    return '$_temp0';
  }

  @override
  String get perfilNutricional => 'Nutrition profile';

  @override
  String get perfilNutricionalAyuda => 'Tailors recipes to your preferences';

  @override
  String get perfilListaCompras => 'SHOPPING LIST';

  @override
  String get perfilComprados => 'BOUGHT';

  @override
  String get perfilLimpiarComprados => 'Clear bought';

  @override
  String get perfilLimpiar => 'Clear';

  @override
  String get perfilLimpiarPregunta => 'Remove every product marked as bought?';

  @override
  String get perfilListaVaciaTitulo => 'Your shopping list is empty';

  @override
  String get perfilListaVaciaDescripcion =>
      'Products you use up or remove will show up here.';

  @override
  String perfilMarcarComprado(String nombre) {
    return 'Mark $nombre as bought';
  }

  @override
  String perfilConsumido(String fecha) {
    return 'Used: $fecha';
  }

  @override
  String perfilVencido(String fecha) {
    return 'Expired: $fecha';
  }

  @override
  String get perfilErrorLista => 'We couldn\'t load your shopping list.';

  @override
  String get recetasRotulo => 'RECIPE ENGINE';

  @override
  String get recetasTitulo => 'Zero Waste';

  @override
  String get recetasBuscar => 'Type an ingredient or dish and press search';

  @override
  String get recetasGenerando => 'The AI is preparing more recipes…';

  @override
  String get recetasSugeridas => 'SUGGESTED RECIPES';

  @override
  String get recetasMenorTiempo => 'Quickest';

  @override
  String get recetasOrdenarMenorTiempo => 'Sort by shortest time';

  @override
  String get recetasPriorizando => 'Prioritising urgent ingredients';

  @override
  String get recetasSinProductos => 'Nothing in your pantry';

  @override
  String get recetasSinUrgentes => 'Nothing urgent in your pantry';

  @override
  String get recetasErrorCarga => 'We couldn\'t load recipes';

  @override
  String get recetasSinResultados => 'No results';

  @override
  String recetasSinResultadosDescripcion(String busqueda) {
    return 'No recipe matches \"$busqueda\".';
  }

  @override
  String get recetasSinSugerenciasTitulo => 'No suggestions yet';

  @override
  String get recetasSinSugerenciasDescripcion =>
      'Add products to your pantry and we will suggest recipes that use them.';

  @override
  String get recetasBuscarDeNuevo => 'Search again';

  @override
  String get recetasCocinarTitulo => 'What did you use up?';

  @override
  String get recetasCocinarDescripcion =>
      'What you tick leaves your pantry and counts towards your saved food. Untick whatever you still have.';

  @override
  String get recetasSinCoincidencias =>
      'None of your products match this recipe.';

  @override
  String get recetasConfirmar => 'Confirm';

  @override
  String recetasSalvados(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad products saved. Enjoy!',
      one: '1 product saved. Enjoy!',
    );
    return '$_temp0';
  }

  @override
  String get agregarRotulo => 'ADD FOOD';

  @override
  String get agregarTitulo => 'Hybrid Entry';

  @override
  String get agregarEscanear => 'Scan';

  @override
  String get agregarManual => 'Manual';

  @override
  String get agregarApuntaCodigo => 'Point at the barcode';

  @override
  String get agregarTocaCamara => 'Tap to open the camera';

  @override
  String get agregarBuscando => 'Looking up the product…';

  @override
  String agregarUltimoCodigo(String codigo) {
    return 'Last code: $codigo';
  }

  @override
  String get agregarNoEncontrado => 'Product not found. Add it manually.';

  @override
  String get agregarSinConexion =>
      'No connection. We couldn\'t look up the code.';

  @override
  String agregarGuardado(String nombre) {
    return '$nombre added to the pantry.';
  }

  @override
  String get agregarNombre => 'Name';

  @override
  String get agregarNombreProducto => 'Product name';

  @override
  String get agregarNombreEjemplo => 'e.g. Greek yoghurt';

  @override
  String get agregarCategoria => 'Pick a category';

  @override
  String get agregarElegirCategoria => 'Choose category';

  @override
  String get agregarCantidad => 'Amount';

  @override
  String get agregarUnidad => 'Unit';

  @override
  String get agregarFecha => 'Expiry date';

  @override
  String get agregarElegirFecha => 'Pick a date';

  @override
  String get agregarFechaRecomendada =>
      'This is the recommended expiry date for this product';

  @override
  String get agregarGuardar => 'Save product';

  @override
  String get agregarFaltanCampos => 'Fill in name and date.';

  @override
  String get agregarNombreVacio => 'The name cannot be empty.';

  @override
  String get agregarConfirmar => 'CONFIRM PRODUCT';

  @override
  String get agregarAgregarADespensa => 'Add to my pantry';
}
