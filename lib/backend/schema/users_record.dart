import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "peso" field.
  double? _peso;
  double get peso => _peso ?? 0.0;
  bool hasPeso() => _peso != null;

  // "altura" field.
  double? _altura;
  double get altura => _altura ?? 0.0;
  bool hasAltura() => _altura != null;

  // "data_nascimento" field.
  DateTime? _dataNascimento;
  DateTime? get dataNascimento => _dataNascimento;
  bool hasDataNascimento() => _dataNascimento != null;

  // "cpf" field.
  String? _cpf;
  String get cpf => _cpf ?? '';
  bool hasCpf() => _cpf != null;

  // "sexo" field.
  String? _sexo;
  String get sexo => _sexo ?? '';
  bool hasSexo() => _sexo != null;

  // "tmb" field.
  double? _tmb;
  double get tmb => _tmb ?? 0.0;
  bool hasTmb() => _tmb != null;

  // "nivel_atividade" field.
  double? _nivelAtividade;
  double get nivelAtividade => _nivelAtividade ?? 0.0;
  bool hasNivelAtividade() => _nivelAtividade != null;

  // "get" field.
  double? _get;
  double get get => _get ?? 0.0;
  bool hasGet() => _get != null;

  // "calorias_total_dia" field.
  double? _caloriasTotalDia;
  double get caloriasTotalDia => _caloriasTotalDia ?? 0.0;
  bool hasCaloriasTotalDia() => _caloriasTotalDia != null;

  // "ingestao_calorias_total" field.
  double? _ingestaoCaloriasTotal;
  double get ingestaoCaloriasTotal => _ingestaoCaloriasTotal ?? 0.0;
  bool hasIngestaoCaloriasTotal() => _ingestaoCaloriasTotal != null;

  // "cadastro_completo" field.
  bool? _cadastroCompleto;
  bool get cadastroCompleto => _cadastroCompleto ?? false;
  bool hasCadastroCompleto() => _cadastroCompleto != null;

  // "deficit_programado" field.
  double? _deficitProgramado;
  double get deficitProgramado => _deficitProgramado ?? 0.0;
  bool hasDeficitProgramado() => _deficitProgramado != null;

  // "gordura_a_queimar" field.
  double? _gorduraAQueimar;
  double get gorduraAQueimar => _gorduraAQueimar ?? 0.0;
  bool hasGorduraAQueimar() => _gorduraAQueimar != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "carboidrato_dia" field.
  double? _carboidratoDia;
  double get carboidratoDia => _carboidratoDia ?? 0.0;
  bool hasCarboidratoDia() => _carboidratoDia != null;

  // "proteina_dia" field.
  double? _proteinaDia;
  double get proteinaDia => _proteinaDia ?? 0.0;
  bool hasProteinaDia() => _proteinaDia != null;

  // "gordura_dia" field.
  double? _gorduraDia;
  double get gorduraDia => _gorduraDia ?? 0.0;
  bool hasGorduraDia() => _gorduraDia != null;

  // "tmb_calculado" field.
  bool? _tmbCalculado;
  bool get tmbCalculado => _tmbCalculado ?? false;
  bool hasTmbCalculado() => _tmbCalculado != null;

  String? _diaResumoDashboard;
  String get diaResumoDashboard => _diaResumoDashboard ?? '';
  bool hasDiaResumoDashboard() => _diaResumoDashboard != null;

  String? _diaUltimoZerarManualResumo;
  String get diaUltimoZerarManualResumo => _diaUltimoZerarManualResumo ?? '';
  bool hasDiaUltimoZerarManualResumo() => _diaUltimoZerarManualResumo != null;

  /// Dia civil (yyyy-MM-dd) em que a meta de déficit foi registada.
  String? _diaMetaProgramada;
  String get diaMetaProgramada => _diaMetaProgramada ?? '';
  bool hasDiaMetaProgramada() => _diaMetaProgramada != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = dateTimeFromFirestore(snapshotData['created_time']);
    _peso = castToType<double>(snapshotData['peso']);
    _altura = castToType<double>(snapshotData['altura']);
    _dataNascimento = dateTimeFromFirestore(snapshotData['data_nascimento']);
    _cpf = snapshotData['cpf'] as String?;
    _sexo = snapshotData['sexo'] as String?;
    _tmb = castToType<double>(snapshotData['tmb']);
    _nivelAtividade = castToType<double>(snapshotData['nivel_atividade']);
    _get = castToType<double>(snapshotData['get']);
    _caloriasTotalDia = castToType<double>(snapshotData['calorias_total_dia']);
    _ingestaoCaloriasTotal =
        castToType<double>(snapshotData['ingestao_calorias_total']);
    _cadastroCompleto = snapshotData['cadastro_completo'] as bool?;
    _deficitProgramado = castToType<double>(snapshotData['deficit_programado']);
    _gorduraAQueimar = castToType<double>(snapshotData['gordura_a_queimar']);
    _phoneNumber = snapshotData['phone_number'] as String?;
    _carboidratoDia = castToType<double>(snapshotData['carboidrato_dia']);
    _proteinaDia = castToType<double>(snapshotData['proteina_dia']);
    _gorduraDia = castToType<double>(snapshotData['gordura_dia']);
    _tmbCalculado = snapshotData['tmb_calculado'] as bool?;
    _diaResumoDashboard = snapshotData['dia_resumo_dashboard'] as String?;
    _diaUltimoZerarManualResumo =
        snapshotData['dia_ultimo_zerar_manual_resumo'] as String?;
    _diaMetaProgramada = snapshotData['dia_meta_programada'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  double? peso,
  double? altura,
  DateTime? dataNascimento,
  String? cpf,
  String? sexo,
  double? tmb,
  double? nivelAtividade,
  double? get,
  double? caloriasTotalDia,
  double? ingestaoCaloriasTotal,
  bool? cadastroCompleto,
  double? deficitProgramado,
  double? gorduraAQueimar,
  String? phoneNumber,
  double? carboidratoDia,
  double? proteinaDia,
  double? gorduraDia,
  bool? tmbCalculado,
  String? diaMetaProgramada,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'peso': peso,
      'altura': altura,
      'data_nascimento': dataNascimento,
      'cpf': cpf,
      'sexo': sexo,
      'tmb': tmb,
      'nivel_atividade': nivelAtividade,
      'get': get,
      'calorias_total_dia': caloriasTotalDia,
      'ingestao_calorias_total': ingestaoCaloriasTotal,
      'cadastro_completo': cadastroCompleto,
      'deficit_programado': deficitProgramado,
      'gordura_a_queimar': gorduraAQueimar,
      'phone_number': phoneNumber,
      'carboidrato_dia': carboidratoDia,
      'proteina_dia': proteinaDia,
      'gordura_dia': gorduraDia,
      'tmb_calculado': tmbCalculado,
      'dia_meta_programada': diaMetaProgramada,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.peso == e2?.peso &&
        e1?.altura == e2?.altura &&
        e1?.dataNascimento == e2?.dataNascimento &&
        e1?.cpf == e2?.cpf &&
        e1?.sexo == e2?.sexo &&
        e1?.tmb == e2?.tmb &&
        e1?.nivelAtividade == e2?.nivelAtividade &&
        e1?.get == e2?.get &&
        e1?.caloriasTotalDia == e2?.caloriasTotalDia &&
        e1?.ingestaoCaloriasTotal == e2?.ingestaoCaloriasTotal &&
        e1?.cadastroCompleto == e2?.cadastroCompleto &&
        e1?.deficitProgramado == e2?.deficitProgramado &&
        e1?.gorduraAQueimar == e2?.gorduraAQueimar &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.carboidratoDia == e2?.carboidratoDia &&
        e1?.proteinaDia == e2?.proteinaDia &&
        e1?.gorduraDia == e2?.gorduraDia &&
        e1?.tmbCalculado == e2?.tmbCalculado;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.peso,
        e?.altura,
        e?.dataNascimento,
        e?.cpf,
        e?.sexo,
        e?.tmb,
        e?.nivelAtividade,
        e?.get,
        e?.caloriasTotalDia,
        e?.ingestaoCaloriasTotal,
        e?.cadastroCompleto,
        e?.deficitProgramado,
        e?.gorduraAQueimar,
        e?.phoneNumber,
        e?.carboidratoDia,
        e?.proteinaDia,
        e?.gorduraDia,
        e?.tmbCalculado
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
