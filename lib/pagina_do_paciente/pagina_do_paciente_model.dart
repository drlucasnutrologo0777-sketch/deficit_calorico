import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/index.dart';
import 'pagina_do_paciente_widget.dart' show PaginaDoPacienteWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PaginaDoPacienteModel extends FlutterFlowModel<PaginaDoPacienteWidget> {
  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadDataSubir = false;
  FFUploadedFile uploadedLocalFile_uploadDataSubir =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataSubir = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
