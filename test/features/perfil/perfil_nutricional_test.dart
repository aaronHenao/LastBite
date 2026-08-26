import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/features/perfil/domain/perfil_nutricional.dart';

void main() {
  test('serializa y recupera las preferencias nutricionales', () {
    const perfil = PerfilNutricional(
      userType: 'athlete',
      goal: 'gain_weight',
      dietaryType: 'vegetarian',
      restrictions: ['cerdo'],
      allergies: ['maní'],
    );

    final recuperado = PerfilNutricional.fromMap(perfil.toMap());

    expect(recuperado.userType, 'athlete');
    expect(recuperado.goal, 'gain_weight');
    expect(recuperado.dietaryType, 'vegetarian');
    expect(recuperado.restrictions, ['cerdo']);
    expect(recuperado.allergies, ['maní']);
  });

  test('la firma cambia cuando cambian las preferencias', () {
    const base = PerfilNutricional();
    const atleta = PerfilNutricional(userType: 'athlete');

    expect(base.cacheKey, isNot(atleta.cacheKey));
  });
}
