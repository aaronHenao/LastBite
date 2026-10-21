import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/features/recetas/domain/disponibilidad_ingrediente.dart';

void main() {
  const despensa = ['Pechuga de pollo', 'Limón', 'Cebolla'];

  test('reconoce lo que hay aunque cambien tildes o el nombre sea parcial', () {
    expect(
      disponibilidadIngrediente('Jugo de limon', despensa),
      Disponibilidad.tienes,
    );
    expect(
      disponibilidadIngrediente('Pollo (300 g)', despensa),
      Disponibilidad.tienes,
    );
  });

  test('la cantidad entre parentesis no es parte del nombre', () {
    expect(
      disponibilidadIngrediente('Cebolla (1 unidad)', despensa),
      Disponibilidad.tienes,
    );
  });

  test('los basicos cuentan aparte de lo que falta', () {
    expect(disponibilidadIngrediente('Sal', despensa), Disponibilidad.basico);
    expect(
      disponibilidadIngrediente('Aceite de oliva', despensa),
      Disponibilidad.basico,
    );
    // "sal" al comienzo de otra palabra no es sal.
    expect(
      disponibilidadIngrediente('Salchicha', despensa),
      Disponibilidad.falta,
    );
  });

  test('lo demas falta', () {
    expect(
      disponibilidadIngrediente('Crema de leche (100 ml)', despensa),
      Disponibilidad.falta,
    );
  });
}
