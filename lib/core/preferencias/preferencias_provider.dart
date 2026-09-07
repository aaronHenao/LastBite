import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lastbite/core/data/despensa_ref.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';

import 'preferencias.dart';

/// Guarda las preferencias en el documento del usuario, no en el dispositivo:
/// asi viajan entre el telefono y la web sin sumar dependencias.
class PreferenciasNotifier extends StreamNotifier<Preferencias> {
  @override
  Stream<Preferencias> build() async* {
    final user = await ref.watch(firebaseUserProvider.future);
    if (user == null) {
      yield const Preferencias();
      return;
    }

    yield* docUsuario(user.uid).snapshots().map(
      (doc) => Preferencias.fromMap(
        doc.data()?['preferencias'] as Map<String, dynamic>?,
      ),
    );
  }

  Future<void> _guardar(Preferencias nuevas) async {
    // Optimista: el control responde al instante y Firestore confirma.
    state = AsyncData(nuevas);

    final user = await ref.read(firebaseUserProvider.future);
    if (user == null) return;
    await docUsuario(
      user.uid,
    ).set({'preferencias': nuevas.toMap()}, SetOptions(merge: true));
  }

  Preferencias get _actuales => state.valueOrNull ?? const Preferencias();

  Future<void> cambiarTema(ThemeMode tema) =>
      _guardar(_actuales.copyWith(tema: tema));

  Future<void> cambiarEscalaTexto(double escala) =>
      _guardar(_actuales.copyWith(escalaTexto: escala));

  Future<void> cambiarAltoContraste(bool activo) =>
      _guardar(_actuales.copyWith(altoContraste: activo));

  Future<void> cambiarReducirMovimiento(bool activo) =>
      _guardar(_actuales.copyWith(reducirMovimiento: activo));

  /// null vuelve a seguir el idioma del dispositivo.
  Future<void> cambiarIdioma(String? codigo) => _guardar(
    _actuales.copyWith(idioma: codigo, limpiarIdioma: codigo == null),
  );
}

final preferenciasProvider =
    StreamNotifierProvider<PreferenciasNotifier, Preferencias>(
      PreferenciasNotifier.new,
    );
