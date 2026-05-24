import '/backend/schema/users_record.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';

/// Dados mínimos do perfil (peso, altura, nascimento, nome).
bool perfilCadastroMinimoCompleto(UsersRecord? user) {
  if (user == null) {
    return false;
  }
  if (user.cadastroCompleto) {
    return true;
  }
  final alturaCm = functions.normalizarAlturaCm(user.altura);
  final temNome = user.displayName.trim().isNotEmpty;
  return user.peso > 0 &&
      alturaCm > 0 &&
      user.dataNascimento != null &&
      temNome;
}

/// TMB guardada no Firebase (ecrã Calcular TMB ou cadastro com TMB).
bool perfilTemTmbSalvo(UsersRecord? user) {
  return functions.perfilTemTmbUtilizavel(user);
}

/// Rota inicial após login: cadastro → TMB → painel.
String routePathPosLogin(UsersRecord? user) {
  if (!perfilCadastroMinimoCompleto(user)) {
    return PaginaCadastroWidget.routePath;
  }
  if (!perfilTemTmbSalvo(user)) {
    return TmbWidget.routePath;
  }
  return PaginaDoPacienteWidget.routePath;
}

String routeNamePosLogin(UsersRecord? user) {
  if (!perfilCadastroMinimoCompleto(user)) {
    return PaginaCadastroWidget.routeName;
  }
  if (!perfilTemTmbSalvo(user)) {
    return TmbWidget.routeName;
  }
  return PaginaDoPacienteWidget.routeName;
}

/// Impede abrir o painel antes de concluir cadastro + TMB.
String? redirectSeOnboardingIncompleto(
  String location,
  UsersRecord? user,
) {
  final destino = routePathPosLogin(user);

  if (location == '/' ||
      location == PaginaInicialWidget.routePath ||
      location == CriarLoginSenhaWidget.routePath) {
    return destino;
  }

  if (destino == PaginaCadastroWidget.routePath) {
    if (location != PaginaCadastroWidget.routePath) {
      return PaginaCadastroWidget.routePath;
    }
    return null;
  }

  if (destino == TmbWidget.routePath) {
    final permitido = location == PaginaCadastroWidget.routePath ||
        location == TmbWidget.routePath;
    if (!permitido) {
      return TmbWidget.routePath;
    }
    return null;
  }

  return null;
}
