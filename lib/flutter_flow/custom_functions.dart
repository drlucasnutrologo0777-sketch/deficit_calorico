import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

double calcularTmb(
  DateTime dataDeNascimento,
  double peso,
  double altura,
  bool isMasculino,
  String nivelAtividade,
) {
  final hoje = DateTime.now();
  int idade = hoje.year - dataDeNascimento.year;
  if (hoje.month < dataDeNascimento.month ||
      (hoje.month == dataDeNascimento.month &&
          hoje.day < dataDeNascimento.day)) {
    idade--;
  }

  double resultado;
  if (isMasculino) {
    resultado = 66.5 + (13.75 * peso) + (5.003 * altura) - (6.75 * idade);
  } else {
    resultado = 655.1 + (9.563 * peso) + (1.85 * altura) - (4.676 * idade);
  }

  return resultado.roundToDouble();
}

bool sexoEhMasculino(String? sexo) {
  final s = (sexo ?? '').toLowerCase().trim();
  if (s.isEmpty) {
    return true;
  }
  return s.startsWith('m') ||
      s.contains('homem') ||
      s.contains('mascul') ||
      s.contains('macul');
}

double normalizarAlturaCm(double altura) {
  if (altura <= 0) {
    return 0;
  }
  if (altura < 3.5) {
    return altura * 100;
  }
  return altura;
}

DateTime? parseDataNascimentoTexto(String? texto) {
  final t = (texto ?? '').trim();
  if (t.isEmpty) {
    return null;
  }
  final br = RegExp(r'^(\d{1,2})[/.-](\d{1,2})[/.-](\d{4})$').firstMatch(t);
  if (br != null) {
    final dia = int.tryParse(br.group(1)!);
    final mes = int.tryParse(br.group(2)!);
    final ano = int.tryParse(br.group(3)!);
    if (dia != null && mes != null && ano != null) {
      return DateTime(ano, mes, dia);
    }
  }
  return DateTime.tryParse(t);
}

DateTime? dataNascimentoInformada({
  DateTime? datePicked,
  String? texto,
}) {
  if (datePicked != null) {
    return DateTime(datePicked.year, datePicked.month, datePicked.day);
  }
  return parseDataNascimentoTexto(texto);
}

String formatarDataNascimento(DateTime? data) {
  if (data == null) {
    return '';
  }
  final d = data.day.toString().padLeft(2, '0');
  final m = data.month.toString().padLeft(2, '0');
  return '$d/$m/${data.year}';
}

