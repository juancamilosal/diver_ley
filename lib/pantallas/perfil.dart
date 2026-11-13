import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../datos/demo.dart';
import '../logica/fechas.dart';
import '../logica/ruta.dart';
import '../providers.dart';
import '../tema.dart';
import '../widgets/certificado.dart';
import '../widgets/tarjeta.dart';
import 'simulacro_inicio.dart';

class PantallaPerfil extends ConsumerWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progreso = ref.watch(progresoProvider);
    final contenido = ref.watch(contenidoProvider).value;
    final hoy = ref.watch(relojProvider)();
    final usuario = Demo.usuario;
    final certificados = contenido == null
        ? const []
        : [
            for (final u in contenido.unidades)
              if (unidadCompleta(u, progreso)) u,
          ];
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colores.verde,
                child: Text(
                  usuario.iniciales,
                  style: rubik(26, color: Colores.blanco),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(usuario.nombre, style: rubik(22)),
                    Text(
                      usuario.cargo,
                      style: nunito(15, peso: FontWeight.w700),
                    ),
                    Text(
                      '${Demo.empresa.nombre} · ${usuario.area}',
                      style: nunito(14, color: Colores.textoSuave),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.1,
            children: [
              _Estadistica(
                icono: Icons.local_fire_department_rounded,
                color: Colores.naranja,
                valor: '${progreso.rachaActual(hoy)}',
                etiqueta: 'Días de racha',
              ),
              _Estadistica(
                icono: Icons.star_rounded,
                color: Colores.dorado,
                valor: '${progreso.xp}',
                etiqueta: 'XP en total',
              ),
              _Estadistica(
                icono: Icons.school_rounded,
                color: Colores.verde,
                valor: '${progreso.leccionesCompletadas.length}',
                etiqueta: 'Lecciones',
              ),
              _Estadistica(
                icono: Icons.track_changes_rounded,
                color: Colores.navy,
                valor: '${progreso.precision} %',
                etiqueta: 'Precisión',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Certificados', style: rubik(18)),
          const SizedBox(height: 10),
          if (certificados.isEmpty)
            Text(
              'Completa una unidad para obtener tu primer certificado.',
              style: nunito(15, color: Colores.textoSuave),
            ),
          for (final u in certificados)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Tarjeta(
                onTap: () => mostrarCertificado(
                  context,
                  u,
                  progreso.fechasCertificado[u.id] ?? hoy,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colores.dorado,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.titulo,
                            style: nunito(16, peso: FontWeight.w700),
                          ),
                          Text(
                            '${u.norma} · '
                            '${fechaCorta(progreso.fechasCertificado[u.id] ?? hoy)}',
                            style: nunito(13, color: Colores.textoSuave),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colores.grisOscuro,
                    ),
                  ],
                ),
              ),
            ),
          if (progreso.simulacros.isNotEmpty && contenido != null) ...[
            const SizedBox(height: 14),
            Text('Simulacros de auditoría', style: rubik(18)),
            const SizedBox(height: 10),
            for (final s in progreso.simulacros.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FilaSimulacro(
                  rol: contenido.rol(s.rolId).nombre,
                  fecha: s.fecha,
                  puntaje: s.puntaje,
                ),
              ),
          ],
          const SizedBox(height: 14),
          Text('Esta demo', style: rubik(18)),
          const SizedBox(height: 10),
          Tarjeta(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.offline_pin_rounded,
                    color: Colores.verde,
                  ),
                  title: Text(
                    'Funciona sin conexión',
                    style: nunito(16, peso: FontWeight.w700),
                  ),
                  subtitle: Text(
                    contenido == null
                        ? 'Cargando contenido…'
                        : '${contenido.unidades.length} unidades guardadas en '
                              'el celular para la obra o el campo.',
                    style: nunito(14, color: Colores.textoSuave),
                  ),
                ),
                const Divider(height: 1, color: Colores.borde),
                SwitchListTile(
                  secondary: const Icon(Icons.lock_open_rounded),
                  title: Text(
                    'Desbloquear todas las lecciones',
                    style: nunito(16, peso: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Para recorrer la demo sin seguir el orden.',
                    style: nunito(14, color: Colores.textoSuave),
                  ),
                  value: progreso.desbloquearTodo,
                  onChanged: ref
                      .read(progresoProvider.notifier)
                      .desbloquearTodo,
                ),
                const Divider(height: 1, color: Colores.borde),
                ListTile(
                  leading: const Icon(Icons.restart_alt_rounded),
                  title: Text(
                    'Reiniciar la demo',
                    style: nunito(16, peso: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Vuelve al avance inicial: 12 días de racha y la '
                    'primera unidad completa.',
                    style: nunito(14, color: Colores.textoSuave),
                  ),
                  onTap: () => _confirmarReinicio(context, ref),
                ),
                const Divider(height: 1, color: Colores.borde),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: Text(
                    'Cerrar sesión',
                    style: nunito(16, peso: FontWeight.w700),
                  ),
                  onTap: ref.read(progresoProvider.notifier).cerrarSesion,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: Colores.textoSuave,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Las preguntas de esta demo son de ejemplo. Antes de usarlas '
                  'con trabajadores, un profesional SST con licencia las '
                  'revisa y les pone fecha de vigencia.',
                  style: nunito(13, color: Colores.textoSuave, alto: 1.35),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarReinicio(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Reiniciar la demo?', style: rubik(20)),
        content: Text(
          'Se borran el avance, los simulacros y los certificados nuevos.',
          style: nunito(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(progresoProvider.notifier).reiniciarDemo();
  }
}

class _Estadistica extends StatelessWidget {
  const _Estadistica({
    required this.icono,
    required this.color,
    required this.valor,
    required this.etiqueta,
  });

  final IconData icono;
  final Color color;
  final String valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) => Tarjeta(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(
      children: [
        Icon(icono, color: color, size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(child: Text(valor, style: rubik(20))),
              Text(
                etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: nunito(13, color: Colores.textoSuave),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
