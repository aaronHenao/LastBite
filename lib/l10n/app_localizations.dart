import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n? of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appNombre.
  ///
  /// In es, this message translates to:
  /// **'LastBite'**
  String get appNombre;

  /// No description provided for @navDespensa.
  ///
  /// In es, this message translates to:
  /// **'Despensa'**
  String get navDespensa;

  /// No description provided for @navAgregar.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get navAgregar;

  /// No description provided for @navRecetas.
  ///
  /// In es, this message translates to:
  /// **'Recetas'**
  String get navRecetas;

  /// No description provided for @navAlertas.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get navAlertas;

  /// No description provided for @accionVolver.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get accionVolver;

  /// No description provided for @accionReintentar.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get accionReintentar;

  /// No description provided for @accionCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get accionCancelar;

  /// No description provided for @accionAgregarProducto.
  ///
  /// In es, this message translates to:
  /// **'Agregar producto'**
  String get accionAgregarProducto;

  /// No description provided for @accionLimpiarBusqueda.
  ///
  /// In es, this message translates to:
  /// **'Limpiar búsqueda'**
  String get accionLimpiarBusqueda;

  /// No description provided for @accionDetalleTecnico.
  ///
  /// In es, this message translates to:
  /// **'Detalle técnico'**
  String get accionDetalleTecnico;

  /// No description provided for @cuentaMenu.
  ///
  /// In es, this message translates to:
  /// **'Menú de cuenta'**
  String get cuentaMenu;

  /// No description provided for @cuentaMia.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta'**
  String get cuentaMia;

  /// No description provided for @cuentaPerfil.
  ///
  /// In es, this message translates to:
  /// **'Perfil y lista de compras'**
  String get cuentaPerfil;

  /// No description provided for @cuentaCompartida.
  ///
  /// In es, this message translates to:
  /// **'Despensa compartida'**
  String get cuentaCompartida;

  /// No description provided for @cuentaConsultaRapida.
  ///
  /// In es, this message translates to:
  /// **'Consulta rápida'**
  String get cuentaConsultaRapida;

  /// No description provided for @cuentaAccesibilidad.
  ///
  /// In es, this message translates to:
  /// **'Accesibilidad'**
  String get cuentaAccesibilidad;

  /// No description provided for @cuentaCerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get cuentaCerrarSesion;

  /// No description provided for @despensaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Mi Despensa'**
  String get despensaTitulo;

  /// No description provided for @despensaProductos.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get despensaProductos;

  /// No description provided for @despensaSalvados.
  ///
  /// In es, this message translates to:
  /// **'Salvados'**
  String get despensaSalvados;

  /// No description provided for @despensaPorVencer.
  ///
  /// In es, this message translates to:
  /// **'Por vencer'**
  String get despensaPorVencer;

  /// No description provided for @despensaProximosAVencer.
  ///
  /// In es, this message translates to:
  /// **'PRÓXIMOS A VENCER'**
  String get despensaProximosAVencer;

  /// No description provided for @despensaEnBuenEstado.
  ///
  /// In es, this message translates to:
  /// **'EN BUEN ESTADO'**
  String get despensaEnBuenEstado;

  /// No description provided for @despensaVaciaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tu despensa está vacía'**
  String get despensaVaciaTitulo;

  /// No description provided for @despensaVaciaDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Agregá lo que tengas en casa y te avisamos antes de que se venza.'**
  String get despensaVaciaDescripcion;

  /// No description provided for @despensaErrorCarga.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu despensa.'**
  String get despensaErrorCarga;

  /// No description provided for @estadoVencido.
  ///
  /// In es, this message translates to:
  /// **'¡Vencido!'**
  String get estadoVencido;

  /// No description provided for @estadoHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get estadoHoy;

  /// No description provided for @estadoManana.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get estadoManana;

  /// No description provided for @estadoDias.
  ///
  /// In es, this message translates to:
  /// **'{dias}d'**
  String estadoDias(int dias);

  /// Como anuncia un producto el lector de pantalla
  ///
  /// In es, this message translates to:
  /// **'{nombre}, {cantidad}, {categoria}, {estado}'**
  String lectorProducto(
    String nombre,
    String cantidad,
    String categoria,
    String estado,
  );

  /// No description provided for @lectorVenceHoy.
  ///
  /// In es, this message translates to:
  /// **'vence hoy'**
  String get lectorVenceHoy;

  /// No description provided for @lectorVenceManana.
  ///
  /// In es, this message translates to:
  /// **'vence mañana'**
  String get lectorVenceManana;

  /// No description provided for @lectorVenceEnDias.
  ///
  /// In es, this message translates to:
  /// **'vence en {dias} días'**
  String lectorVenceEnDias(int dias);

  /// No description provided for @lectorVencidoHace.
  ///
  /// In es, this message translates to:
  /// **'{dias, plural, one{vencido hace 1 día} other{vencido hace {dias} días}}'**
  String lectorVencidoHace(int dias);

  /// No description provided for @ajustesTitulo.
  ///
  /// In es, this message translates to:
  /// **'Accesibilidad'**
  String get ajustesTitulo;

  /// No description provided for @ajustesDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Ajustá la app a cómo la necesitás usar. Todo se guarda en tu cuenta, así que te acompaña al teléfono y a la web.'**
  String get ajustesDescripcion;

  /// No description provided for @ajustesTamanoTexto.
  ///
  /// In es, this message translates to:
  /// **'TAMAÑO DEL TEXTO'**
  String get ajustesTamanoTexto;

  /// No description provided for @ajustesTamanoTextoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Toda la app crece con este ajuste, no solo esta pantalla.'**
  String get ajustesTamanoTextoAyuda;

  /// No description provided for @ajustesEscalaNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get ajustesEscalaNormal;

  /// No description provided for @ajustesEscalaGrande.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get ajustesEscalaGrande;

  /// No description provided for @ajustesEscalaMasGrande.
  ///
  /// In es, this message translates to:
  /// **'Más grande'**
  String get ajustesEscalaMasGrande;

  /// No description provided for @ajustesEscalaMaxima.
  ///
  /// In es, this message translates to:
  /// **'Máximo'**
  String get ajustesEscalaMaxima;

  /// No description provided for @ajustesContraste.
  ///
  /// In es, this message translates to:
  /// **'CONTRASTE'**
  String get ajustesContraste;

  /// No description provided for @ajustesContrasteAyuda.
  ///
  /// In es, this message translates to:
  /// **'Sube el contraste al máximo y refuerza los bordes. Ayuda con baja visión y a plena luz del sol.'**
  String get ajustesContrasteAyuda;

  /// No description provided for @ajustesAltoContraste.
  ///
  /// In es, this message translates to:
  /// **'Alto contraste'**
  String get ajustesAltoContraste;

  /// No description provided for @ajustesMovimiento.
  ///
  /// In es, this message translates to:
  /// **'MOVIMIENTO'**
  String get ajustesMovimiento;

  /// No description provided for @ajustesMovimientoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Apaga las transiciones. Útil si el movimiento en pantalla te marea o te distrae.'**
  String get ajustesMovimientoAyuda;

  /// No description provided for @ajustesReducirMovimiento.
  ///
  /// In es, this message translates to:
  /// **'Reducir movimiento'**
  String get ajustesReducirMovimiento;

  /// No description provided for @ajustesApariencia.
  ///
  /// In es, this message translates to:
  /// **'APARIENCIA'**
  String get ajustesApariencia;

  /// No description provided for @ajustesAparienciaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Automático sigue el ajuste de tu dispositivo.'**
  String get ajustesAparienciaAyuda;

  /// No description provided for @ajustesTemaAutomatico.
  ///
  /// In es, this message translates to:
  /// **'Automático'**
  String get ajustesTemaAutomatico;

  /// No description provided for @ajustesTemaClaro.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get ajustesTemaClaro;

  /// No description provided for @ajustesTemaOscuro.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get ajustesTemaOscuro;

  /// No description provided for @ajustesIdioma.
  ///
  /// In es, this message translates to:
  /// **'IDIOMA'**
  String get ajustesIdioma;

  /// No description provided for @ajustesIdiomaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Automático usa el idioma de tu dispositivo.'**
  String get ajustesIdiomaAyuda;

  /// No description provided for @ajustesIdiomaAutomatico.
  ///
  /// In es, this message translates to:
  /// **'Automático'**
  String get ajustesIdiomaAutomatico;

  /// No description provided for @ajustesLectorTitulo.
  ///
  /// In es, this message translates to:
  /// **'Lector de pantalla'**
  String get ajustesLectorTitulo;

  /// No description provided for @ajustesLectorAyuda.
  ///
  /// In es, this message translates to:
  /// **'La app está preparada para TalkBack y VoiceOver: cada producto se anuncia con su nombre, su cantidad y cuánto le queda. Se activa desde los ajustes de tu dispositivo, no desde aquí.'**
  String get ajustesLectorAyuda;

  /// No description provided for @alertaDescartar.
  ///
  /// In es, this message translates to:
  /// **'Descartar alerta de {producto}'**
  String alertaDescartar(String producto);

  /// No description provided for @alertasVaciasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Todo bajo control'**
  String get alertasVaciasTitulo;

  /// No description provided for @alertasVaciasDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Ningún producto de tu despensa está por vencerse. Te avisamos apenas alguno lo esté.'**
  String get alertasVaciasDescripcion;

  /// No description provided for @alertasErrorCarga.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus alertas.'**
  String get alertasErrorCarga;

  /// No description provided for @compartidaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Despensa compartida'**
  String get compartidaTitulo;

  /// No description provided for @compartidaIntro.
  ///
  /// In es, this message translates to:
  /// **'Comparte una sola despensa con tu familia: los productos, las alertas y las recetas son los mismos para todos.'**
  String get compartidaIntro;

  /// No description provided for @compartidaCrear.
  ///
  /// In es, this message translates to:
  /// **'Crear despensa'**
  String get compartidaCrear;

  /// No description provided for @compartidaCrearAyuda.
  ///
  /// In es, this message translates to:
  /// **'Genera un código para que tu familia se una a tu despensa.'**
  String get compartidaCrearAyuda;

  /// No description provided for @compartidaUnirme.
  ///
  /// In es, this message translates to:
  /// **'Unirme con código'**
  String get compartidaUnirme;

  /// No description provided for @compartidaUnirmeAyuda.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes un código de 6 caracteres de tu familia.'**
  String get compartidaUnirmeAyuda;

  /// No description provided for @compartidaNotaUnaSola.
  ///
  /// In es, this message translates to:
  /// **'Solo puedes estar en una despensa a la vez: la tuya personal o una compartida.'**
  String get compartidaNotaUnaSola;

  /// No description provided for @compartidaEresAdmin.
  ///
  /// In es, this message translates to:
  /// **'Eres el administrador de esta despensa.'**
  String get compartidaEresAdmin;

  /// No description provided for @compartidaAdministradaPor.
  ///
  /// In es, this message translates to:
  /// **'Administrada por {nombre}.'**
  String compartidaAdministradaPor(String nombre);

  /// No description provided for @compartidaOtroMiembro.
  ///
  /// In es, this message translates to:
  /// **'otro miembro'**
  String get compartidaOtroMiembro;

  /// No description provided for @compartidaCodigoRotulo.
  ///
  /// In es, this message translates to:
  /// **'CÓDIGO DE INVITACIÓN'**
  String get compartidaCodigoRotulo;

  /// No description provided for @compartidaCopiar.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get compartidaCopiar;

  /// No description provided for @compartidaCodigoCopiado.
  ///
  /// In es, this message translates to:
  /// **'Código copiado'**
  String get compartidaCodigoCopiado;

  /// No description provided for @compartidaMiembros.
  ///
  /// In es, this message translates to:
  /// **'MIEMBROS ({cantidad})'**
  String compartidaMiembros(int cantidad);

  /// No description provided for @compartidaSalir.
  ///
  /// In es, this message translates to:
  /// **'Salir de la despensa'**
  String get compartidaSalir;

  /// No description provided for @compartidaSalirCeder.
  ///
  /// In es, this message translates to:
  /// **'Salir y ceder la administración'**
  String get compartidaSalirCeder;

  /// No description provided for @compartidaEliminar.
  ///
  /// In es, this message translates to:
  /// **'Eliminar despensa'**
  String get compartidaEliminar;

  /// No description provided for @compartidaCrearTitulo.
  ///
  /// In es, this message translates to:
  /// **'Crear despensa familiar'**
  String get compartidaCrearTitulo;

  /// No description provided for @compartidaCrearDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Ponle un nombre. Después compartes el código con tu familia.'**
  String get compartidaCrearDescripcion;

  /// No description provided for @compartidaNombreDefecto.
  ///
  /// In es, this message translates to:
  /// **'Despensa familiar'**
  String get compartidaNombreDefecto;

  /// No description provided for @compartidaNombrePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la despensa'**
  String get compartidaNombrePlaceholder;

  /// No description provided for @compartidaAccionCrear.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get compartidaAccionCrear;

  /// No description provided for @compartidaUnirmeTitulo.
  ///
  /// In es, this message translates to:
  /// **'Unirme a una despensa'**
  String get compartidaUnirmeTitulo;

  /// No description provided for @compartidaUnirmeDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Escribe el código de 6 caracteres que te compartieron.'**
  String get compartidaUnirmeDescripcion;

  /// No description provided for @compartidaAccionUnirme.
  ///
  /// In es, this message translates to:
  /// **'Unirme'**
  String get compartidaAccionUnirme;

  /// No description provided for @compartidaSinCodigo.
  ///
  /// In es, this message translates to:
  /// **'No existe una despensa con ese código.'**
  String get compartidaSinCodigo;

  /// No description provided for @compartidaMigrarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Migrar tus productos'**
  String get compartidaMigrarTitulo;

  /// No description provided for @compartidaMigrarDescripcion.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, one{Tienes 1 producto en tu despensa personal. ¿Querés moverlo a la despensa compartida? Si no, se queda en tu despensa personal.} other{Tienes {cantidad} productos en tu despensa personal. ¿Querés moverlos a la despensa compartida? Si no, se quedan en tu despensa personal.}}'**
  String compartidaMigrarDescripcion(int cantidad);

  /// No description provided for @compartidaMigrar.
  ///
  /// In es, this message translates to:
  /// **'Migrar'**
  String get compartidaMigrar;

  /// No description provided for @compartidaNoMigrar.
  ///
  /// In es, this message translates to:
  /// **'No migrar'**
  String get compartidaNoMigrar;

  /// No description provided for @compartidaEliminarDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Todos los miembros volverán a su despensa personal y los productos compartidos pasarán a la tuya. Esta acción no se puede deshacer.'**
  String get compartidaEliminarDescripcion;

  /// No description provided for @compartidaEliminarAccion.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get compartidaEliminarAccion;

  /// No description provided for @compartidaExpulsarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eliminar miembro'**
  String get compartidaExpulsarTitulo;

  /// No description provided for @compartidaExpulsarDescripcion.
  ///
  /// In es, this message translates to:
  /// **'{nombre} volverá a su despensa personal y dejará de ver esta despensa.'**
  String compartidaExpulsarDescripcion(String nombre);

  /// No description provided for @compartidaSalirDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Volverás a tu despensa personal. Los productos que agregaste se quedan en la despensa compartida.'**
  String get compartidaSalirDescripcion;

  /// No description provided for @compartidaSalirAccion.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get compartidaSalirAccion;

  /// No description provided for @compartidaNuevoAdminTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Quién administra la despensa?'**
  String get compartidaNuevoAdminTitulo;

  /// No description provided for @compartidaNuevoAdminDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Quien elijas va a poder agregar y sacar miembros, y eliminar la despensa.'**
  String get compartidaNuevoAdminDescripcion;

  /// No description provided for @compartidaContinuar.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get compartidaContinuar;

  /// No description provided for @compartidaCederDescripcion.
  ///
  /// In es, this message translates to:
  /// **'{nombre} pasa a ser el administrador y vos volvés a tu despensa personal. Los productos que agregaste se quedan en la compartida.'**
  String compartidaCederDescripcion(String nombre);

  /// No description provided for @compartidaCreada.
  ///
  /// In es, this message translates to:
  /// **'Despensa creada'**
  String get compartidaCreada;

  /// No description provided for @compartidaTeUniste.
  ///
  /// In es, this message translates to:
  /// **'Te uniste a la despensa'**
  String get compartidaTeUniste;

  /// No description provided for @compartidaSaliste.
  ///
  /// In es, this message translates to:
  /// **'Saliste de la despensa'**
  String get compartidaSaliste;

  /// No description provided for @compartidaSalisteConAdmin.
  ///
  /// In es, this message translates to:
  /// **'Saliste de la despensa. Ahora administra {nombre}.'**
  String compartidaSalisteConAdmin(String nombre);

  /// No description provided for @compartidaEliminada.
  ///
  /// In es, this message translates to:
  /// **'Despensa eliminada'**
  String get compartidaEliminada;

  /// No description provided for @compartidaMiembroSalio.
  ///
  /// In es, this message translates to:
  /// **'{nombre} salió de la despensa'**
  String compartidaMiembroSalio(String nombre);

  /// No description provided for @perfilUsuario.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get perfilUsuario;

  /// No description provided for @perfilSalvados.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, one{1 alimento salvado} other{{cantidad} alimentos salvados}}'**
  String perfilSalvados(int cantidad);

  /// No description provided for @perfilNutricional.
  ///
  /// In es, this message translates to:
  /// **'Perfil nutricional'**
  String get perfilNutricional;

  /// No description provided for @perfilNutricionalAyuda.
  ///
  /// In es, this message translates to:
  /// **'Adapta las recetas a tus preferencias'**
  String get perfilNutricionalAyuda;

  /// No description provided for @perfilListaCompras.
  ///
  /// In es, this message translates to:
  /// **'LISTA DE COMPRAS'**
  String get perfilListaCompras;

  /// No description provided for @perfilComprados.
  ///
  /// In es, this message translates to:
  /// **'COMPRADOS'**
  String get perfilComprados;

  /// No description provided for @perfilLimpiarComprados.
  ///
  /// In es, this message translates to:
  /// **'Limpiar comprados'**
  String get perfilLimpiarComprados;

  /// No description provided for @perfilLimpiar.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get perfilLimpiar;

  /// No description provided for @perfilLimpiarPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar todos los productos marcados como comprados?'**
  String get perfilLimpiarPregunta;

  /// No description provided for @perfilListaVaciaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tu lista de compras está vacía'**
  String get perfilListaVaciaTitulo;

  /// No description provided for @perfilListaVaciaDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Los productos que consumas o elimines aparecerán aquí.'**
  String get perfilListaVaciaDescripcion;

  /// No description provided for @perfilMarcarComprado.
  ///
  /// In es, this message translates to:
  /// **'Marcar {nombre} como comprado'**
  String perfilMarcarComprado(String nombre);

  /// No description provided for @perfilConsumido.
  ///
  /// In es, this message translates to:
  /// **'Consumido: {fecha}'**
  String perfilConsumido(String fecha);

  /// No description provided for @perfilVencido.
  ///
  /// In es, this message translates to:
  /// **'Venció: {fecha}'**
  String perfilVencido(String fecha);

  /// No description provided for @perfilErrorLista.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu lista de compras.'**
  String get perfilErrorLista;

  /// No description provided for @recetasRotulo.
  ///
  /// In es, this message translates to:
  /// **'MOTOR DE RECETAS'**
  String get recetasRotulo;

  /// No description provided for @recetasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Residuo Cero'**
  String get recetasTitulo;

  /// No description provided for @recetasBuscar.
  ///
  /// In es, this message translates to:
  /// **'Escribe un ingrediente o plato y pulsa buscar'**
  String get recetasBuscar;

  /// No description provided for @recetasGenerando.
  ///
  /// In es, this message translates to:
  /// **'La IA está preparando más recetas…'**
  String get recetasGenerando;

  /// No description provided for @recetasSugeridas.
  ///
  /// In es, this message translates to:
  /// **'RECETAS SUGERIDAS'**
  String get recetasSugeridas;

  /// No description provided for @recetasMenorTiempo.
  ///
  /// In es, this message translates to:
  /// **'Menor tiempo'**
  String get recetasMenorTiempo;

  /// No description provided for @recetasOrdenarMenorTiempo.
  ///
  /// In es, this message translates to:
  /// **'Ordenar por menor tiempo'**
  String get recetasOrdenarMenorTiempo;

  /// No description provided for @recetasPriorizando.
  ///
  /// In es, this message translates to:
  /// **'Priorizando ingredientes urgentes'**
  String get recetasPriorizando;

  /// No description provided for @recetasSinProductos.
  ///
  /// In es, this message translates to:
  /// **'No hay productos en tu despensa'**
  String get recetasSinProductos;

  /// No description provided for @recetasSinUrgentes.
  ///
  /// In es, this message translates to:
  /// **'No hay productos urgentes en tu despensa'**
  String get recetasSinUrgentes;

  /// No description provided for @recetasErrorCarga.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar recetas'**
  String get recetasErrorCarga;

  /// No description provided for @recetasSinResultados.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get recetasSinResultados;

  /// No description provided for @recetasSinResultadosDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Ninguna receta coincide con \"{busqueda}\".'**
  String recetasSinResultadosDescripcion(String busqueda);

  /// No description provided for @recetasSinSugerenciasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay sugerencias'**
  String get recetasSinSugerenciasTitulo;

  /// No description provided for @recetasSinSugerenciasDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Agregá productos a tu despensa y te proponemos recetas que los aprovechen.'**
  String get recetasSinSugerenciasDescripcion;

  /// No description provided for @recetasBuscarDeNuevo.
  ///
  /// In es, this message translates to:
  /// **'Buscar de nuevo'**
  String get recetasBuscarDeNuevo;

  /// No description provided for @recetasCocinarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Qué usaste por completo?'**
  String get recetasCocinarTitulo;

  /// No description provided for @recetasCocinarDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Lo que marques sale de tu despensa y suma a tus alimentos salvados. Destildá lo que todavía te quede.'**
  String get recetasCocinarDescripcion;

  /// No description provided for @recetasSinCoincidencias.
  ///
  /// In es, this message translates to:
  /// **'Ninguno de tus productos coincide con esta receta.'**
  String get recetasSinCoincidencias;

  /// No description provided for @recetasConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get recetasConfirmar;

  /// No description provided for @recetasSalvados.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, one{1 producto salvado. ¡Buen provecho!} other{{cantidad} productos salvados. ¡Buen provecho!}}'**
  String recetasSalvados(int cantidad);

  /// No description provided for @agregarRotulo.
  ///
  /// In es, this message translates to:
  /// **'AGREGAR ALIMENTO'**
  String get agregarRotulo;

  /// No description provided for @agregarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Entrada Híbrida'**
  String get agregarTitulo;

  /// No description provided for @agregarEscanear.
  ///
  /// In es, this message translates to:
  /// **'Escanear'**
  String get agregarEscanear;

  /// No description provided for @agregarManual.
  ///
  /// In es, this message translates to:
  /// **'Manual'**
  String get agregarManual;

  /// No description provided for @agregarApuntaCodigo.
  ///
  /// In es, this message translates to:
  /// **'Apunta al código de barras'**
  String get agregarApuntaCodigo;

  /// No description provided for @agregarTocaCamara.
  ///
  /// In es, this message translates to:
  /// **'Tocá para abrir la cámara'**
  String get agregarTocaCamara;

  /// No description provided for @agregarBuscando.
  ///
  /// In es, this message translates to:
  /// **'Buscando el producto…'**
  String get agregarBuscando;

  /// No description provided for @agregarUltimoCodigo.
  ///
  /// In es, this message translates to:
  /// **'Último código: {codigo}'**
  String agregarUltimoCodigo(String codigo);

  /// No description provided for @agregarNoEncontrado.
  ///
  /// In es, this message translates to:
  /// **'Producto no encontrado. Ingrésalo manualmente.'**
  String get agregarNoEncontrado;

  /// No description provided for @agregarSinConexion.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. No pudimos consultar el código.'**
  String get agregarSinConexion;

  /// No description provided for @agregarGuardado.
  ///
  /// In es, this message translates to:
  /// **'{nombre} agregado a la despensa.'**
  String agregarGuardado(String nombre);

  /// No description provided for @agregarNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get agregarNombre;

  /// No description provided for @agregarNombreProducto.
  ///
  /// In es, this message translates to:
  /// **'Nombre del producto'**
  String get agregarNombreProducto;

  /// No description provided for @agregarNombreEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Ej: Yogur griego'**
  String get agregarNombreEjemplo;

  /// No description provided for @agregarCategoria.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una categoría'**
  String get agregarCategoria;

  /// No description provided for @agregarElegirCategoria.
  ///
  /// In es, this message translates to:
  /// **'Elige categoría'**
  String get agregarElegirCategoria;

  /// No description provided for @agregarCantidad.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get agregarCantidad;

  /// No description provided for @agregarUnidad.
  ///
  /// In es, this message translates to:
  /// **'Unidad'**
  String get agregarUnidad;

  /// No description provided for @agregarFecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha de vencimiento'**
  String get agregarFecha;

  /// No description provided for @agregarElegirFecha.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una fecha'**
  String get agregarElegirFecha;

  /// No description provided for @agregarFechaRecomendada.
  ///
  /// In es, this message translates to:
  /// **'Esta es la fecha de caducidad recomendada para este producto'**
  String get agregarFechaRecomendada;

  /// No description provided for @agregarGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar producto'**
  String get agregarGuardar;

  /// No description provided for @agregarFaltanCampos.
  ///
  /// In es, this message translates to:
  /// **'Completa nombre y fecha.'**
  String get agregarFaltanCampos;

  /// No description provided for @agregarNombreVacio.
  ///
  /// In es, this message translates to:
  /// **'El nombre no puede estar vacío.'**
  String get agregarNombreVacio;

  /// No description provided for @agregarConfirmar.
  ///
  /// In es, this message translates to:
  /// **'CONFIRMAR PRODUCTO'**
  String get agregarConfirmar;

  /// No description provided for @agregarAgregarADespensa.
  ///
  /// In es, this message translates to:
  /// **'Agregar a mi despensa'**
  String get agregarAgregarADespensa;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'es':
      return L10nEs();
    case 'pt':
      return L10nPt();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
