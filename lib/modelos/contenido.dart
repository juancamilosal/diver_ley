/// Modelos del contenido de aprendizaje.
///
/// Tienen la misma forma que los archivos de `assets/contenido/` y que las
/// colecciones que tendrá Directus más adelante.
library;

enum TipoPregunta { opcion, vf, ordenar, completar }

enum TipoUnidad { norma, procedimiento }

class Pregunta {
  const Pregunta({
    required this.id,
    required this.tipo,
    required this.enunciado,
    required this.opciones,
    required this.correcta,
    required this.explicacion,
    required this.fuente,
  });

  final String id;
  final TipoPregunta tipo;
  final String enunciado;

  /// Opciones para elegir. En [TipoPregunta.ordenar] van en el orden
  /// correcto; la pantalla las muestra revueltas.
  final List<String> opciones;

  /// Índice de la opción correcta. No aplica a [TipoPregunta.ordenar].
  final int correcta;
  final String explicacion;

  /// Norma o documento que sustenta la respuesta.
  final String fuente;

  /// Texto de la respuesta correcta, para mostrarlo al equivocarse.
  String get respuestaCorrecta =>
      tipo == TipoPregunta.ordenar ? opciones.join(' → ') : opciones[correcta];

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    final tipo = TipoPregunta.values.byName(json['tipo'] as String);
    return switch (tipo) {
      TipoPregunta.vf => Pregunta(
        id: json['id'] as String,
        tipo: tipo,
        enunciado: json['enunciado'] as String,
        opciones: const ['Verdadero', 'Falso'],
        correcta: (json['respuesta'] as bool) ? 0 : 1,
        explicacion: json['explicacion'] as String,
        fuente: json['fuente'] as String,
      ),
      TipoPregunta.ordenar => Pregunta(
        id: json['id'] as String,
        tipo: tipo,
        enunciado: json['enunciado'] as String,
        opciones: List<String>.from(json['pasos'] as List),
        correcta: -1,
        explicacion: json['explicacion'] as String,
        fuente: json['fuente'] as String,
      ),
      _ => Pregunta(
        id: json['id'] as String,
        tipo: tipo,
        enunciado: json['enunciado'] as String,
        opciones: List<String>.from(json['opciones'] as List),
        correcta: json['correcta'] as int,
        explicacion: json['explicacion'] as String,
        fuente: json['fuente'] as String,
      ),
    };
  }
}

class Leccion {
  const Leccion({
    required this.id,
    required this.titulo,
    required this.preguntas,
  });

  final String id;
  final String titulo;
  final List<Pregunta> preguntas;

  /// Minutos aproximados: unos 35 segundos por pregunta.
  int get minutos => (preguntas.length * 35 / 60).ceil();

  factory Leccion.fromJson(Map<String, dynamic> json) => Leccion(
    id: json['id'] as String,
    titulo: json['titulo'] as String,
    preguntas: [
      for (final p in json['preguntas'] as List)
        Pregunta.fromJson(p as Map<String, dynamic>),
    ],
  );
}

/// Datos de un procedimiento que subió la empresa.
class Procedimiento {
  const Procedimiento({
    required this.documento,
    required this.aprobadoPor,
    required this.fechaAprobacion,
    required this.generadoConIa,
  });

  final String documento;
  final String aprobadoPor;
  final DateTime fechaAprobacion;
  final bool generadoConIa;

  factory Procedimiento.fromJson(Map<String, dynamic> json) => Procedimiento(
    documento: json['documento'] as String,
    aprobadoPor: json['aprobadoPor'] as String,
    fechaAprobacion: DateTime.parse(json['fechaAprobacion'] as String),
    generadoConIa: json['generadoConIa'] as bool? ?? false,
  );
}

class Unidad {
  const Unidad({
    required this.id,
    required this.titulo,
    required this.norma,
    required this.descripcion,
    required this.tipo,
    required this.lecciones,
    this.procedimiento,
  });

  final String id;
  final String titulo;

  /// Etiqueta corta de la norma o documento, por ejemplo "Res. 0312 de 2019".
  final String norma;
  final String descripcion;
  final TipoUnidad tipo;
  final List<Leccion> lecciones;
  final Procedimiento? procedimiento;

  int get totalPreguntas =>
      lecciones.fold(0, (total, l) => total + l.preguntas.length);

  factory Unidad.fromJson(Map<String, dynamic> json) => Unidad(
    id: json['id'] as String,
    titulo: json['titulo'] as String,
    norma: json['norma'] as String,
    descripcion: json['descripcion'] as String,
    tipo: TipoUnidad.values.byName(json['tipo'] as String),
    lecciones: [
      for (final l in json['lecciones'] as List)
        Leccion.fromJson(l as Map<String, dynamic>),
    ],
    procedimiento: json['procedimiento'] == null
        ? null
        : Procedimiento.fromJson(json['procedimiento'] as Map<String, dynamic>),
  );
}

/// Cargo para el simulacro de auditoría.
class Rol {
  const Rol({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  final String id;
  final String nombre;
  final String descripcion;

  factory Rol.fromJson(Map<String, dynamic> json) => Rol(
    id: json['id'] as String,
    nombre: json['nombre'] as String,
    descripcion: json['descripcion'] as String,
  );
}

/// Pregunta del simulacro, hecha como la haría un auditor.
class PreguntaAuditor {
  const PreguntaAuditor({
    required this.id,
    required this.roles,
    required this.tema,
    required this.unidadId,
    required this.pregunta,
    required this.opciones,
    required this.correcta,
    required this.explicacion,
    required this.fuente,
  });

  final String id;
  final List<String> roles;
  final String tema;

  /// Unidad que se recomienda repasar si se responde mal.
  final String unidadId;
  final String pregunta;
  final List<String> opciones;
  final int correcta;
  final String explicacion;
  final String fuente;

  factory PreguntaAuditor.fromJson(Map<String, dynamic> json) =>
      PreguntaAuditor(
        id: json['id'] as String,
        roles: List<String>.from(json['roles'] as List),
        tema: json['tema'] as String,
        unidadId: json['unidad'] as String,
        pregunta: json['pregunta'] as String,
        opciones: List<String>.from(json['opciones'] as List),
        correcta: json['correcta'] as int,
        explicacion: json['explicacion'] as String,
        fuente: json['fuente'] as String,
      );
}

/// Todo el contenido que usa la app.
class Contenido {
  const Contenido({
    required this.version,
    required this.unidades,
    required this.roles,
    required this.preguntasAuditor,
  });

  final String version;
  final List<Unidad> unidades;
  final List<Rol> roles;
  final List<PreguntaAuditor> preguntasAuditor;

  Unidad unidad(String id) => unidades.firstWhere((u) => u.id == id);

  Rol rol(String id) => roles.firstWhere((r) => r.id == id);

  /// Todas las lecciones en el orden de la ruta.
  List<Leccion> get leccionesEnOrden => [
    for (final u in unidades) ...u.lecciones,
  ];

  /// Unidad a la que pertenece una lección.
  Unidad unidadDeLeccion(String leccionId) =>
      unidades.firstWhere((u) => u.lecciones.any((l) => l.id == leccionId));

  List<PreguntaAuditor> preguntasDeRol(String rolId) =>
      preguntasAuditor.where((p) => p.roles.contains(rolId)).toList();
}
