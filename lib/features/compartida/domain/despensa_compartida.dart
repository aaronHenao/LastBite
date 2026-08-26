class MiembroDespensa {
  final String uid;
  final String nombre;
  final String? email;
  final String? fotoUrl;
  final DateTime unidoEn;

  const MiembroDespensa({
    required this.uid,
    required this.nombre,
    required this.unidoEn,
    this.email,
    this.fotoUrl,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'nombre': nombre,
    'email': email,
    'fotoUrl': fotoUrl,
    'unidoEn': unidoEn.toIso8601String(),
  };

  factory MiembroDespensa.fromMap(Map<String, dynamic> map) => MiembroDespensa(
    uid: map['uid'] as String,
    nombre: (map['nombre'] as String?)?.trim().isNotEmpty == true
        ? map['nombre'] as String
        : 'Miembro',
    email: map['email'] as String?,
    fotoUrl: map['fotoUrl'] as String?,
    unidoEn:
        DateTime.tryParse(map['unidoEn']?.toString() ?? '') ?? DateTime.now(),
  );
}

class DespensaCompartida {
  final String id;
  final String nombre;
  final String codigo;
  final String adminUid;
  final DateTime creadaEn;
  final List<MiembroDespensa> miembros;

  const DespensaCompartida({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.adminUid,
    required this.creadaEn,
    required this.miembros,
  });

  bool esAdmin(String uid) => adminUid == uid;

  MiembroDespensa? miembro(String uid) {
    for (final m in miembros) {
      if (m.uid == uid) return m;
    }
    return null;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'codigo': codigo,
    'adminUid': adminUid,
    'creadaEn': creadaEn.toIso8601String(),
    'miembrosUids': miembros.map((m) => m.uid).toList(),
    'miembros': {for (final m in miembros) m.uid: m.toMap()},
  };

  factory DespensaCompartida.fromMap(Map<String, dynamic> map) {
    final raw = (map['miembros'] as Map<String, dynamic>?) ?? {};
    final miembros =
        raw.values
            .map((v) => MiembroDespensa.fromMap(Map<String, dynamic>.from(v as Map)))
            .toList()
          ..sort((a, b) => a.unidoEn.compareTo(b.unidoEn));

    return DespensaCompartida(
      id: map['id'] as String,
      nombre: map['nombre'] as String? ?? 'Despensa familiar',
      codigo: map['codigo'] as String? ?? '',
      adminUid: map['adminUid'] as String? ?? '',
      creadaEn:
          DateTime.tryParse(map['creadaEn']?.toString() ?? '') ?? DateTime.now(),
      miembros: miembros,
    );
  }
}
