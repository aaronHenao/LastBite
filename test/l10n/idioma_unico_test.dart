import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/preferencias/preferencias.dart';
import 'package:lastbite/core/preferencias/preferencias_provider.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/agregar/presentation/agregar_screen.dart';
import 'package:lastbite/features/ajustes/presentation/ajustes_screen.dart';
import 'package:lastbite/features/alertas/domain/alerta.dart';
import 'package:lastbite/features/alertas/presentation/alertas_provider.dart';
import 'package:lastbite/features/alertas/presentation/alertas_screen.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/auth/presentation/login_screen.dart';
import 'package:lastbite/features/auth/presentation/register_screen.dart';
import 'package:lastbite/features/ayuda/presentation/ayuda_screen.dart';
import 'package:lastbite/features/compartida/domain/despensa_compartida.dart';
import 'package:lastbite/features/compartida/presentation/compartida_provider.dart';
import 'package:lastbite/features/compartida/presentation/compartida_screen.dart';
import 'package:lastbite/features/consulta_rapida/presentation/consulta_rapida_screen.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import 'package:lastbite/features/despensa/presentation/despensa_screen.dart';
import 'package:lastbite/features/perfil/domain/item_compra.dart';
import 'package:lastbite/features/perfil/domain/perfil_nutricional.dart';
import 'package:lastbite/features/perfil/presentation/perfil_nutricional_provider.dart';
import 'package:lastbite/features/perfil/presentation/perfil_nutricional_screen.dart';
import 'package:lastbite/features/perfil/presentation/perfil_provider.dart';
import 'package:lastbite/features/perfil/presentation/perfil_screen.dart';
import 'package:lastbite/features/recetas/domain/receta.dart';
import 'package:lastbite/features/recetas/presentation/widgets/receta_card.dart';
import 'package:lastbite/l10n/app_localizations.dart';

/// Con la app en ingles no puede aparecer ni una palabra en español.
///
/// Varias pantallas tenian textos escritos a mano en español y se veian asi
/// aunque se eligiera otro idioma. Esta prueba monta cada pantalla en ingles,
/// con datos en ingles, y falla si algun texto visible, tooltip, pista o
/// etiqueta para el lector tiene señales de español.

class _UsuarioFalso implements User {
  @override
  String get uid => 'u1';

