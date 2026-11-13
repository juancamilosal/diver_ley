/// Datos de ejemplo de la demo: una constructora ficticia y su gente.
///
/// En la versión final esto llega de Directus al iniciar sesión.
library;

import '../logica/fechas.dart';
import '../modelos/progreso.dart';

class Empresa {
  const Empresa({
    required this.nombre,
    required this.codigo,
    required this.sede,
  });

  final String nombre;
  final String codigo;
  final String sede;
}

class Usuario {
  const Usuario({
    required this.nombre,
    required this.cedula,
    required this.cargo,
    required this.rolId,
    required this.area,
  });

  final String nombre;
  final String cedula;
  final String cargo;

  /// Rol del simulacro que le corresponde por su cargo.
  final String rolId;
  final String area;

  String get iniciales => nombre.split(' ').take(2).map((p) => p[0]).join();
}

class Companero {
  const Companero({
    required this.nombre,
    required this.cargo,
    required this.xpSemana,
  });

  final String nombre;
  final String cargo;
  final int xpSemana;
}

class AreaEmpresa {
  const AreaEmpresa({required this.nombre, required this.alDia});

  final String nombre;

  /// Porcentaje del personal con la capacitación al día.
  final int alDia;
}

abstract final class Demo {
  static const empresa = Empresa(
    nombre: 'Constructora Andina S.A.S.',
    codigo: 'ANDINA',
    sede: 'Obra Torre Norte',
  );

  static const usuario = Usuario(
    nombre: 'Andrés Gómez',
    cedula: '1020345678',
    cargo: 'Supervisor de obra',
    rolId: 'supervisor',
    area: 'Obra Torre Norte',
  );

  static const liga = 'Liga Oro';

  static const companeros = [
    Companero(nombre: 'Marcela Ríos', cargo: 'Oficial de obra', xpSemana: 120),
    Companero(nombre: 'Jhon Fredy Cárdenas', cargo: 'Operario', xpSemana: 96),
    Companero(nombre: 'Paola Herrera', cargo: 'Almacenista', xpSemana: 78),
    Companero(
      nombre: 'Luis Ángel Mora',
      cargo: 'Maestro de obra',
      xpSemana: 64,
    ),
    Companero(nombre: 'Wilmer Castaño', cargo: 'Operario', xpSemana: 52),
    Companero(nombre: 'Diana Patiño', cargo: 'Residente de obra', xpSemana: 41),
    Companero(nombre: 'Óscar Benítez', cargo: 'Electricista', xpSemana: 30),
    Companero(nombre: 'Yeison Arias', cargo: 'Ayudante', xpSemana: 18),
    Companero(nombre: 'Camilo Ortiz', cargo: 'Soldador', xpSemana: 9),
  ];

  static const areas = [
    AreaEmpresa(nombre: 'Oficina principal', alDia: 95),
    AreaEmpresa(nombre: 'Almacén central', alDia: 92),
    AreaEmpresa(nombre: 'Obra Torre Norte', alDia: 87),
    AreaEmpresa(nombre: 'Obra Parque Sur', alDia: 74),
    AreaEmpresa(nombre: 'Contratistas', alDia: 61),
  ];

  /// Progreso con el que arranca la demo: 12 días de racha (el último ayer)
  /// y la primera unidad terminada, para que la ruta se vea en uso.
  static Progreso progresoInicial(DateTime ahora) {
    final ayer = ahora.subtract(const Duration(days: 1));
    final haceUnaSemana = ahora.subtract(const Duration(days: 6));
    return Progreso(
      sesionIniciada: false,
      xp: 340,
      xpSemana: 85,
      racha: 12,
      ultimaPractica: diaDe(ayer),
      xpHoy: 15,
      leccionesCompletadas: const {'sgsst-1', 'sgsst-2', 'res0312-1'},
      correctas: 13,
      respondidas: 15,
      simulacros: const [],
      desbloquearTodo: false,
      fechasCertificado: {'sgsst': haceUnaSemana},
    );
  }
}
