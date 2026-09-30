import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/features/alertas/domain/alerta.dart';
import 'package:lastbite/features/perfil/domain/perfil_nutricional.dart';
import 'package:lastbite/features/recetas/data/datasources/recetas_remote_exception.dart';
import 'package:lastbite/features/recetas/data/models/receta_busqueda_remote_model.dart';
import 'package:lastbite/features/recetas/data/models/receta_detalle_remote_model.dart';
import 'package:lastbite/features/recetas/data/models/receta_ia_model.dart';
import 'package:lastbite/features/recetas/data/services/imagenes_recetas_service.dart';
import 'package:lastbite/features/recetas/data/services/nvidia_nim_service.dart';
import 'package:lastbite/features/recetas/data/services/recetas_service.dart';
import 'package:lastbite/features/recetas/domain/receta.dart';

/// IA falsa: responde en streaming, de a [trozo] caracteres, y cuenta las
/// llamadas. Cada evento es todo el texto recibido hasta ese momento.
class _IaFalsa extends NvidiaNimService {
  _IaFalsa(this.respuesta, {this.trozo = 40}) : super(apiKey: 'test');

  String respuesta;
  final int trozo;
  int llamadas = 0;
  String? ultimoPrompt;
  Completer<void>? bloqueo;

  @override
  Stream<String> completarStream({
    required String sistema,
    required String usuario,
    int maxTokens = 2000,
    double temperatura = 0.5,
    Map<String, dynamic>? esquemaJson,
  }) async* {
    llamadas++;
    ultimoPrompt = usuario;
    if (bloqueo != null) await bloqueo!.future;
    for (var i = trozo; i < respuesta.length + trozo; i += trozo) {
      yield respuesta.substring(0, i.clamp(0, respuesta.length));
    }
  }
}

/// Sin red: devuelve una imagen fija, o null para [sinImagen].
class _ImagenesFalsas extends ImagenesRecetasService {
  _ImagenesFalsas({this.sinImagen = false}) : super(apiKey: 'test');

  final bool sinImagen;
  final descripciones = <String>[];

  @override
  Future<String?> generar(String descripcion, {int semilla = 0}) async {
    descripciones.add(descripcion);
    if (sinImagen) return null;
    return 'data:image/jpeg;base64,AAAA';
  }
}

String _json(String titulo) =>
    '''
{"recetas":[{"titulo":"$titulo","imagen":"A plate of chicken in cream sauce","tipos":["main course","almuerzo"],
"minutos":"35 min","porciones":2,
"ingredientes":[
  {"nombre":"cebolla","cantidad":"1 unidad"},
  {"nombre":"sal"},
  {"nombre":"pechuga de pollo","cantidad":"300 g"},
  {"nombre":"crema de leche","cantidad":"100 ml"}
],
"pasos":["1. Corta el pollo.","Paso 2: Sofríe la cebolla.","Mezcla todo."]}]}''';

