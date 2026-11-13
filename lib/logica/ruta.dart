import '../modelos/contenido.dart';
import '../modelos/progreso.dart';

enum EstadoLeccion { completada, actual, disponible, bloqueada }

/// Estado de cada lección en la ruta de aprendizaje.
EstadoLeccion estadoDe(
  String leccionId,
  Contenido contenido,
  Progreso progreso,
) {
  if (progreso.leccionesCompletadas.contains(leccionId)) {
    return EstadoLeccion.completada;
  }
  final actual = leccionActual(contenido, progreso);
  if (actual?.id == leccionId) return EstadoLeccion.actual;
  return progreso.desbloquearTodo
      ? EstadoLeccion.disponible
      : EstadoLeccion.bloqueada;
}

/// Primera lección sin completar, en el orden de la ruta.
Leccion? leccionActual(Contenido contenido, Progreso progreso) {
  for (final l in contenido.leccionesEnOrden) {
    if (!progreso.leccionesCompletadas.contains(l.id)) return l;
  }
  return null;
}

bool unidadCompleta(Unidad unidad, Progreso progreso) =>
    unidad.lecciones.every((l) => progreso.leccionesCompletadas.contains(l.id));
