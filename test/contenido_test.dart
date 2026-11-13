import 'package:diver_ley/modelos/contenido.dart';
import 'package:flutter_test/flutter_test.dart';

import 'contenido_de_prueba.dart';

/// Revisa que el contenido esté completo y bien armado.
void main() {
  late Contenido contenido;

  setUpAll(() async => contenido = await cargarContenidoDePrueba());

  test('los ids son únicos', () {
    final ids = [
      for (final u in contenido.unidades) u.id,
      for (final l in contenido.leccionesEnOrden) l.id,
      for (final l in contenido.leccionesEnOrden)
        for (final p in l.preguntas) p.id,
      for (final p in contenido.preguntasAuditor) p.id,
    ];
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('cada pregunta tiene respuesta válida, explicación y fuente', () {
    for (final l in contenido.leccionesEnOrden) {
      expect(l.preguntas, hasLength(5), reason: l.id);
      for (final p in l.preguntas) {
        expect(p.explicacion, isNotEmpty, reason: p.id);
        expect(p.fuente, isNotEmpty, reason: p.id);
        if (p.tipo == TipoPregunta.ordenar) {
          expect(p.opciones.length, greaterThanOrEqualTo(3), reason: p.id);
        } else {
          expect(p.correcta, inInclusiveRange(0, p.opciones.length - 1));
        }
        if (p.tipo == TipoPregunta.completar) {
          expect(p.enunciado, contains('___'), reason: p.id);
        }
      }
    }
  });

  test('el simulacro tiene al menos 8 preguntas por cargo', () {
    expect(contenido.roles.map((r) => r.id), [
      'operario',
      'supervisor',
      'hseq',
    ]);
    for (final rol in contenido.roles) {
      expect(contenido.preguntasDeRol(rol.id).length, greaterThanOrEqualTo(8));
    }
    for (final p in contenido.preguntasAuditor) {
      expect(contenido.unidades.map((u) => u.id), contains(p.unidadId));
      expect(p.correcta, inInclusiveRange(0, p.opciones.length - 1));
    }
  });

  test('la unidad de emergencias es un procedimiento de la empresa', () {
    final u = contenido.unidad('emergencias');
    expect(u.tipo, TipoUnidad.procedimiento);
    expect(u.procedimiento?.generadoConIa, isTrue);
  });
}