void main() {
  group('RecetaIaModel.parsearRespuesta', () {
    test('tolera markdown, razonamiento y texto alrededor del JSON', () {
      final contenido =
          '<think>pienso...</think>\nAqui tienes:\n```json\n'
          '${_json('pollo cremoso')}\n```\nBuen provecho';

      final recetas = RecetaIaModel.parsearRespuesta(contenido);

      expect(recetas, hasLength(1));
      final r = recetas.single;
      expect(r.titulo, 'Pollo cremoso');
      expect(r.minutos, 35);
      expect(r.porciones, 2);
      expect(r.tipos, ['main course', 'lunch']);
      expect(r.pasos, [
        'Corta el pollo.',
        'Sofríe la cebolla.',
        'Mezcla todo.',
      ]);
      expect(r.instrucciones, startsWith('1. Corta el pollo.\n2. '));
    });

    test('descarta recetas incompletas y duplicadas', () {
      const contenido = '''
[{"titulo":"Sin pasos","ingredientes":["arroz"],"pasos":[]},
 {"titulo":"","ingredientes":["arroz"],"pasos":["a"]},
 {"titulo":"Arroz","ingredientes":["arroz"],"pasos":["Cocina."]},
 {"titulo":"arroz","ingredientes":["arroz"],"pasos":["Otra vez."]}]''';

      final recetas = RecetaIaModel.parsearRespuesta(contenido);

      expect(recetas.map((r) => r.titulo), ['Arroz']);
    });

    test('lanza RecetasRemoteException si no hay nada usable', () {
      expect(
        () => RecetaIaModel.parsearRespuesta('Lo siento, no puedo.'),
        throwsA(isA<RecetasRemoteException>()),
      );
      expect(
        () => RecetaIaModel.parsearRespuesta('{"recetas": [ {"titulo": '),
        throwsA(isA<RecetasRemoteException>()),
      );
      expect(
        () => RecetaIaModel.parsearRespuesta('{"recetas": []}'),
        throwsA(isA<RecetasRemoteException>()),
      );
    });
  });

  group('conversion a la forma Spoonacular', () {
    final receta = RecetaIaModel.parsearRespuesta(_json('Pollo')).single;

    test('lo que hay en la despensa va primero, luego los basicos', () {
      final raw = receta.toBusquedaRaw(['Pechuga de Pollo', 'Cebolla']);
      final domain = RecetaBusquedaRemoteModel.fromJson(raw).toDomain();

      expect(domain.ingredientesUsados, 3);
      expect(domain.ingredientesFaltantes, 1);
      expect(domain.ingredientes, [
        'Cebolla (1 unidad)',
        'Pechuga de pollo (300 g)',
        'Sal',
        'Crema de leche (100 ml)',
      ]);
      expect(domain.porcentajeMatch, 75);
      expect(domain.imagenUrl, isEmpty);
      expect(domain.instrucciones, isNotEmpty);
      expect(domain.porciones, 2);
    });

    test('el detalle se lee con RecetaDetalleRemoteModel', () {
      final detalle = RecetaDetalleRemoteModel.fromApiRaw(
        receta.toDetalleRaw(['cebolla']),
      );
      expect(detalle.informacion.titulo, 'Pollo');
      expect(detalle.informacion.minutosPreparacion, 35);
      expect(detalle.ingredientes.first, 'Cebolla (1 unidad)');
      expect(detalle.informacion.instrucciones, contains('\n'));
    });

    test('el id es estable, ignora tildes y no choca con Spoonacular', () {
      expect(idRecetaIa('Pollo al curry'), idRecetaIa('  pollo al CURRY '));
      expect(idRecetaIa('Crema de ahuyama'), idRecetaIa('Créma de ahuyama'));
      expect(idRecetaIa('Pollo'), isNot(idRecetaIa('Arroz')));
      for (final t in ['a', 'Tortilla española', 'x' * 300]) {
        expect(idRecetaIa(t), inInclusiveRange(1000000000, 2147483647));
      }
    });
  });

  group('RecetasService', () {
    test('genera, recuerda la busqueda y resuelve el detalle por id', () async {
      final ia = _IaFalsa(_json('Pollo guisado'));
      final service = RecetasService(imagenes: _ImagenesFalsas(), ia: ia);

      final raw = await service.buscarRecetasPorDespensaRaw(
        productosDespensa: ['pollo', 'cebolla', 'pollo'],
        ingredientePrincipal: 'guiso',
      );
      final otra = await service.buscarRecetasPorDespensaRaw(
        productosDespensa: ['pollo', 'cebolla'],
        ingredientePrincipal: 'guiso',
      );

      expect(ia.llamadas, 1, reason: 'la segunda busqueda sale de memoria');
      expect(otra, same(raw));
      expect(ia.ultimoPrompt, contains('"guiso"'));

      // Otra instancia (otra pantalla) ve el mismo detalle.
      final detalle = await RecetasService(
        imagenes: _ImagenesFalsas(),
        ia: _IaFalsa(''),
      ).obtenerDetalleRecetaRaw(recetaId: raw.first['id'] as int);
      expect((detalle['information'] as Map)['title'], 'Pollo guisado');
    });

    test('cada receta trae su ilustracion generada', () async {
      final imagenes = _ImagenesFalsas();
      final raw = await RecetasService(
        ia: _IaFalsa(_json('Pollo en crema')),
        imagenes: imagenes,
      ).buscarRecetasPorDespensaRaw(productosDespensa: ['pollo']);

      expect(imagenes.descripciones, ['A plate of chicken in cream sauce']);
      final receta = RecetaBusquedaRemoteModel.fromJson(raw.first).toDomain();
      expect(receta.imagenUrl, 'data:image/jpeg;base64,AAAA');
      // Sobrevive a la cache de Firestore.
      expect(Receta.fromMap(receta.toMap()).imagenUrl, receta.imagenUrl);
    });

    test('sin imagen la receta queda con emoji (imagen vacia)', () async {
      final raw = await RecetasService(
        ia: _IaFalsa(_json('Pollo sin foto')),
        imagenes: _ImagenesFalsas(sinImagen: true),
      ).buscarRecetasPorDespensaRaw(productosDespensa: ['papa', 'huevo']);

      final receta = RecetaBusquedaRemoteModel.fromJson(raw.first).toDomain();
      expect(receta.imagenUrl, isEmpty);
    });

    test('el stream muestra cada receta en cuanto llega', () async {
      String receta(String t) =>
          '{"titulo":"$t","imagen":"x","ingredientes":[{"nombre":"papa",'
          '"cantidad":"1"}],"pasos":["Cocina."]}';
      final ia = _IaFalsa(
        '{"recetas":[${receta('Uno')},${receta('Dos')},${receta('Tres')}]}',
        trozo: 15,
      );

      final eventos =
          await RecetasService(
                ia: ia,
                imagenes: _ImagenesFalsas(sinImagen: true),
              )
              .buscarRecetasPorDespensaStream(
                productosDespensa: ['papa', 'yuca'],
              )
              .toList();

      expect(eventos.map((e) => e.length).take(3), [1, 2, 3]);
      expect(eventos.last.map((r) => r['title']), ['Uno', 'Dos', 'Tres']);
    });

    test('la imagen llega en un evento posterior a la receta', () async {
      final eventos =
          await RecetasService(
                ia: _IaFalsa(_json('Pollo por partes')),
                imagenes: _ImagenesFalsas(),
              )
              .buscarRecetasPorDespensaStream(
                productosDespensa: ['pollo', 'arroz'],
              )
              .toList();

      expect(eventos.first.single['image'], isEmpty);
      expect(eventos.last.single['image'], 'data:image/jpeg;base64,AAAA');
    });

    test('dos pedidos simultaneos iguales hacen una sola llamada', () async {
      final ia = _IaFalsa(_json('Arepa rellena'))..bloqueo = Completer();
      final service = RecetasService(imagenes: _ImagenesFalsas(), ia: ia);

      Future<List<Map<String, dynamic>>> pedir() =>
          service.buscarRecetasPorDespensaRaw(
            productosDespensa: ['arepa', 'queso'],
            number: 1,
          );

      final a = pedir();
      final b = pedir();
      ia.bloqueo!.complete();

      expect(await a, same(await b));
      expect(ia.llamadas, 1);
    });

    test('el perfil llega al prompt', () async {
      final ia = _IaFalsa(_json('Tofu salteado'));
      await RecetasService(
        imagenes: _ImagenesFalsas(),
        ia: ia,
      ).buscarRecetasPorDespensaRaw(
        productosDespensa: ['tofu'],
        perfil: const PerfilNutricional(
          dietaryType: 'vegan',
          allergies: ['maní'],
          userType: 'athlete',
        ),
      );

      expect(ia.ultimoPrompt, contains('vegana'));
      expect(ia.ultimoPrompt, contains('NUNCA incluir: maní'));
      expect(ia.ultimoPrompt, contains('proteína'));
    });

    test('sin ingredientes ni busqueda no llama a la IA', () async {
      final ia = _IaFalsa('');
      await expectLater(
        RecetasService(
          imagenes: _ImagenesFalsas(),
          ia: ia,
        ).buscarRecetasPorDespensaRaw(productosDespensa: ['  ']),
        throwsA(isA<RecetasRemoteException>()),
      );
      expect(ia.llamadas, 0);
    });

    test('un id desconocido (Spoonacular viejo) da un error legible', () {
      expect(
        RecetasService(
          imagenes: _ImagenesFalsas(),
          ia: _IaFalsa(''),
        ).obtenerDetalleRecetaRaw(recetaId: 715538),
        throwsA(isA<RecetasRemoteException>()),
      );
    });
  });

  group('compatibilidad con datos guardados', () {
    test('Receta.fromMap tolera campos faltantes', () {
      final receta = Receta.fromMap({'id': 42, 'titulo': 'Vieja'});
      expect(receta.id, 42);
      expect(receta.imagenUrl, '');
      expect(receta.likes, 0);
      expect(receta.instrucciones, isNull);
    });

    test('la alerta guarda y recupera la receta completa', () {
      final alerta = Alerta(
        id: 'p1_aviso3',
        productoId: 'p1',
        nombreProducto: 'Pollo',
        emoji: '🍗',
        fechaCaducidad: DateTime(2026, 10, 1),
        tipo: AlertaTipo.aviso3,
        creadaEn: DateTime(2026, 9, 28),
        recetaSugerida: Receta(
          id: idRecetaIa('Pollo guisado'),
          titulo: 'Pollo guisado',
          imagenUrl: '',
          ingredientesUsados: 1,
          ingredientesFaltantes: 0,
          likes: 0,
          minutosPreparacion: 30,
          porciones: 2,
          ingredientes: const ['Pollo (300 g)'],
          instrucciones: '1. Cocina.\n2. Sirve.',
        ),
      );

      final leida = Alerta.fromMap(alerta.toMap()).recetaSugerida!;
      expect(leida.instrucciones, '1. Cocina.\n2. Sirve.');
      expect(leida.minutosPreparacion, 30);
      expect(leida.porciones, 2);
    });

    test('una alerta de Spoonacular se lee sin instrucciones', () {
      final alerta = Alerta.fromMap({
        'id': 'p1_aviso1',
        'tipo': 'aviso1',
        'receta': {
          'id': 715538,
          'titulo': 'Pasta',
          'imagenUrl': 'https://img.spoonacular.com/recipes/715538-312x231.jpg',
          'ingredientesUsados': 2,
          'ingredientesFaltantes': 3,
          'likes': 10,
          'ingredientes': ['pasta', 'tomate'],
        },
      });

      expect(alerta.recetaSugerida!.id, 715538);
      expect(alerta.recetaSugerida!.instrucciones, isNull);
    });
  });

  group('RecetaIaModel.objetosCompletos', () {
    test('solo devuelve las recetas cuyo objeto ya cerro', () {
      const parcial =
          '{"recetas":[{"titulo":"A","pasos":["x}"]},{"titulo":"B","pasos":["y';
      expect(RecetaIaModel.objetosCompletos(parcial).map((o) => o['titulo']), [
        'A',
      ]);
    });

    test('respeta llaves y comillas escapadas dentro de los textos', () {
      const texto =
          r'{"recetas":[{"titulo":"Dice \"hola\" {ok}","pasos":["a"]},'
          r'{"titulo":"B","pasos":["b"]}]}';
      final objetos = RecetaIaModel.objetosCompletos(texto);
      expect(objetos.map((o) => o['titulo']), ['Dice "hola" {ok}', 'B']);
    });

    test('sin arreglo todavia no hay nada', () {
      expect(RecetaIaModel.objetosCompletos('{"rec'), isEmpty);
    });
  });
}