  @override
  String? get displayName => 'Alex';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DespensaFalsa extends DespensaNotifier {
  @override
  Stream<List<Producto>> build() => Stream.value([
    Producto(
      id: '1',
      nombre: 'Whole milk',
      emoji: '🥛',
      categoria: 'Leche',
      cantidad: '2 unidad',
      fechaCaducidad: DateTime.now().add(const Duration(days: 1, hours: 1)),
      esFresco: false,
    ),
    Producto(
      id: '2',
      nombre: 'Rice',
      emoji: '🌾',
      categoria: 'Grano',
      cantidad: '1 taza',
      fechaCaducidad: DateTime.now().add(const Duration(days: 90)),
      esFresco: false,
    ),
  ]);
}

class _AlertasFalsas extends AlertasNotifier {
  @override
  Future<List<Alerta>> build() async => [
    for (final tipo in AlertaTipo.values)
      Alerta(
        id: tipo.name,
        productoId: '1',
        nombreProducto: 'Whole milk',
        emoji: '🥛',
        fechaCaducidad: DateTime.now().add(const Duration(days: 1, hours: 1)),
        tipo: tipo,
        creadaEn: DateTime(2026, 9, 1),
      ),
  ];
}

class _ListaFalsa extends ListaComprasNotifier {
  @override
  Future<List<ItemCompra>> build() async => [
    ItemCompra(
      id: 'c1',
      nombre: 'Bread',
      emoji: '🍞',
      comprado: false,
      agregadoEn: DateTime(2026, 9, 1),
      fechaConsumido: DateTime(2026, 9, 2),
    ),
  ];
}

class _PreferenciasFalsas extends PreferenciasNotifier {
  @override
  Stream<Preferencias> build() => Stream.value(const Preferencias());
}

class _PerfilNutricionalFalso extends PerfilNutricionalNotifier {
  @override
  Future<PerfilNutricional?> build() async => null;
}

final _compartida = DespensaCompartida(
  id: 'd1',
  nombre: 'Home',
  codigo: 'ABC234',
  adminUid: 'u1',
  creadaEn: DateTime(2026, 9, 1),
  miembros: [
    MiembroDespensa(uid: 'u1', nombre: 'Alex', unidoEn: DateTime(2026, 9, 1)),
    MiembroDespensa(uid: 'u2', nombre: 'Sam', unidoEn: DateTime(2026, 9, 2)),
  ],
);

/// Palabras y signos que solo aparecen en español. Los nombres de los
/// idiomas en el selector ("Español", "Português") se escriben en su propio
/// idioma a proposito y no cuentan.
final _senalesDeEspanol = RegExp(
  r'[áéíóúñ¿¡]|\b(de|del|la|las|los|el|tu|tus|para|con|que|una|un|es|está|'
  r'hoy|despensa|agregar|receta|recetas|producto|productos|buscar|cuenta|'
  r'vence|vencido|unidad|unidades|taza|leche|ayuda|cerrar|guardar)\b',
  caseSensitive: false,
);
const _permitidos = {'Español', 'Português'};

Iterable<String> _textosVisibles(WidgetTester tester) sync* {
  for (final w in tester.allWidgets) {
    if (w is Text) {
      yield w.data ?? w.textSpan?.toPlainText() ?? '';
    } else if (w is Tooltip) {
      yield w.message ?? '';
    } else if (w is Semantics) {
      yield w.properties.label ?? '';
    } else if (w is TextField) {
      yield w.decoration?.hintText ?? '';
      yield w.decoration?.labelText ?? '';
    }
  }
}

void _sinEspanol(WidgetTester tester, String pantalla) {
  final encontrados = _textosVisibles(tester)
      .where((t) => t.isNotEmpty && !_permitidos.contains(t))
      .where(_senalesDeEspanol.hasMatch)
      .toSet();
  expect(encontrados, isEmpty, reason: 'Textos en español en $pantalla');
}

Future<void> _montar(
  WidgetTester tester,
  Widget pantalla, {
  DespensaCompartida? compartida,
}) async {
  tester.view.physicalSize = const Size(500, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        firebaseUserProvider.overrideWith(
          (ref) => Stream<User?>.value(_UsuarioFalso()),
        ),
        authStateProvider.overrideWith((ref) => const Stream.empty()),
        despensaCompartidaProvider.overrideWith(
          (ref) => Stream.value(compartida),
        ),
        despensaProvider.overrideWith(_DespensaFalsa.new),
        listaComprasProvider.overrideWith(_ListaFalsa.new),
        alertasProvider.overrideWith(_AlertasFalsas.new),
        preferenciasProvider.overrideWith(_PreferenciasFalsas.new),
        perfilNutricionalProvider.overrideWith(_PerfilNutricionalFalso.new),
        productosPersonalesCountProvider.overrideWith((ref) async => 0),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        theme: AppTheme.light,
        home: Scaffold(body: pantalla),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  for (final caso in <String, Widget>{
    'despensa': const DespensaScreen(),
    'alertas': const AlertasScreen(),
    'perfil y lista de compras': const PerfilScreen(),
    'agregar': const AgregarScreen(),
    'despensa compartida': const DespensaCompartidaScreen(),
    'accesibilidad': const AjustesScreen(),
    'consulta rapida': const ConsultaRapidaScreen(),
    'perfil nutricional': const PerfilNutricionalScreen(),
    'login': const LoginScreen(),
    'registro': const RegisterScreen(),
  }.entries) {
    testWidgets('${caso.key} se ve solo en ingles', (tester) async {
      await _montar(tester, caso.value);
      _sinEspanol(tester, caso.key);
    });
  }

  testWidgets('despensa compartida con miembros se ve solo en ingles', (
    tester,
  ) async {
    await _montar(
      tester,
      const DespensaCompartidaScreen(),
      compartida: _compartida,
    );
    _sinEspanol(tester, 'despensa compartida con miembros');
  });

  testWidgets('cada seccion de la ayuda se ve solo en ingles', (tester) async {
    for (final seccion in SeccionAyuda.values) {
      await _montar(tester, AyudaScreen(seccion: seccion));
      _sinEspanol(tester, 'ayuda: ${seccion.name}');
    }
  });

  testWidgets('el formulario manual de agregar se ve solo en ingles', (
    tester,
  ) async {
    await _montar(tester, const AgregarScreen());
    await tester.tap(find.text('Manual').first);
    await tester.pumpAndSettle();
    _sinEspanol(tester, 'agregar a mano');
  });

  testWidgets('las hojas de la despensa se ven solo en ingles', (
    tester,
  ) async {
    await _montar(tester, const DespensaScreen());

    await tester.tap(find.text('Whole milk'));
    await tester.pumpAndSettle();
    _sinEspanol(tester, 'acciones de un producto');
    Navigator.of(tester.element(find.byType(DespensaScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Account menu'));
    await tester.pumpAndSettle();
    _sinEspanol(tester, 'menu de cuenta');
  });

  testWidgets('el detalle de una receta se ve solo en ingles', (tester) async {
    await _montar(
      tester,
      RecetaDetalleSheet(
        receta: Receta(
          id: 1,
          titulo: 'Rice pudding',
          imagenUrl: '',
          ingredientesUsados: 2,
          ingredientesFaltantes: 1,
          likes: 3,
          minutosPreparacion: 30,
          ingredientes: const ['Rice (1 cup)', 'Salt', 'Cinnamon (1 stick)'],
          instrucciones: 'Boil the rice.\nAdd the cinnamon.',
        ),
        productosEnDespensa: const {'rice'},
        onCocinar: (_) async {},
        isDialog: true,
      ),
    );
    _sinEspanol(tester, 'detalle de receta');
  });
}
