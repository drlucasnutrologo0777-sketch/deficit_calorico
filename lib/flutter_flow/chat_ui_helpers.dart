import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kChatGold = Color(0xFFC6A969);
const kChatBg = Color(0xFF000000);
const kChatCard = Color(0xFF1C1C1E);
const kChatSidebar = Color(0xFF0D0D0F);
const kChatOnline = Color(0xFF22C55E);
const kChatMuted = Color(0xFF8E8E93);

const kCoresUtilizadorChat = <Color>[
  Color(0xFF22C55E),
  Color(0xFFF97316),
  Color(0xFFA855F7),
  Color(0xFF38BDF8),
  Color(0xFFF472B6),
  Color(0xFFEAB308),
  Color(0xFF14B8A6),
  Color(0xFFEF4444),
];

const kAtalhosMensagemChat = <(String emoji, String texto)>[
  ('🔥', 'Bora treinar!'),
  ('💪', 'Foco no objetivo'),
  ('👏', 'Boa!'),
  ('🙏', 'Motivação'),
  ('💧', 'Beba água!'),
];

Color corUtilizadorChat(String nome) {
  if (nome.isEmpty) {
    return kCoresUtilizadorChat.first;
  }
  return kCoresUtilizadorChat[nome.hashCode.abs() % kCoresUtilizadorChat.length];
}

String inicialUtilizador(String nome) {
  final limpo = nome.trim();
  if (limpo.isEmpty) {
    return '?';
  }
  return limpo.substring(0, 1).toUpperCase();
}

String horaMensagem(dynamic createdAt) {
  if (createdAt is Timestamp) {
    final d = createdAt.toDate().toLocal();
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
  return '';
}

List<Map<String, String>> salasChatPadrao() {
  return List.generate(
    10,
    (i) => {
      'id': 'sala_${i + 1}',
      'nome': 'Sala ${i + 1}',
    },
  );
}

int ordemSalaId(String id) {
  final match = RegExp(r'(\d+)').firstMatch(id);
  if (match != null) {
    return int.tryParse(match.group(1)!) ?? 0;
  }
  return id.hashCode;
}

TextStyle estiloTituloResenha(BuildContext context) => GoogleFonts.interTight(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 28,
      height: 1.1,
    );

TextStyle estiloTituloResenhaDestaque() => GoogleFonts.interTight(
      color: kChatGold,
      fontWeight: FontWeight.bold,
      fontSize: 28,
      height: 1.1,
    );

Widget botaoEspiarSala({required VoidCallback onPressed}) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search_rounded, color: kChatMuted, size: 18),
        SizedBox(height: 2),
        Text(
          'Espiar',
          style: GoogleFonts.inter(
            color: kChatMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget botaoEntrarSala({required VoidCallback onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: kChatGold,
      foregroundColor: Colors.black,
      elevation: 0,
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      minimumSize: Size(0, 36),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
    ),
    child: Text(
      'Entrar',
      style: GoogleFonts.interTight(
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    ),
  );
}

Widget atalhoMensagemPill({
  required String emoji,
  required String texto,
  required VoidCallback? onTap,
}) {
  return Material(
    color: kChatCard,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF2C2C2E)),
        ),
        child: Text(
          '$emoji $texto',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ),
    ),
  );
}
