import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../datos/demo.dart';
import '../logica/fechas.dart';
import '../logica/ruta.dart';
import '../modelos/contenido.dart';
import '../modelos/progreso.dart';
import '../providers.dart';
import '../tema.dart';
import '../widgets/boton.dart';
import '../widgets/certificado.dart';
import '../widgets/estado_usuario.dart';
import '../widgets/tarjeta.dart';

/// La ruta de aprendizaje: unidades con sus lecciones en camino.
class PantallaAprender extends ConsumerStatefulWidget {
  const PantallaAprender({super.key});

  @override
  ConsumerState<PantallaAprender> createState() => _PantallaAprenderState();
}

class _PantallaAprenderState extends ConsumerState<PantallaAprender> {
  final _claveActual = GlobalKey();
  bool _desplazado = false;

  /// Al abrir, lleva la vista a la lección que sigue.
  void _irALeccionActual() {
    if (_desplazado) return;
    _desplazado = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contexto = _claveActual.currentContext;
      if (contexto != null && contexto.mounted) {
        Scrollable.ensureVisible(
          contexto,
          alignment: 0.45,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contenido = ref.watch(contenidoProvider);
    final progreso = ref.watch(progresoProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: const BoxDecoration(
                color: Colores.blanco,
                border: Border(
                  bottom: BorderSide(color: Colores.borde, width: 2),
                ),
              ),
              child: const EstadoUsuario(),
            ),
            Expanded(
              child: contenido.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('No se pudo cargar el contenido: $e')),
                data: (c) {
                  _irALeccionActual();
                  return _Ruta(
                    contenido: c,
                    progreso: progreso,
                    claveActual: _claveActual,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ruta extends StatelessWidget {
  const _Ruta({
    required this.contenido,
    required this.progreso,
    required this.claveActual,
  });

  final Contenido contenido;
  final Progreso progreso;
  final GlobalKey claveActual;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          children: [
            for (final (i, unidad) in contenido.unidades.indexed) ...[
              _BannerUnidad(numero: i + 1, unidad: unidad),
              const SizedBox(height: 24),
              _Camino(
                unidad: unidad,
                numero: i + 1,
                contenido: contenido,
                progreso: progreso,
                claveActual: claveActual,
              ),
              const SizedBox(height: 32),
            ],
            Text(
              'Pronto: más unidades de tu sector y tus procedimientos.',
              textAlign: TextAlign.center,
              style: nunito(14, color: Colores.textoSuave),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BannerUnidad extends StatelessWidget {
  const _BannerUnidad({required this.numero, required this.unidad});

  final int numero;
  final Unidad unidad;

  @override
  Widget build(BuildContext context) {
    final esProcedimiento = unidad.tipo == TipoUnidad.procedimiento;
    final fondo = esProcedimiento ? Colores.navy : Colores.verde;
    final sombra = esProcedimiento
        ? const Color(0xFF0B1428)
        : Colores.verdeOscuro;
    return Container(
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
        border: Border(bottom: BorderSide(color: sombra, width: 5)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Antetitulo(
                  'Unidad $numero · ${unidad.norma}',
                  color: esProcedimiento
                      ? Colores.menta
                      : const Color(0xFFCDEFD9),
                ),
                const SizedBox(height: 4),
                Text(unidad.titulo, style: rubik(21, color: Colores.blanco)),
                if (esProcedimiento) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colores.navyClaro,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.apartment,
                          size: 16,
                          color: Colores.menta,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Procedimiento de tu empresa',
                            style: nunito(
                              13,
                              peso: FontWeight.w700,
                              color: Colores.menta,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Guía de la unidad',
            onPressed: () => _mostrarGuia(context, numero, unidad),
            icon: const Icon(Icons.menu_book_rounded, color: Colores.blanco),
          ),
        ],
      ),
    );
  }
}

/// Desplazamiento horizontal de cada nodo para que el camino serpentee.
const _vaivenes = [0.0, 0.45, 0.7, 0.45, 0.0, -0.45, -0.7, -0.45];

class _Camino extends StatelessWidget {
  const _Camino({
    required this.unidad,
    required this.numero,
    required this.contenido,
    required this.progreso,
    required this.claveActual,
  });

  final Unidad unidad;
  final int numero;
  final Contenido contenido;
  final Progreso progreso;
  final GlobalKey claveActual;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, restricciones) {
      final amplitud = (restricciones.maxWidth / 2 - 60).clamp(0.0, 110.0);
      final completa = unidadCompleta(unidad, progreso);
      return Column(
        children: [
          for (final (i, leccion) in unidad.lecciones.indexed)
            Transform.translate(
              offset: Offset(_vaivenes[i % _vaivenes.length] * amplitud, 0),
              child: _NodoLeccion(
                key:
                    estadoDe(leccion.id, contenido, progreso) ==
                        EstadoLeccion.actual
                    ? claveActual
                    : null,
                leccion: leccion,
                numero: i + 1,
                unidad: unidad,
                estado: estadoDe(leccion.id, contenido, progreso),
              ),
            ),
          Transform.translate(
            offset: Offset(
              _vaivenes[unidad.lecciones.length % _vaivenes.length] * amplitud,
              0,
            ),
            child: _NodoCertificado(
              unidad: unidad,
              completa: completa,
              fecha: progreso.fechasCertificado[unidad.id],
            ),
          ),
        ],
      );
    },
  );
}

class _NodoLeccion extends StatelessWidget {
  const _NodoLeccion({
    super.key,
    required this.leccion,
    required this.numero,
    required this.unidad,
    required this.estado,
  });

  final Leccion leccion;
  final int numero;
  final Unidad unidad;
  final EstadoLeccion estado;

  @override
  Widget build(BuildContext context) {
    final (color, sombra, icono, colorIcono) = switch (estado) {
      EstadoLeccion.completada => (
        Colores.verde,
        Colores.verdeOscuro,
        Icons.check_rounded,
        Colores.blanco,
      ),
      EstadoLeccion.actual => (
        Colores.verde,
        Colores.verdeOscuro,
        Icons.play_arrow_rounded,
        Colores.blanco,
      ),
      EstadoLeccion.disponible => (
        Colores.blanco,
        Colores.borde,
        Icons.play_arrow_rounded,
        Colores.verde,
      ),
      EstadoLeccion.bloqueada => (
        Colores.gris,
        Colores.borde,
        Icons.lock_rounded,
        Colores.grisOscuro,
      ),
    };
    final esActual = estado == EstadoLeccion.actual;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          if (esActual) const _GloboEmpezar(),
          Semantics(
            button: true,
            label: 'Lección $numero: ${leccion.titulo}',
            child: GestureDetector(
              onTap: () => _tocarLeccion(context),
              child: Container(
                width: 120,
                alignment: Alignment.center,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border(bottom: BorderSide(color: sombra, width: 6)),
                    boxShadow: esActual
                        ? [
                            BoxShadow(
                              color: Colores.verde.withValues(alpha: 0.25),
                              spreadRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(icono, color: colorIcono, size: 38),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 150,
            child: Text(
              leccion.titulo,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: nunito(
                13,
                peso: FontWeight.w700,
                color: estado == EstadoLeccion.bloqueada
                    ? Colores.grisOscuro
                    : Colores.texto,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _tocarLeccion(BuildContext context) {
    if (estado == EstadoLeccion.bloqueada) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Completa la lección anterior para desbloquear esta.',
            ),
          ),
        );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _HojaLeccion(
        leccion: leccion,
        numero: numero,
        unidad: unidad,
        completada: estado == EstadoLeccion.completada,
      ),
    );
  }
}

class _GloboEmpezar extends StatelessWidget {
  const _GloboEmpezar();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colores.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colores.borde, width: 2),
      ),
      child: Text(
        'EMPEZAR',
        style: rubik(15, color: Colores.verde).copyWith(letterSpacing: 1),
      ),
    ),
  );
}

class _NodoCertificado extends StatelessWidget {
  const _NodoCertificado({
    required this.unidad,
    required this.completa,
    required this.fecha,
  });

  final Unidad unidad;
  final bool completa;
  final DateTime? fecha;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      children: [
        Semantics(
          button: true,
          label: 'Certificado de ${unidad.titulo}',
          child: GestureDetector(
            onTap: () {
              if (completa) {
                mostrarCertificado(context, unidad, fecha ?? DateTime.now());
              } else {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Completa todas las lecciones de la unidad para '
                        'obtener el certificado.',
                      ),
                    ),
                  );
              }
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: completa ? Colores.dorado : Colores.gris,
                shape: BoxShape.circle,
                border: Border(
                  bottom: BorderSide(
                    color: completa ? const Color(0xFFA67A10) : Colores.borde,
                    width: 6,
                  ),
                ),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 38,
                color: completa ? Colores.blanco : Colores.grisOscuro,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Certificado',
          style: nunito(
            13,
            peso: FontWeight.w700,
            color: completa ? Colores.texto : Colores.grisOscuro,
          ),
        ),
      ],
    ),
  );
}

class _HojaLeccion extends StatelessWidget {
  const _HojaLeccion({
    required this.leccion,
    required this.numero,
    required this.unidad,
    required this.completada,
  });

  final Leccion leccion;
  final int numero;
  final Unidad unidad;
  final bool completada;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Antetitulo(
            'Lección $numero de ${unidad.lecciones.length} · ${unidad.norma}',
          ),
          const SizedBox(height: 6),
          Text(leccion.titulo, style: rubik(24)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _Dato(
                icono: Icons.quiz_outlined,
                texto: '${leccion.preguntas.length} preguntas',
              ),
              _Dato(
                icono: Icons.timer_outlined,
                texto: '~${leccion.minutos} min',
              ),
              const _Dato(
                icono: Icons.star_rounded,
                texto: 'Hasta 20 XP',
                color: Colores.dorado,
              ),
            ],
          ),
          if (completada) ...[
            const SizedBox(height: 12),
            Text(
              'Ya la completaste. Repetirla refuerza lo aprendido y suma XP.',
              style: nunito(15, color: Colores.textoSuave),
            ),
          ],
          const SizedBox(height: 20),
          Boton(
            texto: completada ? 'Practicar de nuevo' : 'Empezar',
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/leccion/${leccion.id}');
            },
          ),
        ],
      ),
    ),
  );
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.icono,
    required this.texto,
    this.color = Colores.textoSuave,
  });

  final IconData icono;
  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icono, size: 20, color: color),
      const SizedBox(width: 4),
      Text(
        texto,
        style: nunito(15, peso: FontWeight.w700, color: color),
      ),
    ],
  );
}

