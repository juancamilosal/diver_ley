import 'package:material_ui/material_ui.dart';

import '../tema.dart';

/// Marca de la app: un escudo con visto bueno sobre verde.
class LogoDiverLey extends StatelessWidget {
  const LogoDiverLey({super.key, this.tamano = 72});

  final double tamano;

  @override
  Widget build(BuildContext context) => Container(
    width: tamano,
    height: tamano,
    decoration: BoxDecoration(
      color: Colores.verde,
      borderRadius: BorderRadius.circular(tamano * 0.28),
      border: Border(
        bottom: BorderSide(color: Colores.verdeOscuro, width: tamano * 0.07),
      ),
    ),
    child: Icon(
      Icons.verified_user_rounded,
      color: Colores.blanco,
      size: tamano * 0.58,
    ),
  );
}
