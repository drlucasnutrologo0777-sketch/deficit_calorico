import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/food_categories.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lista_alimentos_model.dart';
export 'lista_alimentos_model.dart';

class ListaAlimentosWidget extends StatefulWidget {
  const ListaAlimentosWidget({super.key});

  static String routeName = 'lista_alimentos';
  static String routePath = '/listaAlimentos';

  @override
  State<ListaAlimentosWidget> createState() => _ListaAlimentosWidgetState();
}

class _ListaAlimentosWidgetState extends State<ListaAlimentosWidget> {
  late ListaAlimentosModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ListaAlimentosModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _abrirCategoria(FoodCategoryEntry entry) {
    if (entry.isManualCalories) {
      context.pushNamed(OutrasIngestaoCaloricasWidget.routeName);
      return;
    }
    final key = entry.firestoreKeys.first;
    context.pushNamed(
      PagRegistrarAlimentosWidget.routeName,
      queryParameters: {
        'categoria': serializeParam(key, ParamType.String),
      }.withoutNulls,
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
            'Alimentos',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          elevation: 0.0,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
                child: Text(
                  'Selecione uma categoria',
                  style: GoogleFonts.inter(
                    color: Color(0xFFA1A1A6),
                    fontSize: 14.0,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: kFoodCategories.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.0),
                  itemBuilder: (context, index) {
                    final entry = kFoodCategories[index];
                    return InkWell(
                      onTap: () => _abrirCategoria(entry),
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF141416),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Color(0x33C6A969)),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.label,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFA1A1A6),
                              size: 20.0,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
