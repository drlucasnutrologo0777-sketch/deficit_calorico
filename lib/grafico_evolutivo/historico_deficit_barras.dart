import 'dart:math' as math;

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Barras dos últimos dias em `/users/{uid}/historico_resumo_diario/{yyyy-MM-dd}`.
class HistoricoDeficitBarras extends StatelessWidget {
  const HistoricoDeficitBarras({super.key});

  static const _diaSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  static double _asDouble(dynamic v) {
    if (v == null) {
      return 0.0;
    }
    if (v is num) {
      return v.toDouble();
    }
    return double.tryParse(v.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final ref = currentUserReference;
    if (ref == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: ref
          .collection('historico_resumo_diario')
          .orderBy('dia', descending: true)
          .limit(7)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Sem histórico ainda.\nRegiste dias ou use Zerar para arquivar.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFFA1A1A6),
                fontSize: 11.0,
                height: 1.3,
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final da = (a.data() as Map)['dia']?.toString() ?? '';
            final db = (b.data() as Map)['dia']?.toString() ?? '';
            return da.compareTo(db);
          });

        final values = docs
            .map((d) => _asDouble((d.data() as Map)['deficit_efetivo']))
            .toList();
        final maxAbs = values.fold<double>(
          1.0,
          (m, v) => math.max(m, v.abs()),
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(docs.length, (i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final dia = data['dia']?.toString() ?? '';
            final deficit = _asDouble(data['deficit_efetivo']);
            final h = (deficit.abs() / maxAbs * 72).clamp(4.0, 72.0);
            final color = deficit >= 0
                ? const Color(0xFF30D158)
                : const Color(0xFFCF6679);
            DateTime? parsed;
            if (dia.length >= 10) {
              parsed = DateTime.tryParse(dia);
            }
            final label = parsed != null
                ? _diaSemana[(parsed.weekday - 1) % 7]
                : dia.substring(math.max(0, dia.length - 2));

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 3.0,
                  height: h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    label,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          color: const Color(0xFFA1A1A6),
                          fontSize: 10.0,
                        ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
