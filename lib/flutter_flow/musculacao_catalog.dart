import 'dart:convert';

import 'package:flutter/services.dart';

/// Entrada do catálogo local `assets/jsons/musculacao_exercicios_catalogo.json` (build 114).
class MusculacaoCategoria {
  const MusculacaoCategoria({
    required this.slug,
    required this.categoriaRegisto,
    required this.exercicios,
  });

  final String slug;
  final String categoriaRegisto;
  final List<String> exercicios;
}

const _assetPath = 'assets/jsons/musculacao_exercicios_catalogo.json';

List<MusculacaoCategoria>? _cache;

/// Grupos exibidos na lista de treino → chave gravada em `registros_treinos.categoria`.
const kMusculacaoListaGrupos = <({String label, String categoriaRegisto})>[
  (label: 'Abdômen', categoriaRegisto: 'Abdômen'),
  (label: 'Peito', categoriaRegisto: 'Peitoral'),
  (label: 'Bíceps', categoriaRegisto: 'Bíceps'),
  (label: 'Tríceps', categoriaRegisto: 'Tríceps'),
  (label: 'Costas', categoriaRegisto: 'Costas'),
  (label: 'Ombro', categoriaRegisto: 'Ombro'),
  (label: 'Glúteo', categoriaRegisto: 'Glúteo'),
  (label: 'Perna 1', categoriaRegisto: 'Perna 1'),
  (label: 'Perna 2', categoriaRegisto: 'Perna 2'),
];

Future<List<MusculacaoCategoria>> loadMusculacaoCatalog() async {
  if (_cache != null) {
    return _cache!;
  }
  final raw = await rootBundle.loadString(_assetPath);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final cats = json['categorias'] as List<dynamic>? ?? [];
  _cache = cats.map((c) {
    final map = c as Map<String, dynamic>;
    final exList = map['exercicios'] as List<dynamic>? ?? [];
    final names = exList
        .map((e) => (e as Map<String, dynamic>)['nome'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return MusculacaoCategoria(
      slug: map['slug'] as String? ?? '',
      categoriaRegisto: map['categoriaRegisto'] as String? ?? '',
      exercicios: names,
    );
  }).toList();
  return _cache!;
}

Future<List<String>> exerciciosMusculacaoCategoria(String categoriaRegisto) async {
  final catalog = await loadMusculacaoCatalog();
  for (final cat in catalog) {
    if (cat.categoriaRegisto == categoriaRegisto) {
      return cat.exercicios;
    }
  }
  return const [];
}

/// Gasto estimado (kcal) — fórmula do build 114: séries × repetições × carga × 0,025.
double gastoCaloricoMusculacao({
  required double series,
  required double repeticoes,
  required double carga,
}) {
  if (series <= 0 || repeticoes <= 0 || carga <= 0) {
    return 0.0;
  }
  return series * repeticoes * carga * 0.025;
}

double? parseTreinoNumero(String? text) {
  final v = double.tryParse((text ?? '').trim().replaceAll(',', '.'));
  if (v == null || v <= 0) {
    return null;
  }
  return v;
}
