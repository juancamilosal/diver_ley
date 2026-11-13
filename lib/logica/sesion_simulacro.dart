import 'dart:math';

import '../modelos/contenido.dart';
import '../modelos/progreso.dart';

/// Un simulacro de auditoría: sin pistas, con tiempo y con resultado por tema.
class SesionSimulacro {
  SesionSimulacro({
    required this.rol,
    required List<PreguntaAuditor> banco,
    Random? azar,
    int maximo = 8,
  }) : preguntas = (List.of(banco)..shuffle(azar)).take(maximo).toList() {
    final r = azar ?? Random();
    for (final p in preguntas) {
      _ordenes[p.id] = List.generate(p.opciones.length, (i) => i)..shuffle(r);
    }
  }

  static const duracion = Duration(minutes: 4);

  final Rol rol;
  final List<PreguntaAuditor> preguntas;
  final Map<String, List<int>> _ordenes = {};

  /// Pregunta → índice de la opción elegida.
  final Map<String, int> respuestas = {};
  int _indice = 0;

  int get indice => _indice;

  PreguntaAuditor get actual => preguntas[_indice];

  List<int> get ordenActual => _ordenes[actual.id]!;

  bool get terminada => _indice >= preguntas.length;

  void responder(int opcion) {
    respuestas[actual.id] = opcion;
    _indice++;
  }

  /// Termina el simulacro (por ejemplo, al acabarse el tiempo).
  void terminar() => _indice = preguntas.length;

  bool acerto(PreguntaAuditor p) => respuestas[p.id] == p.correcta;

  ResultadoSimulacro resultado(DateTime fecha) {
    final porTema = <String, List<int>>{};
    for (final p in preguntas) {
      final tema = porTema.putIfAbsent(p.tema, () => [0, 0]);
      if (acerto(p)) tema[0]++;
      tema[1]++;
    }
    return ResultadoSimulacro(
      rolId: rol.id,
      fecha: fecha,
      aciertos: preguntas.where(acerto).length,
      total: preguntas.length,
      porTema: porTema,
    );
  }
}

enum Nivel { preparado, porReforzar, critico }

Nivel nivelDe(int puntaje) => puntaje >= 85
    ? Nivel.preparado
    : puntaje >= 60
    ? Nivel.porReforzar
    : Nivel.critico;
