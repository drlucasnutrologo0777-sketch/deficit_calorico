import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/app_state.dart';

/// Indica que o utilizador já usou **Zerar** manualmente no dia civil actual.
class ManualDailyResetAlreadyUsedTodayException implements Exception {
  const ManualDailyResetAlreadyUsedTodayException();

  @override
  String toString() =>
      'ManualDailyResetAlreadyUsedTodayException: Zerar já foi '
      'utilizado neste dia.';
}

/// Chave yyyy-MM-dd pelo **relógio local** do telemóvel (não UTC).
String currentLocalDashboardDayKey() {
  final n = DateTime.now();
  final m = n.month.toString().padLeft(2, '0');
  final d = n.day.toString().padLeft(2, '0');
  return '${n.year}-$m-$d';
}

/// Lê `dia_resumo_dashboard` como String (Firestore pode gravar formatos diferentes).
String readDashboardDayKey(dynamic raw) {
  if (raw == null) {
    return '';
  }
  if (raw is String) {
    return raw;
  }
  if (raw is Timestamp) {
    final local = raw.toDate().toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '${local.year}-$m-$d';
  }
  return raw.toString();
}

bool _resetInProgress = false;

double _asDouble(dynamic v) {
  if (v == null) {
    return 0.0;
  }
  if (v is num) {
    return v.toDouble();
  }
  return double.tryParse(v.toString()) ?? 0.0;
}

/// Grava snapshot do dia em `/users/{uid}/historico_resumo_diario/{yyyy-MM-dd}`.
Future<void> archiveDashboardDaySnapshot(
  DocumentReference userRef,
  String dayKey,
  Map<String, dynamic> userData,
) async {
  if (dayKey.isEmpty) {
    return;
  }

  final ingestao = _asDouble(userData['ingestao_calorias_total']);
  final gasto = _asDouble(userData['calorias_total_dia']);
  final tmb = _asDouble(userData['tmb']);
  // Mesma fórmula do painel: (TMB + gasto) − ingestão.
  final saldoPainel = (tmb + gasto) - ingestao;

  await userRef.collection('historico_resumo_diario').doc(dayKey).set(
    {
      'dia': dayKey,
      'ingestao_calorias_total': ingestao,
      'calorias_total_dia': gasto,
      'carboidrato_dia': _asDouble(userData['carboidrato_dia']),
      'proteina_dia': _asDouble(userData['proteina_dia']),
      'gordura_dia': _asDouble(userData['gordura_dia']),
      'deficit_programado': _asDouble(userData['deficit_programado']),
      'gordura_a_queimar': _asDouble(userData['gordura_a_queimar']),
      'get': _asDouble(userData['get']),
      'tmb': tmb,
      'deficit_efetivo': saldoPainel,
      'gordura_estimada_g': saldoPainel.abs() / 9.0,
      'arquivado_em': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );
}

Future<void> _zeroDashboardTotalsOnUser(
  DocumentReference userRef, {
  bool markManualResetUsedToday = false,
  bool clearDailyMeta = false,
}) async {
  final hoje = currentLocalDashboardDayKey();
  final payload = <String, dynamic>{
    'dia_resumo_dashboard': hoje,
    'ingestao_calorias_total': 0.0,
    'calorias_total_dia': 0.0,
    'carboidrato_dia': 0.0,
    'proteina_dia': 0.0,
    'gordura_dia': 0.0,
  };
  if (clearDailyMeta) {
    payload['deficit_programado'] = 0.0;
    payload['gordura_a_queimar'] = 0.0;
    payload['dia_meta_programada'] = '';
  }
  if (markManualResetUsedToday) {
    payload['dia_ultimo_zerar_manual_resumo'] = hoje;
  }
  await userRef.update(payload);
}

/// Se `dia_resumo_dashboard` ≠ hoje civil local, arquiva o dia anterior e zera
/// os totais do card **Resumo do Dia**.
Future<void> ensureDailyDashboardTotalsIfNewCalendarDay(
  DocumentReference userRef,
  Map<String, dynamic> userSnapshotData,
) async {
  if (_resetInProgress) {
    return;
  }

  final hoje = currentLocalDashboardDayKey();
  final ultimo = readDashboardDayKey(userSnapshotData['dia_resumo_dashboard']);

  if (ultimo == hoje) {
    return;
  }

  _resetInProgress = true;
  try {
    if (ultimo.isNotEmpty) {
      try {
        await archiveDashboardDaySnapshot(userRef, ultimo, userSnapshotData);
      } catch (_) {
        /* histórico opcional — não impede limpar o painel */
      }
    }

    await _zeroDashboardTotalsOnUser(userRef, clearDailyMeta: true);
    FFAppState().syncLocalStateAfterDailyTotalsReset(clearDailyMeta: true);
  } finally {
    _resetInProgress = false;
  }
}

/// Busca o documento no servidor e aplica o reset se mudou o dia civil local.
Future<void> refreshDailyDashboardResetFromServer() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null || uid.isEmpty) {
    return;
  }
  final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
  final snap = await userRef.get(const GetOptions(source: Source.server));
  if (!snap.exists) {
    return;
  }
  final data = snap.data();
  if (data == null) {
    return;
  }
  await ensureDailyDashboardTotalsIfNewCalendarDay(
    userRef,
    Map<String, dynamic>.from(data),
  );
}

/// Zera totais do dia actual (1× por dia civil). Arquiva antes para o gráfico.
Future<void> manualResetDailyDashboardTotals(DocumentReference userRef) async {
  final ds = await userRef.get();
  final snap = ds.data();
  final Map<String, dynamic> data =
      snap == null ? {} : Map<String, dynamic>.from(snap as Map);
  final hoje = currentLocalDashboardDayKey();

  final marcador = data['dia_ultimo_zerar_manual_resumo'];
  final marcadorStr = readDashboardDayKey(marcador);
  if (marcadorStr == hoje) {
    throw const ManualDailyResetAlreadyUsedTodayException();
  }

  try {
    await archiveDashboardDaySnapshot(userRef, hoje, data);
  } catch (_) {
    /* histórico opcional */
  }

  await _zeroDashboardTotalsOnUser(
    userRef,
    markManualResetUsedToday: true,
  );
  FFAppState().syncLocalStateAfterDailyTotalsReset();
}
