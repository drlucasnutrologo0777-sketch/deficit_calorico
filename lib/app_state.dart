import 'package:flutter/material.dart';
import '/backend/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  int _vlrCarga = 5;
  int get vlrCarga => _vlrCarga;
  set vlrCarga(int value) {
    _vlrCarga = value;
  }

  /// paciente digita o deficit calorico que quer fazer
  double _deficitProgramado = 300.0;
  double get deficitProgramado => _deficitProgramado;
  set deficitProgramado(double value) {
    _deficitProgramado = value;
  }

  /// quantidade de gordura queimada com a caloria programada
  double _gorduraAQueimar = 0.0;
  double get gorduraAQueimar => _gorduraAQueimar;
  set gorduraAQueimar(double value) {
    _gorduraAQueimar = value;
  }

  void syncLocalStateAfterDailyTotalsReset({bool clearDailyMeta = false}) {
    if (clearDailyMeta) {
      _deficitProgramado = 300.0;
      _gorduraAQueimar = 0.0;
    }
    notifyListeners();
  }
}
