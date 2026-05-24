import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// todos os alimentos do aplicativo
class AlimentosRecord extends FirestoreRecord {
  AlimentosRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "calorias" field.
  double? _calorias;
  double get calorias => _calorias ?? 0.0;
  bool hasCalorias() => _calorias != null;

  // "proteinas" field.
  double? _proteinas;
  double get proteinas => _proteinas ?? 0.0;
  bool hasProteinas() => _proteinas != null;

  // "gorduras" field.
  double? _gorduras;
  double get gorduras => _gorduras ?? 0.0;
  bool hasGorduras() => _gorduras != null;

  // "carboidratos" field.
  double? _carboidratos;
  double get carboidratos => _carboidratos ?? 0.0;
  bool hasCarboidratos() => _carboidratos != null;

  // "categorias" field.
  String? _categorias;
  String get categorias => _categorias ?? '';
  bool hasCategorias() => _categorias != null;

  // "porcao_base" field.
  double? _porcaoBase;
  double get porcaoBase => _porcaoBase ?? 0.0;
  bool hasPorcaoBase() => _porcaoBase != null;

  // "tipo_de_alimento" field.
  String? _tipoDeAlimento;
  String get tipoDeAlimento => _tipoDeAlimento ?? '';
  bool hasTipoDeAlimento() => _tipoDeAlimento != null;

  void _initializeFields() {
    _calorias = castToType<double>(snapshotData['calorias']);
    _proteinas = castToType<double>(snapshotData['proteinas']);
    _gorduras = castToType<double>(snapshotData['gorduras']);
    _carboidratos = castToType<double>(snapshotData['carboidratos']);
    _categorias = snapshotData['categorias'] as String?;
    _porcaoBase = castToType<double>(snapshotData['porcao_base']);
    _tipoDeAlimento = snapshotData['tipo_de_alimento'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('alimentos');

  static Stream<AlimentosRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AlimentosRecord.fromSnapshot(s));

  static Future<AlimentosRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AlimentosRecord.fromSnapshot(s));

  static AlimentosRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AlimentosRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AlimentosRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AlimentosRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AlimentosRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AlimentosRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAlimentosRecordData({
  double? calorias,
  double? proteinas,
  double? gorduras,
  double? carboidratos,
  String? categorias,
  double? porcaoBase,
  String? tipoDeAlimento,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'calorias': calorias,
      'proteinas': proteinas,
      'gorduras': gorduras,
      'carboidratos': carboidratos,
      'categorias': categorias,
      'porcao_base': porcaoBase,
      'tipo_de_alimento': tipoDeAlimento,
    }.withoutNulls,
  );

  return firestoreData;
}

class AlimentosRecordDocumentEquality implements Equality<AlimentosRecord> {
  const AlimentosRecordDocumentEquality();

  @override
  bool equals(AlimentosRecord? e1, AlimentosRecord? e2) {
    return e1?.calorias == e2?.calorias &&
        e1?.proteinas == e2?.proteinas &&
        e1?.gorduras == e2?.gorduras &&
        e1?.carboidratos == e2?.carboidratos &&
        e1?.categorias == e2?.categorias &&
        e1?.porcaoBase == e2?.porcaoBase &&
        e1?.tipoDeAlimento == e2?.tipoDeAlimento;
  }

  @override
  int hash(AlimentosRecord? e) => const ListEquality().hash([
        e?.calorias,
        e?.proteinas,
        e?.gorduras,
        e?.carboidratos,
        e?.categorias,
        e?.porcaoBase,
        e?.tipoDeAlimento
      ]);

  @override
  bool isValidKey(Object? o) => o is AlimentosRecord;
}
