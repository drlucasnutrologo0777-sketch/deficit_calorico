import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'pag_registrar_bioimpedancia_widget.dart'
    show PagRegistrarBioimpedanciaWidget;

class PagRegistrarBioimpedanciaModel
    extends FlutterFlowModel<PagRegistrarBioimpedanciaWidget> {
  FocusNode? gorduraFocusNode;
  TextEditingController? gorduraController;
  String? Function(BuildContext, String?)? gorduraValidator;

  FocusNode? musculoFocusNode;
  TextEditingController? musculoController;
  String? Function(BuildContext, String?)? musculoValidator;

  FocusNode? aguaFocusNode;
  TextEditingController? aguaController;
  String? Function(BuildContext, String?)? aguaValidator;

  FocusNode? outrosFocusNode;
  TextEditingController? outrosController;

  @override
  void initState(BuildContext context) {
    gorduraController ??= TextEditingController();
    gorduraFocusNode ??= FocusNode();
    musculoController ??= TextEditingController();
    musculoFocusNode ??= FocusNode();
    aguaController ??= TextEditingController();
    aguaFocusNode ??= FocusNode();
    outrosController ??= TextEditingController();
    outrosFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    gorduraFocusNode?.dispose();
    gorduraController?.dispose();
    musculoFocusNode?.dispose();
    musculoController?.dispose();
    aguaFocusNode?.dispose();
    aguaController?.dispose();
    outrosFocusNode?.dispose();
    outrosController?.dispose();
  }
}
