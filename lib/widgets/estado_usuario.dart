import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../modelos/progreso.dart';
import '../providers.dart';
import '../tema.dart';

/// Racha, XP y meta del día, arriba de la ruta.
class EstadoUsuario extends ConsumerWidget {
  const EstadoUsuario({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progreso = ref.watch(progresoProvider);
    final hoy = ref.watch(relojProvider)();
    final racha = progreso.rachaActual(hoy);
    final xpHoy = progreso.xpDeHoy(hoy);
    final practico = progreso.practicoHoy(hoy);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Indicador(
          icono: Icons.local_fire_department_rounded,
          color: practico ? Colores.naranja : Colores.grisOscuro,
          texto: '$racha',
          ayuda: practico
              ? 'Racha de $racha días. ¡Ya practicaste hoy!'
              : 'Racha de $racha días. Haz una lección hoy para no perderla.',
        ),
        _Indicador(
          icono: Icons.star_rounded,
          color: Colores.dorado,
          texto: '${progreso.xp} XP',
          ayuda: 'Puntos de experiencia acumulados.',
        ),
        _MetaDiaria(xpHoy: xpHoy),
      ],
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.icono,
    required this.color,
    required this.texto,
    required this.ayuda,
  });

  final IconData icono;
  final Color color;
  final String texto;
  final String ayuda;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: ayuda,
    triggerMode: TooltipTriggerMode.tap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: color, size: 28),
          const SizedBox(width: 4),
          Text(texto, style: rubik(18, color: color)),
        ],
      ),
    ),
  );
}

class _MetaDiaria extends StatelessWidget {
  const _MetaDiaria({required this.xpHoy});

  final int xpHoy;

  @override
  Widget build(BuildContext context) {
    const meta = Progreso.metaDiaria;
    final cumplida = xpHoy >= meta;
    return Tooltip(
      message: 'Meta diaria: $meta XP',
      triggerMode: TooltipTriggerMode.tap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (xpHoy / meta).clamp(0, 1),
                  strokeWidth: 4,
                  backgroundColor: Colores.gris,
                  color: Colores.verde,
                ),
                if (cumplida)
                  const Icon(Icons.check, size: 14, color: Colores.verde),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${xpHoy.clamp(0, 999)}/$meta',
            style: rubik(16, color: cumplida ? Colores.verde : Colores.texto),
          ),
        ],
      ),
    );
  }
}
