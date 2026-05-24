import 'dart:convert';

import 'package:flutter/services.dart';

class CoachMensagem {
  const CoachMensagem({
    required this.titulo,
    required this.corpo,
    this.credito,
  });

  final String titulo;
  final String corpo;
  final String? credito;
}

const _assetPath = 'assets/jsons/coach_mensagens.json';

List<CoachMensagem>? _bomDiaCache;

Future<List<CoachMensagem>> _bomDiaMensagens() async {
  if (_bomDiaCache != null) {
    return _bomDiaCache!;
  }
  final raw = await rootBundle.loadString(_assetPath);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final frases = json['frases'] as Map<String, dynamic>? ?? {};
  final lista = frases['bom_dia_planeamento'] as List<dynamic>? ?? [];
  _bomDiaCache = lista.map((item) {
    final m = item as Map<String, dynamic>;
    return CoachMensagem(
      titulo: m['titulo'] as String? ?? 'Coach',
      corpo: m['corpo'] as String? ?? '',
      credito: m['credito'] as String?,
    );
  }).where((m) => m.corpo.isNotEmpty).toList();
  return _bomDiaCache!;
}

/// Mensagem estável no dia civil local (rotação determinística).
Future<CoachMensagem> coachMensagemDoDia({String nome = 'atleta'}) async {
  final pool = await _bomDiaMensagens();
  if (pool.isEmpty) {
    return CoachMensagem(
      titulo: 'Coach',
      corpo: 'Bom dia, $nome. Registe refeições e movimento com honestidade hoje.',
    );
  }
  final now = DateTime.now();
  final seed = now.year * 10000 + now.month * 100 + now.day;
  final idx = seed % pool.length;
  final msg = pool[idx];
  final primeiroNome = nome.trim().split(RegExp(r'\s+')).first;
  final display = primeiroNome.isEmpty ? 'atleta' : primeiroNome;
  return CoachMensagem(
    titulo: msg.titulo,
    corpo: msg.corpo.replaceAll('{nome}', display),
    credito: msg.credito,
  );
}
