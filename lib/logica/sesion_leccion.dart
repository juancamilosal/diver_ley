import 'dart:math';

import '../modelos/contenido.dart';

/// Respuesta del usuario: el índice elegido o, en [TipoPregunta.ordenar],
/// los índices de los pasos en el orden en que los tocó.
sealed class Respuesta {
  const Respuesta();
}

class RespuestaOpcion extends Respuesta {
  const RespuestaOpcion(this.indice);
  final int indice;
}

class RespuestaOrden extends Respuesta {
  const RespuestaOrden(this.indices);
  final List<int> indices;
}

bool esCorrecta(Pregunta pregunta, Respuesta respuesta) => switch (respuesta) {
  RespuestaOpcion(:final indice) => indice == pregunta.correcta,
  RespuestaOrden(:final indices) =>
    indices.length == pregunta.opciones.length &&
        [for (var i = 0; i < indices.length; i++) indices[i] == i]
            .every((ok) => ok),
};

/// Una lección en curso, al estilo de las apps de idiomas: las preguntas
/// falladas vuelven al final de la fila hasta que se responden bien.
class SesionLeccion {
  SesionLeccion(this.leccion, {Random? azar})
    : _cola = List.of(leccion.preguntas),
      _ordenes = {
        for (final p in leccion.preguntas) p.id: _ordenDe(p, azar ?? Random()),
      };

  final Leccion leccion;
  final List<Pregunta> _cola;
  final Map<String, List<int>> _ordenes;
  final Set<String> _falladas = {};
  int _indice = 0;
  int _resueltas = 0;
  int _aciertosPrimeraVez = 0;

  /// Las de verdadero o falso no se revuelven; las demás sí.
  static List<int> _ordenDe(Pregunta p, Random azar) {
    final orden = List.generate(p.opciones.length, (i) => i);
    if (p.tipo == TipoPregunta.vf) return orden;
    orden.shuffle(azar);
    // Un ordenar que ya sale en orden no sirve como pregunta.
    if (p.tipo == TipoPregunta.ordenar && orden.length > 1) {
      while ([for (var i = 0; i < orden.length; i++) orden[i] == i]
          .every((ok) => ok)) {
        orden.shuffle(azar);
      }
    }
    return orden;
  }

  Pregunta get actual => _cola[_indice];

  /// Orden en que se muestran las opciones de la pregunta actual.
  List<int> get ordenActual => _ordenes[actual.id]!;

  bool get terminada => _indice >= _cola.length;

  int get total => leccion.preguntas.length;

  /// Avance de 0 a 1: preguntas ya respondidas bien.
  double get avance => _resueltas / total;

  int get aciertosPrimeraVez => _aciertosPrimeraVez;

  bool get sinErrores => _falladas.isEmpty;

  /// Precisión de la lección: aciertos al primer intento.
  int get precision => (_aciertosPrimeraVez * 100 / total).round();

  /// 5 por terminar, 2 por cada acierto al primer intento y 5 más sin errores.
  int get xp => 5 + _aciertosPrimeraVez * 2 + (sinErrores ? 5 : 0);

  /// Registra la respuesta de la pregunta actual y dice si fue correcta.
  bool responder(Respuesta respuesta) {
    final pregunta = actual;
    final ok = esCorrecta(pregunta, respuesta);
    if (ok) {
      _resueltas++;
      if (!_falladas.contains(pregunta.id)) _aciertosPrimeraVez++;
    } else {
      _falladas.add(pregunta.id);
      _cola.add(pregunta);
    }
    return ok;
  }

  void siguiente() => _indice++;
}
