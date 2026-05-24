import 'dart:math' as math;

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/daily_dashboard_reset.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ponto diário para o gráfico evolutivo.
class EvolucaoDiaPoint {
  const EvolucaoDiaPoint({
    required this.dia,
    required this.ingestaoKcal,
    required this.gastoKcal,
    required this.gorduraGramas,
  });

  final DateTime dia;
  final double ingestaoKcal;
  final double gastoKcal;

  /// Positivo = gordura a queimar; negativo = gordura a ganhar.
  final double gorduraGramas;
}

class HistoricoEvolucaoChart extends StatelessWidget {
  const HistoricoEvolucaoChart({
    super.key,
    required this.dias,
    this.height = 200,
  });

  final int dias;
  final double height;

  static double _asDouble(dynamic v) {
    if (v == null) {
      return 0.0;
    }
    if (v is num) {
      return v.toDouble();
    }
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static DateTime? _parseDia(String? dia) {
    if (dia == null || dia.length < 10) {
      return null;
    }
    return DateTime.tryParse(dia);
  }

  static List<EvolucaoDiaPoint> _pointsFromDocs(List<QueryDocumentSnapshot> docs) {
    final list = <EvolucaoDiaPoint>[];
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final diaStr = data['dia']?.toString() ?? doc.id;
      final parsed = _parseDia(diaStr) ?? DateTime.now();
      final ingestao = _asDouble(data['ingestao_calorias_total']);
      final gasto = _asDouble(data['calorias_total_dia']);
      final deficit = _asDouble(data['deficit_efetivo']);
      // Positivo = déficit (queimar); negativo = superávit (ganhar).
      final gorduraG = deficit / 9.0;
      list.add(
        EvolucaoDiaPoint(
          dia: parsed,
          ingestaoKcal: ingestao,
          gastoKcal: gasto,
          gorduraGramas: gorduraG,
        ),
      );
    }
    list.sort((a, b) => a.dia.compareTo(b.dia));
    return list;
  }

  static String _diaKey(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static List<EvolucaoDiaPoint> _mergeDiaAtual(
    List<EvolucaoDiaPoint> points,
    Map<String, dynamic>? userData,
  ) {
    if (userData == null) {
      return points;
    }
    final hojeKey = currentLocalDashboardDayKey();
    final hojeDate = DateTime.tryParse(hojeKey) ?? DateTime.now();
    if (points.any((p) => _diaKey(p.dia) == hojeKey)) {
      return points;
    }

    final ingestao = _asDouble(userData['ingestao_calorias_total']);
    final gasto = _asDouble(userData['calorias_total_dia']);
    final tmb = _asDouble(userData['tmb']);
    if (ingestao <= 0 && gasto <= 0 && tmb <= 0) {
      return points;
    }

    final deficit = (tmb + gasto) - ingestao;
    final merged = [
      ...points,
      EvolucaoDiaPoint(
        dia: hojeDate,
        ingestaoKcal: ingestao,
        gastoKcal: gasto,
        gorduraGramas: deficit / 9.0,
      ),
    ];
    merged.sort((a, b) => a.dia.compareTo(b.dia));
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    final ref = currentUserReference;
    if (ref == null) {
      return const SizedBox.shrink();
    }

    final limit = dias.clamp(5, 90);

    return StreamBuilder<DocumentSnapshot>(
      stream: ref.snapshots(),
      builder: (context, userSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: ref
              .collection('historico_resumo_diario')
              .orderBy('dia', descending: true)
              .limit(limit)
              .snapshots(),
          builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final userData = userSnap.data?.data() as Map<String, dynamic>?;
        var points = snapshot.hasData
            ? _mergeDiaAtual(
                _pointsFromDocs(snapshot.data!.docs),
                userData,
              )
            : _mergeDiaAtual([], userData);

        if (points.isEmpty) {
          return SizedBox(
            height: height,
            child: Center(
              child: Text(
                'Sem histórico ainda.\nUse o painel diariamente ou Zerar '
                'para arquivar cada dia.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFFA1A1A6),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
          );
        }

        if (points.length < 2) {
          final p = points.first;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _resumoDia(p),
              SizedBox(height: 8),
              Text(
                'Registe mais dias para ver a evolução em linhas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B6B70),
                  fontSize: 11,
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: height,
              child: CustomPaint(
                painter: _EvolucaoLinhasPainter(points: points),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _legend('Ingestão', const Color(0xFF38BDF8)),
                _legend('Gasto', const Color(0xFFC6A969)),
                _legend('Gordura (g)', const Color(0xFF22C55E)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Gordura: + queimar · − ganhar (estimativa do saldo do dia)',
              style: GoogleFonts.inter(
                color: const Color(0xFF6B6B70),
                fontSize: 10,
              ),
            ),
          ],
        );
          },
        );
      },
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(color: const Color(0xFFA1A1A6), fontSize: 11),
        ),
      ],
    );
  }

