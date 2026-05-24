import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/aerobico_options.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/registrar_gasto_calorico.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pag_registrar_aerobico_model.dart';
export 'pag_registrar_aerobico_model.dart';

class PagRegistrarAerobicoWidget extends StatefulWidget {
  const PagRegistrarAerobicoWidget({super.key});

  static String routeName = 'pag_registrar_aerobico';
  static String routePath = '/pagRegistrarAerobico';

  @override
  State<PagRegistrarAerobicoWidget> createState() =>
      _PagRegistrarAerobicoWidgetState();
}

class _PagRegistrarAerobicoWidgetState extends State<PagRegistrarAerobicoWidget> {
  late PagRegistrarAerobicoModel _model;
  AerobicoOption? _selecionado;
  bool _mostrarResumo = false;
  final _outrosNome = TextEditingController();
  final _outrosTempo = TextEditingController();
  final _outrosKcal = TextEditingController();
  bool _registrandoOutros = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PagRegistrarAerobicoModel());
    _selecionado = kAerobicoOptions.first;
  }

  @override
  void dispose() {
    _outrosNome.dispose();
    _outrosTempo.dispose();
    _outrosKcal.dispose();
    _model.dispose();
    super.dispose();
  }

  InputDecoration _campoOutros(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Color(0xFF4A4A4F), fontSize: 14),
        filled: true,
        fillColor: Color(0xFF1E1E22),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2A2A2E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFFC6A969)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  Future<void> _registrarOutros() async {
    if (currentUserReference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Faça login novamente.')),
      );
      return;
    }
    final nome = _outrosNome.text.trim();
    final minutos =
        double.tryParse(_outrosTempo.text.trim().replaceAll(',', '.'));
    final kcal = double.tryParse(_outrosKcal.text.trim().replaceAll(',', '.'));
    if (nome.isEmpty || minutos == null || minutos <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informe exercício e tempo válidos.')),
      );
      return;
    }
    if (kcal == null || kcal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informe gasto calórico válido (kcal).')),
      );
      return;
    }
    setState(() => _registrandoOutros = true);
    try {
      await registrarGastoCaloricoManual(
        nome: nome,
        minutos: minutos,
        kcal: kcal,
        categoria: 'Aeróbico - outros',
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$nome registado (~${kcal.toStringAsFixed(0)} kcal, ${minutos.toStringAsFixed(0)} min).',
          ),
        ),
      );
      context.goNamed(PaginaDoPacienteWidget.routeName);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _registrandoOutros = false);
      }
    }
  }

  Future<void> _registrar() async {
    final opt = _selecionado;
    if (opt == null || currentUserReference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione um exercício e faça login.')),
      );
      return;
    }
    if (!_mostrarResumo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Toque em Salvar antes de Registrar.')),
      );
      return;
    }
    try {
      await RegistrosTreinosRecord.collection.doc().set(
            createRegistrosTreinosRecordData(
              tipoDeExercicio: opt.nome,
              gastoCalorico: opt.kcal30Min,
              series: 1,
              repeticoes: 1,
              carga: 30,
              categoria: 'Aeróbico',
              userRef: currentUserReference,
              data: getCurrentTimestamp,
            ),
          );
      await currentUserReference!.update({
        ...mapToFirestore({
          'calorias_total_dia': FieldValue.increment(opt.kcal30Min),
        }),
      });
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${opt.nome} registado (~${opt.kcal30Min.toStringAsFixed(0)} kcal / 30 min).',
          ),
        ),
      );
      context.goNamed(PaginaDoPacienteWidget.routeName);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final opt = _selecionado;
    return Scaffold(
      backgroundColor: Color(0xFF0B0B0C),
      appBar: AppBar(
        backgroundColor: Color(0xFF0B0B0C),
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderRadius: 22,
          buttonSize: 44,
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Aeróbico',
          style: GoogleFonts.interTight(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'SELECIONAR EXERCÍCIO',
                    style: GoogleFonts.inter(
                      color: Color(0xFFA1A1A6),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: kAerobicoOptions.length,
                    itemBuilder: (context, i) {
                      final item = kAerobicoOptions[i];
                      final selected = _selecionado?.nome == item.nome;
                      return InkWell(
                        onTap: () => setState(() {
                          _selecionado = item;
                          _mostrarResumo = false;
                        }),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF141416),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? Color(0xFFC6A969)
                                  : Color(0xFF2A2A2E),
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          padding: EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.nome,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${item.kcal30Min.toStringAsFixed(0)} kcal',
                                style: GoogleFonts.inter(
                                  color: Color(0xFFA1A1A6),
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '30 min',
                                style: GoogleFonts.inter(
                                  color: Color(0xFF5A5A5E),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  FFButtonWidget(
                    onPressed: opt == null
                        ? null
                        : () => setState(() => _mostrarResumo = true),
                    text: 'Salvar',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      color: Color(0xFFC6A969),
                      textStyle: GoogleFonts.interTight(
                        color: Color(0xFF0B0B0C),
                        fontWeight: FontWeight.bold,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  if (_mostrarResumo && opt != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF141416),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Color(0xFF2A2A2E)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt.nome,
                            style: GoogleFonts.interTight(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tempo: 30 minutos',
                            style: GoogleFonts.inter(color: Color(0xFFA1A1A6)),
                          ),
                          Text(
                            'Gasto estimado: ${opt.kcal30Min.toStringAsFixed(0)} kcal',
                            style: GoogleFonts.inter(
                              color: Color(0xFFC6A969),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    FFButtonWidget(
                      onPressed: _registrar,
                      text: 'Registrar',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 50,
                        color: Color(0xFF141416),
                        textStyle: GoogleFonts.interTight(
                          color: Color(0xFFC6A969),
                          fontWeight: FontWeight.bold,
                        ),
                        borderSide: BorderSide(color: Color(0xFFC6A969), width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                  SizedBox(height: 28),
                  Divider(color: Color(0xFF2A2A2E), height: 1),
                  SizedBox(height: 16),
                  Text(
                    'OUTROS GASTOS CALÓRICOS',
                    style: GoogleFonts.inter(
                      color: Color(0xFFA1A1A6),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Exercício não listado? Indique nome, tempo e kcal.',
                    style: GoogleFonts.inter(
                      color: Color(0xFF5A5A5E),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF141416),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Color(0xFF2A2A2E)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Exercício',
                          style: GoogleFonts.inter(
                            color: Color(0xFFA1A1A6),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 6),
                        TextField(
                          controller: _outrosNome,
                          style: GoogleFonts.inter(color: Colors.white),
                          textCapitalization: TextCapitalization.sentences,
                          decoration: _campoOutros('Ex: Natação, HIIT…'),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Tempo (minutos)',
                          style: GoogleFonts.inter(
                            color: Color(0xFFA1A1A6),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 6),
                        TextField(
                          controller: _outrosTempo,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.inter(color: Colors.white),
                          decoration: _campoOutros('Ex: 45'),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Gasto calórico (kcal)',
                          style: GoogleFonts.inter(
                            color: Color(0xFFA1A1A6),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 6),
                        TextField(
                          controller: _outrosKcal,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.inter(color: Colors.white),
                          decoration: _campoOutros('Ex: 320'),
                        ),
                        SizedBox(height: 16),
                        FFButtonWidget(
                          onPressed:
                              _registrandoOutros ? null : _registrarOutros,
                          text: 'Registrar gasto',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 48,
                            color: Color(0xFF141416),
                            textStyle: GoogleFonts.interTight(
                              color: Color(0xFFC6A969),
                              fontWeight: FontWeight.bold,
                            ),
                            borderSide: BorderSide(
                              color: Color(0xFFC6A969),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

