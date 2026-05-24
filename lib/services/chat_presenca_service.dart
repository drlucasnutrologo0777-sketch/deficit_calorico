import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Mantém o utilizador visível na lista da sala enquanto está no chat.
class ChatPresencaService {
  ChatPresencaService._();

  static final ChatPresencaService instance = ChatPresencaService._();

  Timer? _heartbeat;
  String? _salaAtiva;

  DocumentReference<Map<String, dynamic>> _doc(String salaId) {
    return FirebaseFirestore.instance
        .collection('presenca_sala')
        .doc('${salaId}_$currentUserUid');
  }

  Future<void> entrar(String salaId) async {
    if (currentUserReference == null || currentUserUid.isEmpty) {
      return;
    }
    _salaAtiva = salaId;
    await _doc(salaId).set(
      {
        'sala_id': salaId,
        'user_ref': currentUserReference,
        'autor_nome': currentUserDisplayName.isNotEmpty
            ? currentUserDisplayName
            : 'Utilizador',
        'last_seen': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(
      const Duration(seconds: 45),
      (_) => _atualizarLastSeen(salaId),
    );
  }

  Future<void> _atualizarLastSeen(String salaId) async {
    if (currentUserReference == null) {
      return;
    }
    try {
      await _doc(salaId).update({
        'last_seen': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // doc pode ter sido removido
    }
  }

  Future<void> sair() async {
    _heartbeat?.cancel();
    _heartbeat = null;
    final salaId = _salaAtiva;
    _salaAtiva = null;
    if (salaId == null || currentUserUid.isEmpty) {
      return;
    }
    try {
      await _doc(salaId).delete();
    } catch (_) {}
  }
}
