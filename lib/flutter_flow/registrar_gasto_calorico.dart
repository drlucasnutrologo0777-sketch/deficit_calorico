import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Grava gasto calórico manual (nome, minutos, kcal) em [registros_treinos].
Future<void> registrarGastoCaloricoManual({
  required String nome,
  required double minutos,
  required double kcal,
  required String categoria,
}) async {
  if (currentUserReference == null) {
    throw StateError('Utilizador não autenticado.');
  }
  await RegistrosTreinosRecord.collection.doc().set(
        createRegistrosTreinosRecordData(
          tipoDeExercicio: nome,
          gastoCalorico: kcal,
          series: 1,
          repeticoes: minutos,
          carga: 1,
          categoria: categoria,
          userRef: currentUserReference,
          data: getCurrentTimestamp,
        ),
      );
  await currentUserReference!.update({
    ...mapToFirestore({
      'calorias_total_dia': FieldValue.increment(kcal),
    }),
  });
}
