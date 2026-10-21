import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/core/widgets/avatar_usuario.dart';

Future<void> _montar(WidgetTester tester, String? fotoUrl) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: Center(child: AvatarUsuario(fotoUrl: fotoUrl))),
    ),
  );
}

void main() {
  // El circulo vacio en el menu de cuenta: sin icono no se sabe que ahi esta
  // la cuenta.
  for (final caso in <String, String?>{
    'sin foto': null,
    'con la url vacia': '  ',
    'mientras la foto carga': 'https://example.com/foto.jpg',
  }.entries) {
    testWidgets('muestra el icono de usuario ${caso.key}', (tester) async {
      await _montar(tester, caso.value);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });
  }
}
