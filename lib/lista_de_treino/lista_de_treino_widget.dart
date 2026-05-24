import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/musculacao_catalog.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lista_de_treino_model.dart';
export 'lista_de_treino_model.dart';

class ListaDeTreinoWidget extends StatefulWidget {
  const ListaDeTreinoWidget({super.key});

  static String routeName = 'lista_de_treino';
  static String routePath = '/listaDeTreino';

  @override
  State<ListaDeTreinoWidget> createState() => _ListaDeTreinoWidgetState();
}

class _ListaDeTreinoWidgetState extends State<ListaDeTreinoWidget> {
  late ListaDeTreinoModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ListaDeTreinoModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _abrirMusculacao(String categoriaRegisto) {
    context.pushNamed(
      PagRegistrarTreinoWidget.routeName,
      queryParameters: {'categoria': categoriaRegisto},
    );
  }

  Widget _grupoTile({
    required String label,
    required String categoriaRegisto,
    Color borderColor = const Color(0x33FFFFFF),
  }) {
    return InkWell(
      onTap: () => _abrirMusculacao(categoriaRegisto),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFF141416),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            Icon(Icons.chevron_right, color: Color(0xFFA1A1A6), size: 16),
          ],
        ),
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
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'Treino',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Musculação',
                        style: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.bold,
                              ),
                              color: Colors.white,
                            ),
                      ),
                      SizedBox(height: 12),
                      ...kMusculacaoListaGrupos.map(
                        (g) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: _grupoTile(
                            label: g.label,
                            categoriaRegisto: g.categoriaRegisto,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'AERÓBICO',
                        style: GoogleFonts.inter(
                          color: Color(0xFFA1A1A6),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () => context.pushNamed(
                          PagRegistrarAerobicoWidget.routeName,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFF141416),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFC6A969)),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Iniciar Aeróbico',
                                style: GoogleFonts.inter(
                                  color: Color(0xFFC6A969),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: Color(0xFFC6A969), size: 16),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Divider(height: 8, thickness: 1, color: Color(0x22FFFFFF)),
                      InkWell(
                        onTap: () => context.safePop(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFF141416),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0x33FF4444)),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'Sair',
                              style: GoogleFonts.inter(
                                color: Color(0xFFFF5555),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
