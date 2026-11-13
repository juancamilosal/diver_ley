import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../logica/sesion_leccion.dart';
import '../modelos/contenido.dart';
import '../modelos/progreso.dart';
import '../providers.dart';
import '../tema.dart';
import '../widgets/boton.dart';
import '../widgets/certificado.dart';
import '../widgets/tarjeta.dart';

class PantallaLeccion extends ConsumerStatefulWidget {
  const PantallaLeccion({super.key, required this.leccionId});

  final String leccionId;

  @override
  ConsumerState<PantallaLeccion> createState() => _PantallaLeccionState();
}

class _PantallaLeccionState extends ConsumerState<PantallaLeccion> {
  SesionLeccion? _sesion;
  Unidad? _unidad;

  /// Opción elegida (índice original) en preguntas de elegir.
  int? _opcion;

  /// Pasos tocados (índices originales) en preguntas de ordenar.
  final List<int> _orden = [];

  /// `null` mientras no se ha comprobado la respuesta.
  bool? _correcta;
  Celebracion? _celebracion;

  void _iniciar(Contenido contenido) {
    if (_sesion != null) return;
    final unidad = contenido.unidadDeLeccion(widget.leccionId);
    _unidad = unidad;
    _sesion = SesionLeccion(
      unidad.lecciones.firstWhere((l) => l.id == widget.leccionId),
    );
  }

  bool get _hayRespuesta {
    final pregunta = _sesion!.actual;
    return pregunta.tipo == TipoPregunta.ordenar
        ? _orden.length == pregunta.opciones.length
        : _opcion != null;
  }

  void _comprobar() {
    final sesion = _sesion!;
    final respuesta = sesion.actual.tipo == TipoPregunta.ordenar
        ? RespuestaOrden(List.of(_orden))
        : RespuestaOpcion(_opcion!);
    final ok = sesion.responder(respuesta);
    ok ? HapticFeedback.mediumImpact() : HapticFeedback.heavyImpact();
    setState(() => _correcta = ok);
  }

  void _continuar() {
    final sesion = _sesion!;
    sesion.siguiente();
    if (sesion.terminada) {
      _celebracion = ref
          .read(progresoProvider.notifier)
          .completarLeccion(
            unidad: _unidad!,
            leccionId: widget.leccionId,
            xp: sesion.xp,
            correctas: sesion.aciertosPrimeraVez,
            respondidas: sesion.total,
          );
    }
    setState(() {
      _opcion = null;
      _orden.clear();
      _correcta = null;
    });
  }

  Future<void> _salir() async {
    final sesion = _sesion;
    if (sesion == null || sesion.terminada || sesion.avance == 0) {
      context.pop();
      return;
    }
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Salir de la lección?', style: rubik(20)),
        content: Text('Perderás el avance de esta lección.', style: nunito(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Seguir aprendiendo'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colores.naranjaOscuro),
            child: const Text('Salir'),
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
    final sesion = _sesion!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _salir();
      },
      child: Scaffold(
        body: SafeArea(
          child: sesion.terminada
              ? _Final(
                  sesion: sesion,
                  unidad: _unidad!,
                  celebracion: _celebracion!,
                  fechaCertificado: ref
                      .watch(progresoProvider)
                      .fechasCertificado[_unidad!.id],
                )
              : _pregunta(sesion),
        ),
      ),
    );
  }

