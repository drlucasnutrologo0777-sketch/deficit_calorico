import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/chat_ui_helpers.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/chat_presenca_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalaChatMensagensWidget extends StatefulWidget {
  const SalaChatMensagensWidget({
    super.key,
    required this.salaId,
    this.salaNome = 'Sala',
    this.modoEspiar = false,
  });

  final String salaId;
  final String salaNome;
  final bool modoEspiar;

  static String routeName = 'sala_chat_mensagens';
  static String routePath = '/salaChatMensagens';

  @override
  State<SalaChatMensagensWidget> createState() =>
      _SalaChatMensagensWidgetState();
}

class _SalaChatMensagensWidgetState extends State<SalaChatMensagensWidget> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  late bool _modoEspiar;
  int _ultimoTotalMensagens = 0;

  DocumentReference? get _salaRef =>
      FirebaseFirestore.instance.collection('salas_chat').doc(widget.salaId);

  bool get _podeParticipar => !_modoEspiar;

  @override
  void initState() {
    super.initState();
    _modoEspiar = widget.modoEspiar;
    if (_podeParticipar) {
      ChatPresencaService.instance.entrar(widget.salaId);
    }
  }

  @override
  void dispose() {
    if (_podeParticipar) {
      ChatPresencaService.instance.sair();
    }
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _textoMsg(Map<String, dynamic> data) {
    return (data['texto'] ??
            data['mensagem'] ??
            data['conteudo'] ??
            data['body'] ??
            '')
        .toString();
  }

  String _autorMsg(Map<String, dynamic> data) {
    return (data['autor_nome'] ??
            data['nome_autor'] ??
            data['display_name'] ??
            'Utilizador')
        .toString();
  }

  Future<void> _entrarNaSala() async {
    setState(() => _modoEspiar = false);
    await ChatPresencaService.instance.entrar(widget.salaId);
  }

  Future<void> _sairDaSala() async {
    await ChatPresencaService.instance.sair();
    if (mounted) {
      context.safePop();
    }
  }

  Future<void> _enviar([String? textoOverride]) async {
    if (!_podeParticipar) {
      return;
    }
    final texto = (textoOverride ?? _textController.text).trim();
    if (texto.isEmpty || currentUserReference == null || _sending) {
      return;
    }
    setState(() => _sending = true);
    try {
      await FirebaseFirestore.instance.collection('mensagens_chat').add({
        'texto': texto,
        'sala_id': widget.salaId,
        'sala_ref': _salaRef,
        'user_ref': currentUserReference,
        'autor_nome': currentUserDisplayName.isNotEmpty
            ? currentUserDisplayName
            : 'Utilizador',
        'created_at': FieldValue.serverTimestamp(),
      });
      await ChatPresencaService.instance.entrar(widget.salaId);
      if (textoOverride == null) {
        _textController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível enviar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  List<String> _nomesPresenca(QuerySnapshot? snap) {
    final nomes = <String>[];
    if (snap == null) {
      return nomes;
    }
    for (final d in snap.docs) {
      final data = d.data() as Map<String, dynamic>;
      nomes.add((data['autor_nome'] ?? 'Utilizador').toString());
    }
    return nomes;
  }

  Widget _mensagemTile(Map<String, dynamic> data) {
    final autor = _autorMsg(data);
    final cor = corUtilizadorChat(autor);
    final hora = horaMensagem(data['created_at']);

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: cor.withValues(alpha: 0.55), width: 1.5),
            ),
            child: Text(
              inicialUtilizador(autor),
              style: GoogleFonts.interTight(
                color: cor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        autor,
                        style: GoogleFonts.inter(
                          color: cor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hora.isNotEmpty) ...[
                      SizedBox(width: 6),
                      Text(
                        hora,
                        style: GoogleFonts.inter(
                          color: Color(0xFF636366),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  _textoMsg(data),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarParticipantes(List<String> nomes) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kChatSidebar,
        border: Border(left: BorderSide(color: Color(0xFF2C2C2E), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 12, 8, 8),
            child: Text(
              'NA SALA (${nomes.length})',
              style: GoogleFonts.interTight(
                color: kChatGold,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Expanded(
            child: nomes.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Ninguém',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Color(0xFF636366),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    itemCount: nomes.length,
                    itemBuilder: (context, i) {
                      final nome = nomes[i];
                      final cor = corUtilizadorChat(nome);
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: cor, width: 2),
                              ),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                nome,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8, 4, 8, 10),
            child: _modoEspiar
                ? ElevatedButton(
                    onPressed: _entrarNaSala,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kChatGold,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Entrar',
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: _sairDaSala,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFFEF4444),
                      side: BorderSide(color: Color(0xFFEF4444)),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Sair da sala',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _listaMensagens() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mensagens_chat')
          .where('sala_id', isEqualTo: widget.salaId)
          .limit(200)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final err = snapshot.error.toString();
          final precisaRegras = err.contains('permission') ||
              err.contains('PERMISSION_DENIED');
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                precisaRegras
                    ? 'Publique as regras Firestore para ver o chat.'
                    : 'Erro: $err',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: kChatMuted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: kChatGold, strokeWidth: 2),
          );
        }
        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final da = a.data() as Map<String, dynamic>;
            final db = b.data() as Map<String, dynamic>;
            final ta = da['created_at'];
            final tb = db['created_at'];
            if (ta is Timestamp && tb is Timestamp) {
              return ta.compareTo(tb);
            }
            return a.id.compareTo(b.id);
          });

        if (docs.length != _ultimoTotalMensagens) {
          _ultimoTotalMensagens = docs.length;
          _scrollParaFim();
        }

        if (docs.isEmpty) {
          return Center(
            child: Text(
              _modoEspiar
                  ? 'Sem mensagens.'
                  : 'Seja o primeiro\na escrever.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: kChatMuted, fontSize: 12),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(10, 8, 6, 8),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            return _mensagemTile(docs[i].data() as Map<String, dynamic>);
          },
        );
      },
    );
  }

  Widget _areaInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10, 4, 10, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Mensagem para Todos…',
                    hintStyle: GoogleFonts.inter(
                      color: Color(0xFF636366),
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: kChatCard,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: Color(0xFF2C2C2E)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: Color(0xFF2C2C2E)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _enviar(),
                ),
              ),
              SizedBox(width: 6),
              Material(
                color: kChatGold,
                shape: CircleBorder(),
                child: InkWell(
                  customBorder: CircleBorder(),
                  onTap: _sending ? null : () => _enviar(),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: _sending
                        ? Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.black,
                            size: 26,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 8),
            itemCount: kAtalhosMensagemChat.length,
            separatorBuilder: (_, __) => SizedBox(width: 6),
            itemBuilder: (context, i) {
              final (emoji, texto) = kAtalhosMensagemChat[i];
              return atalhoMensagemPill(
                emoji: emoji,
                texto: texto,
                onTap: _sending ? null : () => _enviar('$emoji $texto'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _colunaChat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_modoEspiar)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: Color(0xFF141418),
            child: Text(
              'Modo espiar',
              style: GoogleFonts.inter(
                color: kChatMuted,
                fontSize: 10,
              ),
            ),
          ),
        Expanded(child: _listaMensagens()),
        if (_podeParticipar)
          SafeArea(top: false, child: _areaInput())
        else
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Toque Entrar na barra lateral para participar.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: kChatMuted, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kChatBg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('presenca_sala')
              .where('sala_id', isEqualTo: widget.salaId)
              .snapshots(),
          builder: (context, presSnap) {
            final nomes = _nomesPresenca(
              presSnap.hasData ? presSnap.data : null,
            );
            final count = nomes.length;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(2, 2, 8, 6),
                  child: Row(
                    children: [
                      FlutterFlowIconButton(
                        borderRadius: 22,
                        buttonSize: 40,
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18),
                        onPressed: () => context.safePop(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.salaNome,
                              style: GoogleFonts.interTight(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: count > 0
                                        ? kChatOnline
                                        : Color(0xFF5A5A5E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  '$count pessoas dentro',
                                  style: GoogleFonts.inter(
                                    color: kChatMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.people_alt_outlined, color: kChatGold, size: 22),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 7, child: _colunaChat()),
                      Expanded(flex: 3, child: _sidebarParticipantes(nomes)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
