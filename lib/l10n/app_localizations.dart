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

  /// No description provided for @accionDeshacer.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get accionDeshacer;

  /// No description provided for @cuentaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get cuentaAyuda;

  /// No description provided for @accesoListaCompras.
  ///
  /// In es, this message translates to:
  /// **'Lista de compras'**
  String get accesoListaCompras;

  /// No description provided for @accesoCompartida.
  ///
  /// In es, this message translates to:
  /// **'Compartida'**
  String get accesoCompartida;

  /// No description provided for @accesoBuscar.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get accesoBuscar;

  /// No description provided for @ayudaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get ayudaTitulo;

  /// No description provided for @ayudaDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Cómo usar LastBite y respuestas a las dudas más comunes.'**
  String get ayudaDescripcion;

  /// No description provided for @ayudaAbrir.
  ///
  /// In es, this message translates to:
  /// **'Abrir ayuda'**
  String get ayudaAbrir;

  /// No description provided for @ayudaPrimerosPasos.
  ///
  /// In es, this message translates to:
  /// **'PRIMEROS PASOS'**
  String get ayudaPrimerosPasos;

  /// No description provided for @ayudaPaso1.
  ///
  /// In es, this message translates to:
  /// **'Agrega lo que tienes en casa: escanea el código de barras o escríbelo a mano.'**
  String get ayudaPaso1;

  /// No description provided for @ayudaPaso2.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu despensa: arriba quedan los productos que vencen primero.'**
  String get ayudaPaso2;

  /// No description provided for @ayudaPaso3.
  ///
  /// In es, this message translates to:
  /// **'Cocina con las recetas sugeridas y marca lo que usaste como consumido para sumar alimentos salvados.'**
  String get ayudaPaso3;

  /// No description provided for @ayudaPreguntas.
  ///
  /// In es, this message translates to:
  /// **'PREGUNTAS FRECUENTES'**
  String get ayudaPreguntas;

  /// No description provided for @ayudaSeccionDespensa.
  ///
  /// In es, this message translates to:
  /// **'Despensa'**
  String get ayudaSeccionDespensa;

  /// No description provided for @ayudaSeccionAgregar.
  ///
  /// In es, this message translates to:
  /// **'Agregar productos'**
  String get ayudaSeccionAgregar;

  /// No description provided for @ayudaSeccionRecetas.
  ///
  /// In es, this message translates to:
  /// **'Recetas'**
  String get ayudaSeccionRecetas;

  /// No description provided for @ayudaSeccionAlertas.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get ayudaSeccionAlertas;

  /// No description provided for @ayudaSeccionCompartir.
  ///
  /// In es, this message translates to:
  /// **'Despensa compartida y lista de compras'**
  String get ayudaSeccionCompartir;

  /// No description provided for @ayudaSeccionCuenta.
  ///
  /// In es, this message translates to:
  /// **'Búsqueda, cuenta y ajustes'**
  String get ayudaSeccionCuenta;

  /// No description provided for @ayudaDespensaP1.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo marco que usé un producto?'**
  String get ayudaDespensaP1;

  /// No description provided for @ayudaDespensaR1.
  ///
  /// In es, this message translates to:
  /// **'Tócalo en la despensa y elige «Marcar como consumido». Suma a tus alimentos salvados y al ahorro del mes. Si te equivocas, toca «Deshacer» en el aviso que aparece abajo.'**
  String get ayudaDespensaR1;

  /// No description provided for @ayudaDespensaP2.
  ///
  /// In es, this message translates to:
  /// **'¿Qué significan los días de cada producto?'**
  String get ayudaDespensaP2;

  /// No description provided for @ayudaDespensaR2.
  ///
  /// In es, this message translates to:
  /// **'Son los días que le quedan antes de vencer. «Próximos a vencer» agrupa los que vencen en 3 días o menos; los vencidos se marcan en rojo.'**
  String get ayudaDespensaR2;

  /// No description provided for @ayudaDespensaP3.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo se calcula el ahorro?'**
  String get ayudaDespensaP3;

  /// No description provided for @ayudaDespensaR3.
  ///
  /// In es, this message translates to:
  /// **'Es un estimado: lo que consumiste antes de que se venciera, multiplicado por un precio promedio de su categoría.'**
  String get ayudaDespensaR3;

  /// No description provided for @ayudaAgregarP1.
  ///
  /// In es, this message translates to:
  /// **'¿Qué hago si el código de barras no aparece?'**
  String get ayudaAgregarP1;

  /// No description provided for @ayudaAgregarR1.
  ///
  /// In es, this message translates to:
  /// **'LastBite te pasa al ingreso manual. Escribe el nombre, elige la categoría y guarda.'**
  String get ayudaAgregarR1;

  /// No description provided for @ayudaAgregarP2.
  ///
  /// In es, this message translates to:
  /// **'¿Quién elige la fecha de vencimiento?'**
  String get ayudaAgregarP2;

  /// No description provided for @ayudaAgregarR2.
  ///
  /// In es, this message translates to:
  /// **'La app propone una según la categoría del producto. Cámbiala antes de guardar si el empaque dice otra.'**
  String get ayudaAgregarR2;

  /// No description provided for @ayudaRecetasP1.
  ///
  /// In es, this message translates to:
  /// **'¿Qué significa el porcentaje de cada receta?'**
  String get ayudaRecetasP1;

  /// No description provided for @ayudaRecetasR1.
  ///
  /// In es, this message translates to:
  /// **'Es la parte de los ingredientes que ya tienes. Los básicos (sal, pimienta, aceite y agua) cuentan como disponibles. En el detalle cada ingrediente dice «Tienes», «Básico» o «Falta».'**
  String get ayudaRecetasR1;

  /// No description provided for @ayudaRecetasP2.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué las recetas no cambian cuando cambio la despensa?'**
  String get ayudaRecetasP2;

  /// No description provided for @ayudaRecetasR2.
  ///
  /// In es, this message translates to:
  /// **'Para que no pierdas la que estabas mirando. Cuando tu despensa cambia aparece un aviso con el botón «Actualizar recetas».'**
  String get ayudaRecetasR2;

  /// No description provided for @ayudaRecetasP3.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué tardan en aparecer?'**
  String get ayudaRecetasP3;

  /// No description provided for @ayudaRecetasR3.
  ///
  /// In es, this message translates to:
  /// **'Las genera una IA a partir de tu despensa y puede tardar unos segundos. La primera aparece apenas está lista.'**
  String get ayudaRecetasR3;

  /// No description provided for @ayudaRecetasP4.
  ///
  /// In es, this message translates to:
  /// **'¿Qué pasa al tocar «Ya la cociné»?'**
  String get ayudaRecetasP4;

  /// No description provided for @ayudaRecetasR4.
  ///
  /// In es, this message translates to:
  /// **'Eliges qué productos se terminaron y se marcan como consumidos. Puedes deshacerlo desde el aviso.'**
  String get ayudaRecetasR4;

  /// No description provided for @ayudaAlertasP1.
  ///
  /// In es, this message translates to:
  /// **'¿Cuándo aparece una alerta?'**
  String get ayudaAlertasP1;

  /// No description provided for @ayudaAlertasR1.
  ///
  /// In es, this message translates to:
  /// **'Cuando un producto está por vencer o ya venció. Las alertas quedan guardadas hasta que las borres.'**
  String get ayudaAlertasR1;

  /// No description provided for @ayudaAlertasP2.
  ///
  /// In es, this message translates to:
  /// **'No me llegan las notificaciones'**
  String get ayudaAlertasP2;

  /// No description provided for @ayudaAlertasR2.
  ///
  /// In es, this message translates to:
  /// **'Revisa que LastBite tenga permiso de notificaciones en los ajustes de tu teléfono.'**
  String get ayudaAlertasR2;

  /// No description provided for @ayudaCompartirP1.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo comparto la despensa con mi familia?'**
  String get ayudaCompartirP1;

  /// No description provided for @ayudaCompartirR1.
  ///
  /// In es, this message translates to:
  /// **'Toca «Compartida» en la despensa y crea una despensa. Pasa el código a quien quieras sumar: esa persona toca «Unirme con código» y lo escribe.'**
  String get ayudaCompartirR1;

  /// No description provided for @ayudaCompartirP2.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde está la lista de compras?'**
  String get ayudaCompartirP2;

  /// No description provided for @ayudaCompartirR2.
  ///
  /// In es, this message translates to:
  /// **'En «Lista de compras», arriba en la despensa. Al consumir o eliminar un producto, LastBite te ofrece agregarlo.'**
  String get ayudaCompartirR2;

  /// No description provided for @ayudaCuentaP1.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo busco un producto?'**
  String get ayudaCuentaP1;

  /// No description provided for @ayudaCuentaR1.
  ///
  /// In es, this message translates to:
  /// **'Toca «Buscar» en la despensa. No hace falta escribir el nombre exacto: da igual el orden de las palabras, las tildes y un error de tipeo.'**
  String get ayudaCuentaR1;

  /// No description provided for @ayudaCuentaP2.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo cambio el tamaño del texto, el tema o el idioma?'**
  String get ayudaCuentaP2;

  /// No description provided for @ayudaCuentaR2.
  ///
  /// In es, this message translates to:
  /// **'En el menú de tu cuenta, «Accesibilidad». Ahí también puedes restablecer todo a como venía.'**
  String get ayudaCuentaR2;

  /// No description provided for @despensaSalvado.
  ///
  /// In es, this message translates to:
  /// **'Salvaste {nombre}.'**
  String despensaSalvado(String nombre);

  /// No description provided for @despensaSalvadoYEnLista.
  ///
  /// In es, this message translates to:
  /// **'Salvaste {nombre}. Quedó en tu lista de compras.'**
  String despensaSalvadoYEnLista(String nombre);

  /// No description provided for @despensaEliminado.
  ///
  /// In es, this message translates to:
  /// **'Quitaste {nombre} de la despensa.'**
  String despensaEliminado(String nombre);

  /// No description provided for @despensaEliminadoYEnLista.
  ///
  /// In es, this message translates to:
  /// **'Quitaste {nombre} de la despensa. Quedó en tu lista de compras.'**
  String despensaEliminadoYEnLista(String nombre);

  /// No description provided for @recetasBuscando.
  ///
  /// In es, this message translates to:
  /// **'Buscando recetas con lo que tienes. Puede tardar unos segundos.'**
  String get recetasBuscando;

  /// No description provided for @recetasDespensaCambio.
  ///
  /// In es, this message translates to:
  /// **'Tu despensa cambió. Estas recetas se quedan hasta que decidas actualizarlas.'**
  String get recetasDespensaCambio;

  /// No description provided for @recetasActualizar.
  ///
  /// In es, this message translates to:
  /// **'Actualizar recetas'**
  String get recetasActualizar;

  /// No description provided for @recetasFaltan.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, one{Falta 1} other{Faltan {cantidad}}}'**
  String recetasFaltan(int cantidad);

  /// No description provided for @recetasTienesDeTotal.
  ///
  /// In es, this message translates to:
  /// **'Tienes {disponibles} de {total} ingredientes'**
  String recetasTienesDeTotal(int disponibles, int total);

  /// No description provided for @recetasIngredienteTienes.
  ///
  /// In es, this message translates to:
  /// **'Tienes'**
  String get recetasIngredienteTienes;

  /// No description provided for @recetasIngredienteBasico.
  ///
  /// In es, this message translates to:
  /// **'Básico'**
  String get recetasIngredienteBasico;

  /// No description provided for @recetasIngredienteFalta.
  ///
  /// In es, this message translates to:
  /// **'Falta'**
  String get recetasIngredienteFalta;

  /// No description provided for @recetasBasicosNota.
  ///
  /// In es, this message translates to:
  /// **'«Básico» es sal, pimienta, aceite o agua: se asume que los tienes en casa.'**
  String get recetasBasicosNota;

  /// No description provided for @recetasIngredientes.
  ///
  /// In es, this message translates to:
  /// **'INGREDIENTES'**
  String get recetasIngredientes;

  /// No description provided for @recetasPreparacion.
  ///
  /// In es, this message translates to:
  /// **'PREPARACIÓN'**
  String get recetasPreparacion;

  /// No description provided for @agregarGuardadoVence.
  ///
  /// In es, this message translates to:
  /// **'{dias, plural, =0{{nombre} quedó en tu despensa. Vence hoy.} one{{nombre} quedó en tu despensa. Vence mañana.} other{{nombre} quedó en tu despensa. Vence en {dias} días.}}'**
  String agregarGuardadoVence(String nombre, int dias);

  /// No description provided for @ajustesRestablecer.
  ///
  /// In es, this message translates to:
  /// **'Restablecer ajustes'**
  String get ajustesRestablecer;

  /// No description provided for @ajustesRestablecerAyuda.
  ///
  /// In es, this message translates to:
  /// **'Vuelve el tamaño del texto, el contraste, el movimiento, el tema y el idioma a como venían. Tus productos, listas y alertas no se tocan.'**
  String get ajustesRestablecerAyuda;

  /// No description provided for @ajustesRestablecerPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Restablecer los ajustes?'**
  String get ajustesRestablecerPregunta;

  /// No description provided for @ajustesRestablecerAccion.
  ///
  /// In es, this message translates to:
  /// **'Restablecer'**
  String get ajustesRestablecerAccion;

  /// No description provided for @ajustesRestablecidos.
  ///
  /// In es, this message translates to:
  /// **'Los ajustes volvieron a como venían.'**
  String get ajustesRestablecidos;

  /// No description provided for @consultaSinResultados.
  ///
  /// In es, this message translates to:
  /// **'No encontramos «{busqueda}»'**
  String consultaSinResultados(String busqueda);

  /// No description provided for @consultaSinResultadosDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otra palabra. No hace falta escribir el nombre exacto ni poner tildes.'**
  String get consultaSinResultadosDescripcion;

  /// No description provided for @despensaConsumir.
  ///
  /// In es, this message translates to:
  /// **'Marcar como consumido'**
  String get despensaConsumir;

  /// No description provided for @despensaConsumirAyuda.
  ///
  /// In es, this message translates to:
  /// **'Suma a tus alimentos salvados'**
  String get despensaConsumirAyuda;

  /// No description provided for @despensaEliminar.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get despensaEliminar;

  /// No description provided for @despensaEliminarAyuda.
  ///
  /// In es, this message translates to:
  /// **'No suma a alimentos salvados'**
  String get despensaEliminarAyuda;

  /// No description provided for @despensaListaPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Añadir a lista de compras?'**
  String get despensaListaPregunta;

  /// No description provided for @despensaListaDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Agregar {nombre} a tu lista para la próxima compra.'**
  String despensaListaDescripcion(String nombre);

  /// No description provided for @despensaListaNo.
  ///
  /// In es, this message translates to:
  /// **'No, gracias'**
  String get despensaListaNo;

  /// No description provided for @despensaListaSi.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get despensaListaSi;

  /// No description provided for @recetasYaLaCocine.
  ///
  /// In es, this message translates to:
  /// **'Ya la cociné'**
  String get recetasYaLaCocine;

  /// No description provided for @categoriaVerdura.
  ///
  /// In es, this message translates to:
  /// **'Verdura'**
  String get categoriaVerdura;

  /// No description provided for @categoriaFruta.
  ///
  /// In es, this message translates to:
  /// **'Fruta'**
  String get categoriaFruta;

  /// No description provided for @categoriaHierba.
  ///
  /// In es, this message translates to:
  /// **'Hierba'**
  String get categoriaHierba;

  /// No description provided for @categoriaCarne.
  ///
  /// In es, this message translates to:
  /// **'Carne'**
  String get categoriaCarne;

  /// No description provided for @categoriaPollo.
  ///
  /// In es, this message translates to:
  /// **'Pollo'**
  String get categoriaPollo;

  /// No description provided for @categoriaPescado.
  ///
  /// In es, this message translates to:
  /// **'Pescado'**
  String get categoriaPescado;

  /// No description provided for @categoriaHuevo.
  ///
  /// In es, this message translates to:
  /// **'Huevo'**
  String get categoriaHuevo;

  /// No description provided for @categoriaLeche.
  ///
  /// In es, this message translates to:
  /// **'Leche'**
  String get categoriaLeche;

  /// No description provided for @categoriaYogur.
  ///
  /// In es, this message translates to:
  /// **'Yogur'**
  String get categoriaYogur;

  /// No description provided for @categoriaQueso.
  ///
  /// In es, this message translates to:
  /// **'Queso'**
  String get categoriaQueso;

  /// No description provided for @categoriaMantequilla.
  ///
  /// In es, this message translates to:
  /// **'Mantequilla'**
  String get categoriaMantequilla;

  /// No description provided for @categoriaPan.
  ///
  /// In es, this message translates to:
  /// **'Pan'**
  String get categoriaPan;

  /// No description provided for @categoriaEmbutido.
  ///
  /// In es, this message translates to:
  /// **'Embutido'**
  String get categoriaEmbutido;

  /// No description provided for @categoriaJugo.
  ///
  /// In es, this message translates to:
  /// **'Jugo'**
  String get categoriaJugo;

  /// No description provided for @categoriaGrano.
  ///
  /// In es, this message translates to:
  /// **'Grano'**
  String get categoriaGrano;

  /// No description provided for @categoriaConserva.
  ///
  /// In es, this message translates to:
  /// **'Conserva'**
  String get categoriaConserva;

  /// No description provided for @categoriaCereal.
  ///
  /// In es, this message translates to:
  /// **'Cereal'**
  String get categoriaCereal;

  /// No description provided for @categoriaOtro.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get categoriaOtro;

  /// No description provided for @unidadUnidad.
  ///
  /// In es, this message translates to:
  /// **'unidad'**
  String get unidadUnidad;

  /// No description provided for @unidadCucharada.
  ///
  /// In es, this message translates to:
  /// **'cda'**
  String get unidadCucharada;

  /// No description provided for @unidadTaza.
  ///
  /// In es, this message translates to:
  /// **'taza'**
  String get unidadTaza;

  /// No description provided for @cantidadUnidades.
  ///
  /// In es, this message translates to:
  /// **'{numero} {cantidad, plural, one{unidad} other{unidades}}'**
  String cantidadUnidades(String numero, num cantidad);

  /// No description provided for @cantidadTazas.
  ///
  /// In es, this message translates to:
  /// **'{numero} {cantidad, plural, one{taza} other{tazas}}'**
  String cantidadTazas(String numero, num cantidad);

  /// No description provided for @cantidadCucharadas.
  ///
  /// In es, this message translates to:
  /// **'{numero} cda'**
  String cantidadCucharadas(String numero);

  /// No description provided for @temaAutomaticoAccion.
  ///
  /// In es, this message translates to:
  /// **'Tema: automático. Toca para cambiar.'**
  String get temaAutomaticoAccion;

  /// No description provided for @temaClaroAccion.
  ///
  /// In es, this message translates to:
  /// **'Tema: claro. Toca para cambiar.'**
  String get temaClaroAccion;

  /// No description provided for @temaOscuroAccion.
  ///
  /// In es, this message translates to:
  /// **'Tema: oscuro. Toca para cambiar.'**
  String get temaOscuroAccion;

  /// No description provided for @cuentaPerfilAyuda.
  ///
  /// In es, this message translates to:
  /// **'Ver perfil y lista de compras'**
  String get cuentaPerfilAyuda;

  /// No description provided for @cuentaCompartidaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Crea una o únete con un código'**
  String get cuentaCompartidaAyuda;

  /// No description provided for @cuentaConsultaRapidaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Buscar productos de tu despensa'**
  String get cuentaConsultaRapidaAyuda;

  /// No description provided for @cuentaAccesibilidadAyuda.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de texto, contraste y movimiento'**
  String get cuentaAccesibilidadAyuda;

  /// No description provided for @despensaAhorroMes.
  ///
  /// In es, this message translates to:
  /// **'Ahorro estimado de {mes}'**
  String despensaAhorroMes(DateTime mes);

  /// No description provided for @despensaAhorroVacio.
  ///
  /// In es, this message translates to:
  /// **'Consume un producto antes de que venza para empezar a sumar'**
  String get despensaAhorroVacio;

  /// No description provided for @despensaAhorroNota.
  ///
  /// In es, this message translates to:
  /// **'Estimado según precios promedio por categoría'**
  String get despensaAhorroNota;

  /// No description provided for @agregarCantidadEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Ej: 1'**
  String get agregarCantidadEjemplo;

  /// No description provided for @alertasRotulo.
  ///
  /// In es, this message translates to:
  /// **'ALERTAS'**
  String get alertasRotulo;

  /// No description provided for @alertasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Caducidad y recetas'**
  String get alertasTitulo;

  /// No description provided for @alertasNota.
  ///
  /// In es, this message translates to:
  /// **'Las alertas se mantienen hasta que decidas borrarlas.'**
  String get alertasNota;

  /// No description provided for @alertasBorrarTodo.
  ///
  /// In es, this message translates to:
  /// **'Borrar todo'**
  String get alertasBorrarTodo;

  /// No description provided for @alertasBorrarPregunta.
  ///
  /// In es, this message translates to:
  /// **'Borrar todas las alertas'**
  String get alertasBorrarPregunta;

  /// No description provided for @alertasBorrarDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Esta acción elimina las alertas actuales. Las nuevas se generan cuando corresponda.'**
  String get alertasBorrarDescripcion;

  /// No description provided for @alertasEliminadas.
  ///
  /// In es, this message translates to:
  /// **'Alertas eliminadas'**
  String get alertasEliminadas;

  /// No description provided for @alertaDescartada.
  ///
  /// In es, this message translates to:
  /// **'Alerta de {producto} descartada'**
  String alertaDescartada(String producto);

  /// No description provided for @alertaDescartarCorto.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get alertaDescartarCorto;

  /// No description provided for @alertaDescartarTooltip.
  ///
  /// In es, this message translates to:
  /// **'Descartar alerta'**
  String get alertaDescartarTooltip;

  /// No description provided for @alertaRecetaSugerida.
  ///
  /// In es, this message translates to:
  /// **'RECETA SUGERIDA'**
  String get alertaRecetaSugerida;

  /// No description provided for @alertaTituloAviso5.
  ///
  /// In es, this message translates to:
  /// **'Primer aviso'**
  String get alertaTituloAviso5;

  /// No description provided for @alertaTituloAviso3.
  ///
  /// In es, this message translates to:
  /// **'Aviso crítico'**
  String get alertaTituloAviso3;

  /// No description provided for @alertaTituloAviso1.
  ///
  /// In es, this message translates to:
  /// **'Último día'**
  String get alertaTituloAviso1;

  /// No description provided for @alertaTituloVencido.
  ///
  /// In es, this message translates to:
  /// **'Producto vencido'**
  String get alertaTituloVencido;

  /// No description provided for @alertaMensajeAviso5.
  ///
  /// In es, this message translates to:
  /// **'Tu {producto} vence en 5 días. Ten cuidado.'**
  String alertaMensajeAviso5(String producto);

  /// No description provided for @alertaMensajeAviso3.
  ///
  /// In es, this message translates to:
  /// **'Tu {producto} vence en 3 días. Te sugerimos una receta.'**
  String alertaMensajeAviso3(String producto);

  /// No description provided for @alertaMensajeAviso1.
  ///
  /// In es, this message translates to:
  /// **'Tu {producto} vence mañana. Aprovéchalo hoy.'**
  String alertaMensajeAviso1(String producto);

  /// No description provided for @alertaMensajeVencido.
  ///
  /// In es, this message translates to:
  /// **'Tu {producto} ya venció. Retíralo de la despensa.'**
  String alertaMensajeVencido(String producto);

  /// No description provided for @notifCanal.
  ///
  /// In es, this message translates to:
  /// **'Alertas de vencimiento'**
  String get notifCanal;

  /// No description provided for @notifCanalDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones de productos próximos a vencer'**
  String get notifCanalDescripcion;

  /// No description provided for @notifVenceManana.
  ///
  /// In es, this message translates to:
  /// **'{producto} vence mañana'**
  String notifVenceManana(String producto);

  /// No description provided for @notifVenceMananaConReceta.
  ///
  /// In es, this message translates to:
  /// **'Aprovéchalo hoy: toca para ver una receta sugerida.'**
  String get notifVenceMananaConReceta;

  /// No description provided for @notifVenceMananaSinReceta.
  ///
  /// In es, this message translates to:
  /// **'Es tu último día para usarlo. ¡No lo desperdicies!'**
  String get notifVenceMananaSinReceta;

  /// No description provided for @notifVenceEn3.
  ///
  /// In es, this message translates to:
  /// **'{producto} vence en 3 días'**
  String notifVenceEn3(String producto);

  /// No description provided for @notifVenceEn3Cuerpo.
  ///
  /// In es, this message translates to:
  /// **'Planifica una receta antes de que sea tarde.'**
  String get notifVenceEn3Cuerpo;

  /// No description provided for @notifVencido.
  ///
  /// In es, this message translates to:
  /// **'{producto} ya venció'**
  String notifVencido(String producto);

  /// No description provided for @notifVencidoCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Retíralo de tu despensa.'**
  String get notifVencidoCuerpo;

  /// No description provided for @authBienvenido.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a'**
  String get authBienvenido;

  /// No description provided for @authCorreo.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authCorreo;

  /// No description provided for @authCorreoEjemplo.
  ///
  /// In es, this message translates to:
  /// **'tu@correo.com'**
  String get authCorreoEjemplo;

  /// No description provided for @authContrasena.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authContrasena;

  /// No description provided for @authConfirmarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get authConfirmarContrasena;

  /// No description provided for @authIniciarSesion.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authIniciarSesion;

  /// No description provided for @authOContinua.
  ///
  /// In es, this message translates to:
  /// **'o continúa con'**
  String get authOContinua;

  /// No description provided for @authContinuarGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get authContinuarGoogle;

  /// No description provided for @authSinCuentaPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get authSinCuentaPregunta;

  /// No description provided for @authRegistrate.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get authRegistrate;

  /// No description provided for @authCreaCuenta.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get authCreaCuenta;

  /// No description provided for @authCreaCuentaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Empieza a salvar tus alimentos'**
  String get authCreaCuentaAyuda;

  /// No description provided for @authNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get authNombre;

  /// No description provided for @authNombreEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get authNombreEjemplo;

  /// No description provided for @authCrearCuenta.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authCrearCuenta;

  /// No description provided for @authCompletaCampos.
  ///
  /// In es, this message translates to:
  /// **'Completa todos los campos.'**
  String get authCompletaCampos;

  /// No description provided for @authContrasenasNoCoinciden.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden.'**
  String get authContrasenasNoCoinciden;

  /// No description provided for @authContrasenaCorta.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres.'**
  String get authContrasenaCorta;

  /// No description provided for @authCredencialesIncorrectas.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos.'**
  String get authCredencialesIncorrectas;

  /// No description provided for @authCorreoRegistrado.
  ///
  /// In es, this message translates to:
  /// **'Este correo ya está registrado.'**
  String get authCorreoRegistrado;

  /// No description provided for @authCorreoInvalido.
  ///
  /// In es, this message translates to:
  /// **'El correo no es válido.'**
  String get authCorreoInvalido;

  /// No description provided for @authSinCuenta.
  ///
  /// In es, this message translates to:
  /// **'No existe una cuenta con este correo.'**
  String get authSinCuenta;

  /// No description provided for @authContrasenaIncorrecta.
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta.'**
  String get authContrasenaIncorrecta;

  /// No description provided for @authDemasiadosIntentos.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera un momento.'**
  String get authDemasiadosIntentos;

  /// No description provided for @authSinConexion.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a internet.'**
  String get authSinConexion;

  /// No description provided for @authVentanaBloqueada.
  ///
  /// In es, this message translates to:
  /// **'El navegador bloqueó la ventana de Google. Permite ventanas emergentes.'**
  String get authVentanaBloqueada;

  /// No description provided for @authErrorDesconocido.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar el acceso. Código: {codigo}'**
  String authErrorDesconocido(String codigo);

  /// No description provided for @compartidaMiembroSinNombre.
  ///
  /// In es, this message translates to:
  /// **'Miembro'**
  String get compartidaMiembroSinNombre;

  /// No description provided for @compartidaTu.
  ///
  /// In es, this message translates to:
  /// **'{nombre} (tú)'**
  String compartidaTu(String nombre);

  /// No description provided for @compartidaAdmin.
  ///
  /// In es, this message translates to:
  /// **'ADMIN'**
  String get compartidaAdmin;

  /// No description provided for @compartidaEliminarMiembro.
  ///
  /// In es, this message translates to:
  /// **'Eliminar miembro'**
  String get compartidaEliminarMiembro;

  /// No description provided for @compartidaErrorLargoCodigo.
  ///
  /// In es, this message translates to:
  /// **'El código debe tener {largo} caracteres.'**
  String compartidaErrorLargoCodigo(int largo);

  /// No description provided for @compartidaErrorCodigoInexistente.
  ///
  /// In es, this message translates to:
  /// **'No existe una despensa con ese código.'**
  String get compartidaErrorCodigoInexistente;

  /// No description provided for @compartidaErrorNoExiste.
  ///
  /// In es, this message translates to:
  /// **'La despensa ya no existe.'**
  String get compartidaErrorNoExiste;

  /// No description provided for @compartidaErrorUnicoMiembro.
  ///
  /// In es, this message translates to:
  /// **'Eres el único miembro. Elimina la despensa en vez de salir.'**
  String get compartidaErrorUnicoMiembro;

  /// No description provided for @compartidaErrorElegirAdmin.
  ///
  /// In es, this message translates to:
  /// **'Elige a quién le dejas la administración antes de salir.'**
  String get compartidaErrorElegirAdmin;

  /// No description provided for @compartidaErrorAdminInvalido.
  ///
  /// In es, this message translates to:
  /// **'El nuevo administrador debe ser otro miembro de la despensa.'**
  String get compartidaErrorAdminInvalido;

  /// No description provided for @compartidaErrorSoloAdminMiembros.
  ///
  /// In es, this message translates to:
  /// **'Solo el administrador puede eliminar miembros.'**
  String get compartidaErrorSoloAdminMiembros;

  /// No description provided for @compartidaErrorAdminNoSeElimina.
  ///
  /// In es, this message translates to:
  /// **'El administrador no puede eliminarse a sí mismo.'**
  String get compartidaErrorAdminNoSeElimina;

  /// No description provided for @compartidaErrorSoloAdminEliminar.
  ///
  /// In es, this message translates to:
  /// **'Solo el administrador puede eliminar la despensa.'**
  String get compartidaErrorSoloAdminEliminar;

  /// No description provided for @compartidaErrorYaPerteneces.
  ///
  /// In es, this message translates to:
  /// **'Ya perteneces a una despensa compartida. Sal de ella primero.'**
  String get compartidaErrorYaPerteneces;

  /// No description provided for @compartidaErrorSinCodigo.
  ///
  /// In es, this message translates to:
  /// **'No se pudo generar un código. Intenta de nuevo.'**
  String get compartidaErrorSinCodigo;

  /// No description provided for @compartidaErrorSinSesion.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión.'**
  String get compartidaErrorSinSesion;

  /// No description provided for @compartidaErrorDesconocido.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Intenta de nuevo.'**
  String get compartidaErrorDesconocido;

  /// No description provided for @escanerPermisoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Permiso de cámara requerido'**
  String get escanerPermisoTitulo;

  /// No description provided for @escanerPermisoDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos acceso a la cámara para escanear el código de barras.'**
  String get escanerPermisoDescripcion;

  /// No description provided for @escanerEntendido.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get escanerEntendido;

  /// No description provided for @escanerTitulo.
  ///
  /// In es, this message translates to:
  /// **'Escanear producto'**
  String get escanerTitulo;

  /// No description provided for @escanerApagarFlash.
  ///
  /// In es, this message translates to:
  /// **'Apagar flash'**
  String get escanerApagarFlash;

  /// No description provided for @escanerEncenderFlash.
  ///
  /// In es, this message translates to:
  /// **'Encender flash'**
  String get escanerEncenderFlash;

  /// No description provided for @escanerCambiarCamara.
  ///
  /// In es, this message translates to:
  /// **'Cambiar cámara'**
  String get escanerCambiarCamara;

  /// No description provided for @escanerPermisoDenegado.
  ///
  /// In es, this message translates to:
  /// **'Permiso de cámara denegado'**
  String get escanerPermisoDenegado;

  /// No description provided for @escanerNoInicia.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar la cámara'**
  String get escanerNoInicia;

  /// No description provided for @escanerAlinea.
  ///
  /// In es, this message translates to:
  /// **'Alinea el código de barras dentro del marco'**
  String get escanerAlinea;

  /// No description provided for @nutricionalRotulo.
  ///
  /// In es, this message translates to:
  /// **'PERFIL NUTRICIONAL'**
  String get nutricionalRotulo;

  /// No description provided for @nutricionalTitulo.
  ///
  /// In es, this message translates to:
  /// **'Preferencias de recetas'**
  String get nutricionalTitulo;

  /// No description provided for @nutricionalTipoUsuario.
  ///
  /// In es, this message translates to:
  /// **'Tipo de usuario'**
  String get nutricionalTipoUsuario;

  /// No description provided for @nutricionalSinPreferencia.
  ///
  /// In es, this message translates to:
  /// **'Sin preferencia'**
  String get nutricionalSinPreferencia;

  /// No description provided for @nutricionalDeportista.
  ///
  /// In es, this message translates to:
  /// **'Deportista'**
  String get nutricionalDeportista;

  /// No description provided for @nutricionalPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan nutricional'**
  String get nutricionalPlan;

  /// No description provided for @nutricionalObjetivo.
  ///
  /// In es, this message translates to:
  /// **'Objetivo nutricional'**
  String get nutricionalObjetivo;

  /// No description provided for @nutricionalSinObjetivo.
  ///
  /// In es, this message translates to:
  /// **'Sin objetivo específico'**
  String get nutricionalSinObjetivo;

  /// No description provided for @nutricionalPerderPeso.
  ///
  /// In es, this message translates to:
  /// **'Perder peso'**
  String get nutricionalPerderPeso;

  /// No description provided for @nutricionalMantenerPeso.
  ///
  /// In es, this message translates to:
  /// **'Mantener peso'**
  String get nutricionalMantenerPeso;

  /// No description provided for @nutricionalGanarPeso.
  ///
  /// In es, this message translates to:
  /// **'Ganar peso'**
  String get nutricionalGanarPeso;

  /// No description provided for @nutricionalAlimentacion.
  ///
  /// In es, this message translates to:
  /// **'Tipo de alimentación'**
  String get nutricionalAlimentacion;

  /// No description provided for @nutricionalOmnivora.
  ///
  /// In es, this message translates to:
  /// **'Omnívora'**
  String get nutricionalOmnivora;

  /// No description provided for @nutricionalVegetariana.
  ///
  /// In es, this message translates to:
  /// **'Vegetariana'**
  String get nutricionalVegetariana;

  /// No description provided for @nutricionalVegana.
  ///
  /// In es, this message translates to:
  /// **'Vegana'**
  String get nutricionalVegana;

  /// No description provided for @nutricionalOtra.
  ///
  /// In es, this message translates to:
  /// **'Otra'**
  String get nutricionalOtra;

  /// No description provided for @nutricionalRestricciones.
  ///
  /// In es, this message translates to:
  /// **'Restricciones alimentarias'**
  String get nutricionalRestricciones;

  /// No description provided for @nutricionalRestriccionesEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Ej. cerdo, mariscos'**
  String get nutricionalRestriccionesEjemplo;

  /// No description provided for @nutricionalAlergias.
  ///
  /// In es, this message translates to:
  /// **'Alergias o intolerancias'**
  String get nutricionalAlergias;

  /// No description provided for @nutricionalAlergiasEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Ej. maní, gluten'**
  String get nutricionalAlergiasEjemplo;

  /// No description provided for @nutricionalGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar perfil'**
  String get nutricionalGuardar;

  /// No description provided for @nutricionalErrorGuardar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el perfil. Revisa tu conexión e intenta de nuevo.'**
  String get nutricionalErrorGuardar;

  /// No description provided for @nutricionalGuardado.
  ///
  /// In es, this message translates to:
  /// **'Perfil nutricional guardado'**
  String get nutricionalGuardado;

  /// No description provided for @consultaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Consulta rápida'**
  String get consultaTitulo;

  /// No description provided for @consultaBuscar.
  ///
  /// In es, this message translates to:
  /// **'Buscar producto'**
  String get consultaBuscar;

  /// No description provided for @consultaErrorCarga.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus productos.'**
  String get consultaErrorCarga;

  /// No description provided for @consultaVacia.
  ///
  /// In es, this message translates to:
  /// **'Tu despensa está vacía. Agrega productos para consultarlos aquí.'**
  String get consultaVacia;

  /// No description provided for @consultaCantidad.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get consultaCantidad;

  /// No description provided for @consultaFechaCaducidad.
  ///
  /// In es, this message translates to:
  /// **'Fecha de vencimiento'**
  String get consultaFechaCaducidad;

  /// No description provided for @consultaEstado.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get consultaEstado;

  /// No description provided for @consultaEstadoVencido.
  ///
  /// In es, this message translates to:
  /// **'Vencido'**
  String get consultaEstadoVencido;

  /// No description provided for @consultaEstadoPorVencer.
  ///
  /// In es, this message translates to:
  /// **'Próximo a vencer'**
  String get consultaEstadoPorVencer;

  /// No description provided for @consultaEstadoVigente.
  ///
  /// In es, this message translates to:
  /// **'En buen estado'**
  String get consultaEstadoVigente;

  /// No description provided for @recetasErrorFaltaClave.
  ///
  /// In es, this message translates to:
  /// **'Falta la clave de la IA. Ejecuta la app con --dart-define-from-file=env.json.'**
  String get recetasErrorFaltaClave;

  /// No description provided for @recetasErrorRespuestaVacia.
  ///
  /// In es, this message translates to:
  /// **'La IA respondió vacío. Intenta de nuevo.'**
  String get recetasErrorRespuestaVacia;

  /// No description provided for @recetasErrorTiempo.
  ///
  /// In es, this message translates to:
  /// **'La IA tardó demasiado en responder. Intenta de nuevo.'**
  String get recetasErrorTiempo;

  /// No description provided for @recetasErrorSinConexion.
  ///
  /// In es, this message translates to:
  /// **'No hay conexión con el servicio de recetas. Revisa tu internet.'**
  String get recetasErrorSinConexion;

  /// No description provided for @recetasErrorClave.
  ///
  /// In es, this message translates to:
  /// **'La clave de la IA no es válida o expiró.'**
  String get recetasErrorClave;

  /// No description provided for @recetasErrorCreditos.
  ///
  /// In es, this message translates to:
  /// **'Se agotaron los créditos del servicio de IA.'**
  String get recetasErrorCreditos;

  /// No description provided for @recetasErrorModeloInexistente.
  ///
  /// In es, this message translates to:
  /// **'El modelo de IA configurado no existe.'**
  String get recetasErrorModeloInexistente;

  /// No description provided for @recetasErrorModeloRetirado.
  ///
  /// In es, this message translates to:
  /// **'El modelo de IA configurado fue retirado por NVIDIA.'**
  String get recetasErrorModeloRetirado;

  /// No description provided for @recetasErrorDemasiadas.
  ///
  /// In es, this message translates to:
  /// **'Demasiadas consultas a la IA. Espera un momento.'**
  String get recetasErrorDemasiadas;

  /// No description provided for @recetasErrorServicio.
  ///
  /// In es, this message translates to:
  /// **'El servicio de IA no está disponible ahora mismo.'**
  String get recetasErrorServicio;

  /// No description provided for @recetasErrorSinRecetas.
  ///
  /// In es, this message translates to:
  /// **'La IA no devolvió recetas válidas. Intenta de nuevo.'**
  String get recetasErrorSinRecetas;

  /// No description provided for @recetasErrorFormato.
  ///
  /// In es, this message translates to:
  /// **'La IA respondió en un formato inesperado. Intenta de nuevo.'**
  String get recetasErrorFormato;

  /// No description provided for @recetasErrorIncompleta.
  ///
  /// In es, this message translates to:
  /// **'La respuesta de la IA llegó incompleta. Intenta de nuevo.'**
  String get recetasErrorIncompleta;

  /// No description provided for @recetasErrorDetalle.
  ///
  /// In es, this message translates to:
  /// **'El detalle de esta receta ya no está disponible. Actualiza las sugerencias para generar una nueva.'**
  String get recetasErrorDetalle;

  /// No description provided for @recetasErrorSinIngredientes.
  ///
  /// In es, this message translates to:
  /// **'No hay ingredientes válidos para buscar recetas.'**
  String get recetasErrorSinIngredientes;

  /// No description provided for @recetasErrorDesconocido.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron generar recetas.'**
  String get recetasErrorDesconocido;

  /// No description provided for @recetasErrorDetalleCarga.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la preparación. Revisa tu conexión.'**
  String get recetasErrorDetalleCarga;

  /// No description provided for @recetasOrdenDesayuno.
  ///
  /// In es, this message translates to:
  /// **'Es temprano: primero las de desayuno'**
  String get recetasOrdenDesayuno;

  /// No description provided for @recetasOrdenPrincipal.
  ///
  /// In es, this message translates to:
  /// **'Primero los platos fuertes'**
  String get recetasOrdenPrincipal;

  /// No description provided for @recetasOrdenSemana.
  ///
  /// In es, this message translates to:
  /// **'Es día de semana: primero las más rápidas'**
  String get recetasOrdenSemana;

  /// No description provided for @recetasOrdenFinde.
  ///
  /// In es, this message translates to:
  /// **'Es fin de semana: hay tiempo para algo más elaborado'**
  String get recetasOrdenFinde;

  /// No description provided for @recetasMatch.
  ///
  /// In es, this message translates to:
  /// **'{porcentaje}% match'**
  String recetasMatch(int porcentaje);

  /// No description provided for @recetasLikes.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, one{1 me gusta} other{{cantidad} me gusta}}'**
  String recetasLikes(int cantidad);

  /// No description provided for @accionCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get accionCerrar;
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
