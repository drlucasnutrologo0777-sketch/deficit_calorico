import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/daily_dashboard_reset.dart';
import '/components/coach_card.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'painel_acao_menu_item.dart';
import 'pagina_do_paciente_model.dart';
export 'pagina_do_paciente_model.dart';

/// Criar tela inicial mobile-first para app fitness premium com design
/// escuro, minimalista e sofisticado.
///
/// Sem gradientes ou neon.
///
/// Cores: fundo #0B0B0C, cards #141416, texto #FFFFFF, secundário #A1A1A6,
/// destaque #C6A969, sucesso #30D158.
///
/// Layout: SafeArea > Container padding 16 (maxWidth 600 centralizado) >
/// SingleChildScrollView > Column (spacing 16, alinhamento start).
///
/// Topo:
/// Foto de perfil (clicável para atualizar) + Nome
/// Texto secundário: “TMB: valor”
///
/// Card principal:
/// Container padding 16, radius 12, borda sutil
/// Mostrar:
/// Meta diária (g gordura)
/// Gordura queimada (g)
/// Ingestão calórica
/// Gasto calórico
/// Falta para meta (dourado ou verde)
///
/// Linha:
/// “Consumo: X kcal | Gasto: Y kcal”
///
/// Ações:
/// Programar gasto do dia
/// Registro alimentar
/// Registro de treino
/// Configurações
///
/// Regras:
/// Padding 16, spacing 16, sem altura fixa, evitar overflow.
///
/// Dados atualizados em tempo real.
class PaginaDoPacienteWidget extends StatefulWidget {
  const PaginaDoPacienteWidget({
    super.key,
    String? fotoPerfil,
  }) : this.fotoPerfil = fotoPerfil ?? 'foto';

  final String fotoPerfil;

  static String routeName = 'pagina_do_paciente';
  static String routePath = '/paginaDoPaciente';

  @override
  State<PaginaDoPacienteWidget> createState() => _PaginaDoPacienteWidgetState();
}

class _PaginaDoPacienteWidgetState extends State<PaginaDoPacienteWidget> {
  late PaginaDoPacienteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _tmbSyncEmProgresso = false;
  bool _tmbSyncFeito = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaginaDoPacienteModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshDailyDashboardResetFromServer();
      _syncMetaFromFirestore();
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _syncMetaFromFirestore() {
    final doc = currentUserDocument;
    if (doc == null) {
      return;
    }
    final hoje = currentLocalDashboardDayKey();
    if (functions.metaDeficitDefinidaHoje(doc, hoje)) {
      FFAppState().update(() {
        FFAppState().deficitProgramado = doc.deficitProgramado;
        FFAppState().gorduraAQueimar = doc.gorduraAQueimar > 0
            ? doc.gorduraAQueimar
            : functions.gramasGorduraDeKcal(doc.deficitProgramado);
      });
    }
  }

  Future<void> _persistirTmbSeCalculavel(UsersRecord user) async {
    if (_tmbSyncFeito || _tmbSyncEmProgresso) {
      return;
    }
    if (user.tmb > 0) {
      _tmbSyncFeito = true;
      return;
    }
    final calc = functions.tmbCalculadaDoPerfil(user);
    if (calc == null || calc <= 0 || currentUserReference == null) {
      return;
    }
    _tmbSyncEmProgresso = true;
    try {
      final nivel = user.nivelAtividade > 0 ? user.nivelAtividade : 1.2;
      await currentUserReference!.set(
        createUsersRecordData(
          tmb: calc,
          tmbCalculado: true,
          get: (calc * nivel).roundToDouble(),
        ),
        SetOptions(merge: true),
      );
      _tmbSyncFeito = true;
    } catch (_) {
      /* exibe valor calculado mesmo se gravação falhar */
    } finally {
      _tmbSyncEmProgresso = false;
    }
  }

