import 'dart:math';

import 'package:diver_ley/logica/sesion_leccion.dart';
import 'package:diver_ley/modelos/contenido.dart';
import 'package:flutter_test/flutter_test.dart';

Pregunta _opcion(String id) => Pregunta(
  id: id,
  tipo: TipoPregunta.opcion,
  enunciado: '¿$id?',
  opciones: const ['a', 'b', 'c'],
  correcta: 1,
  explicacion: '',
  fuente: '',
);

const _ordenar = Pregunta(
  id: 'orden',
  tipo: TipoPregunta.ordenar,
  enunciado: 'Ordena',
  opciones: ['1', '2', '3', '4'],
  correcta: -1,
  explicacion: '',
  fuente: '',
);

void main() {
  test('sin errores da el XP máximo y 100 % de precisión', () {
    final sesion = SesionLeccion(
      Leccion(id: 'l', titulo: 'L', preguntas: [_opcion('p1'), _opcion('p2')]),
      azar: Random(1),
    );
    while (!sesion.terminada) {
      expect(sesion.responder(const RespuestaOpcion(1)), isTrue);
      sesion.siguiente();
    }
    expect(sesion.precision, 100);
    expect(sesion.sinErrores, isTrue);
    expect(sesion.xp, 5 + 2 * 2 + 5);
  });

  test('una pregunta fallada vuelve al final de la fila', () {
    final sesion = SesionLeccion(
      Leccion(id: 'l', titulo: 'L', preguntas: [_opcion('p1'), _opcion('p2')]),
      azar: Random(1),
    );
    expect(sesion.responder(const RespuestaOpcion(0)), isFalse);
    sesion.siguiente();
    expect(sesion.actual.id, 'p2');
    sesion.responder(const RespuestaOpcion(1));
    sesion.siguiente();
    expect(sesion.terminada, isFalse);
    expect(sesion.actual.id, 'p1');
    expect(sesion.avance, 0.5);
    sesion.responder(const RespuestaOpcion(1));
    sesion.siguiente();
    expect(sesion.terminada, isTrue);
    expect(sesion.aciertosPrimeraVez, 1);
    expect(sesion.precision, 50);
    expect(sesion.xp, 5 + 2);
  });

  test('ordenar se muestra revuelto y se califica por posición', () {
    for (var semilla = 0; semilla < 20; semilla++) {
      final sesion = SesionLeccion(
        const Leccion(id: 'l', titulo: 'L', preguntas: [_ordenar]),
        azar: Random(semilla),
      );
      expect(sesion.ordenActual, isNot(equals([0, 1, 2, 3])));
    }
    expect(esCorrecta(_ordenar, const RespuestaOrden([0, 1, 2, 3])), isTrue);
    expect(esCorrecta(_ordenar, const RespuestaOrden([1, 0, 2, 3])), isFalse);
    expect(esCorrecta(_ordenar, const RespuestaOrden([0, 1, 2])), isFalse);
  });

  test('verdadero o falso no se revuelve', () {
    final vf = Pregunta.fromJson({
      'id': 'vf',
      'tipo': 'vf',
      'enunciado': 'x',
      'respuesta': false,
      'explicacion': '',
      'fuente': '',
    });
    final sesion = SesionLeccion(
      Leccion(id: 'l', titulo: 'L', preguntas: [vf]),
      azar: Random(3),
    );
    expect(sesion.ordenActual, [0, 1]);
    expect(vf.correcta, 1);
    expect(vf.respuestaCorrecta, 'Falso');
  });
}
