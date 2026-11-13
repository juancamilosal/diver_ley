import '../logica/fechas.dart';

/// Resultado guardado de un simulacro de auditoría.
class ResultadoSimulacro {
  const ResultadoSimulacro({
    required this.rolId,
    required this.fecha,
    required this.aciertos,
    required this.total,
    required this.porTema,
  });

  final String rolId;
  final DateTime fecha;
  final int aciertos;
  final int total;

  /// Tema → `[aciertos, total]`.
  final Map<String, List<int>> porTema;

  int get puntaje => total == 0 ? 0 : (aciertos * 100 / total).round();

  Map<String, dynamic> toJson() => {
    'rolId': rolId,
    'fecha': fecha.toIso8601String(),
    'aciertos': aciertos,
    'total': total,
    'porTema': porTema,
  };

  factory ResultadoSimulacro.fromJson(Map<String, dynamic> json) =>
      ResultadoSimulacro(
        rolId: json['rolId'] as String,
        fecha: DateTime.parse(json['fecha'] as String),
        aciertos: json['aciertos'] as int,
        total: json['total'] as int,
        porTema: {
          for (final e in (json['porTema'] as Map<String, dynamic>).entries)
            e.key: List<int>.from(e.value as List),
        },
      );
}

/// Progreso del usuario en el celular.
class Progreso {
  const Progreso({
    required this.sesionIniciada,
    required this.xp,
    required this.xpSemana,
    required this.racha,
    required this.ultimaPractica,
    required this.xpHoy,
    required this.leccionesCompletadas,
    required this.correctas,
    required this.respondidas,
    required this.simulacros,
    required this.desbloquearTodo,
    this.fechasCertificado = const {},
  });

  final bool sesionIniciada;
  final int xp;
  final int xpSemana;

  /// Racha guardada. La que se muestra es [rachaActual].
  final int racha;

  /// Último día con una lección completada (`aaaa-mm-dd`).
  final String? ultimaPractica;

  /// XP ganados el día de [ultimaPractica].
  final int xpHoy;
  final Set<String> leccionesCompletadas;
  final int correctas;
  final int respondidas;
  final List<ResultadoSimulacro> simulacros;

  /// Modo demo: deja abrir cualquier lección.
  final bool desbloquearTodo;

  /// Unidad → fecha en que se completó (para el certificado).
  final Map<String, DateTime> fechasCertificado;

  static const metaDiaria = 30;

  /// La racha se pierde si pasó más de un día sin practicar.
  int rachaActual(DateTime hoy) {
    if (ultimaPractica == null) return 0;
    final dias = diasEntre(DateTime.parse(ultimaPractica!), hoy);
    return dias <= 1 ? racha : 0;
  }

  bool practicoHoy(DateTime hoy) => ultimaPractica == diaDe(hoy);

  int xpDeHoy(DateTime hoy) => practicoHoy(hoy) ? xpHoy : 0;

  int get precision =>
      respondidas == 0 ? 0 : (correctas * 100 / respondidas).round();

  Progreso copyWith({
    bool? sesionIniciada,
    int? xp,
    int? xpSemana,
    int? racha,
    String? ultimaPractica,
    int? xpHoy,
    Set<String>? leccionesCompletadas,
    int? correctas,
    int? respondidas,
    List<ResultadoSimulacro>? simulacros,
    bool? desbloquearTodo,
    Map<String, DateTime>? fechasCertificado,
  }) => Progreso(
    sesionIniciada: sesionIniciada ?? this.sesionIniciada,
    xp: xp ?? this.xp,
    xpSemana: xpSemana ?? this.xpSemana,
    racha: racha ?? this.racha,
    ultimaPractica: ultimaPractica ?? this.ultimaPractica,
    xpHoy: xpHoy ?? this.xpHoy,
    leccionesCompletadas: leccionesCompletadas ?? this.leccionesCompletadas,
    correctas: correctas ?? this.correctas,
    respondidas: respondidas ?? this.respondidas,
    simulacros: simulacros ?? this.simulacros,
    desbloquearTodo: desbloquearTodo ?? this.desbloquearTodo,
    fechasCertificado: fechasCertificado ?? this.fechasCertificado,
  );

  Map<String, dynamic> toJson() => {
    'sesionIniciada': sesionIniciada,
    'xp': xp,
    'xpSemana': xpSemana,
    'racha': racha,
    'ultimaPractica': ultimaPractica,
    'xpHoy': xpHoy,
    'leccionesCompletadas': leccionesCompletadas.toList(),
    'correctas': correctas,
    'respondidas': respondidas,
    'simulacros': [for (final s in simulacros) s.toJson()],
    'desbloquearTodo': desbloquearTodo,
    'fechasCertificado': {
      for (final e in fechasCertificado.entries)
        e.key: e.value.toIso8601String(),
    },
  };

  factory Progreso.fromJson(Map<String, dynamic> json) => Progreso(
    sesionIniciada: json['sesionIniciada'] as bool,
    xp: json['xp'] as int,
    xpSemana: json['xpSemana'] as int,
    racha: json['racha'] as int,
    ultimaPractica: json['ultimaPractica'] as String?,
    xpHoy: json['xpHoy'] as int,
    leccionesCompletadas: Set<String>.from(
      json['leccionesCompletadas'] as List,
    ),
    correctas: json['correctas'] as int,
    respondidas: json['respondidas'] as int,
    simulacros: [
      for (final s in json['simulacros'] as List)
        ResultadoSimulacro.fromJson(s as Map<String, dynamic>),
    ],
    desbloquearTodo: json['desbloquearTodo'] as bool? ?? false,
    fechasCertificado: {
      for (final e
          in (json['fechasCertificado'] as Map<String, dynamic>? ?? {}).entries)
        e.key: DateTime.parse(e.value as String),
    },
  );
}