  Widget _cardTmbPainel(BuildContext context, double tmb) {
    final temValor = tmb > 0;
    return InkWell(
      onTap: () => context.pushNamed(TmbWidget.routeName),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 12),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFF141416),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0x44C6A969),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFC6A969),
              size: 22,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Taxa Metabólica Basal (TMB)',
                    style: GoogleFonts.inter(
                      color: Color(0xFFA1A1A6),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    temValor ? '${tmb.round()} kcal/dia' : 'Toque para calcular',
                    style: GoogleFonts.interTight(
                      color: temValor ? Color(0xFFC6A969) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: temValor ? 22 : 15,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFC6A969),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _persistirFotoPerfil(String novaUrl) async {
    if (currentUserReference == null || novaUrl.isEmpty) {
      return;
    }
    await currentUserReference!.update(
      createUsersRecordData(photoUrl: novaUrl),
    );
    try {
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(novaUrl);
    } catch (_) {
      /* Auth photo opcional; Firestore é a fonte principal */
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRef = currentUserReference;
    if (userRef == null) {
      return Scaffold(
        backgroundColor: Color(0xFF0B0B0C),
        body: Center(
          child: Text(
            'Sessão expirada. Faça login novamente.',
            style: GoogleFonts.inter(color: Color(0xFFA1A1A6)),
          ),
        ),
      );
    }
    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(userRef),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Color(0xFF0B0B0C),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar o painel.\nVerifique a ligação e tente de novo.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Color(0xFFA1A1A6)),
                ),
              ),
            ),
          );
        }
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Color(0xFF0B0B0C),
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        final paginaDoPacienteUsersRecord = snapshot.data!;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ensureDailyDashboardTotalsIfNewCalendarDay(
            userRef,
            paginaDoPacienteUsersRecord.snapshotData,
          );
          _persistirTmbSeCalculavel(paginaDoPacienteUsersRecord);
        });

        final hojePainel = currentLocalDashboardDayKey();

        final zerarJaUsadoHoje =
            paginaDoPacienteUsersRecord.diaUltimoZerarManualResumo ==
                hojePainel;

        final tmbPainel = functions.tmbDoUsuario(paginaDoPacienteUsersRecord);
        final ingestaoPainel = valueOrDefault(
            paginaDoPacienteUsersRecord.ingestaoCaloriasTotal, 0.0);
        final gastoPainel = paginaDoPacienteUsersRecord.caloriasTotalDia;
        final saldoPainel = functions.painelSaldoExibidoDia(
          tmbPainel,
          gastoPainel,
          ingestaoPainel,
        );
        final gorduraPainel = functions.painelGorduraVisivelDia(
          tmbPainel,
          gastoPainel,
          ingestaoPainel,
        );
        final gorduraEmGanho = gorduraPainel.emGanho;
        final mostrarTopoTmbAlimentacao = functions.painelUsaTmbMenosAlimentacao(
          tmbPainel,
          gastoPainel,
          ingestaoPainel,
        );
        final topoGorduraGramas = functions.painelTopoGorduraTmbMenosAlimentacao(
          tmbPainel,
          gastoPainel,
          ingestaoPainel,
        );
        final gorduraLabel =
            gorduraEmGanho ? 'Gordura a ganhar' : 'Gordura a queimar';
        final gorduraGramasTexto = gorduraPainel.gramas.toStringAsFixed(0);
        final gorduraValorColor = gorduraEmGanho
            ? const Color(0xFFEF4444)
            : (gorduraPainel.mostrarQueimar
                ? const Color(0xFF2DDE58)
                : const Color(0xFF5A5A5E));
        final gorduraUnidadeColor = gorduraEmGanho
            ? const Color(0xFFEF4444)
            : (gorduraPainel.mostrarQueimar
                ? const Color(0xFF0EDC63)
                : const Color(0xFF5A5A5E));
        final deficitValorColor = saldoPainel.modoVermelho
            ? const Color(0xFFEF4444)
            : (saldoPainel.modoVerde
                ? const Color(0xFF30D158)
                : const Color(0xFFC6A969));
        final saldoRotulo = saldoPainel.rotulo;
        final saldoTexto =
            functions.textoPainelSaldoExibido(saldoPainel);
        final semTmbNoCalculo = tmbPainel <= 0;
        final metaHoje = functions.metaDeficitDefinidaHoje(
          paginaDoPacienteUsersRecord,
          hojePainel,
        );
        final metaKcalHoje = metaHoje
            ? paginaDoPacienteUsersRecord.deficitProgramado
            : 0.0;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Color(0xFF0B0B0C),
            body: SafeArea(
              top: true,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 16.0, 16.0, 16.0),
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: 600.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            AuthUserStreamWidget(
                                              builder: (context) {
                                                final photoUrl = _model
                                                        .uploadedFileUrl_uploadDataSubir
                                                        .isNotEmpty
                                                    ? _model
                                                        .uploadedFileUrl_uploadDataSubir
                                                    : currentUserPhoto;
                                                return Container(
                                                  width: 56.0,
                                                  height: 56.0,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFF141416),
                                                    border: Border.all(
                                                      color: Color(0x33C6A969),
                                                    ),
                                                  ),
                                                  child: photoUrl.isNotEmpty
                                                      ? Image.network(
                                                          photoUrl,
                                                          key: ValueKey(photoUrl),
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context,
                                                                  error,
                                                                  stackTrace) =>
                                                              Icon(
                                                            Icons
                                                                .person_rounded,
                                                            color: Color(
                                                                0xFFA1A1A6),
                                                            size: 28.0,
                                                          ),
                                                        )
                                                      : Icon(
                                                          Icons.person_rounded,
                                                          color:
                                                              Color(0xFFA1A1A6),
                                                          size: 28.0,
                                                        ),
                                                );
                                              },
                                            ),
                                            Positioned(
                                              right: 0.0,
                                              bottom: 0.0,
                                              child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    final selectedMedia =
                                                        await selectMedia(
                                                      mediaSource: MediaSource
                                                          .photoGallery,
                                                      multiImage: false,
                                                    );
                                                    if (selectedMedia != null &&
                                                        selectedMedia.every((m) =>
                                                            validateFileFormat(
                                                                m.storagePath,
                                                                context))) {
                                                      safeSetState(() => _model
                                                              .isDataUploading_uploadDataSubir =
                                                          true);
                                                      var selectedUploadedFiles =
                                                          <FFUploadedFile>[];

                                                      var downloadUrls =
                                                          <String>[];
                                                      try {
                                                        selectedUploadedFiles =
                                                            selectedMedia
                                                                .map((m) =>
                                                                    FFUploadedFile(
                                                                      name: m
                                                                          .storagePath
                                                                          .split(
                                                                              '/')
                                                                          .last,
                                                                      bytes: m
                                                                          .bytes,
                                                                      height: m
                                                                          .dimensions
                                                                          ?.height,
                                                                      width: m
                                                                          .dimensions
                                                                          ?.width,
                                                                      blurHash:
                                                                          m.blurHash,
                                                                      originalFilename:
                                                                          m.originalFilename,
                                                                    ))
                                                                .toList();

                                                        downloadUrls =
                                                            (await Future.wait(
                                                          selectedMedia.map(
                                                            (m) async =>
                                                                await uploadData(
                                                                    m.storagePath,
                                                                    m.bytes),
                                                          ),
                                                        ))
                                                                .where((u) =>
                                                                    u != null)
                                                                .map((u) => u!)
                                                                .toList();
                                                      } finally {
                                                        _model.isDataUploading_uploadDataSubir =
                                                            false;
                                                      }
                                                      if (selectedUploadedFiles
                                                                  .length ==
                                                              selectedMedia
                                                                  .length &&
                                                          downloadUrls.length ==
                                                              selectedMedia
                                                                  .length) {
                                                        safeSetState(() {
                                                          _model.uploadedLocalFile_uploadDataSubir =
                                                              selectedUploadedFiles
                                                                  .first;
                                                          _model.uploadedFileUrl_uploadDataSubir =
                                                              downloadUrls
                                                                  .first;
                                                        });
                                                      } else {
                                                        safeSetState(() {});
                                                        if (!context.mounted) {
                                                          return;
                                                        }
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Falha ao enviar a foto.',
                                                            ),
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                    } else {
                                                      return;
                                                    }

                                                    final novaUrl = _model
                                                        .uploadedFileUrl_uploadDataSubir;
                                                    if (novaUrl.isEmpty ||
                                                        currentUserReference ==
                                                            null) {
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Não foi possível salvar a foto.',
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }

                                                    try {
                                                      await _persistirFotoPerfil(
                                                          novaUrl);
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      safeSetState(() {
                                                        _model.uploadedFileUrl_uploadDataSubir =
                                                            '';
                                                      });
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          backgroundColor:
                                                              Color(0xFF141416),
                                                          content: Text(
                                                            'Foto salva com sucesso!',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          duration: Duration(
                                                              seconds: 3),
                                                        ),
                                                      );
                                                    } catch (_) {
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Não foi possível salvar a foto.',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 22.0,
                                                    height: 22.0,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFC6A969),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color:
                                                            Color(0xFF0B0B0C),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.camera_alt_rounded,
                                                      color: Color(0xFF0B0B0C),
                                                      size: 12.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                valueOrDefault<String>(
                                                  paginaDoPacienteUsersRecord
                                                          .displayName
                                                          .isNotEmpty
                                                      ? paginaDoPacienteUsersRecord
                                                          .displayName
                                                      : currentUserDisplayName,
                                                  'Utilizador',
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .titleMedium
                                                    .override(
                                                      font: GoogleFonts
                                                          .interTight(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .fontStyle,
                                                      ),
                                                      color: Colors.white,
                                                      fontSize: 17.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .fontStyle,
                                                    ),
                                              ),
                                              SizedBox(height: 4),
                                              InkWell(
                                                onTap: () => context.pushNamed(
                                                  TmbWidget.routeName,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    vertical: 2,
                                                  ),
                                                  child: mostrarTopoTmbAlimentacao
                                                      ? FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                'TMB ${tmbPainel.toStringAsFixed(0)}',
                                                                style: GoogleFonts
                                                                    .inter(
                                                                  color: const Color(
                                                                      0xFFC6A969),
                                                                  fontSize:
                                                                      12.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                              Text(
                                                                '  ·  ',
                                                                style: GoogleFonts
                                                                    .inter(
                                                                  color: const Color(
                                                                      0xFF5A5A5E),
                                                                  fontSize:
                                                                      12.0,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Gordura a queimar (TMB − alimentação)',
                                                                style: GoogleFonts
                                                                    .inter(
                                                                  color: const Color(
                                                                      0xFFA1A1A6),
                                                                  fontSize:
                                                                      11.0,
                                                                ),
                                                              ),
                                                              Text(
                                                                '  ·  ',
                                                                style: GoogleFonts
                                                                    .inter(
                                                                  color: const Color(
                                                                      0xFF5A5A5E),
                                                                  fontSize:
                                                                      12.0,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${topoGorduraGramas.toStringAsFixed(0)} g',
                                                                style: GoogleFonts
                                                                    .inter(
                                                                  color: const Color(
                                                                      0xFF30D158),
                                                                  fontSize:
                                                                      12.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              'TMB: ',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontWeight,
                                                                      fontStyle:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                    ),
                                                                    color: const Color(
                                                                        0xFFA1A1A6),
                                                                    fontSize:
                                                                        13.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                            ),
                                                            Text(
                                                              tmbPainel > 0
                                                                  ? tmbPainel
                                                                      .toStringAsFixed(
                                                                          0)
                                                                  : 'Calcular',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                    color: tmbPainel >
                                                                            0
                                                                        ? const Color(
                                                                            0xFFC6A969)
                                                                        : Colors
                                                                            .white,
                                                                    fontSize:
                                                                        13.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                            ),
                                                            Text(
                                                              tmbPainel > 0
                                                                  ? ' kcal'
                                                                  : '',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontWeight,
                                                                    ),
                                                                    color: const Color(
                                                                        0xFFA1A1A6),
                                                                    fontSize:
                                                                        13.0,
                                                                  ),
                                                            ),
                                                            if (tmbPainel <= 0)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                    left: 4),
                                                                child: Icon(
                                                                  Icons
                                                                      .chevron_right_rounded,
                                                                  size: 16,
                                                                  color: const Color(
                                                                      0xFFC6A969),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 12.0)),
                                    ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF141416),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Icon(
                                          Icons.notifications_none_rounded,
                                          color: Color(0xFFA1A1A6),
                                          size: 20.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (tmbPainel <= 0)
                                  _cardTmbPainel(context, tmbPainel),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: CoachCard(
                                    nomeUsuario: currentUserDisplayName,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF141416),
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: Color(0x22FFFFFF),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Resumo do Dia',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .override(
                                                            font: GoogleFonts
                                                                .interTight(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                            ),
                                                            color: Color(
                                                                0xFFA1A1A6),
                                                            fontSize: 14.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                          ),
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextButton.icon(
                                                onPressed: zerarJaUsadoHoje
                                                    ? null
                                                    : () async {
                                                        final confirm =
                                                            await showDialog<
                                                                bool>(
                                                          context: context,
                                                          builder: (ctx) =>
                                                              AlertDialog(
                                                            backgroundColor:
                                                                Color(
                                                                    0xFF141416),
                                                            title: Text(
                                                              'Zerar dados de hoje?',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            content: Text(
                                                              'Volta a zero o resumo de hoje '
                                                              '(ingestão, gasto calórico e macros). '
                                                              'Os valores vão para o histórico/gráfico.\n\n'
                                                              'A meta do dia (desafio) '
                                                              'não é apagada — só zera '
                                                              'à meia-noite.\n\n'
                                                              'Use se o app não zerou '
                                                              'automaticamente ao mudar o dia.\n\n'
                                                              '• Não apaga foto de perfil.\n'
                                                              '• Só pode usar 1 vez por dia.',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xFFA1A1A6),
                                                                height: 1.35,
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        ctx,
                                                                        false),
                                                                child: Text(
                                                                    'Cancelar'),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        ctx,
                                                                        true),
                                                                child: Text(
                                                                  'Zerar agora',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFFC6A969),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                        if (confirm != true ||
                                                            !context.mounted) {
                                                          return;
                                                        }
                                                        final userRef =
                                                            currentUserReference;
                                                        if (userRef == null) {
                                                          return;
                                                        }
                                                        try {
                                                          await manualResetDailyDashboardTotals(
                                                              userRef);
                                                          if (!context
                                                              .mounted) {
                                                            return;
                                                          }
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'Resumo zerado. Registe de novo.'),
                                                            ),
                                                          );
                                                        } on ManualDailyResetAlreadyUsedTodayException {
                                                          if (!context
                                                              .mounted) {
                                                            return;
                                                          }
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'Zerar já usado hoje.'),
                                                            ),
                                                          );
                                                        } catch (_) {
                                                          if (!context
                                                              .mounted) {
                                                            return;
                                                          }
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'Não foi possível zerar.'),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Color(0xFFC6A969),
                                                  disabledForegroundColor:
                                                      Color(0xFF5A5A5E),
                                                  padding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(
                                                              8.0, 4.0, 8.0,
                                                              4.0),
                                                  minimumSize: Size(0.0, 28.0),
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                                icon: Icon(
                                                  zerarJaUsadoHoje
                                                      ? Icons.check_rounded
                                                      : Icons.restart_alt_rounded,
                                                  size: 18.0,
                                                ),
                                                label: Text(
                                                  zerarJaUsadoHoje
                                                      ? 'Zerado hoje'
                                                      : 'Zerar dia',
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13.0,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '1× por dia · se não zerou sozinho',
                                                style: GoogleFonts.inter(
                                                  fontSize: 10.0,
                                                  color: Color(0xFF5A5A5E),
                                                ),
                                              ),
                                            ],
                                          ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        10.0, 0.0, 10.0, 0.0),
                                                child: Container(
                                                  height: 27.0,
                                                  decoration: BoxDecoration(
                                                    color: Color(0x1AC6A969),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      'Hoje',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodySmall
                                                          .override(
                                                            font: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontStyle,
                                                            ),
                                                            color: Color(
                                                                0xFFC6A969),
                                                            fontSize: 10.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontStyle,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            height: 1.0,
                                            thickness: 1.0,
                                            color: Color(0x1AFFFFFF),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Meta de déficit calórico hoje',
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .override(
                                                            font: GoogleFonts
                                                                .inter(),
                                                            color: const Color(
                                                                0xFFA1A1A6),
                                                            fontSize: 12.0,
                                                          ),
                                                    ),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            metaHoje
                                                                ? metaKcalHoje
                                                                    .toStringAsFixed(
                                                                        0)
                                                                : '—',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleLarge
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .interTight(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  color: metaHoje
                                                                      ? Colors
                                                                          .white
                                                                      : const Color(
                                                                          0xFF5A5A5E),
                                                                  fontSize: 28.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    4.0),
                                                            child: Text(
                                                              'kcal',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(),
                                                                    color: const Color(
                                                                        0xFFA1A1A6),
                                                                    fontSize:
                                                                        13.0,
                                                                  ),
                                                            ),
                                                          ),
                                                        ].divide(const SizedBox(
                                                            width: 4.0)),
                                                      ),
                                                    ),
                                                    if (!metaHoje)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 4.0),
                                                        child: Text(
                                                          'Desafio opcional — use '
                                                          'Programar déficit do dia',
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: const Color(
                                                                0xFF5A5A5E),
                                                            fontSize: 11.0,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10.0),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      gorduraLabel,
                                                      maxLines: 2,
                                                      textAlign: TextAlign.end,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .override(
                                                            font: GoogleFonts
                                                                .inter(),
                                                            color: const Color(
                                                                0xFFA1A1A6),
                                                            fontSize: 12.0,
                                                          ),
                                                    ),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            gorduraGramasTexto,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleLarge
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .interTight(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  color:
                                                                      gorduraValorColor,
                                                                  fontSize: 28.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    4.0),
                                                            child: Text(
                                                              'g',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(),
                                                                    color:
                                                                        gorduraUnidadeColor,
                                                                    fontSize:
                                                                        13.0,
                                                                  ),
                                                            ),
                                                          ),
                                                        ].divide(const SizedBox(
                                                            width: 4.0)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            height: 1.0,
                                            thickness: 1.0,
                                            color: Color(0x1AFFFFFF),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Ingestão calórica',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontStyle,
                                                          ),
                                                          color:
                                                              Color(0xFFA1A1A6),
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      AuthUserStreamWidget(
                                                        builder: (context) =>
                                                            Text(
                                                          valueOrDefault<
                                                              String>(
                                                            valueOrDefault(
                                                                    currentUserDocument
                                                                        ?.ingestaoCaloriasTotal,
                                                                    0.0)
                                                                .toString(),
                                                            '1100',
                                                          ),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .titleMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .interTight(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 22.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    3.0),
                                                        child: Text(
                                                          'kcal',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodySmall
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontStyle,
                                                                ),
                                                                color: Color(
                                                                    0xFFA1A1A6),
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 4.0)),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Gasto calórico',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontStyle,
                                                          ),
                                                          color:
                                                              Color(0xFFA1A1A6),
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      AuthUserStreamWidget(
                                                        builder: (context) =>
                                                            Text(
                                                          valueOrDefault<
                                                              String>(
                                                            valueOrDefault(
                                                                    currentUserDocument
                                                                        ?.caloriasTotalDia,
                                                                    0.0)
                                                                .toString(),
                                                            '650',
                                                          ),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .titleMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .interTight(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 22.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    3.0),
                                                        child: Text(
                                                          'kcal',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodySmall
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontStyle,
                                                                ),
                                                                color: Color(
                                                                    0xFFA1A1A6),
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 4.0)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            height: 1.0,
                                            thickness: 1.0,
                                            color: Color(0x1AFFFFFF),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                flex: 2,
                                                child: Text(
                                                  '$saldoRotulo:',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodySmall
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color: Color(0xFFA1A1A6),
                                                        fontSize: 13.0,
                                                      ),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 3,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    if (!saldoPainel.mostrarTmb)
                                                      Icon(
                                                        saldoPainel.modoVermelho
                                                            ? Icons
                                                                .trending_up_rounded
                                                            : Icons
                                                                .trending_down_rounded,
                                                        color:
                                                            deficitValorColor,
                                                        size: 16.0,
                                                      ),
                                                    Flexible(
                                                      child: Text(
                                                        saldoTexto,
                                                        textAlign: TextAlign.end,
                                                        overflow:
                                                            TextOverflow.visible,
                                                        softWrap: false,
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .titleSmall
                                                            .override(
                                                              font: GoogleFonts
                                                                  .interTight(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              color:
                                                                  deficitValorColor,
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                      ),
                                                    ),
                                                    Text(
                                                      ' kcal',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color:
                                                              deficitValorColor,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                ].divide(SizedBox(width: 6.0)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (semTmbNoCalculo && ingestaoPainel > 0)
                                            Padding(
                                              padding: EdgeInsets.only(top: 6),
                                              child: Text(
                                                'Sem TMB no cálculo: superávit/déficit '
                                                'usa (TMB + gasto) − ingestão. '
                                                'Calcule a TMB para o saldo ficar completo.',
                                                style: GoogleFonts.inter(
                                                  color: Color(0xFF5A5A5E),
                                                  fontSize: 11,
                                                  height: 1.35,
                                                ),
                                              ),
                                            ),
                                        ].divide(SizedBox(height: 14.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF141416),
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: Color(0x22FFFFFF),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Proteínas',
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .labelSmall
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontStyle,
                                                      ),
                                                      color: Color(0xFFA1A1A6),
                                                      fontSize: 11.0,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                              Text(
                                                '${valueOrDefault<String>(valueOrDefault(currentUserDocument?.proteinaDia, 0.0).toString(), '0')} g',
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      color: Color(0xFF0AD64D),
                                                      fontSize: 14.0,
                                                    ),
                                              ),
                                            ].divide(SizedBox(height: 4.0)),
                                          ),
                                        ),
                                        Container(
                                          width: 1.0,
                                          height: 36.0,
                                          color: Color(0xFF2A2A2E),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Carbos',
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .labelSmall
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                      color: Color(0xFFA1A1A6),
                                                      fontSize: 11.0,
                                                    ),
                                              ),
                                              Text(
                                                '${valueOrDefault<String>(valueOrDefault(currentUserDocument?.carboidratoDia, 0.0).toString(), '0')} g',
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .warning,
                                                      fontSize: 14.0,
                                                    ),
                                              ),
                                            ].divide(SizedBox(height: 4.0)),
                                          ),
                                        ),
                                        Container(
                                          width: 1.0,
                                          height: 36.0,
                                          color: Color(0xFF2A2A2E),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Gorduras',
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .labelSmall
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                      color: Color(0xFFA1A1A6),
                                                      fontSize: 11.0,
                                                    ),
                                              ),
                                              Text(
                                                '${valueOrDefault<String>(valueOrDefault(currentUserDocument?.gorduraDia, 0.0).toString(), '0')} g',
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .warning,
                                                      fontSize: 14.0,
                                                    ),
                                              ),
                                            ].divide(SizedBox(height: 4.0)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Text(
                                    'AÇÕES RÁPIDAS',
                                    style: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontStyle,
                                          ),
                                          color: Color(0xFFA1A1A6),
                                          fontSize: 11.0,
                                          letterSpacing: 1.5,
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF141416),
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: Color(0x22FFFFFF),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 16.0, 16.0, 16.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 40.0,
                                                    height: 40.0,
                                                    decoration: BoxDecoration(
                                                      color: Color(0x1AC6A969),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                      child: Icon(
                                                        Icons.schedule_rounded,
                                                        color:
                                                            Color(0xFFC6A969),
                                                        size: 20.0,
                                                      ),
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          context.goNamed(
                                                              ProgramarDeficitCaloricoWidget
                                                                  .routeName);
                                                        },
                                                        child: Text(
                                                          'Programar deficit calórico do dia',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .titleSmall
                                                              .override(
                                                                font: GoogleFonts
                                                                    .interTight(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                                ),
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                      Text(
                                                        'Defina suas atividades planejadas',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodySmall
                                                            .override(
                                                              font: GoogleFonts
                                                                  .inter(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontStyle,
                                                              ),
                                                              color: Color(
                                                                  0xFFA1A1A6),
                                                              fontSize: 12.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontStyle,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ].divide(SizedBox(width: 14.0)),
                                              ),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                color: Color(0xFFA1A1A6),
                                                size: 18.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          height: 1.0,
                                          thickness: 1.0,
                                          indent: 70.0,
                                          color: Color(0x1AFFFFFF),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 16.0, 16.0, 16.0),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              context.pushNamed(
                                                  ListaAlimentosWidget
                                                      .routeName);
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    context.pushNamed(
                                                        ListaAlimentosWidget
                                                            .routeName);
                                                  },
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          context.pushNamed(
                                                              ListaAlimentosWidget
                                                                  .routeName);
                                                        },
                                                        child: Container(
                                                          width: 40.0,
                                                          height: 40.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0x1A30D158),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Icon(
                                                              Icons
                                                                  .restaurant_menu_rounded,
                                                              color: Color(
                                                                  0xFF30D158),
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              context.pushNamed(
                                                                  ListaAlimentosWidget
                                                                      .routeName);
                                                            },
                                                            child: Text(
                                                              'Registro alimentar',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .interTight(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontStyle,
                                                                    ),
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        15.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                          ),
                                                          Text(
                                                            'Registre refeições e lanches',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodySmall
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Color(
                                                                      0xFFA1A1A6),
                                                                  fontSize:
                                                                      12.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontStyle,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 14.0)),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.chevron_right_rounded,
                                                  color: Color(0xFFA1A1A6),
                                                  size: 18.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          height: 1.0,
                                          thickness: 1.0,
                                          indent: 70.0,
                                          color: Color(0x1AFFFFFF),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 16.0, 16.0, 16.0),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              context.pushNamed(
                                                  ListaDeTreinoWidget
                                                      .routeName);
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        context.pushNamed(
                                                            ListaDeTreinoWidget
                                                                .routeName);
                                                      },
                                                      child: Container(
                                                        width: 40.0,
                                                        height: 40.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0x1A5E9EFF),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Icon(
                                                            Icons
                                                                .fitness_center_rounded,
                                                            color: Color(
                                                                0xFF5E9EFF),
                                                            size: 20.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            context.pushNamed(
                                                                ListaDeTreinoWidget
                                                                    .routeName);
                                                          },
                                                          child: Text(
                                                            'Registrar treinos',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleSmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .interTight(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      15.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                                ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'Adicione séries, cargas e tempo',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodySmall
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .fontStyle,
                                                                ),
                                                                color: Color(
                                                                    0xFFA1A1A6),
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 14.0)),
                                                ),
                                                Icon(
                                                  Icons.chevron_right_rounded,
                                                  color: Color(0xFFA1A1A6),
                                                  size: 18.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        painelMenuDivider(),
                                        PainelAcaoMenuItem(
                                          icon: Icons.local_fire_department_outlined,
                                          iconColor: Color(0xFFFF9F43),
                                          iconBg: Color(0x1AFF9F43),
                                          title: 'Outros gastos calóricos',
                                          subtitle:
                                              'Atividades extras que queimam calorias',
                                          onTap: () => context.pushNamed(
                                            OutrosGastosCaloricosWidget.routeName,
                                          ),
                                        ),
                                        painelMenuDivider(),
                                        PainelAcaoMenuItem(
                                          icon: Icons.directions_run_rounded,
                                          iconColor: Color(0xFFFF9F43),
                                          iconBg: Color(0x1AFF9F43),
                                          title: 'Atividade aeróbica',
                                          subtitle:
                                              'Registar cardio e atualizar gasto diário',
                                          onTap: () => context.pushNamed(
                                            PagRegistrarAerobicoWidget.routeName,
                                          ),
                                        ),
                                        painelMenuDivider(),
                                        PainelAcaoMenuItem(
                                          icon: Icons.monitor_heart_outlined,
                                          iconColor: Color(0xFFA1A1A6),
                                          iconBg: Color(0x1AFFFFFF),
                                          title: 'Bioimpedância',
                                          subtitle:
                                              'Gordura, Músculo, água e outros ao longo do tempo',
                                          onTap: () => context.pushNamed(
                                            PagRegistrarBioimpedanciaWidget
                                                .routeName,
                                          ),
                                        ),
                                        painelMenuDivider(),
                                        PainelAcaoMenuItem(
                                          icon: Icons.show_chart_rounded,
                                          iconColor: Color(0xFF5E9EFF),
                                          iconBg: Color(0x1A5E9EFF),
                                          title: 'Gráfico evolutivo',
                                          subtitle:
                                              'Explore e tendências corporais',
                                          onTap: () => context.pushNamed(
                                            GraficoEvolutivoWidget.routeName,
                                          ),
                                        ),
                                        painelMenuDivider(),
                                        PainelAcaoMenuItem(
                                          icon: Icons.local_fire_department_rounded,
                                          iconColor: Color(0xFFFF9F43),
                                          iconBg: Color(0x1AFF9F43),
                                          title: 'TMB',
                                          subtitle:
                                              'Taxa metabólica basal e base de gasto energético',
                                          onTap: () => context.pushNamed(
                                            TmbWidget.routeName,
                                          ),
                                        ),
                                        painelMenuDivider(),
                                        PainelAcaoMenuItem(
                                          icon: Icons.settings_rounded,
                                          iconColor: Color(0xFF5E9EFF),
                                          iconBg: Color(0x1A5E9EFF),
                                          title: 'Editar perfil',
                                          subtitle:
                                              'Perfil, metas e preferências',
                                          onTap: () => context.pushNamed(
                                            EditarPerfilWidget.routeName,
                                          ),
                                        ),
                                        painelMenuDivider(),
                                        PainelAcaoMenuItem(
                                          icon: Icons.chat_bubble_outline_rounded,
                                          iconColor: Color(0xFFA1A1A6),
                                          iconBg: Color(0x1AFFFFFF),
                                          title: 'Resenha Bodybuilder',
                                          subtitle: 'Bate-papo da comunidade',
                                          onTap: () => context.pushNamed(
                                            PagResenhaBodybuilderWidget.routeName,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                      ),
                  ]
                      .divide(SizedBox(height: 16.0))
                      .addToStart(SizedBox(height: 16.0))
                      .addToEnd(SizedBox(height: 32.0)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
