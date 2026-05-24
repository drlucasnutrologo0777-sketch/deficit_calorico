import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/food_categories.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pag_registrar_alimentos_model.dart';
export 'pag_registrar_alimentos_model.dart';

class PagRegistrarAlimentosWidget extends StatefulWidget {
  const PagRegistrarAlimentosWidget({
    super.key,
    this.categoria,
  });

  final String? categoria;

  static String routeName = 'pag_registrar_alimentos';
  static String routePath = '/pagRegistrarAlimentos';

  @override
  State<PagRegistrarAlimentosWidget> createState() =>
      _PagRegistrarAlimentosWidgetState();
}

class _PagRegistrarAlimentosWidgetState
    extends State<PagRegistrarAlimentosWidget> {
  late PagRegistrarAlimentosModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  FoodCategoryEntry get _categoriaEntry =>
      foodCategoryOrDefault(widget.categoria);

  List<String> get _firestoreKeys => _categoriaEntry.firestoreKeys;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PagRegistrarAlimentosModel());
    _model.textController ??= TextEditingController(text: '100');
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  List<AlimentosRecord> _prepareFoodList(List<AlimentosRecord> raw) {
    return mergeWithCategorySeed(raw, _categoriaEntry.seedKey);
  }

  AlimentosRecord? _selectedFood(List<AlimentosRecord> foods) {
    if (foods.isEmpty) {
      return null;
    }
    final selected = _model.dropDownValue;
    if (selected != null && selected.isNotEmpty) {
      for (final food in foods) {
        if (food.tipoDeAlimento == selected) {
          return food;
        }
      }
    }
    return foods.first;
  }

  double _grams() {
    return double.tryParse(
          (_model.textController?.text ?? '').replaceAll(',', '.'),
        ) ??
        0.0;
  }

  void _syncDropdown(List<AlimentosRecord> foods) {
    if (foods.isEmpty) {
      return;
    }
    final names = foods.map((e) => e.tipoDeAlimento).toList();
    if (_model.dropDownValue == null ||
        !names.contains(_model.dropDownValue)) {
      _model.dropDownValue = names.first;
      _model.dropDownValueController ??= FormFieldController<String>(null);
      _model.dropDownValueController!.value = names.first;
    }
  }

  Future<void> _registrar(AlimentosRecord food) async {
    if (currentUserReference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Faça login novamente.')),
      );
      return;
    }

    final grams = _grams();
    if (grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informe a quantidade em gramas.')),
      );
      return;
    }

    final kcal = scaledMacro(food.calorias, food, grams);
    final prot = scaledMacro(food.proteinas, food, grams);
    final gord = scaledMacro(food.gorduras, food, grams);
    final carb = scaledMacro(food.carboidratos, food, grams);

    try {
      await RegistrosConsumoRecord.collection.doc().set(
            createRegistrosConsumoRecordData(
              caloriasTotal: kcal,
              proteinasTotal: prot,
              gordurasTotal: gord,
              carboidratosTotal: carb,
              quantidadeGramas: grams,
              dataRegistro: getCurrentTimestamp,
              userRef: currentUserReference,
              tipoDeAliemento: food.tipoDeAlimento,
            ),
          );

      await currentUserReference!.update({
        ...mapToFirestore({
          'ingestao_calorias_total': FieldValue.increment(kcal),
          'proteina_dia': FieldValue.increment(prot),
          'gordura_dia': FieldValue.increment(gord),
          'carboidrato_dia': FieldValue.increment(carb),
        }),
      });

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF141416),
          content: Text(
            '${food.tipoDeAlimento} registado (${grams.toStringAsFixed(0)} g).',
            style: TextStyle(color: Colors.white),
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

  Widget _macroRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: Color(0xFFA1A1A6), fontSize: 13.0),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_firestoreKeys.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFF0B0B0C),
        appBar: AppBar(
          backgroundColor: Color(0xFF0B0B0C),
          leading: FlutterFlowIconButton(
            borderRadius: 22.0,
            buttonSize: 44.0,
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.safePop(),
          ),
          title: Text('Alimentos', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Text(
            'Categoria inválida.',
            style: TextStyle(color: Color(0xFFA1A1A6)),
          ),
        ),
      );
    }

    return StreamBuilder<List<AlimentosRecord>>(
      stream: queryAlimentosRecord(
        queryBuilder: (q) {
          var query = q;
          if (_firestoreKeys.length == 1) {
            query = query.where('categorias', isEqualTo: _firestoreKeys.first);
          } else {
            query = query.where('categorias', whereIn: _firestoreKeys);
          }
          return query;
        },
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Color(0xFF0B0B0C),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final foods = _prepareFoodList(snapshot.data!);
        _syncDropdown(foods);
        final selected = _selectedFood(foods);
        final grams = _grams();
        final kcalPreview = selected != null
            ? scaledMacro(selected.calorias, selected, grams)
            : 0.0;

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
                icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => context.safePop(),
              ),
              title: Text(
                'Registrar alimento',
                style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevation: 0.0,
            ),
            body: SafeArea(
              child: foods.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'Nenhum alimento nesta categoria.\n'
                          'Atualize o app ou verifique a coleção alimentos no Firebase.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Color(0xFFA1A1A6),
                            height: 1.4,
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _categoriaEntry.label,
                                style: GoogleFonts.interTight(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                ),
                              ),
                              Text(
                                'Selecione o tipo e a quantidade',
                                style: GoogleFonts.inter(
                                  color: Color(0xFFA1A1A6),
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 20.0),
                              Text(
                                'TIPO DE ALIMENTO',
                                style: GoogleFonts.inter(
                                  color: Color(0xFFC6A969),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.0,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF141416),
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(color: Color(0xFF2A2A2E)),
                                ),
                                child: FlutterFlowDropDown<String>(
                                  controller:
                                      _model.dropDownValueController ??=
                                          FormFieldController<String>(
                                              _model.dropDownValue),
                                  options: foods
                                      .map((e) => e.tipoDeAlimento)
                                      .toList(),
                                  onChanged: (val) => safeSetState(
                                    () => _model.dropDownValue = val,
                                  ),
                                  width: double.infinity,
                                  height: 52.0,
                                  textStyle: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                  ),
                                  hintText: 'Selecione aqui...',
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFFC6A969),
                                  ),
                                  fillColor: Color(0xFF141416),
                                  elevation: 0.0,
                                  borderColor: Colors.transparent,
                                  borderWidth: 0.0,
                                  borderRadius: 12.0,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  hidesUnderline: true,
                                  isSearchable: true,
                                  isMultiSelect: false,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFF141416),
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(color: Color(0xFF2A2A2E)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'INFORMAÇÕES NUTRICIONAIS',
                                      style: GoogleFonts.inter(
                                        color: Color(0xFFC6A969),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.0,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    if (selected != null) ...[
                                      _macroRow(
                                        'Porção base',
                                        '${selected.porcaoBase.toStringAsFixed(0)} g',
                                      ),
                                      _macroRow(
                                        'Calorias (porção)',
                                        '${selected.calorias.toStringAsFixed(0)} kcal',
                                      ),
                                      _macroRow(
                                        'Proteínas',
                                        '${selected.proteinas.toStringAsFixed(1)} g',
                                      ),
                                      _macroRow(
                                        'Gorduras',
                                        '${selected.gorduras.toStringAsFixed(1)} g',
                                      ),
                                      _macroRow(
                                        'Carboidratos',
                                        '${selected.carboidratos.toStringAsFixed(1)} g',
                                      ),
                                      Divider(color: Color(0xFF2A2A2E)),
                                      _macroRow(
                                        'Total (${grams.toStringAsFixed(0)} g)',
                                        '${kcalPreview.toStringAsFixed(0)} kcal',
                                        valueColor: Color(0xFF30D158),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'QUANTIDADE (g)',
                                style: GoogleFonts.inter(
                                  color: Color(0xFFC6A969),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.0,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              TextFormField(
                                controller: _model.textController,
                                focusNode: _model.textFieldFocusNode,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: Colors.white),
                                onChanged: (_) => safeSetState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Ex: 150',
                                  hintStyle: TextStyle(color: Color(0xFFA1A1A6)),
                                  filled: true,
                                  fillColor: Color(0xFF141416),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide:
                                        BorderSide(color: Color(0xFF2A2A2E)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide:
                                        BorderSide(color: Color(0xFF2A2A2E)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide:
                                        BorderSide(color: Color(0xFFC6A969)),
                                  ),
                                  contentPadding: EdgeInsets.all(16.0),
                                ),
                              ),
                              SizedBox(height: 24.0),
                              FFButtonWidget(
                                onPressed: selected == null
                                    ? null
                                    : () => _registrar(selected),
                                text: 'Registrar',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 54.0,
                                  color: Color(0xFFC6A969),
                                  textStyle: GoogleFonts.interTight(
                                    color: Color(0xFF0B0B0C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
