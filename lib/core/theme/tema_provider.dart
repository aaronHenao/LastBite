import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lastbite/core/data/despensa_ref.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';

/// Tema elegido por la persona.
///
/// Se guarda en su documento de usuario y no en el dispositivo: asi la
/// preferencia viaja entre el telefono y la web sin sumar dependencias.
class TemaNotifier extends StreamNotifier<ThemeMode> {
  @override
  Stream<ThemeMode> build() async* {
    final user = await ref.watch(firebaseUserProvider.future);
    if (user == null) {
      yield ThemeMode.system;
      return;
    }

    yield* docUsuario(user.uid).snapshots().map(
      (doc) => _desdeTexto(doc.data()?['tema']?.toString()),
    );
  }

  Future<void> cambiar(ThemeMode modo) async {
    // Optimista: el interruptor responde al instante y Firestore confirma.
    state = AsyncData(modo);

    final user = await ref.read(firebaseUserProvider.future);
    if (user == null) return;
    await docUsuario(user.uid).set({'tema': modo.name}, SetOptions(merge: true));
  }

  static ThemeMode _desdeTexto(String? valor) => switch (valor) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

final temaProvider = StreamNotifierProvider<TemaNotifier, ThemeMode>(
  TemaNotifier.new,
);
