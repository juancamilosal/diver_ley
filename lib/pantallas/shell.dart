import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../tema.dart';

/// Barra de abajo con las cuatro secciones de la app.
class ShellPrincipal extends StatelessWidget {
  const ShellPrincipal({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: shell,
    bottomNavigationBar: DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colores.borde, width: 2)),
      ),
      child: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route, color: Colores.verde),
            label: 'Aprender',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check, color: Colores.verde),
            label: 'Simulacro',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: Colores.verde),
            label: 'Liga',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colores.verde),
            label: 'Perfil',
          ),
        ],
      ),
    ),
  );
}
