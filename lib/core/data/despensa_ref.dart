import 'package:cloud_firestore/cloud_firestore.dart';

const coleccionDespensasCompartidas = 'despensas_compartidas';
const coleccionCodigosDespensa = 'codigos_despensa';

/// Raiz de datos de una despensa: la personal del usuario o una compartida.
///
/// Todas las subcolecciones (productos, alertas, estadisticas,
/// recetas_sugeridas) cuelgan de este documento, asi que cambiar la raiz
/// cambia de despensa sin tocar el resto de los repositorios.
DocumentReference<Map<String, dynamic>> raizDespensa({
  required String userId,
  String? despensaCompartidaId,
}) {
  final db = FirebaseFirestore.instance;
  if (despensaCompartidaId != null && despensaCompartidaId.trim().isNotEmpty) {
    return db.collection(coleccionDespensasCompartidas).doc(despensaCompartidaId);
  }
  return db.collection('users').doc(userId);
}

/// Documento del usuario, donde vive el puntero a su despensa compartida.
DocumentReference<Map<String, dynamic>> docUsuario(String userId) =>
    FirebaseFirestore.instance.collection('users').doc(userId);
