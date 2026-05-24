import '/backend/schema/registros_bioimpedancia_record.dart';
import '/components/bioimpedancia_evolution_chart.dart';
import '/services/bioimpedancia_evolution_notifier.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Parecer comparando o registo mais recente com o anterior.
class BioimpedanciaParecerCard extends StatelessWidget {
  const BioimpedanciaParecerCard({
    super.key,
    required this.atual,
    this.anterior,
    this.destaqueAposRegisto = false,
  });

  final RegistrosBioimpedanciaRecord atual;
  final RegistrosBioimpedanciaRecord? anterior;
  final bool destaqueAposRegisto;

  @override
  Widget build(BuildContext context) {
    final msg = buildBioimpedanciaEvolutionMessage(
      anterior: anterior,
      atual: atual,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: destaqueAposRegisto
              ? const Color(0x88C6A969)
              : const Color(0xFF2A2A2E),
          width: destaqueAposRegisto ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                destaqueAposRegisto
                    ? Icons.notifications_active_outlined
                    : Icons.insights_outlined,
                color: const Color(0xFFC6A969),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  destaqueAposRegisto ? 'Novo parecer' : 'Parecer da evolução',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            msg.body.split('\n').first,
            style: GoogleFonts.inter(
              color: const Color(0xFFC6A969),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (anterior != null) ...[
            const SizedBox(height: 12),
            Text(
              'Comparativo com registo anterior',
              style: GoogleFonts.inter(
                color: const Color(0xFFA1A1A6),
                fontSize: 11,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          ...msg.metricas.map(_metricRow),
          if (anterior == null) ...[
            const SizedBox(height: 8),
            Text(
              'Registe novamente em outro dia para ver a comparação automática.',
              style: GoogleFonts.inter(
                color: const Color(0xFF6B6B70),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricRow(BioimpedanciaMetricParecer m) {
    Color cor;
    IconData icon;
    String deltaTxt;

    if (anterior == null && m.anterior == 0) {
      cor = const Color(0xFFA1A1A6);
      icon = Icons.circle_outlined;
      deltaTxt = '${m.atual.toStringAsFixed(1)}%';
    } else if (m.isEstavel) {
      cor = const Color(0xFFA1A1A6);
      icon = Icons.remove_rounded;
      deltaTxt = 'estável · ${m.atual.toStringAsFixed(1)}%';
    } else if (m.isMelhor) {
      cor = const Color(0xFF22C55E);
      icon = m.menorEhMelhor ? Icons.trending_down_rounded : Icons.trending_up_rounded;
      final sign = m.delta > 0 ? '+' : '';
      deltaTxt = '$sign${m.delta.toStringAsFixed(1)} p.p. · ${m.atual.toStringAsFixed(1)}%';
    } else {
      cor = const Color(0xFFEF4444);
      icon = m.menorEhMelhor ? Icons.trending_up_rounded : Icons.trending_down_rounded;
      final sign = m.delta > 0 ? '+' : '';
      deltaTxt = '$sign${m.delta.toStringAsFixed(1)} p.p. · ${m.atual.toStringAsFixed(1)}%';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: cor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              m.nome,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            ),
          ),
          Text(
            deltaTxt,
            style: GoogleFonts.inter(
              color: cor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

List<RegistrosBioimpedanciaRecord> sortBioimpedanciaRecords(
  List<RegistrosBioimpedanciaRecord> records,
) {
  final sorted = List<RegistrosBioimpedanciaRecord>.from(records);
  sorted.sort((a, b) {
    final da = a.dataRegistro ?? a.dataBio ?? DateTime.fromMillisecondsSinceEpoch(0);
    final db = b.dataRegistro ?? b.dataBio ?? DateTime.fromMillisecondsSinceEpoch(0);
    return db.compareTo(da);
  });
  return sorted;
}

List<BioimpedanciaChartPoint> bioPointsFromRecords(
  List<RegistrosBioimpedanciaRecord> records,
) {
  final sorted = List<RegistrosBioimpedanciaRecord>.from(records);
  sorted.sort((a, b) {
    final da = a.dataRegistro ?? a.dataBio ?? DateTime.fromMillisecondsSinceEpoch(0);
    final db = b.dataRegistro ?? b.dataBio ?? DateTime.fromMillisecondsSinceEpoch(0);
    return da.compareTo(db);
  });
  return sorted
      .map(
        (r) => BioimpedanciaChartPoint(
          date: r.dataRegistro ?? r.dataBio ?? DateTime.now(),
          gordura: r.percGordura,
          musculo: r.percMusculo,
          agua: r.percAgua,
        ),
      )
      .toList();
}
