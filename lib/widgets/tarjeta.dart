import 'package:material_ui/material_ui.dart';

import '../tema.dart';

/// Tarjeta blanca con borde suave, la base de casi todas las pantallas.
class Tarjeta extends StatelessWidget {
  const Tarjeta({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colores.blanco,
    this.colorBorde = Colores.borde,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color colorBorde;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(20);
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: radio,
        side: BorderSide(color: colorBorde, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Etiqueta pequeña en mayúsculas sobre los títulos.
class Antetitulo extends StatelessWidget {
  const Antetitulo(this.texto, {super.key, this.color = Colores.verde});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    texto.toUpperCase(),
    style: nunito(
      13,
      peso: FontWeight.w800,
      color: color,
    ).copyWith(letterSpacing: 1.2),
  );
}