  Widget _pregunta(SesionLeccion sesion) {
    final pregunta = sesion.actual;
    final bloqueada = _correcta != null;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Salir',
                onPressed: _salir,
                icon: const Icon(Icons.close_rounded, size: 30),
                color: Colores.grisOscuro,
              ),
              Expanded(child: _BarraAvance(valor: sesion.avance)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Antetitulo(switch (pregunta.tipo) {
                      TipoPregunta.opcion => 'Elige la respuesta correcta',
                      TipoPregunta.vf => '¿Verdadero o falso?',
                      TipoPregunta.ordenar => 'Toca los pasos en orden',
                      TipoPregunta.completar => 'Completa la frase',
                    }),
                    const SizedBox(height: 10),
                    if (pregunta.tipo == TipoPregunta.completar)
                      _FraseConEspacio(
                        enunciado: pregunta.enunciado,
                        palabra: _opcion == null
                            ? null
                            : pregunta.opciones[_opcion!],
                      )
                    else
                      Text(pregunta.enunciado, style: rubik(23, alto: 1.25)),
                    const SizedBox(height: 24),
                    switch (pregunta.tipo) {
                      TipoPregunta.vf => _VerdaderoFalso(
                        seleccion: _opcion,
                        correcta: bloqueada ? pregunta.correcta : null,
                        onTap: bloqueada
                            ? null
                            : (i) => setState(() => _opcion = i),
                      ),
                      TipoPregunta.ordenar => _Ordenar(
                        pasos: pregunta.opciones,
                        orden: sesion.ordenActual,
                        elegidos: _orden,
                        resultado: _correcta,
                        onCambio: bloqueada ? null : () => setState(() {}),
                      ),
                      TipoPregunta.completar => _Fichas(
                        pregunta: pregunta,
                        orden: sesion.ordenActual,
                        seleccion: _opcion,
                        correcta: bloqueada ? pregunta.correcta : null,
                        onTap: bloqueada
                            ? null
                            : (i) => setState(() => _opcion = i),
                      ),
                      TipoPregunta.opcion => _Opciones(
                        pregunta: pregunta,
                        orden: sesion.ordenActual,
                        seleccion: _opcion,
                        correcta: bloqueada ? pregunta.correcta : null,
                        onTap: bloqueada
                            ? null
                            : (i) => setState(() => _opcion = i),
                      ),
                    },
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_correcta == null)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colores.borde, width: 2)),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Boton(
                  texto: 'Comprobar',
                  onPressed: _hayRespuesta ? _comprobar : null,
                ),
              ),
            ),
          )
        else
          _PanelResultado(
            pregunta: pregunta,
            correcta: _correcta!,
            onContinuar: _continuar,
          ),
      ],
    );
  }
}

class _BarraAvance extends StatelessWidget {
  const _BarraAvance({required this.valor});

