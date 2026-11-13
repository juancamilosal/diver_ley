import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../logica/fechas.dart';
import '../logica/sesion_simulacro.dart';
import '../modelos/contenido.dart';
import '../modelos/progreso.dart';
import '../providers.dart';
import '../tema.dart';
import '../widgets/boton.dart';
import '../widgets/tarjeta.dart';
import 'simulacro_inicio.dart';

class PantallaSimulacro extends ConsumerStatefulWidget {
  const PantallaSimulacro({super.key, required this.rolId});

  final String rolId;

  @override
  ConsumerState<PantallaSimulacro> createState() => _PantallaSimulacroState();
}

class _PantallaSimulacroState extends ConsumerState<PantallaSimulacro> {
  SesionSimulacro? _sesion;
  ResultadoSimulacro? _resultado;
  int? _opcion;
  Timer? _reloj;
  Duration _restante = SesionSimulacro.duracion;

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  void _iniciar(Contenido contenido) {
    if (_sesion != null) return;
    _sesion = SesionSimulacro(
      rol: contenido.rol(widget.rolId),
      banco: contenido.preguntasDeRol(widget.rolId),
    );
    _reloj = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _restante -= const Duration(seconds: 1));
      if (_restante <= Duration.zero) {
        _sesion!.terminar();
        _finalizar();
      }
    });
  }

  void _responder() {
    final sesion = _sesion!;
    sesion.responder(_opcion!);
    setState(() => _opcion = null);
    if (sesion.terminada) _finalizar();
  }

  void _finalizar() {
    if (_resultado != null) return;
    _reloj?.cancel();
    final resultado = _sesion!.resultado(ref.read(relojProvider)());
    ref.read(progresoProvider.notifier).registrarSimulacro(resultado);
    setState(() => _resultado = resultado);
  }

  Future<void> _salir() async {
    if (_resultado != null) {
      context.pop();
      return;
    }
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Abandonar el simulacro?', style: rubik(20)),
        content: Text('No se guardará ningún resultado.', style: nunito(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuar simulacro'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colores.naranjaOscuro),
            child: const Text('Abandonar'),
          ),
        ],
      ),
    );
    if (salir == true && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final contenido = ref.watch(contenidoProvider).value;
    if (contenido == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _iniciar(contenido);
    final resultado = _resultado;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _salir();
      },
      child: Scaffold(
        body: SafeArea(
          child: resultado == null
              ? _pregunta(_sesion!)
              : _Resultado(
                  sesion: _sesion!,
                  resultado: resultado,
                  contenido: contenido,
                ),
        ),
      ),
    );
  }

  Widget _pregunta(SesionSimulacro sesion) {
    final pregunta = sesion.actual;
    final minutos = _restante.inMinutes;
    final segundos = (_restante.inSeconds % 60).toString().padLeft(2, '0');
    final urgente = _restante.inSeconds <= 30;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Abandonar',
                onPressed: _salir,
                icon: const Icon(Icons.close_rounded, size: 30),
                color: Colores.grisOscuro,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Antetitulo('Simulacro', color: Colores.naranjaOscuro),
                    Text(
                      sesion.rol.nombre,
                      style: nunito(14, color: Colores.textoSuave),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: urgente ? Colores.naranjaSuave : Colores.blanco,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: urgente ? Colores.naranjaOscuro : Colores.borde,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 20,
                      color: urgente ? Colores.naranjaOscuro : Colores.texto,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$minutos:$segundos',
                      style: rubik(
                        17,
                        color: urgente ? Colores.naranjaOscuro : Colores.texto,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              for (var i = 0; i < sesion.preguntas.length; i++)
                Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i < sesion.indice
                          ? Colores.navy
                          : i == sesion.indice
                          ? Colores.naranja
                          : Colores.gris,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pregunta ${sesion.indice + 1} de ${sesion.preguntas.length}'
                      ' · ${pregunta.tema}',
                      style: nunito(
                        14,
                        peso: FontWeight.w700,
                        color: Colores.textoSuave,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: Colores.navy,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person_search_rounded,
                                color: Colores.menta,
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Auditor',
                                style: nunito(
                                  15,
                                  peso: FontWeight.w800,
                                  color: Colores.menta,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pregunta.pregunta,
                            style: rubik(
                              21,
                              peso: FontWeight.w600,
                              color: Colores.crema,
                              alto: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tu respuesta',
                      textAlign: TextAlign.right,
                      style: nunito(
                        14,
                        peso: FontWeight.w700,
                        color: Colores.textoSuave,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final i in sesion.ordenActual)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 32),
                        child: Tarjeta(
                          color: _opcion == i
                              ? Colores.verdeSuave
                              : Colores.blanco,
                          colorBorde: _opcion == i
                              ? Colores.verde
                              : Colores.borde,
                          onTap: () => setState(() => _opcion = i),
                          child: Text(
                            pregunta.opciones[i],
                            style: nunito(
                              16,
                              peso: _opcion == i
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              alto: 1.3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colores.borde, width: 2)),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Boton(
                texto: 'Responder',
                color: Colores.navy,
                colorSombra: const Color(0xFF0B1428),
                onPressed: _opcion == null ? null : _responder,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Resultado extends StatelessWidget {
  const _Resultado({
    required this.sesion,
    required this.resultado,
    required this.contenido,
  });

  final SesionSimulacro sesion;
  final ResultadoSimulacro resultado;
  final Contenido contenido;

  @override
  Widget build(BuildContext context) {
    final nivel = nivelDe(resultado.puntaje);
    final color = colorDeNivel(nivel);
    final temas = resultado.porTema.entries.toList()
      ..sort(
        (a, b) => (a.value[0] / a.value[1]).compareTo(b.value[0] / b.value[1]),
      );
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            children: [
              Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: resultado.puntaje / 100),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => CircularProgressIndicator(
                            value: v,
                            strokeWidth: 14,
                            backgroundColor: Colores.gris,
                            color: color,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${resultado.puntaje} %',
                            style: rubik(34, color: color),
                          ),
                          Text(
                            '${resultado.aciertos} de ${resultado.total}',
                            style: nunito(14, color: Colores.textoSuave),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                nombreDeNivel(nivel),
                textAlign: TextAlign.center,
                style: rubik(28, color: color),
              ),
              const SizedBox(height: 6),
              Text(
                switch (nivel) {
                  Nivel.preparado =>
                    'Respondiste como alguien listo para la auditoría.',
                  Nivel.porReforzar => 'Vas bien. Repasa los temas marcados antes de la auditoría.',
                  Nivel.critico =>
                    'Hoy el auditor encontraría brechas. Repasa los temas '
                        'marcados y vuelve a intentarlo.',
                },
                textAlign: TextAlign.center,
                style: nunito(16, color: Colores.textoSuave, alto: 1.35),
              ),
              const SizedBox(height: 14),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colores.verdeSuave,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: Colores.verde,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Guardado como evidencia · ${fechaHora(resultado.fecha)}',
                          style: nunito(
                            13,
                            peso: FontWeight.w700,
                            color: Colores.verde,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Por tema', style: rubik(18)),
              const SizedBox(height: 10),
              for (final tema in temas)
                _FilaTema(
                  tema: tema.key,
                  aciertos: tema.value[0],
                  total: tema.value[1],
                  unidad: _unidadDeTema(tema.key),
                ),
              const SizedBox(height: 16),
              Text('Tus respuestas', style: rubik(18)),
              const SizedBox(height: 10),
              for (final (n, p) in sesion.preguntas.indexed)
                _RevisionRespuesta(
                  numero: n + 1,
                  pregunta: p,
                  elegida: sesion.respuestas[p.id],
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Boton(texto: 'Terminar', onPressed: () => context.pop()),
        ),
      ],
    );
  }

  /// Unidad a repasar para un tema (la de su primera pregunta).
  Unidad _unidadDeTema(String tema) => contenido.unidad(
    sesion.preguntas.firstWhere((p) => p.tema == tema).unidadId,
  );
}

class _FilaTema extends StatelessWidget {
  const _FilaTema({
    required this.tema,
    required this.aciertos,
    required this.total,
    required this.unidad,
  });

  final String tema;
  final int aciertos;
  final int total;
  final Unidad unidad;

  @override
  Widget build(BuildContext context) {
    final completo = aciertos == total;
    final color = completo
        ? Colores.verde
        : aciertos == 0
        ? Colores.naranjaOscuro
        : Colores.dorado;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Tarjeta(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tema, style: nunito(16, peso: FontWeight.w700)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: aciertos / total,
                      minHeight: 10,
                      backgroundColor: Colores.gris,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$aciertos de $total correctas',
                    style: nunito(13, color: Colores.textoSuave),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (completo)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.check_circle_rounded, color: Colores.verde),
              )
            else
              TextButton(
                onPressed: () {
                  final router = GoRouter.of(context);
                  router.pop();
                  router.push('/leccion/${unidad.lecciones.first.id}');
                },
                child: const Text('Repasar'),
              ),
          ],
        ),
      ),
    );
  }
}

class _RevisionRespuesta extends StatelessWidget {
  const _RevisionRespuesta({
    required this.numero,
    required this.pregunta,
    required this.elegida,
  });

  final int numero;
  final PreguntaAuditor pregunta;
  final int? elegida;

  @override
  Widget build(BuildContext context) {
    final acerto = elegida == pregunta.correcta;
    final color = acerto ? Colores.verde : Colores.naranjaOscuro;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Tarjeta(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(
              acerto ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: color,
            ),
            title: Text(
              '$numero. ${pregunta.pregunta}',
              style: nunito(15, peso: FontWeight.w700, alto: 1.3),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!acerto)
                Text(
                  elegida == null
                      ? 'Sin responder (se acabó el tiempo).'
                      : 'Respondiste: ${pregunta.opciones[elegida!]}',
                  style: nunito(14, color: Colores.naranjaOscuro),
                ),
              const SizedBox(height: 4),
              Text(
                'Correcta: ${pregunta.opciones[pregunta.correcta]}',
                style: nunito(14, peso: FontWeight.w700, color: Colores.verde),
              ),
              const SizedBox(height: 6),
              Text(pregunta.explicacion, style: nunito(14, alto: 1.35)),
              const SizedBox(height: 6),
              Text(
                pregunta.fuente,
                style: nunito(
                  13,
                  peso: FontWeight.w700,
                  color: Colores.textoSuave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
