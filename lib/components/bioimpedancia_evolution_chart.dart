import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ponto no gráfico de bioimpedância (%).
class BioimpedanciaChartPoint {
  const BioimpedanciaChartPoint({
    required this.date,
    required this.gordura,
    required this.musculo,
    required this.agua,
  });

  final DateTime date;
  final double gordura;
  final double musculo;
  final double agua;
}

class BioimpedanciaEvolutionChart extends StatelessWidget {
  const BioimpedanciaEvolutionChart({
    super.key,
    required this.points,
    this.height = 200,
  });

  final List<BioimpedanciaChartPoint> points;
  final double height;

  static const _corGordura = Color(0xFFEF4444);
  static const _corMusculo = Color(0xFFC6A969);
  static const _corAgua = Color(0xFF38BDF8);

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return Container(
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          points.isEmpty
              ? 'Registe a primeira bioimpedância para ver a evolução.'
              : 'Registe mais um ponto para traçar o gráfico.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFFA1A1A6),
            fontSize: 12,
            height: 1.35,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: CustomPaint(
            painter: _BioimpedanciaLinesPainter(points: points),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            _legend('Gordura', _corGordura),
            _legend('Músculo', _corMusculo),
            _legend('Água', _corAgua),
          ],
        ),
      ],
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFFA1A1A6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _BioimpedanciaLinesPainter extends CustomPainter {
  _BioimpedanciaLinesPainter({required this.points});

  final List<BioimpedanciaChartPoint> points;

  static const _padLeft = 36.0;
  static const _padRight = 8.0;
  static const _padTop = 8.0;
  static const _padBottom = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = size.width - _padLeft - _padRight;
    final chartH = size.height - _padTop - _padBottom;
    if (chartW <= 0 || chartH <= 0) {
      return;
    }

    final allY = [
      ...points.map((p) => p.gordura),
      ...points.map((p) => p.musculo),
      ...points.map((p) => p.agua),
    ];
    var yMin = allY.reduce(math.min);
    var yMax = allY.reduce(math.max);
    if ((yMax - yMin).abs() < 1) {
      yMin -= 2;
      yMax += 2;
    } else {
      yMin -= 1;
      yMax += 1;
    }

    double xAt(int i) =>
        _padLeft + (points.length == 1 ? 0 : i / (points.length - 1)) * chartW;

    double yAt(double v) =>
        _padTop + chartH - ((v - yMin) / (yMax - yMin)) * chartH;

    final gridPaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = _padTop + chartH * i / 3;
      canvas.drawLine(Offset(_padLeft, y), Offset(size.width - _padRight, y), gridPaint);
    }

    _drawSeries(
      canvas,
      points.map((p) => p.gordura).toList(),
      xAt,
      yAt,
      const Color(0xFFEF4444),
    );
    _drawSeries(
      canvas,
      points.map((p) => p.musculo).toList(),
      xAt,
      yAt,
      const Color(0xFFC6A969),
    );
    _drawSeries(
      canvas,
      points.map((p) => p.agua).toList(),
      xAt,
      yAt,
      const Color(0xFF38BDF8),
    );

    final labelStyle = TextStyle(
      color: const Color(0xFF6B6B70),
      fontSize: 9,
      fontFamily: GoogleFonts.inter().fontFamily,
    );
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(text: '${yMax.toStringAsFixed(0)}%', style: labelStyle);
    tp.layout();
    tp.paint(canvas, Offset(2, _padTop - 2));

    tp.text = TextSpan(text: '${yMin.toStringAsFixed(0)}%', style: labelStyle);
    tp.layout();
    tp.paint(canvas, Offset(2, _padTop + chartH - tp.height));

    final step = math.max(1, (points.length / 5).ceil());
    for (var i = 0; i < points.length; i += step) {
      final d = points[i].date;
      final lbl = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
      tp.text = TextSpan(text: lbl, style: labelStyle);
      tp.layout();
      tp.paint(
        canvas,
        Offset(xAt(i) - tp.width / 2, size.height - _padBottom + 4),
      );
    }
    if ((points.length - 1) % step != 0) {
      final d = points.last.date;
      final lbl = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
      tp.text = TextSpan(text: lbl, style: labelStyle);
      tp.layout();
      tp.paint(
        canvas,
        Offset(xAt(points.length - 1) - tp.width / 2, size.height - _padBottom + 4),
      );
    }
  }

  void _drawSeries(
    Canvas canvas,
    List<double> values,
    double Function(int) xAt,
    double Function(double) yAt,
    Color color,
  ) {
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final p = Offset(xAt(i), yAt(values[i]));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(Offset(xAt(i), yAt(values[i])), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BioimpedanciaLinesPainter oldDelegate) =>
      oldDelegate.points != points;
}