int idadeDeNascimento(DateTime nascimento) {
  final hoje = DateTime.now();
  var idade = hoje.year - nascimento.year;
  if (hoje.month < nascimento.month ||
      (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
    idade--;
  }
  return idade < 0 ? 0 : idade;
}

String normalizarSexoSalvo(String? sexo) {
  final s = (sexo ?? '').toLowerCase().trim();
  if (s.contains('fem') || s == 'female') {
    return 'feminino';
  }
  return 'masculino';
}

String rotuloSexoPerfil(String? sexo) {
  return sexoEhMasculino(sexo) ? 'Masculino' : 'Feminino';
}

double parseNumeroCampo(String? texto) {
  final limpo = (texto ?? '').trim().replaceAll(',', '.');
  if (limpo.isEmpty) {
    return 0;
  }
  return double.tryParse(limpo) ?? 0;
}

double? tmbCalculadaDoPerfil(UsersRecord? user) {
  if (user == null) {
    return null;
  }
  final nascimento = user.dataNascimento;
  final alturaCm = normalizarAlturaCm(user.altura);
  if (nascimento == null || user.peso <= 0 || alturaCm <= 0) {
    return null;
  }
  return calcularTmb(
    nascimento,
    user.peso,
    alturaCm,
    sexoEhMasculino(user.sexo),
    user.nivelAtividade.toString(),
  );
}

double tmbDoUsuario(UsersRecord? user) {
  if (user == null) {
    return 0.0;
  }
  if (user.tmb > 0) {
    return user.tmb;
  }
  final calculada = tmbCalculadaDoPerfil(user);
  if (calculada != null && calculada > 0) {
    return calculada;
  }
  if (user.get > 0 && user.nivelAtividade > 0) {
    return (user.get / user.nivelAtividade).roundToDouble();
  }
  return 0.0;
}

bool perfilTemTmbUtilizavel(UsersRecord? user) {
  if (user == null) {
    return false;
  }
  return tmbDoUsuario(user) > 0 || user.tmbCalculado;
}

double calculadoraGordura(double calorias) {
  return calorias / 9;
}

double painelSaldoCaloricoDia(
  double tmb,
  double gastoDia,
  double ingestao,
) {
  return (tmb + gastoDia) - ingestao;
}

/// Déficit mostrado no painel: só aparece quando o saldo total supera o TMB.
/// Superávit (saldo negativo) continua sendo exibido integralmente.
double painelDeficitExibidoDia(
  double tmb,
  double gastoDia,
  double ingestao,
) {
  final saldoTotal = painelSaldoCaloricoDia(tmb, gastoDia, ingestao);
  if (saldoTotal < 0) {
    return saldoTotal;
  }
  if (tmb <= 0) {
    return saldoTotal > 0 ? saldoTotal : 0;
  }
  if (saldoTotal > tmb) {
    return saldoTotal - tmb;
  }
  return 0;
}

class PainelSaldoExibido {
  const PainelSaldoExibido({
    required this.mostrarTmb,
    required this.valorKcal,
    required this.rotulo,
    required this.modoVermelho,
    required this.modoVerde,
  });

  final bool mostrarTmb;
  final double valorKcal;
  final String rotulo;
  final bool modoVermelho;
  final bool modoVerde;
}

/// TMB − alimentação só enquanto a ingestão do dia está **abaixo** da TMB.
bool painelUsaTmbMenosAlimentacao(
  double tmb,
  double gastoDia,
  double ingestao,
) {
  return tmb > 0 && ingestao < tmb && gastoDia <= tmb;
}

double painelKcalTmbMenosAlimentacao(
  double tmb,
  double ingestao,
) {
  final kcal = tmb - ingestao;
  return kcal > 0 ? kcal : 0;
}

/// Linha inferior: TMB dourado = gordura a queimar do basal (TMB − alimentação).
/// Ingestão ≥ TMB → déficit/gordura por atividade + alimentação (saldo do dia).
PainelSaldoExibido painelSaldoExibidoDia(
  double tmb,
  double gastoDia,
  double ingestao,
) {
  final saldoTotal = painelSaldoCaloricoDia(tmb, gastoDia, ingestao);

  if (painelUsaTmbMenosAlimentacao(tmb, gastoDia, ingestao)) {
    return PainelSaldoExibido(
      mostrarTmb: true,
      valorKcal: saldoTotal > 0 ? saldoTotal : 0,
      rotulo: 'Déficit calórico atual',
      modoVermelho: false,
      modoVerde: false,
    );
  }

  if (tmb > 0 && gastoDia > tmb && ingestao <= tmb) {
    return PainelSaldoExibido(
      mostrarTmb: false,
      valorKcal: gastoDia - tmb,
      rotulo: 'Déficit calórico atual',
      modoVermelho: false,
      modoVerde: true,
    );
  }

  if (tmb > 0 && ingestao > tmb) {
    if (saldoTotal > 0) {
      return PainelSaldoExibido(
        mostrarTmb: false,
        valorKcal: saldoTotal,
        rotulo: 'Déficit calórico atual',
        modoVermelho: false,
        modoVerde: true,
      );
    }
    return PainelSaldoExibido(
      mostrarTmb: false,
      valorKcal: saldoTotal,
      rotulo: 'Superávit calórico atual',
      modoVermelho: true,
      modoVerde: false,
    );
  }

  if (tmb > 0 && gastoDia > tmb) {
    return PainelSaldoExibido(
      mostrarTmb: false,
      valorKcal: gastoDia - tmb,
      rotulo: 'Déficit calórico atual',
      modoVermelho: false,
      modoVerde: true,
    );
  }

  if (saldoTotal < 0) {
    return PainelSaldoExibido(
      mostrarTmb: false,
      valorKcal: saldoTotal,
      rotulo: 'Superávit calórico atual',
      modoVermelho: true,
      modoVerde: false,
    );
  }

  return PainelSaldoExibido(
    mostrarTmb: false,
    valorKcal: saldoTotal > 0 ? saldoTotal : 0,
    rotulo: rotuloSaldoCaloricoPainel(saldoTotal),
    modoVermelho: false,
    modoVerde: saldoTotal > 0,
  );
}

String textoPainelSaldoExibido(PainelSaldoExibido saldo) {
  if (saldo.mostrarTmb) {
    return saldo.valorKcal.round().toString();
  }
  if (saldo.modoVermelho && saldo.valorKcal > 0) {
    return '+${saldo.valorKcal.round()}';
  }
  return textoSaldoCaloricoPainel(saldo.valorKcal);
}
double painelGorduraOcultaTmbGrams(double tmb) {
  if (tmb <= 0) {
    return 0;
  }
  return tmb / 9;
}

/// Potencial diário de gordura do TMB (se não comer): TMB÷9, menos o que já comeu.
bool painelGorduraQueimarVemDoTmb(
  double tmb,
  double gastoDia,
  double ingestao,
) {
  return tmb > 0 && ingestao < tmb && gastoDia <= tmb;
}

double painelGorduraQueimarTmbGrams(
  double tmb,
  double gastoDia,
  double ingestao,
) {
  if (!painelGorduraQueimarVemDoTmb(tmb, gastoDia, ingestao)) {
    return 0;
  }
  return painelGorduraBasalVisivelGrams(tmb, ingestao);
}

/// Gordura do TMB que estava oculta: diminui conforme a ingestão sobe.
double painelGorduraBasalVisivelGrams(double tmb, double ingestao) {
  final restante =
      painelGorduraOcultaTmbGrams(tmb) - gramasGorduraDeKcal(ingestao);
  return restante > 0 ? restante : 0;
}

class PainelGorduraVisivel {
  const PainelGorduraVisivel({
    required this.emGanho,
    required this.gramas,
    required this.mostrarQueimar,
    this.modoJejumTmb = false,
    this.kcalTmbMenosIngestao = 0,
  });

  final bool emGanho;
  final double gramas;
  final bool mostrarQueimar;
  final bool modoJejumTmb;
  final double kcalTmbMenosIngestao;
}

/// Linha abaixo do nome: potencial fixo do TMB (TMB÷9), sem exibir TMB−ingestão.
double painelTopoGorduraTmbMenosAlimentacao(
  double tmb,
  double gastoDia,
  double ingestao,
) {
  if (!painelUsaTmbMenosAlimentacao(tmb, gastoDia, ingestao)) {
    return 0;
  }
  return painelGorduraOcultaTmbGrams(tmb);
}

/// Card: gordura a queimar do TMB enquanto ingestão < TMB; depois atividade + alimentação.
PainelGorduraVisivel painelGorduraVisivelDia(
  double tmb,
  double gastoDia,
  double ingestao,
) {
  if (tmb <= 0) {
    final saldo = gastoDia - ingestao;
    if (saldo < 0) {
      return PainelGorduraVisivel(
        emGanho: true,
        gramas: gramasGorduraDeKcal(saldo),
        mostrarQueimar: false,
      );
    }
    return PainelGorduraVisivel(
      emGanho: false,
      gramas: gramasGorduraDeKcal(saldo),
      mostrarQueimar: saldo > 0,
    );
  }

  if (ingestao <= tmb && gastoDia <= tmb) {
    final saldoTotal = painelSaldoCaloricoDia(tmb, gastoDia, ingestao);
    if (saldoTotal < 0) {
      return PainelGorduraVisivel(
        emGanho: true,
        gramas: gramasGorduraDeKcal(-saldoTotal),
        mostrarQueimar: false,
      );
    }
    if (saldoTotal > 0) {
      return PainelGorduraVisivel(
        emGanho: false,
        gramas: gramasGorduraDeKcal(saldoTotal),
        mostrarQueimar: true,
      );
    }
    return const PainelGorduraVisivel(
      emGanho: false,
      gramas: 0,
      mostrarQueimar: false,
    );
  }

  final saldoTotal = painelSaldoCaloricoDia(tmb, gastoDia, ingestao);

  if (saldoTotal < 0) {
    return PainelGorduraVisivel(
      emGanho: true,
      gramas: gramasGorduraDeKcal(-saldoTotal),
      mostrarQueimar: false,
    );
  }

  if (gastoDia > tmb && ingestao <= tmb) {
    return PainelGorduraVisivel(
      emGanho: false,
      gramas: gramasGorduraDeKcal(gastoDia - tmb),
      mostrarQueimar: true,
    );
  }

  if (saldoTotal > 0) {
    return PainelGorduraVisivel(
      emGanho: false,
      gramas: gramasGorduraDeKcal(saldoTotal),
      mostrarQueimar: true,
    );
  }

  return const PainelGorduraVisivel(
    emGanho: false,
    gramas: 0,
    mostrarQueimar: false,
  );
}

@Deprecated('Use painelGorduraVisivelDia')
double painelSaldoGorduraDia(
  double gastoDia,
  double ingestao,
) {
  return gastoDia - ingestao;
}

double gramasGorduraDeKcal(double kcal) {
  return kcal.abs() / 9;
}

String rotuloSaldoCaloricoPainel(double saldo) {
  if (saldo < -0.5) {
    return 'Superávit calórico atual';
  }
  if (saldo > 0.5) {
    return 'Déficit calórico atual';
  }
  return 'Saldo calórico do dia';
}

bool metaDeficitDefinidaHoje(dynamic user, String hoje) {
  if (user == null || hoje.isEmpty) {
    return false;
  }
  double deficit = 0;
  String diaMeta = '';
  if (user is UsersRecord) {
    deficit = user.deficitProgramado;
    diaMeta = user.diaMetaProgramada;
  } else if (user is Map) {
    deficit = (user['deficit_programado'] as num?)?.toDouble() ?? 0;
    diaMeta = (user['dia_meta_programada'] as String?) ?? '';
  }
  return deficit > 0 && diaMeta == hoje;
}

String textoSaldoCaloricoPainel(double saldo) {
  final v = saldo.round();
  if (v < 0) {
    return '−${-v}';
  }
  if (v > 0) {
    return '+$v';
  }
  return '0';
}