  Widget _resumoDia(EvolucaoDiaPoint p) {
    final gorduraTxt = p.gorduraGramas > 0.5
        ? '${p.gorduraGramas.abs().toStringAsFixed(0)} g a queimar'
        : p.gorduraGramas < -0.5
            ? '${p.gorduraGramas.abs().toStringAsFixed(0)} g a ganhar'
            : 'sem alteração estimada de gordura';
    return Text(
      'Último dia: ingestão ${p.ingestaoKcal.toStringAsFixed(0)} kcal · '
      'gasto ${p.gastoKcal.toStringAsFixed(0)} kcal · $gorduraTxt',
      style: GoogleFonts.inter(
        color: const Color(0xFFA1A1A6),
        fontSize: 11,
        height: 1.35,
      ),
    );
  }
}

class _EvolucaoLinhasPainter extends CustomPainter {
  _EvolucaoLinhasPainter({required this.points});

  final List<EvolucaoDiaPoint> points;

  static const _padLeft = 40.0;
  static const _padRight = 36.0;
  static const _padTop = 8.0;
  static const _padBottom = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = size.width - _padLeft - _padRight;
    final chartH = size.height - _padTop - _padBottom;
    if (chartW <= 0 || chartH <= 0) {
      return;
    }

    final ingestao = points.map((p) => p.ingestaoKcal).toList();
    final gasto = points.map((p) => p.gastoKcal).toList();
    final gordura = points.map((p) => p.gorduraGramas).toList();

    var kcalMin = [...ingestao, ...gasto].reduce(math.min);
    var kcalMax = [...ingestao, ...gasto].reduce(math.max);
    if ((kcalMax - kcalMin).abs() < 50) {
      kcalMin -= 100;
      kcalMax += 100;
    } else {
      kcalMin -= 50;
      kcalMax += 50;
    }

    var gMin = gordura.reduce(math.min);
    var gMax = gordura.reduce(math.max);
    if ((gMax - gMin).abs() < 5) {
      gMin -= 10;
      gMax += 10;
    } else {
      gMin -= 5;
      gMax += 5;
    }

    double xAt(int i) => _padLeft +
        (points.length == 1 ? 0 : i / (points.length - 1)) * chartW;

    double yKcal(double v) =>
        _padTop + chartH - ((v - kcalMin) / (kcalMax - kcalMin)) * chartH;

    double yGordura(double v) =>
        _padTop + chartH - ((v - gMin) / (gMax - gMin)) * chartH;

    final gridPaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = _padTop + chartH * i / 3;
      canvas.drawLine(
        Offset(_padLeft, y),
        Offset(size.width - _padRight, y),
        gridPaint,
      );
    }

    _drawLine(canvas, ingestao, xAt, yKcal, const Color(0xFF38BDF8));
    _drawLine(canvas, gasto, xAt, yKcal, const Color(0xFFC6A969));
    _drawLine(canvas, gordura, xAt, yGordura, const Color(0xFF22C55E), dashed: true);

    final labelStyle = TextStyle(
      color: const Color(0xFF6B6B70),
      fontSize: 8,
      fontFamily: GoogleFonts.inter().fontFamily,
    );
    final tp = TextPainter(textDirection: TextDirection.ltr);

    tp.text = TextSpan(
      text: '${kcalMax.toStringAsFixed(0)}',
      style: labelStyle,
    );
    tp.layout();
    tp.paint(canvas, Offset(2, _padTop));

    tp.text = TextSpan(text: 'kcal', style: labelStyle);
    tp.layout();
    tp.paint(canvas, Offset(2, _padTop + 10));

    tp.text = TextSpan(
      text: '${gMax.toStringAsFixed(0)}g',
      style: labelStyle,
    );
    tp.layout();
    tp.paint(canvas, Offset(size.width - _padRight + 2, _padTop));

    final step = math.max(1, (points.length / 5).ceil());
    for (var i = 0; i < points.length; i += step) {
      final d = points[i].dia;
      final lbl =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
      tp.text = TextSpan(text: lbl, style: labelStyle);
      tp.layout();
      tp.paint(
        canvas,
        Offset(xAt(i) - tp.width / 2, size.height - _padBottom + 2),
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    List<double> values,
    double Function(int) xAt,
    double Function(double) yAt,
    Color color, {
    bool dashed = false,
  }) {
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final p = Offset(xAt(i), yAt(values[i]));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = dashed ? 1.5 : 2
      ..style = PaintingStyle.stroke;
    if (dashed) {
      paint.strokeCap = StrokeCap.round;
      _drawDashedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }

    final dotPaint = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(Offset(xAt(i), yAt(values[i])), dashed ? 2.5 : 3, dotPaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final len = math.min(dash, metric.length - dist);
        canvas.drawPath(metric.extractPath(dist, dist + len), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EvolucaoLinhasPainter oldDelegate) =>
      oldDelegate.points != points;
}
