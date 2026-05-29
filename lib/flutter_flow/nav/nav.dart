import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';

import '/auth/base_auth_user_provider.dart';
import '/auth/firebase_auth/auth_util.dart';

import '/main.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

import '/flutter_flow/post_login_route.dart';
import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  // Não bloquear a UI enquanto o Firebase Auth ainda não emitiu o primeiro evento.
  bool get loading => showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

String _loggedInHomePath() =>
    routePathPosLogin(currentUserDocument);

String? _resolveAppRedirect(
  AppStateNotifier notifier,
  GoRouterState state,
) {
  if (notifier.shouldRedirect) {
    final redirectLocation = notifier.getRedirectLocation();
    notifier.clearRedirectLocation();
    return redirectLocation;
  }

  final location = state.matchedLocation;

  if (!notifier.loggedIn) {
    if (location == '/') {
      return PaginaInicialWidget.routePath;
    }
    return null;
  }

  final onboarding = redirectSeOnboardingIncompleto(
    location,
    currentUserDocument,
  );
  if (onboarding != null) {
    return onboarding;
  }

  return null;
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      redirect: (context, state) =>
          _resolveAppRedirect(appStateNotifier, state),
      errorBuilder: (context, state) => appStateNotifier.loggedIn
          ? PaginaDoPacienteWidget()
          : PaginaInicialWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => appStateNotifier.loggedIn
              ? PaginaDoPacienteWidget()
              : PaginaInicialWidget(),
        ),
        FFRoute(
          name: PaginaInicialWidget.routeName,
          path: PaginaInicialWidget.routePath,
          builder: (context, params) => PaginaInicialWidget(),
        ),
        FFRoute(
          name: PaginaCadastroWidget.routeName,
          path: PaginaCadastroWidget.routePath,
          builder: (context, params) => PaginaCadastroWidget(),
        ),
        FFRoute(
          name: CriarLoginSenhaWidget.routeName,
          path: CriarLoginSenhaWidget.routePath,
          builder: (context, params) => CriarLoginSenhaWidget(),
        ),
        FFRoute(
          name: PaginaDoPacienteWidget.routeName,
          path: PaginaDoPacienteWidget.routePath,
          builder: (context, params) => PaginaDoPacienteWidget(
            fotoPerfil: params.getParam(
              'fotoPerfil',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: OutrasIngestaoCaloricasWidget.routeName,
          path: OutrasIngestaoCaloricasWidget.routePath,
          builder: (context, params) => OutrasIngestaoCaloricasWidget(),
        ),
        FFRoute(
          name: PagRegistrarAlimentosWidget.routeName,
          path: PagRegistrarAlimentosWidget.routePath,
          builder: (context, params) => PagRegistrarAlimentosWidget(
            categoria: params.getParam('categoria', ParamType.String),
          ),
        ),
        FFRoute(
          name: ListaAlimentosWidget.routeName,
          path: ListaAlimentosWidget.routePath,
          builder: (context, params) => ListaAlimentosWidget(),
        ),
        FFRoute(
          name: ListaDeTreinoWidget.routeName,
          path: ListaDeTreinoWidget.routePath,
          builder: (context, params) => ListaDeTreinoWidget(),
        ),
        FFRoute(
          name: PagRegistrarAerobicoWidget.routeName,
          path: PagRegistrarAerobicoWidget.routePath,
          builder: (context, params) => PagRegistrarAerobicoWidget(),
        ),
        FFRoute(
          name: PagRegistrarTreinoWidget.routeName,
          path: PagRegistrarTreinoWidget.routePath,
          builder: (context, params) => PagRegistrarTreinoWidget(
            categoria: params.getParam(
              'categoria',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: GraficoEvolutivoWidget.routeName,
          path: GraficoEvolutivoWidget.routePath,
          builder: (context, params) => GraficoEvolutivoWidget(),
        ),
        FFRoute(
          name: ProgramarDeficitCaloricoWidget.routeName,
          path: ProgramarDeficitCaloricoWidget.routePath,
          builder: (context, params) => ProgramarDeficitCaloricoWidget(),
        ),
        FFRoute(
          name: OutrosGastosCaloricosWidget.routeName,
          path: OutrosGastosCaloricosWidget.routePath,
          builder: (context, params) => OutrosGastosCaloricosWidget(),
        ),
        FFRoute(
          name: TmbWidget.routeName,
          path: TmbWidget.routePath,
          builder: (context, params) => TmbWidget(),
        ),
        FFRoute(
          name: EditarPerfilWidget.routeName,
          path: EditarPerfilWidget.routePath,
          builder: (context, params) => EditarPerfilWidget(),
        ),
        FFRoute(
          name: PagRegistrarBioimpedanciaWidget.routeName,
          path: PagRegistrarBioimpedanciaWidget.routePath,
          builder: (context, params) => PagRegistrarBioimpedanciaWidget(),
        ),
        FFRoute(
          name: PagResenhaBodybuilderWidget.routeName,
          path: PagResenhaBodybuilderWidget.routePath,
          builder: (context, params) => PagResenhaBodybuilderWidget(),
        ),
        FFRoute(
          name: SalaChatMensagensWidget.routeName,
          path: SalaChatMensagensWidget.routePath,
          builder: (context, params) => SalaChatMensagensWidget(
            salaId: params.getParam('salaId', ParamType.String) ?? '',
            salaNome: params.getParam('salaNome', ParamType.String) ?? 'Sala',
            modoEspiar: params.getParam('modoEspiar', ParamType.bool) ?? false,
          ),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the home screen
    // instead of popping (avoid sending logged-in users to the login page).
    if (canPop()) {
      pop();
    } else if (loggedIn) {
      go(_loggedInHomePath());
    } else {
      go(PaginaInicialWidget.routePath);
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/criarLoginSenha';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Container(
                  color: const Color(0xFF0B0B0C),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFFC6A969),
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
