import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../datos/demo.dart';
import '../logica/fechas.dart';
import '../providers.dart';
import '../tema.dart';
import '../widgets/tarjeta.dart';

/// Liga semanal del área y avance de cada área de la empresa.
class PantallaLiga extends ConsumerStatefulWidget {
  const PantallaLiga({super.key});

  @override
  ConsumerState<PantallaLiga> createState() => _PantallaLigaState();
}

class _PantallaLigaState extends ConsumerState<PantallaLiga> {
  bool _porAreas = false;

  @override
  Widget build(BuildContext context) {
    final progreso = ref.watch(progresoProvider);
    final dias = diasParaCierreDeLiga(ref.watch(relojProvider)());
    final tabla = [
      for (final c in Demo.companeros) (c.nombre, c.cargo, c.xpSemana, false),
      (Demo.usuario.nombre, Demo.usuario.cargo, progreso.xpSemana, true),
    ]..sort((a, b) => b.$3.compareTo(a.$3));
    return Scaffold(
      appBar: AppBar(title: const Text('Liga')),
      body: ListView(
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
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Colores.dorado,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Colores.blanco,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Demo.liga, style: rubik(22, color: Colores.blanco)),
                      const SizedBox(height: 2),
                      Text(
                        'Compites con tu área: ${Demo.usuario.area}',
                        style: nunito(14, color: const Color(0xFFC9D3E3)),
                      ),
                      Text(
                        'Cierra en $dias ${dias == 1 ? 'día' : 'días'} · '
                        'los 3 primeros suben de liga',
                        style: nunito(
                          14,
                          peso: FontWeight.w700,
                          color: Colores.menta,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Mi área'),
                icon: Icon(Icons.groups_rounded),
              ),
              ButtonSegment(
                value: true,
                label: Text('Por áreas'),
                icon: Icon(Icons.apartment_rounded),
              ),
            ],
            selected: {_porAreas},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _porAreas = s.first),
          ),
          const SizedBox(height: 16),
          if (!_porAreas)
            for (final (i, fila) in tabla.indexed) ...[
              if (i == 3)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Expanded(child: Divider(color: Colores.verde)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Zona de ascenso',
                          style: nunito(
                            13,
                            peso: FontWeight.w800,
                            color: Colores.verde,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colores.verde)),
                    ],
                  ),
                ),
              _FilaLiga(
                posicion: i + 1,
                nombre: fila.$1,
                cargo: fila.$2,
                xp: fila.$3,
                esUsted: fila.$4,
              ),
            ]
          else ...[
            for (final area in Demo.areas) _FilaArea(area: area),
            const SizedBox(height: 8),
            Text(
              'Porcentaje del personal con la capacitación al día. El líder '
              'HSEQ lo ve en su panel por área, sede y contratista.',
              style: nunito(14, color: Colores.textoSuave, alto: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilaLiga extends StatelessWidget {
  const _FilaLiga({
    required this.posicion,
    required this.nombre,
    required this.cargo,
    required this.xp,
    required this.esUsted,
  });

  final int posicion;
  final String nombre;
  final String cargo;
  final int xp;
  final bool esUsted;

  @override
  Widget build(BuildContext context) {
    final podio = posicion <= 3;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tarjeta(
        color: esUsted ? Colores.verdeSuave : Colores.blanco,
        colorBorde: esUsted ? Colores.verde : Colores.borde,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '$posicion',
                textAlign: TextAlign.center,
                style: rubik(
                  18,
                  color: podio ? Colores.verde : Colores.grisOscuro,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: esUsted ? Colores.verde : Colores.navyClaro,
              child: Text(
                nombre.split(' ').take(2).map((p) => p[0]).join(),
                style: rubik(14, color: Colores.blanco),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    esUsted ? '$nombre (tú)' : nombre,
                    style: nunito(16, peso: FontWeight.w700),
                  ),
                  Text(cargo, style: nunito(13, color: Colores.textoSuave)),
                ],
              ),
            ),
            Text('$xp XP', style: rubik(16, color: Colores.textoSuave)),
          ],
        ),
      ),
    );
  }
}

class _FilaArea extends StatelessWidget {
  const _FilaArea({required this.area});

  final AreaEmpresa area;

  @override
  Widget build(BuildContext context) {
    final esMia = area.nombre == Demo.usuario.area;
    final color = area.alDia >= 85
        ? Colores.verde
        : area.alDia >= 70
        ? Colores.dorado
        : Colores.naranjaOscuro;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tarjeta(
        color: esMia ? Colores.verdeSuave : Colores.blanco,
        colorBorde: esMia ? Colores.verde : Colores.borde,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    esMia ? '${area.nombre} (tu área)' : area.nombre,
                    style: nunito(16, peso: FontWeight.w700),
                  ),
                ),
                Text('${area.alDia} %', style: rubik(17, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: area.alDia / 100,
                minHeight: 10,
                backgroundColor: Colores.gris,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
