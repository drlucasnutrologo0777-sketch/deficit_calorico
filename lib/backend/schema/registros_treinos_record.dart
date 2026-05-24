import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RegistrosTreinosRecord extends FirestoreRecord {
  RegistrosTreinosRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "tipo_de_exercicio" field.
  String? _tipoDeExercicio;
  String get tipoDeExercicio => _tipoDeExercicio ?? '';
  bool hasTipoDeExercicio() => _tipoDeExercicio != null;

  // "gasto_calorico" field.
  double? _gastoCalorico;
  double get gastoCalorico => _gastoCalorico ?? 0.0;
  bool hasGastoCalorico() => _gastoCalorico != null;

  // "series" field.
  double? _series;
  double get series => _series ?? 0.0;
  bool hasSeries() => _series != null;

  // "repeticoes" field.
  double? _repeticoes;
  double get repeticoes => _repeticoes ?? 0.0;
  bool hasRepeticoes() => _repeticoes != null;

  // "carga" field.
  double? _carga;
  double get carga => _carga ?? 0.0;
  bool hasCarga() => _carga != null;

  // "categoria" field.
  String? _categoria;
  String get categoria => _categoria ?? '';
  bool hasCategoria() => _categoria != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "data" field.
  DateTime? _data;
  DateTime? get data => _data;
  bool hasData() => _data != null;

  void _initializeFields() {
    _tipoDeExercicio = snapshotData['tipo_de_exercicio'] as String?;
    _gastoCalorico = castToType<double>(snapshotData['gasto_calorico']);
    _series = castToType<double>(snapshotData['series']);
    _repeticoes = castToType<double>(snapshotData['repeticoes']);
    _carga = castToType<double>(snapshotData['carga']);
    _categoria = snapshotData['categoria'] as String?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _data = snapshotData['data'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('registros_treinos');

  static Stream<RegistrosTreinosRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RegistrosTreinosRecord.fromSnapshot(s));

  static Future<RegistrosTreinosRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => RegistrosTreinosRecord.fromSnapshot(s));

  static RegistrosTreinosRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RegistrosTreinosRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RegistrosTreinosRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RegistrosTreinosRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RegistrosTreinosRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RegistrosTreinosRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRegistrosTreinosRecordData({
  String? tipoDeExercicio,
  double? gastoCalorico,
  double? series,
  double? repeticoes,
  double? carga,
  String? categoria,
  DocumentReference? userRef,
  DateTime? data,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'tipo_de_exercicio': tipoDeExercicio,
      'gasto_calorico': gastoCalorico,
      'series': series,
      'repeticoes': repeticoes,
      'carga': carga,
      'categoria': categoria,
      'user_ref': userRef,
      'data': data,
    }.withoutNulls,
  );

  return firestoreData;
}

class RegistrosTreinosRecordDocumentEquality
    implements Equality<RegistrosTreinosRecord> {
  const RegistrosTreinosRecordDocumentEquality();

  @override
  bool equals(RegistrosTreinosRecord? e1, RegistrosTreinosRecord? e2) {
    return e1?.tipoDeExercicio == e2?.tipoDeExercicio &&
        e1?.gastoCalorico == e2?.gastoCalorico &&
        e1?.series == e2?.series &&
        e1?.repeticoes == e2?.repeticoes &&
        e1?.carga == e2?.carga &&
        e1?.categoria == e2?.categoria &&
        e1?.userRef == e2?.userRef &&
        e1?.data == e2?.data;
  }

  @override
  int hash(RegistrosTreinosRecord? e) => const ListEquality().hash([
        e?.tipoDeExercicio,
        e?.gastoCalorico,
        e?.series,
        e?.repeticoes,
        e?.carga,
        e?.categoria,
        e?.userRef,
        e?.data
      ]);

  @override
  bool isValidKey(Object? o) => o is RegistrosTreinosRecord;
}
