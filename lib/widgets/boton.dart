import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../tema.dart';

/// Botón grande con relieve: baja al tocarlo.
class Boton extends StatefulWidget {
  const Boton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.color = Colores.verde,
    this.colorSombra = Colores.verdeOscuro,
    this.colorTexto = Colores.blanco,
    this.icono,
    this.ancho = double.infinity,
  });

  /// Botón blanco con borde, para acciones secundarias.
  const Boton.secundario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icono,
    this.ancho = double.infinity,
  }) : color = Colores.blanco,
       colorSombra = Colores.borde,
       colorTexto = Colores.texto;

  final String texto;
  final VoidCallback? onPressed;
  final Color color;
  final Color colorSombra;
  final Color colorTexto;
  final IconData? icono;
  final double ancho;

  @override
  State<Boton> createState() => _BotonState();
}

class _BotonState extends State<Boton> {
  static const _relieve = 4.0;
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final activo = widget.onPressed != null;
    final color = activo ? widget.color : Colores.gris;
    final sombra = activo ? widget.colorSombra : Colores.borde;
    final texto = activo ? widget.colorTexto : Colores.grisOscuro;
    final bajada = _presionado ? _relieve : 0.0;
    return Semantics(
      button: true,
      enabled: activo,
      child: GestureDetector(
        onTapDown: activo ? (_) => setState(() => _presionado = true) : null,
        onTapCancel: () => setState(() => _presionado = false),
        onTapUp: activo
            ? (_) {
                setState(() => _presionado = false);
                HapticFeedback.lightImpact();
                widget.onPressed!();
              }
            : null,
        child: SizedBox(
          width: widget.ancho,
          height: 56 + _relieve,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: sombra,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 60),
                left: 0,
                right: 0,
                top: bajada,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    border: widget.color == Colores.blanco
                        ? Border.all(color: Colores.borde, width: 2)
                        : null,
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icono != null) ...[
                        Icon(widget.icono, color: texto, size: 22),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          widget.texto.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: rubik(
                            16,
                            color: texto,
                          ).copyWith(letterSpacing: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