void _mostrarGuia(BuildContext context, int numero, Unidad unidad) {
  final procedimiento = unidad.procedimiento;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Antetitulo('Unidad $numero · ${unidad.norma}'),
            const SizedBox(height: 6),
            Text(unidad.titulo, style: rubik(24)),
            const SizedBox(height: 10),
            Text(unidad.descripcion, style: nunito(16, alto: 1.4)),
            const SizedBox(height: 12),
            Text(
              '${unidad.lecciones.length} lecciones · '
              '${unidad.totalPreguntas} preguntas',
              style: nunito(
                15,
                peso: FontWeight.w700,
                color: Colores.textoSuave,
              ),
            ),
            const SizedBox(height: 16),
            if (procedimiento != null)
              Tarjeta(
                color: const Color(0xFFF1F4F9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.apartment, color: Colores.navy),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Procedimiento de ${Demo.empresa.nombre}',
                            style: rubik(15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _FilaGuia('Documento', procedimiento.documento),
                    _FilaGuia('Aprobado por', procedimiento.aprobadoPor),
                    _FilaGuia(
                      'Fecha de aprobación',
                      fechaCorta(procedimiento.fechaAprobacion),
                    ),
                    if (procedimiento.generadoConIa) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 18,
                            color: Colores.naranja,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Las preguntas se generaron con IA a partir del '
                              'documento y la líder HSEQ las revisó antes de '
                              'publicarlas.',
                              style: nunito(14, color: Colores.textoSuave),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.gavel_rounded,
                    size: 20,
                    color: Colores.verde,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cada respuesta muestra la norma y el artículo que la '
                      'sustentan.',
                      style: nunito(15, color: Colores.textoSuave),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

class _FilaGuia extends StatelessWidget {
  const _FilaGuia(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: nunito(13, color: Colores.textoSuave)),
        Text(valor, style: nunito(15, peso: FontWeight.w700)),
      ],
    ),
  );
}