  final double valor;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: valor),
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOut,
    builder: (context, v, _) => ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 16,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colores.gris)),
            FractionallySizedBox(
              widthFactor: v.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colores.verde,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Colores de una opción según si está elegida y el resultado.
(Color fondo, Color borde) _coloresOpcion({
  required bool elegida,
  required bool? esLaCorrecta,
}) {
  if (esLaCorrecta == true) return (Colores.verdeSuave, Colores.verde);
  if (esLaCorrecta == false && elegida) {
    return (Colores.naranjaSuave, Colores.naranjaOscuro);
  }
  if (elegida) return (Colores.verdeSuave, Colores.verde);
  return (Colores.blanco, Colores.borde);
}

class _Opciones extends StatelessWidget {
  const _Opciones({
    required this.pregunta,
    required this.orden,
    required this.seleccion,
    required this.correcta,
    required this.onTap,
  });

  final Pregunta pregunta;
  final List<int> orden;
  final int? seleccion;

  /// Se conoce solo después de comprobar.
  final int? correcta;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final (n, i) in orden.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _Opcion(
            numero: n + 1,
            texto: pregunta.opciones[i],
            elegida: seleccion == i,
            esLaCorrecta: correcta == null ? null : correcta == i,
            onTap: onTap == null ? null : () => onTap!(i),
          ),
        ),
    ],
  );
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.numero,
    required this.texto,
    required this.elegida,
    required this.esLaCorrecta,
    required this.onTap,
  });

  final int numero;
  final String texto;
  final bool elegida;
  final bool? esLaCorrecta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (fondo, borde) = _coloresOpcion(
      elegida: elegida,
      esLaCorrecta: esLaCorrecta,
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borde, width: 2),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: borde == Colores.borde ? Colores.borde : borde,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '$numero',
                    style: rubik(
                      14,
                      color: borde == Colores.borde
                          ? Colores.grisOscuro
                          : borde,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    texto,
                    style: nunito(
                      17,
                      peso: elegida ? FontWeight.w700 : FontWeight.w600,
                      alto: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerdaderoFalso extends StatelessWidget {
  const _VerdaderoFalso({
    required this.seleccion,
    required this.correcta,
    required this.onTap,
  });

  final int? seleccion;
  final int? correcta;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final (i, (texto, icono)) in const [
        ('Verdadero', Icons.check_circle_outline_rounded),
        ('Falso', Icons.cancel_outlined),
      ].indexed) ...[
        if (i > 0) const SizedBox(width: 12),
        Expanded(
          child: Builder(
            builder: (context) {
              final (fondo, borde) = _coloresOpcion(
                elegida: seleccion == i,
                esLaCorrecta: correcta == null ? null : correcta == i,
              );
              final color = borde == Colores.borde ? Colores.grisOscuro : borde;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 130,
                decoration: BoxDecoration(
                  color: fondo,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borde, width: 2),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onTap == null ? null : () => onTap!(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icono, size: 44, color: color),
                        const SizedBox(height: 8),
                        Text(texto, style: rubik(18, color: Colores.texto)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ],
  );
}

/// Enunciado con un espacio que se llena con la ficha elegida.
class _FraseConEspacio extends StatelessWidget {
  const _FraseConEspacio({required this.enunciado, required this.palabra});

  final String enunciado;
  final String? palabra;

  @override
  Widget build(BuildContext context) {
    final partes = enunciado.split('___');
    final estilo = rubik(23, alto: 1.4);
    return Text.rich(
      TextSpan(
        style: estilo,
        children: [
          TextSpan(text: partes.first),
          TextSpan(
            text: palabra ?? '    ',
            style: estilo.copyWith(
              color: Colores.verde,
              decoration: TextDecoration.underline,
              decorationColor: Colores.verde,
              decorationThickness: 2,
            ),
          ),
          if (partes.length > 1) TextSpan(text: partes.sublist(1).join()),
        ],
      ),
    );
  }
}

class _Fichas extends StatelessWidget {
  const _Fichas({
    required this.pregunta,
    required this.orden,
    required this.seleccion,
    required this.correcta,
    required this.onTap,
  });

  final Pregunta pregunta;
  final List<int> orden;
  final int? seleccion;
  final int? correcta;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    alignment: WrapAlignment.center,
    children: [for (final i in orden) _ficha(i)],
  );

  Widget _ficha(int i) {
    final (fondo, borde) = _coloresOpcion(
      elegida: seleccion == i,
      esLaCorrecta: correcta == null ? null : correcta == i,
    );
    return Material(
      color: fondo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borde, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap == null ? null : () => onTap!(i),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            pregunta.opciones[i],
            style: nunito(17, peso: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _Ordenar extends StatelessWidget {
  const _Ordenar({
    required this.pasos,
    required this.orden,
    required this.elegidos,
    required this.resultado,
    required this.onCambio,
  });

  final List<String> pasos;

  /// Orden revuelto en que se muestran los pasos disponibles.
  final List<int> orden;

  /// Lista que se modifica al tocar (la dueña es la pantalla).
  final List<int> elegidos;
  final bool? resultado;
  final VoidCallback? onCambio;

  @override
  Widget build(BuildContext context) {
    final colorBorde = switch (resultado) {
      true => Colores.verde,
      false => Colores.naranjaOscuro,
      null => Colores.borde,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colores.blanco,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorBorde, width: 2),
          ),
          child: elegidos.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text(
                    'Toca abajo el primer paso.',
                    textAlign: TextAlign.center,
                    style: nunito(15, color: Colores.grisOscuro),
                  ),
                )
              : Column(
                  children: [
                    for (final (n, i) in elegidos.indexed)
                      _FilaPaso(
                        numero: n + 1,
                        texto: pasos[i],
                        bienUbicado: resultado == null ? null : i == n,
                        onTap: onCambio == null
                            ? null
                            : () {
                                elegidos.removeAt(n);
                                onCambio!();
                              },
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        for (final i in orden)
          if (!elegidos.contains(i))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Tarjeta(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                onTap: onCambio == null
                    ? null
                    : () {
                        elegidos.add(i);
                        onCambio!();
                      },
                child: Text(
                  pasos[i],
                  style: nunito(16, peso: FontWeight.w600, alto: 1.3),
                ),
              ),
            ),
      ],
    );
  }
}

class _FilaPaso extends StatelessWidget {
  const _FilaPaso({
    required this.numero,
    required this.texto,
    required this.bienUbicado,
    required this.onTap,
  });

  final int numero;
  final String texto;
  final bool? bienUbicado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (bienUbicado) {
      true => Colores.verde,
      false => Colores.naranjaOscuro,
      null => Colores.verde,
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: color,
              child: Text('$numero', style: rubik(14, color: Colores.blanco)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: nunito(16, peso: FontWeight.w700, alto: 1.3),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.close, size: 18, color: Colores.grisOscuro),
          ],
        ),
      ),
    );
  }
}

class _PanelResultado extends StatelessWidget {
  const _PanelResultado({
    required this.pregunta,
    required this.correcta,
    required this.onContinuar,
  });

  final Pregunta pregunta;
  final bool correcta;
  final VoidCallback onContinuar;

  @override
  Widget build(BuildContext context) {
    final color = correcta ? Colores.verde : Colores.naranjaOscuro;
    return Container(
      width: double.infinity,
      color: correcta ? Colores.verdeSuave : Colores.naranjaSuave,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    correcta ? Icons.check_circle_rounded : Icons.info_rounded,
                    color: color,
                    size: 30,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      correcta ? '¡Correcto!' : 'Respuesta correcta:',
                      style: rubik(21, color: color),
                    ),
                  ),
                ],
              ),
              if (!correcta) ...[
                const SizedBox(height: 4),
                Text(
                  pregunta.respuestaCorrecta,
                  style: nunito(16, peso: FontWeight.w800, color: color),
                ),
              ],
              const SizedBox(height: 8),
              Text(pregunta.explicacion, style: nunito(15, alto: 1.35)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.gavel_rounded, size: 18, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pregunta.fuente,
                      style: nunito(14, peso: FontWeight.w700, color: color),
                    ),
                  ),
                ],
              ),
              if (!correcta) ...[
                const SizedBox(height: 6),
                Text(
                  'Esta pregunta volverá al final de la lección.',
                  style: nunito(13, color: Colores.textoSuave),
                ),
              ],
              const SizedBox(height: 14),
              Boton(
                texto: 'Continuar',
                onPressed: onContinuar,
                color: color,
                colorSombra: correcta
                    ? Colores.verdeOscuro
                    : const Color(0xFF8F3D12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Final extends StatelessWidget {
  const _Final({
    required this.sesion,
    required this.unidad,
    required this.celebracion,
    required this.fechaCertificado,
  });

  final SesionLeccion sesion;
  final Unidad unidad;
  final Celebracion celebracion;
  final DateTime? fechaCertificado;

  @override
  Widget build(BuildContext context) {
    final unidadCompleta = celebracion.unidadCompletada != null;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.4, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, escala, child) =>
                          Transform.scale(scale: escala, child: child),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: unidadCompleta
                              ? Colores.dorado
                              : Colores.verde,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          unidadCompleta
                              ? Icons.workspace_premium_rounded
                              : Icons.emoji_events_rounded,
                          color: Colores.blanco,
                          size: 68,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      unidadCompleta
                          ? '¡Unidad completada!'
                          : '¡Lección completada!',
                      textAlign: TextAlign.center,
                      style: rubik(30),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      unidadCompleta
                          ? 'Ganaste el certificado de "${unidad.titulo}". '
                                'Quedó guardado como evidencia de capacitación.'
                          : sesion.sinErrores
                          ? 'Sin errores. Así se llega preparado a la auditoría.'
                          : 'Las preguntas que fallaste se repitieron hasta '
                                'que las acertaste.',
                      textAlign: TextAlign.center,
                      style: nunito(17, color: Colores.textoSuave, alto: 1.35),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _Medalla(
                            titulo: 'XP',
                            valor: '+${sesion.xp}',
                            icono: Icons.star_rounded,
                            color: Colores.dorado,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Medalla(
                            titulo: 'Precisión',
                            valor: '${sesion.precision} %',
                            icono: Icons.track_changes_rounded,
                            color: Colores.verde,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Medalla(
                            titulo: 'Racha',
                            valor:
                                '${celebracion.rachaDespues} '
                                '${celebracion.rachaDespues == 1 ? 'día' : 'días'}',
                            icono: Icons.local_fire_department_rounded,
                            color: Colores.naranja,
                          ),
                        ),
                      ],
                    ),
                    if (celebracion.rachaSubio) ...[
                      const SizedBox(height: 16),
                      _Aviso(
                        icono: Icons.local_fire_department_rounded,
                        color: Colores.naranja,
                        fondo: Colores.naranjaSuave,
                        texto:
                            '¡Tu racha subió a ${celebracion.rachaDespues} días!',
                      ),
                    ],
                    if (celebracion.metaCumplidaAhora) ...[
                      const SizedBox(height: 10),
                      const _Aviso(
                        icono: Icons.flag_rounded,
                        color: Colores.verde,
                        fondo: Colores.verdeSuave,
                        texto:
                            'Cumpliste tu meta diaria de ${Progreso.metaDiaria} XP.',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                if (unidadCompleta) ...[
                  Boton.secundario(
                    texto: 'Ver certificado',
                    icono: Icons.workspace_premium_rounded,
                    onPressed: () => mostrarCertificado(
                      context,
                      unidad,
                      fechaCertificado ?? DateTime.now(),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Boton(texto: 'Continuar', onPressed: () => context.pop()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Medalla extends StatelessWidget {
  const _Medalla({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.all(2),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            titulo.toUpperCase(),
            style: nunito(
              12,
              peso: FontWeight.w800,
              color: Colores.blanco,
            ).copyWith(letterSpacing: 1),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: Colores.blanco,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icono, color: color, size: 26),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(valor, style: rubik(18, color: color)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Aviso extends StatelessWidget {
  const _Aviso({
    required this.icono,
    required this.color,
    required this.fondo,
    required this.texto,
  });

  final IconData icono;
  final Color color;
  final Color fondo;
  final String texto;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: fondo,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(icono, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texto,
            style: nunito(16, peso: FontWeight.w700, color: color),
          ),
        ),
      ],
    ),
  );
}
