import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// registrar consumo diario
class RegistrosConsumoRecord extends FirestoreRecord {
  RegistrosConsumoRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "calorias_total" field.
  double? _caloriasTotal;
  double get caloriasTotal => _caloriasTotal ?? 0.0;
  bool hasCaloriasTotal() => _caloriasTotal != null;

  // "proteinas_total" field.
  double? _proteinasTotal;
  double get proteinasTotal => _proteinasTotal ?? 0.0;
  bool hasProteinasTotal() => _proteinasTotal != null;

  // "gorduras_total" field.
  double? _gordurasTotal;
  double get gordurasTotal => _gordurasTotal ?? 0.0;
  bool hasGordurasTotal() => _gordurasTotal != null;

  // "carboidratos_total" field.
  double? _carboidratosTotal;
  double get carboidratosTotal => _carboidratosTotal ?? 0.0;
  bool hasCarboidratosTotal() => _carboidratosTotal != null;

  // "quantidade_gramas" field.
  double? _quantidadeGramas;
  double get quantidadeGramas => _quantidadeGramas ?? 0.0;
  bool hasQuantidadeGramas() => _quantidadeGramas != null;

  // "data_registro" field.
  DateTime? _dataRegistro;
  DateTime? get dataRegistro => _dataRegistro;
  bool hasDataRegistro() => _dataRegistro != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "tipo_de_aliemento" field.
  String? _tipoDeAliemento;
  String get tipoDeAliemento => _tipoDeAliemento ?? '';
  bool hasTipoDeAliemento() => _tipoDeAliemento != null;

  void _initializeFields() {
    _caloriasTotal = castToType<double>(snapshotData['calorias_total']);
    _proteinasTotal = castToType<double>(snapshotData['proteinas_total']);
    _gordurasTotal = castToType<double>(snapshotData['gorduras_total']);
    _carboidratosTotal = castToType<double>(snapshotData['carboidratos_total']);
    _quantidadeGramas = castToType<double>(snapshotData['quantidade_gramas']);
    _dataRegistro = snapshotData['data_registro'] as DateTime?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _tipoDeAliemento = snapshotData['tipo_de_aliemento'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('registros_consumo');

  static Stream<RegistrosConsumoRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RegistrosConsumoRecord.fromSnapshot(s));

  static Future<RegistrosConsumoRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => RegistrosConsumoRecord.fromSnapshot(s));

  static RegistrosConsumoRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RegistrosConsumoRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RegistrosConsumoRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RegistrosConsumoRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RegistrosConsumoRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RegistrosConsumoRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRegistrosConsumoRecordData({
  double? caloriasTotal,
  double? proteinasTotal,
  double? gordurasTotal,
  double? carboidratosTotal,
  double? quantidadeGramas,
  DateTime? dataRegistro,
  DocumentReference? userRef,
  String? tipoDeAliemento,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'calorias_total': caloriasTotal,
      'proteinas_total': proteinasTotal,
      'gorduras_total': gordurasTotal,
      'carboidratos_total': carboidratosTotal,
      'quantidade_gramas': quantidadeGramas,
      'data_registro': dataRegistro,
      'user_ref': userRef,
      'tipo_de_aliemento': tipoDeAliemento,
    }.withoutNulls,
  );

  return firestoreData;
}

class RegistrosConsumoRecordDocumentEquality
    implements Equality<RegistrosConsumoRecord> {
  const RegistrosConsumoRecordDocumentEquality();

  @override
  bool equals(RegistrosConsumoRecord? e1, RegistrosConsumoRecord? e2) {
    return e1?.caloriasTotal == e2?.caloriasTotal &&
        e1?.proteinasTotal == e2?.proteinasTotal &&
        e1?.gordurasTotal == e2?.gordurasTotal &&
        e1?.carboidratosTotal == e2?.carboidratosTotal &&
        e1?.quantidadeGramas == e2?.quantidadeGramas &&
        e1?.dataRegistro == e2?.dataRegistro &&
        e1?.userRef == e2?.userRef &&
        e1?.tipoDeAliemento == e2?.tipoDeAliemento;
  }

  @override
  int hash(RegistrosConsumoRecord? e) => const ListEquality().hash([
        e?.caloriasTotal,
        e?.proteinasTotal,
        e?.gordurasTotal,
        e?.carboidratosTotal,
        e?.quantidadeGramas,
        e?.dataRegistro,
        e?.userRef,
        e?.tipoDeAliemento
      ]);

  @override
  bool isValidKey(Object? o) => o is RegistrosConsumoRecord;
}
