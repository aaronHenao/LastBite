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

  @override
  String get accionDeshacer => 'Undo';

  @override
  String get cuentaAyuda => 'Help';

  @override
  String get accesoListaCompras => 'Shopping list';

  @override
  String get accesoCompartida => 'Shared';

  @override
  String get accesoBuscar => 'Search';

  @override
  String get ayudaTitulo => 'Help';

  @override
  String get ayudaDescripcion =>
      'How to use LastBite and answers to the most common questions.';

  @override
  String get ayudaAbrir => 'Open help';

  @override
  String get ayudaPrimerosPasos => 'GETTING STARTED';

  @override
  String get ayudaPaso1 =>
      'Add what you have at home: scan the barcode or type it in.';

  @override
  String get ayudaPaso2 =>
      'Check your pantry: the products that expire first stay at the top.';

  @override
  String get ayudaPaso3 =>
      'Cook with the suggested recipes and mark what you used as consumed to count food saved.';

  @override
  String get ayudaPreguntas => 'FREQUENTLY ASKED QUESTIONS';

  @override
  String get ayudaSeccionDespensa => 'Pantry';

  @override
  String get ayudaSeccionAgregar => 'Adding products';

  @override
  String get ayudaSeccionRecetas => 'Recipes';

  @override
  String get ayudaSeccionAlertas => 'Alerts';

  @override
  String get ayudaSeccionCompartir => 'Shared pantry and shopping list';

  @override
  String get ayudaSeccionCuenta => 'Search, account and settings';

  @override
  String get ayudaDespensaP1 => 'How do I mark a product as used?';

  @override
  String get ayudaDespensaR1 =>
      'Tap it in the pantry and choose “Mark as consumed”. It counts toward your food saved and this month\'s savings. If you make a mistake, tap “Undo” in the message at the bottom.';

  @override
  String get ayudaDespensaP2 => 'What do the days on each product mean?';

  @override
  String get ayudaDespensaR2 =>
      'They are the days left before it expires. “Expiring soon” groups the ones that expire in 3 days or less; expired ones are marked in red.';

  @override
  String get ayudaDespensaP3 => 'How are savings calculated?';

  @override
  String get ayudaDespensaR3 =>
      'It\'s an estimate: what you consumed before it expired, multiplied by an average price for its category.';

  @override
  String get ayudaAgregarP1 => 'What if the barcode isn\'t found?';

  @override
  String get ayudaAgregarR1 =>
      'LastBite switches to manual entry. Type the name, choose the category and save.';

  @override
  String get ayudaAgregarP2 => 'Who picks the expiration date?';

  @override
  String get ayudaAgregarR2 =>
      'The app suggests one based on the product category. Change it before saving if the package says otherwise.';

  @override
  String get ayudaRecetasP1 => 'What does each recipe\'s percentage mean?';

  @override
  String get ayudaRecetasR1 =>
      'It\'s the share of ingredients you already have. Basics (salt, pepper, oil and water) count as available. In the details, each ingredient says “You have”, “Basic” or “Missing”.';

  @override
  String get ayudaRecetasP2 =>
      'Why don\'t recipes change when my pantry changes?';

  @override
  String get ayudaRecetasR2 =>
      'So you don\'t lose the one you were looking at. When your pantry changes, a notice appears with an “Update recipes” button.';

  @override
  String get ayudaRecetasP3 => 'Why do they take a while to appear?';

  @override
  String get ayudaRecetasR3 =>
      'An AI creates them from your pantry, which can take a few seconds. The first one shows up as soon as it\'s ready.';

  @override
  String get ayudaRecetasP4 => 'What happens when I tap “I cooked it”?';

  @override
  String get ayudaRecetasR4 =>
      'You choose which products ran out and they are marked as consumed. You can undo it from the message.';

  @override
  String get ayudaAlertasP1 => 'When does an alert appear?';

  @override
  String get ayudaAlertasR1 =>
      'When a product is about to expire or has expired. Alerts stay saved until you delete them.';

  @override
  String get ayudaAlertasP2 => 'I\'m not getting notifications';

  @override
  String get ayudaAlertasR2 =>
      'Check that LastBite has notification permission in your phone settings.';

  @override
  String get ayudaCompartirP1 => 'How do I share the pantry with my family?';

  @override
  String get ayudaCompartirR1 =>
      'Tap “Shared” in the pantry and create a pantry. Give the code to whoever you want to add: they tap “Join with a code” and type it.';

  @override
  String get ayudaCompartirP2 => 'Where is the shopping list?';

  @override
  String get ayudaCompartirR2 =>
      'In “Shopping list”, at the top of the pantry. When you consume or delete a product, LastBite offers to add it.';

  @override
  String get ayudaCuentaP1 => 'How do I search for a product?';

  @override
  String get ayudaCuentaR1 =>
      'Tap “Search” in the pantry. You don\'t need the exact name: word order, accents and a typo don\'t matter.';

  @override
  String get ayudaCuentaP2 =>
      'How do I change the text size, theme or language?';

  @override
  String get ayudaCuentaR2 =>
      'In your account menu, “Accessibility”. You can also reset everything to the defaults there.';

  @override
  String despensaSalvado(String nombre) {
    return 'You saved $nombre.';
  }

  @override
  String despensaSalvadoYEnLista(String nombre) {
    return 'You saved $nombre. It\'s on your shopping list.';
  }

  @override
  String despensaEliminado(String nombre) {
    return 'You removed $nombre from the pantry.';
  }

  @override
  String despensaEliminadoYEnLista(String nombre) {
    return 'You removed $nombre from the pantry. It\'s on your shopping list.';
  }

  @override
  String get recetasBuscando =>
      'Looking for recipes with what you have. This can take a few seconds.';

  @override
  String get recetasDespensaCambio =>
      'Your pantry changed. These recipes stay until you choose to update them.';

  @override
  String get recetasActualizar => 'Update recipes';

  @override
  String recetasFaltan(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad missing',
      one: '1 missing',
    );
    return '$_temp0';
  }

  @override
  String recetasTienesDeTotal(int disponibles, int total) {
    return 'You have $disponibles of $total ingredients';
  }

  @override
  String get recetasIngredienteTienes => 'You have';

  @override
  String get recetasIngredienteBasico => 'Basic';

  @override
  String get recetasIngredienteFalta => 'Missing';

  @override
  String get recetasBasicosNota =>
      '“Basic” means salt, pepper, oil or water: we assume you have them at home.';

  @override
  String get recetasIngredientes => 'INGREDIENTS';

  @override
  String get recetasPreparacion => 'PREPARATION';

  @override
  String agregarGuardadoVence(String nombre, int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$nombre is in your pantry. It expires in $dias days.',
      one: '$nombre is in your pantry. It expires tomorrow.',
      zero: '$nombre is in your pantry. It expires today.',
    );
    return '$_temp0';
  }

  @override
  String get ajustesRestablecer => 'Reset settings';

  @override
  String get ajustesRestablecerAyuda =>
      'Returns text size, contrast, motion, theme and language to their defaults. Your products, lists and alerts are not touched.';

  @override
  String get ajustesRestablecerPregunta => 'Reset settings?';

  @override
  String get ajustesRestablecerAccion => 'Reset';

  @override
  String get ajustesRestablecidos => 'Settings are back to their defaults.';

  @override
  String consultaSinResultados(String busqueda) {
    return 'We couldn\'t find “$busqueda”';
  }

  @override
  String get consultaSinResultadosDescripcion =>
      'Try another word. You don\'t need the exact name or accents.';

  @override
  String get despensaConsumir => 'Mark as consumed';

  @override
  String get despensaConsumirAyuda => 'Counts toward your food saved';

  @override
  String get despensaEliminar => 'Delete';

  @override
  String get despensaEliminarAyuda => 'Doesn\'t count toward food saved';

  @override
  String get despensaListaPregunta => 'Add to shopping list?';

  @override
  String despensaListaDescripcion(String nombre) {
    return 'Add $nombre to your list for your next shopping trip.';
  }

  @override
  String get despensaListaNo => 'No, thanks';

  @override
  String get despensaListaSi => 'Add';

  @override
  String get recetasYaLaCocine => 'I cooked it';

  @override
  String get categoriaVerdura => 'Vegetables';

  @override
  String get categoriaFruta => 'Fruit';

  @override
  String get categoriaHierba => 'Herbs';

  @override
  String get categoriaCarne => 'Meat';

  @override
  String get categoriaPollo => 'Chicken';

  @override
  String get categoriaPescado => 'Fish';

  @override
  String get categoriaHuevo => 'Eggs';

  @override
  String get categoriaLeche => 'Milk';

  @override
  String get categoriaYogur => 'Yogurt';

  @override
  String get categoriaQueso => 'Cheese';

  @override
  String get categoriaMantequilla => 'Butter';

  @override
  String get categoriaPan => 'Bread';

  @override
  String get categoriaEmbutido => 'Cold cuts';

  @override
  String get categoriaJugo => 'Juice';

  @override
  String get categoriaGrano => 'Grains';

  @override
  String get categoriaConserva => 'Canned food';

  @override
  String get categoriaCereal => 'Cereal';

  @override
  String get categoriaOtro => 'Other';

  @override
  String get unidadUnidad => 'unit';

  @override
  String get unidadCucharada => 'tbsp';

  @override
  String get unidadTaza => 'cup';

  @override
  String cantidadUnidades(String numero, num cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'units',
      one: 'unit',
    );
    return '$numero $_temp0';
  }

  @override
  String cantidadTazas(String numero, num cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'cups',
      one: 'cup',
    );
    return '$numero $_temp0';
  }

  @override
  String cantidadCucharadas(String numero) {
    return '$numero tbsp';
  }

  @override
  String get temaAutomaticoAccion => 'Theme: automatic. Tap to change.';

  @override
  String get temaClaroAccion => 'Theme: light. Tap to change.';

  @override
  String get temaOscuroAccion => 'Theme: dark. Tap to change.';

  @override
  String get cuentaPerfilAyuda => 'See your profile and shopping list';

  @override
  String get cuentaCompartidaAyuda => 'Create one or join with a code';

  @override
  String get cuentaConsultaRapidaAyuda => 'Search the products in your pantry';

  @override
  String get cuentaAccesibilidadAyuda => 'Text size, contrast and motion';

  @override
  String despensaAhorroMes(DateTime mes) {
    final intl.DateFormat mesDateFormat = intl.DateFormat.MMMM(localeName);
    final String mesString = mesDateFormat.format(mes);

    return 'Estimated savings for $mesString';
  }

  @override
  String get despensaAhorroVacio =>
      'Use a product before it expires to start adding up';

  @override
  String get despensaAhorroNota => 'Estimated from average prices per category';

  @override
  String get agregarCantidadEjemplo => 'E.g. 1';

  @override
  String get alertasRotulo => 'ALERTS';

  @override
  String get alertasTitulo => 'Expiry and recipes';

  @override
  String get alertasNota => 'Alerts stay until you decide to delete them.';

  @override
  String get alertasBorrarTodo => 'Delete all';

  @override
  String get alertasBorrarPregunta => 'Delete all alerts';

  @override
  String get alertasBorrarDescripcion =>
      'This deletes the current alerts. New ones are created when needed.';

  @override
  String get alertasEliminadas => 'Alerts deleted';

  @override
  String alertaDescartada(String producto) {
    return 'Alert for $producto dismissed';
  }

  @override
  String get alertaDescartarCorto => 'Dismiss';

  @override
  String get alertaDescartarTooltip => 'Dismiss alert';

  @override
  String get alertaRecetaSugerida => 'SUGGESTED RECIPE';

  @override
  String get alertaTituloAviso5 => 'First notice';

  @override
  String get alertaTituloAviso3 => 'Critical notice';

  @override
  String get alertaTituloAviso1 => 'Last day';

  @override
  String get alertaTituloVencido => 'Expired product';

  @override
  String alertaMensajeAviso5(String producto) {
    return 'Your $producto expires in 5 days. Keep an eye on it.';
  }

  @override
  String alertaMensajeAviso3(String producto) {
    return 'Your $producto expires in 3 days. Here\'s a recipe idea.';
  }

  @override
  String alertaMensajeAviso1(String producto) {
    return 'Your $producto expires tomorrow. Use it today.';
  }

  @override
  String alertaMensajeVencido(String producto) {
    return 'Your $producto has expired. Remove it from the pantry.';
  }

  @override
  String get notifCanal => 'Expiry alerts';

  @override
  String get notifCanalDescripcion =>
      'Notifications about products about to expire';

  @override
  String notifVenceManana(String producto) {
    return '$producto expires tomorrow';
  }

  @override
  String get notifVenceMananaConReceta =>
      'Use it today: tap to see a suggested recipe.';

  @override
  String get notifVenceMananaSinReceta =>
      'It\'s your last day to use it. Don\'t let it go to waste!';

  @override
  String notifVenceEn3(String producto) {
    return '$producto expires in 3 days';
  }

  @override
  String get notifVenceEn3Cuerpo => 'Plan a recipe before it\'s too late.';

  @override
  String notifVencido(String producto) {
    return '$producto has expired';
  }

  @override
  String get notifVencidoCuerpo => 'Remove it from your pantry.';

  @override
  String get authBienvenido => 'Welcome to';

  @override
  String get authCorreo => 'Email';

  @override
  String get authCorreoEjemplo => 'you@email.com';

  @override
  String get authContrasena => 'Password';

  @override
  String get authConfirmarContrasena => 'Confirm password';

  @override
  String get authIniciarSesion => 'Sign in';

  @override
  String get authOContinua => 'or continue with';

  @override
  String get authContinuarGoogle => 'Continue with Google';

  @override
  String get authSinCuentaPregunta => 'Don\'t have an account? ';

  @override
  String get authRegistrate => 'Sign up';

  @override
  String get authCreaCuenta => 'Create your account';

  @override
  String get authCreaCuentaAyuda => 'Start saving your food';

  @override
  String get authNombre => 'Name';

  @override
  String get authNombreEjemplo => 'Your name';

  @override
  String get authCrearCuenta => 'Create account';

  @override
  String get authCompletaCampos => 'Fill in all the fields.';

  @override
  String get authContrasenasNoCoinciden => 'The passwords don\'t match.';

  @override
  String get authContrasenaCorta =>
      'The password must be at least 6 characters long.';

  @override
  String get authCredencialesIncorrectas => 'Wrong email or password.';

  @override
  String get authCorreoRegistrado => 'This email is already registered.';

  @override
  String get authCorreoInvalido => 'The email isn\'t valid.';

  @override
  String get authSinCuenta => 'There\'s no account with this email.';

  @override
  String get authContrasenaIncorrecta => 'Wrong password.';

  @override
  String get authDemasiadosIntentos => 'Too many attempts. Wait a moment.';

  @override
  String get authSinConexion => 'No internet connection.';

  @override
  String get authVentanaBloqueada =>
      'The browser blocked the Google window. Allow pop-ups.';

  @override
  String authErrorDesconocido(String codigo) {
    return 'We couldn\'t complete sign-in. Code: $codigo';
  }

  @override
  String get compartidaMiembroSinNombre => 'Member';

  @override
  String compartidaTu(String nombre) {
    return '$nombre (you)';
  }

  @override
  String get compartidaAdmin => 'ADMIN';

  @override
  String get compartidaEliminarMiembro => 'Remove member';

  @override
  String compartidaErrorLargoCodigo(int largo) {
    return 'The code must have $largo characters.';
  }

  @override
  String get compartidaErrorCodigoInexistente =>
      'There\'s no pantry with that code.';

  @override
  String get compartidaErrorNoExiste => 'This pantry no longer exists.';

  @override
  String get compartidaErrorUnicoMiembro =>
      'You\'re the only member. Delete the pantry instead of leaving.';

  @override
  String get compartidaErrorElegirAdmin =>
      'Choose who takes over as admin before leaving.';

  @override
  String get compartidaErrorAdminInvalido =>
      'The new admin must be another member of the pantry.';

  @override
  String get compartidaErrorSoloAdminMiembros =>
      'Only the admin can remove members.';

  @override
  String get compartidaErrorAdminNoSeElimina =>
      'The admin can\'t remove themselves.';

  @override
  String get compartidaErrorSoloAdminEliminar =>
      'Only the admin can delete the pantry.';

  @override
  String get compartidaErrorYaPerteneces =>
      'You already belong to a shared pantry. Leave it first.';

  @override
  String get compartidaErrorSinCodigo =>
      'We couldn\'t create a code. Try again.';

  @override
  String get compartidaErrorSinSesion => 'You need to sign in.';

  @override
  String get compartidaErrorDesconocido => 'Something went wrong. Try again.';

  @override
  String get escanerPermisoTitulo => 'Camera permission needed';

  @override
  String get escanerPermisoDescripcion =>
      'We need camera access to scan the barcode.';

  @override
  String get escanerEntendido => 'Got it';

  @override
  String get escanerTitulo => 'Scan product';

  @override
  String get escanerApagarFlash => 'Turn off flash';

  @override
  String get escanerEncenderFlash => 'Turn on flash';

  @override
  String get escanerCambiarCamara => 'Switch camera';

  @override
  String get escanerPermisoDenegado => 'Camera permission denied';

  @override
  String get escanerNoInicia => 'The camera couldn\'t start';

  @override
  String get escanerAlinea => 'Line up the barcode inside the frame';

  @override
  String get nutricionalRotulo => 'NUTRITION PROFILE';

  @override
  String get nutricionalTitulo => 'Recipe preferences';

  @override
  String get nutricionalTipoUsuario => 'User type';

  @override
  String get nutricionalSinPreferencia => 'No preference';

  @override
  String get nutricionalDeportista => 'Athlete';

  @override
  String get nutricionalPlan => 'Nutrition plan';

  @override
  String get nutricionalObjetivo => 'Nutrition goal';

  @override
  String get nutricionalSinObjetivo => 'No specific goal';

  @override
  String get nutricionalPerderPeso => 'Lose weight';

  @override
  String get nutricionalMantenerPeso => 'Maintain weight';

  @override
  String get nutricionalGanarPeso => 'Gain weight';

  @override
  String get nutricionalAlimentacion => 'Diet';

  @override
  String get nutricionalOmnivora => 'Omnivore';

  @override
  String get nutricionalVegetariana => 'Vegetarian';

  @override
  String get nutricionalVegana => 'Vegan';

  @override
  String get nutricionalOtra => 'Other';

  @override
  String get nutricionalRestricciones => 'Foods you don\'t eat';

  @override
  String get nutricionalRestriccionesEjemplo => 'E.g. pork, seafood';

  @override
  String get nutricionalAlergias => 'Allergies or intolerances';

  @override
  String get nutricionalAlergiasEjemplo => 'E.g. peanuts, gluten';

  @override
  String get nutricionalGuardar => 'Save profile';

  @override
  String get nutricionalErrorGuardar =>
      'We couldn\'t save the profile. Check your connection and try again.';

  @override
  String get nutricionalGuardado => 'Nutrition profile saved';

  @override
  String get consultaTitulo => 'Quick search';

  @override
  String get consultaBuscar => 'Search product';

  @override
  String get consultaErrorCarga => 'We couldn\'t load your products.';

  @override
  String get consultaVacia =>
      'Your pantry is empty. Add products to look them up here.';

  @override
  String get consultaCantidad => 'Quantity';

  @override
  String get consultaFechaCaducidad => 'Expiration date';

  @override
  String get consultaEstado => 'Status';

  @override
  String get consultaEstadoVencido => 'Expired';

  @override
  String get consultaEstadoPorVencer => 'Expiring soon';

  @override
  String get consultaEstadoVigente => 'Good';

  @override
  String get consultaHistorialTitulo => 'Recent searches';

  @override
  String get consultaHistorialLimpiar => 'Clear history';

  @override
  String get recetasErrorFaltaClave =>
      'The AI key is missing. Run the app with --dart-define-from-file=env.json.';

  @override
  String get recetasErrorRespuestaVacia =>
      'The AI sent an empty answer. Try again.';

  @override
  String get recetasErrorTiempo => 'The AI took too long to answer. Try again.';

  @override
  String get recetasErrorSinConexion =>
      'Can\'t reach the recipe service. Check your internet.';

  @override
  String get recetasErrorClave => 'The AI key isn\'t valid or has expired.';

  @override
  String get recetasErrorCreditos => 'The AI service has run out of credits.';

  @override
  String get recetasErrorModeloInexistente =>
      'The configured AI model doesn\'t exist.';

  @override
  String get recetasErrorModeloRetirado =>
      'NVIDIA retired the configured AI model.';

  @override
  String get recetasErrorDemasiadas =>
      'Too many requests to the AI. Wait a moment.';

  @override
  String get recetasErrorServicio =>
      'The AI service isn\'t available right now.';

  @override
  String get recetasErrorSinRecetas =>
      'The AI didn\'t return valid recipes. Try again.';

  @override
  String get recetasErrorFormato =>
      'The AI answered in an unexpected format. Try again.';

  @override
  String get recetasErrorIncompleta =>
      'The AI\'s answer arrived incomplete. Try again.';

  @override
  String get recetasErrorDetalle =>
      'This recipe\'s details are no longer available. Update the suggestions to get a new one.';

  @override
  String get recetasErrorSinIngredientes =>
      'There are no valid ingredients to search recipes with.';

  @override
  String get recetasErrorDesconocido => 'We couldn\'t create recipes.';

  @override
  String get recetasErrorDetalleCarga =>
      'We couldn\'t load the preparation. Check your connection.';

  @override
  String get recetasOrdenDesayuno => 'It\'s early: breakfast recipes first';

  @override
  String get recetasOrdenPrincipal => 'Main dishes first';

  @override
  String get recetasOrdenSemana => 'It\'s a weekday: quickest first';

  @override
  String get recetasOrdenFinde =>
      'It\'s the weekend: time for something more elaborate';

  @override
  String recetasMatch(int porcentaje) {
    return '$porcentaje% match';
  }

  @override
  String recetasLikes(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad likes',
      one: '1 like',
    );
    return '$_temp0';
  }

  @override
  String get accionCerrar => 'Close';
}
