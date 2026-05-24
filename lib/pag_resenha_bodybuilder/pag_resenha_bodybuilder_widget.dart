import '/flutter_flow/chat_ui_helpers.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/index.dart';
import 'pag_resenha_bodybuilder_model.dart';
export 'pag_resenha_bodybuilder_model.dart';

class PagResenhaBodybuilderWidget extends StatefulWidget {
  const PagResenhaBodybuilderWidget({super.key});

  static String routeName = 'pag_resenha_bodybuilder';
  static String routePath = '/pagResenhaBodybuilder';

  @override
  State<PagResenhaBodybuilderWidget> createState() =>
      _PagResenhaBodybuilderWidgetState();
}

class _PagResenhaBodybuilderWidgetState
    extends State<PagResenhaBodybuilderWidget> {
  late PagResenhaBodybuilderModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PagResenhaBodybuilderModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _nomeSala(Map<String, dynamic> data, String id) {
    return (data['nome'] ?? data['titulo'] ?? data['display_name'] ?? id)
        .toString();
  }

  Map<String, List<String>> _presencaPorSala(QuerySnapshot? snap) {
    final map = <String, List<String>>{};
    if (snap == null) {
      return map;
    }
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final salaId = (data['sala_id'] ?? '').toString();
      if (salaId.isEmpty) {
        continue;
      }
      final nome = (data['autor_nome'] ?? 'Utilizador').toString();
      map.putIfAbsent(salaId, () => []).add(nome);
    }
    return map;
  }

  void _abrirSala({
    required String salaId,
    required String salaNome,
    required bool espiar,
  }) {
    context.pushNamed(
      SalaChatMensagensWidget.routeName,
      queryParameters: {
        'salaId': salaId,
        'salaNome': salaNome,
        'modoEspiar': serializeParam(espiar, ParamType.bool),
      }.withoutNulls,
    );
  }

  Widget _cardSala({
    required String salaId,
    required String salaNome,
    required int pessoas,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: kChatCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFF2C2C2E)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Color(0x22C6A969),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0x44C6A969)),
            ),
            child: Icon(Icons.door_front_door_outlined,
                color: kChatGold, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salaNome,
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: pessoas > 0 ? kChatOnline : Color(0xFF5A5A5E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pessoas > 0
                            ? '$pessoas pessoas dentro'
                            : 'Ninguém na sala',
                        style: GoogleFonts.inter(
                          color: kChatMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          botaoEspiarSala(
            onPressed: () => _abrirSala(
              salaId: salaId,
              salaNome: salaNome,
              espiar: true,
            ),
          ),
          SizedBox(width: 4),
          botaoEntrarSala(
            onPressed: () => _abrirSala(
              salaId: salaId,
              salaNome: salaNome,
              espiar: false,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kChatBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FlutterFlowIconButton(
                    borderRadius: 22,
                    buttonSize: 44,
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => context.safePop(),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: estiloTituloResenha(context),
                            children: [
                              TextSpan(text: 'Resenha '),
                              TextSpan(
                                text: 'Bodybuilder',
                                style: estiloTituloResenhaDestaque(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Escolha uma sala para entrar',
                          style: GoogleFonts.inter(
                            color: kChatMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('presenca_sala')
                    .snapshots(),
                builder: (context, presSnap) {
                  final presenca = _presencaPorSala(
                    presSnap.hasData ? presSnap.data : null,
                  );
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('salas_chat')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Não foi possível carregar as salas.',
                            style: TextStyle(color: kChatMuted),
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(color: kChatGold),
                        );
                      }

                      final salas = snapshot.data!.docs.isEmpty
                          ? salasChatPadrao()
                              .map(
                                (s) => _SalaListItem(
                                  id: s['id']!,
                                  data: {'nome': s['nome']},
                                ),
                              )
                              .toList()
                          : snapshot.data!.docs
                              .map(
                                (d) => _SalaListItem(
                                  id: d.id,
                                  data: d.data() as Map<String, dynamic>,
                                ),
                              )
                              .toList();

                      salas.sort(
                        (a, b) =>
                            ordemSalaId(a.id).compareTo(ordemSalaId(b.id)),
                      );

                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: salas.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final sala = salas[i];
                          final nome = _nomeSala(sala.data, sala.id);
                          final count = (presenca[sala.id] ?? []).length;
                          return _cardSala(
                            salaId: sala.id,
                            salaNome: nome,
                            pessoas: count,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalaListItem {
  const _SalaListItem({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;
}
