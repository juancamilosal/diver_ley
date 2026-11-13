import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../datos/demo.dart';
import '../logica/fechas.dart';
import '../logica/sesion_simulacro.dart';
import '../modelos/contenido.dart';
import '../providers.dart';
import '../tema.dart';
import '../widgets/tarjeta.dart';

/// Elegir el cargo para el simulacro de auditoría.
class PantallaSimulacroInicio extends ConsumerWidget {
  const PantallaSimulacroInicio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contenido = ref.watch(contenidoProvider).value;
    final simulacros = ref.watch(progresoProvider).simulacros;
    return Scaffold(
      appBar: AppBar(title: const Text('Simulacro de auditoría')),
      body: contenido == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colores.navy,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ensaya la auditoría',
                              style: rubik(20, color: Colores.blanco),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Preguntas como las haría un auditor según tu '
                              'cargo. Sin pistas y con tiempo. Al final ves '
                              'qué reforzar y el resultado queda como '
                              'evidencia.',
                              style: nunito(
                                15,
                                color: const Color(0xFFC9D3E3),
                                alto: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.record_voice_over_rounded,
                        color: Colores.menta,
                        size: 52,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Elige el cargo', style: rubik(18)),
                const SizedBox(height: 10),
                for (final rol in contenido.roles)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TarjetaRol(
                      rol: rol,
                      preguntas: contenido.preguntasDeRol(rol.id).length,
                      esMiCargo: rol.id == Demo.usuario.rolId,
                    ),
                  ),
                if (simulacros.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Tus simulacros', style: rubik(18)),
                  const SizedBox(height: 10),
                  for (final s in simulacros.take(5))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FilaSimulacro(
                        rol: contenido.rol(s.rolId).nombre,
                        fecha: s.fecha,
                        puntaje: s.puntaje,
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}

class _TarjetaRol extends StatelessWidget {
  const _TarjetaRol({
    required this.rol,
    required this.preguntas,
    required this.esMiCargo,
  });

  final Rol rol;
  final int preguntas;
  final bool esMiCargo;

  @override
  Widget build(BuildContext context) => Tarjeta(
    colorBorde: esMiCargo ? Colores.verde : Colores.borde,
    onTap: () => context.push('/auditoria/${rol.id}'),
    child: Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: esMiCargo ? Colores.verdeSuave : Colores.gris,
          child: Icon(
            switch (rol.id) {
              'operario' => Icons.construction_rounded,
              'supervisor' => Icons.engineering_rounded,
              _ => Icons.health_and_safety_rounded,
            },
            color: esMiCargo ? Colores.verde : Colores.navy,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(rol.nombre, style: rubik(17)),
                  if (esMiCargo)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colores.verde,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Tu cargo',
                        style: nunito(
                          12,
                          peso: FontWeight.w800,
                          color: Colores.blanco,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                rol.descripcion,
                style: nunito(14, color: Colores.textoSuave, alto: 1.3),
              ),
              const SizedBox(height: 4),
              Text(
                '${preguntas.clamp(0, 8)} preguntas · '
                '${SesionSimulacro.duracion.inMinutes} min',
                style: nunito(
                  13,
                  peso: FontWeight.w700,
                  color: Colores.textoSuave,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: Colores.grisOscuro),
      ],
    ),
  );
}

/// Un simulacro del historial con su puntaje.
class FilaSimulacro extends StatelessWidget {
  const FilaSimulacro({
    super.key,
    required this.rol,
    required this.fecha,
    required this.puntaje,
  });

  final String rol;
  final DateTime fecha;
  final int puntaje;

  @override
  Widget build(BuildContext context) {
    final nivel = nivelDe(puntaje);
    return Tarjeta(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.fact_check_rounded, color: colorDeNivel(nivel)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rol, style: nunito(15, peso: FontWeight.w700)),
                Text(
                  fechaHora(fecha),
                  style: nunito(13, color: Colores.textoSuave),
                ),
              ],
            ),
          ),
          Text('$puntaje %', style: rubik(18, color: colorDeNivel(nivel))),
        ],
      ),
    );
  }
}

Color colorDeNivel(Nivel nivel) => switch (nivel) {
  Nivel.preparado => Colores.verde,
  Nivel.porReforzar => Colores.dorado,
  Nivel.critico => Colores.naranjaOscuro,
};

String nombreDeNivel(Nivel nivel) => switch (nivel) {
  Nivel.preparado => 'Preparado',
  Nivel.porReforzar => 'Por reforzar',
  Nivel.critico => 'Crítico',
};
