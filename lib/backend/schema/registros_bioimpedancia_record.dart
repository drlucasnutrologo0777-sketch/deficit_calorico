import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RegistrosBioimpedanciaRecord extends FirestoreRecord {
  RegistrosBioimpedanciaRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  double? _percGordura;
  double get percGordura => _percGordura ?? 0.0;
  bool hasPercGordura() => _percGordura != null;

  double? _percMusculo;
  double get percMusculo => _percMusculo ?? 0.0;
  bool hasPercMusculo() => _percMusculo != null;

  double? _percAgua;
  double get percAgua => _percAgua ?? 0.0;
  bool hasPercAgua() => _percAgua != null;

  double? _percOutros;
  double get percOutros => _percOutros ?? 0.0;
  bool hasPercOutros() => _percOutros != null;

  DateTime? _dataRegistro;
  DateTime? get dataRegistro => _dataRegistro;
  bool hasDataRegistro() => _dataRegistro != null;

  DateTime? _dataBio;
  DateTime? get dataBio => _dataBio;
  bool hasDataBio() => _dataBio != null;

  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  void _initializeFields() {
    _percGordura = castToType<double>(snapshotData['perc_gordura']);
    _percMusculo = castToType<double>(snapshotData['perc_musculo']);
    _percAgua = castToType<double>(snapshotData['perc_agua']);
    _percOutros = castToType<double>(snapshotData['perc_outros']);
    _dataRegistro = snapshotData['data_registro'] as DateTime?;
    _dataBio = snapshotData['data_bio'] as DateTime?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('registros_bioimpedancia');

  static Stream<RegistrosBioimpedanciaRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => RegistrosBioimpedanciaRecord.fromSnapshot(s));

  static Future<RegistrosBioimpedanciaRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => RegistrosBioimpedanciaRecord.fromSnapshot(s));

  static RegistrosBioimpedanciaRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RegistrosBioimpedanciaRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RegistrosBioimpedanciaRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RegistrosBioimpedanciaRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RegistrosBioimpedanciaRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RegistrosBioimpedanciaRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRegistrosBioimpedanciaRecordData({
  double? percGordura,
  double? percMusculo,
  double? percAgua,
  double? percOutros,
  DateTime? dataRegistro,
  DateTime? dataBio,
  DocumentReference? userRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'perc_gordura': percGordura,
      'perc_musculo': percMusculo,
      'perc_agua': percAgua,
      'perc_outros': percOutros,
      'data_registro': dataRegistro,
      'data_bio': dataBio,
      'user_ref': userRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class RegistrosBioimpedanciaRecordDocumentEquality
    implements Equality<RegistrosBioimpedanciaRecord> {
  const RegistrosBioimpedanciaRecordDocumentEquality();

  @override
  bool equals(RegistrosBioimpedanciaRecord? e1, RegistrosBioimpedanciaRecord? e2) {
    return e1?.percGordura == e2?.percGordura &&
        e1?.percMusculo == e2?.percMusculo &&
        e1?.percAgua == e2?.percAgua &&
        e1?.percOutros == e2?.percOutros &&
        e1?.dataRegistro == e2?.dataRegistro &&
        e1?.dataBio == e2?.dataBio &&
        e1?.userRef == e2?.userRef;
  }

  @override
  int hash(RegistrosBioimpedanciaRecord? e) => const ListEquality().hash([
        e?.percGordura,
        e?.percMusculo,
        e?.percAgua,
        e?.percOutros,
        e?.dataRegistro,
        e?.dataBio,
        e?.userRef,
      ]);

  @override
  bool isValidKey(Object? o) => o is RegistrosBioimpedanciaRecord;
}
