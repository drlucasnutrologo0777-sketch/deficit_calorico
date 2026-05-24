import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/services/coach_mensagens_service.dart';

/// Card compacto de coach motivacional (JSON local, paridade 114+).
class CoachCard extends StatelessWidget {
  const CoachCard({
    super.key,
    required this.nomeUsuario,
  });

  final String nomeUsuario;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CoachMensagem>(
      future: coachMensagemDoDia(nome: nomeUsuario),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        final msg = snapshot.data!;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF141416),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: Color(0x33C6A969)),
          ),
          padding: EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology_outlined, color: Color(0xFFC6A969), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Coach do dia',
                      style: GoogleFonts.interTight(
                        color: Color(0xFFC6A969),
                        fontWeight: FontWeight.w700,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                msg.titulo,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
                ),
              ),
              SizedBox(height: 6),
              Text(
                msg.corpo,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Color(0xFFA1A1A6),
                  fontSize: 12.0,
                  height: 1.45,
                ),
              ),
              if (msg.credito != null && msg.credito!.isNotEmpty) ...[
                SizedBox(height: 6),
                Text(
                  msg.credito!,
                  style: GoogleFonts.inter(
                    color: Color(0xFF5A5A5E),
                    fontSize: 10.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
