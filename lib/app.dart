import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'pantallas/aprender.dart';
import 'pantallas/bienvenida.dart';
import 'pantallas/leccion.dart';
import 'pantallas/liga.dart';
import 'pantallas/perfil.dart';
import 'pantallas/shell.dart';
import 'pantallas/simulacro.dart';
import 'pantallas/simulacro_inicio.dart';
import 'providers.dart';
import 'tema.dart';

final _raiz = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final sesion = ValueNotifier<bool>(ref.read(progresoProvider).sesionIniciada);
  ref.listen(
    progresoProvider.select((p) => p.sesionIniciada),
    (_, valor) => sesion.value = valor,
  );
  ref.onDispose(sesion.dispose);

  return GoRouter(
    navigatorKey: _raiz,
    initialLocation: '/aprender',
    refreshListenable: sesion,
    redirect: (context, state) {
      final enBienvenida = state.matchedLocation == '/bienvenida';
      if (!sesion.value) return enBienvenida ? null : '/bienvenida';
      return enBienvenida ? '/aprender' : null;
    },
    routes: [
      GoRoute(
        path: '/bienvenida',
        builder: (context, state) => const PantallaBienvenida(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellPrincipal(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/aprender',
                builder: (context, state) => const PantallaAprender(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/simulacro',
                builder: (context, state) => const PantallaSimulacroInicio(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/liga',
                builder: (context, state) => const PantallaLiga(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/perfil',
                builder: (context, state) => const PantallaPerfil(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/leccion/:id',
        parentNavigatorKey: _raiz,
        builder: (context, state) =>
            PantallaLeccion(leccionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/auditoria/:rol',
        parentNavigatorKey: _raiz,
        builder: (context, state) =>
            PantallaSimulacro(rolId: state.pathParameters['rol']!),
      ),
    ],
  );
});

class DiverLeyApp extends ConsumerWidget {
  const DiverLeyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Diver_Ley',
    debugShowCheckedModeBanner: false,
    theme: temaDiverLey(),
    routerConfig: ref.watch(routerProvider),
  );
}
