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
  // 1. Calcular a idade a partir da data de nascimento
  final hoje = DateTime.now();
  int idade = hoje.year - dataDeNascimento.year;
  if (hoje.month < dataDeNascimento.month ||
      (hoje.month == dataDeNascimento.month &&
          hoje.day < dataDeNascimento.day)) {
    idade--;
  }

  // Harris-Benedict revisada (peso kg, altura cm, idade anos).
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
      s.contains('macul'); // typo comum no projeto
}

/// Converte altura em metros (ex.: 1,75) para centímetros (175).
double normalizarAlturaCm(double altura) {
  if (altura <= 0) {
    return 0;
  }
  if (altura < 3.5) {
    return altura * 100;
  }
  return altura;
}

/// Interpreta data digitada (dd/mm/aaaa, dd-mm-aaaa, etc.).
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

/// TMB a partir do perfil (sem usar o campo `tmb` guardado).
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

/// TMB guardada no Firebase ou calculada a partir do perfil.
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

/// Perfil tem TMB utilizável (guardada, calculável ou via GET).
bool perfilTemTmbUtilizavel(UsersRecord? user) {
  if (user == null) {
    return false;
  }
  return tmbDoUsuario(user) > 0 || user.tmbCalculado;
}

double calculadoraGordura(double calorias) {
  return calorias / 9;
}

/// Saldo do dia: positivo = déficit (gasta mais do que come); negativo = superávit.
double painelSaldoCaloricoDia(
  double tmb,
  double gastoDia,
  double ingestao,
) {
  return (tmb + gastoDia) - ingestao;
}

/// Gordura a queimar/ganhar: só atividade vs ingestão (TMB mantém o corpo, não queima gordura).
double painelSaldoGorduraDia(
  double gastoDia,
  double ingestao,
) {
  return gastoDia - ingestao;
}

/// Gramas de gordura equivalentes às kcal (1 g ≈ 9 kcal).
double gramasGorduraDeKcal(double kcal) {
  return kcal.abs() / 9;
}

/// Rótulo do saldo: negativo = superávit (vermelho), positivo = déficit (verde).
String rotuloSaldoCaloricoPainel(double saldo) {
  if (saldo < -0.5) {
    return 'Superávit calórico atual';
  }
  if (saldo > 0.5) {
    return 'Déficit calórico atual';
  }
  return 'Saldo calórico do dia';
}

/// Valor formatado para o painel (evita cortar dígitos, ex.: −928 em vez de −028).
/// Meta de déficit registada em **Programar déficit** no dia civil [hoje].
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
