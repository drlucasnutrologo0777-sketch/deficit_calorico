import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/bioimpedancia_evolution_chart.dart';
import '/components/bioimpedancia_parecer_card.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/services/bioimpedancia_evolution_notifier.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pag_registrar_bioimpedancia_model.dart';
export 'pag_registrar_bioimpedancia_model.dart';

class PagRegistrarBioimpedanciaWidget extends StatefulWidget {
  const PagRegistrarBioimpedanciaWidget({super.key});

  static String routeName = 'pag_registrar_bioimpedancia';
  static String routePath = '/pagRegistrarBioimpedancia';

  @override
  State<PagRegistrarBioimpedanciaWidget> createState() =>
      _PagRegistrarBioimpedanciaWidgetState();
}

class _PagRegistrarBioimpedanciaWidgetState
    extends State<PagRegistrarBioimpedanciaWidget> {
  late PagRegistrarBioimpedanciaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  bool _salvando = false;
  String? _registoDestaqueId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PagRegistrarBioimpedanciaModel());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _model.dispose();
    super.dispose();
  }

  double? _parsePercent(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: Color(0xFFA1A1A6)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0x22FFFFFF)),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFC6A969)),
        borderRadius: BorderRadius.circular(12.0),
      ),
      filled: true,
      fillColor: Color(0xFF141416),
    );
  }

  void _limparFormulario() {
    _model.gorduraController?.clear();
    _model.musculoController?.clear();
    _model.aguaController?.clear();
    _model.outrosController?.clear();
  }

  Future<void> _salvar() async {
    if (_salvando || currentUserReference == null) {
      return;
    }

    final gordura = _parsePercent(_model.gorduraController!.text);
    final musculo = _parsePercent(_model.musculoController!.text);
    final agua = _parsePercent(_model.aguaController!.text);
    final outros = _parsePercent(_model.outrosController!.text) ?? 0.0;

    if (gordura == null || musculo == null || agua == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha gordura, músculo e água (%).')),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final anteriores = await queryRegistrosBioimpedanciaRecordOnce(
        queryBuilder: (q) =>
            q.where('user_ref', isEqualTo: currentUserReference),
      );
      final ordenados = sortBioimpedanciaRecords(anteriores);
      final anterior = ordenados.isNotEmpty ? ordenados.first : null;

      final agora = getCurrentTimestamp;
      final docRef = RegistrosBioimpedanciaRecord.collection.doc();
      await docRef.set(createRegistrosBioimpedanciaRecordData(
        percGordura: gordura,
        percMusculo: musculo,
        percAgua: agua,
        percOutros: outros,
        dataRegistro: agora,
        dataBio: agora,
        userRef: currentUserReference,
      ));

      final atual = RegistrosBioimpedanciaRecord.getDocumentFromData(
        createRegistrosBioimpedanciaRecordData(
          percGordura: gordura,
          percMusculo: musculo,
          percAgua: agua,
          percOutros: outros,
          dataRegistro: agora,
          dataBio: agora,
          userRef: currentUserReference,
        ),
        docRef,
      );

      final mensagem = await notifyBioimpedanciaEvolution(
        anterior: anterior,
        atual: atual,
      );

      if (!mounted) {
        return;
      }

      _limparFormulario();
      setState(() => _registoDestaqueId = docRef.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem.summary)),
      );

      await _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao guardar bioimpedância.')),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: Color(0xFFA1A1A6),
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF0B0B0C),
        appBar: AppBar(
          backgroundColor: Color(0xFF0B0B0C),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 22.0,
            buttonSize: 44.0,
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24.0),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'Bioimpedância',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          elevation: 0.0,
        ),
        body: SafeArea(
          child: StreamBuilder<List<RegistrosBioimpedanciaRecord>>(
            stream: queryRegistrosBioimpedanciaRecord(
              queryBuilder: (q) => q
                  .where('user_ref', isEqualTo: currentUserReference)
                  .limit(40),
            ),
            builder: (context, snapshot) {
              final records = sortBioimpedanciaRecords(snapshot.data ?? []);
              final chartPoints = bioPointsFromRecords(records);
              final ultimo = records.isNotEmpty ? records.first : null;
              final penultimo = records.length > 1 ? records[1] : null;

              return SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionTitle('EVOLUÇÃO (GORDURA · MÚSCULO · ÁGUA)'),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF141416),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Color(0xFF2A2A2E)),
                          ),
                          child: snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : BioimpedanciaEvolutionChart(
                                  points: chartPoints.length > 15
                                      ? chartPoints.sublist(chartPoints.length - 15)
                                      : chartPoints,
                                  height: 200,
                                ),
                        ),
                        if (ultimo != null) ...[
                          SizedBox(height: 20),
                          BioimpedanciaParecerCard(
                            atual: ultimo,
                            anterior: penultimo,
                            destaqueAposRegisto:
                                _registoDestaqueId == ultimo.reference.id,
                          ),
                        ],
                        SizedBox(height: 24),
                        Divider(color: Color(0xFF2A2A2E)),
                        SizedBox(height: 16),
                        Text(
                          'NOVO REGISTO',
                          style: GoogleFonts.interTight(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Percentagens do equipamento ou relatório. Ao guardar, '
                          'comparamos com o registo anterior e enviamos notificação.',
                          style: GoogleFonts.inter(
                            color: Color(0xFFA1A1A6),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _model.gorduraController,
                          focusNode: _model.gorduraFocusNode,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: Colors.white),
                          decoration: _fieldDecoration('Gordura (%)'),
                        ),
                        SizedBox(height: 12.0),
                        TextFormField(
                          controller: _model.musculoController,
                          focusNode: _model.musculoFocusNode,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: Colors.white),
                          decoration: _fieldDecoration('Músculo (%)'),
                        ),
                        SizedBox(height: 12.0),
                        TextFormField(
                          controller: _model.aguaController,
                          focusNode: _model.aguaFocusNode,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: Colors.white),
                          decoration: _fieldDecoration('Água (%)'),
                        ),
                        SizedBox(height: 12.0),
                        TextFormField(
                          controller: _model.outrosController,
                          focusNode: _model.outrosFocusNode,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: Colors.white),
                          decoration: _fieldDecoration('Outros (%) — opcional'),
                        ),
                        SizedBox(height: 24.0),
                        FFButtonWidget(
                          onPressed: _salvando ? null : _salvar,
                          text: _salvando ? 'A guardar...' : 'Guardar registo',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 48.0,
                            color: Color(0xFFC6A969),
                            textStyle: GoogleFonts.interTight(
                              color: Color(0xFF0B0B0C),
                              fontWeight: FontWeight.bold,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
