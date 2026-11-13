import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'datos/demo.dart';
import 'datos/repositorio_contenido.dart';
import 'logica/fechas.dart';
import 'logica/ruta.dart';
import 'modelos/contenido.dart';
import 'modelos/progreso.dart';

/// Se reemplaza en `main` con la instancia ya cargada.
final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Falta sobrescribir prefsProvider'),
);

/// Hora actual. Las pruebas la reemplazan para controlar la racha.
final relojProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final repositorioProvider = Provider<RepositorioContenido>(
  (ref) => const ContenidoLocal(),
);

final contenidoProvider = FutureProvider<Contenido>(
  (ref) => ref.watch(repositorioProvider).cargar(),
);

final progresoProvider = NotifierProvider<ProgresoNotifier, Progreso>(
  ProgresoNotifier.new,
);

/// Lo que cambió al ganar XP, para celebrarlo en pantalla.
class Celebracion {
  const Celebracion({
    required this.rachaAntes,
    required this.rachaDespues,
    required this.metaCumplidaAhora,
    this.unidadCompletada,
  });

  final int rachaAntes;
  final int rachaDespues;
  final bool metaCumplidaAhora;
  final Unidad? unidadCompletada;

  bool get rachaSubio => rachaDespues > rachaAntes;
}

class ProgresoNotifier extends Notifier<Progreso> {
  static const _clave = 'progreso';

  SharedPreferences get _prefs => ref.read(prefsProvider);
  DateTime _ahora() => ref.read(relojProvider)();

  @override
  Progreso build() {
    final guardado = _prefs.getString(_clave);
    if (guardado != null) {
      try {
        return Progreso.fromJson(jsonDecode(guardado) as Map<String, dynamic>);
      } on Object {
        // Si el formato cambió entre versiones de la demo, se empieza de nuevo.
      }
    }
    return Demo.progresoInicial(_ahora());
  }

  void _guardar(Progreso nuevo) {
    state = nuevo;
    _prefs.setString(_clave, jsonEncode(nuevo.toJson()));
  }

  void iniciarSesion() => _guardar(state.copyWith(sesionIniciada: true));

  void cerrarSesion() => _guardar(state.copyWith(sesionIniciada: false));

  void desbloquearTodo(bool valor) =>
      _guardar(state.copyWith(desbloquearTodo: valor));

  /// Vuelve al progreso inicial de la demo, con la sesión abierta.
  void reiniciarDemo() =>
      _guardar(Demo.progresoInicial(_ahora()).copyWith(sesionIniciada: true));

  /// Suma XP del día y actualiza la racha.
  Progreso _conXp(Progreso p, int xp) {
    final ahora = _ahora();
    final hoy = diaDe(ahora);
    final mismoDia = p.ultimaPractica == hoy;
    final racha = mismoDia
        ? p.racha
        : p.rachaActual(ahora) > 0
        ? p.racha + 1
        : 1;
    return p.copyWith(
      xp: p.xp + xp,
      xpSemana: p.xpSemana + xp,
      racha: racha,
      ultimaPractica: hoy,
      xpHoy: (mismoDia ? p.xpHoy : 0) + xp,
    );
  }

  Celebracion _celebrar(Progreso antes, Progreso despues, [Unidad? unidad]) {
    final ahora = _ahora();
    return Celebracion(
      rachaAntes: antes.rachaActual(ahora),
      rachaDespues: despues.rachaActual(ahora),
      metaCumplidaAhora:
          antes.xpDeHoy(ahora) < Progreso.metaDiaria &&
          despues.xpDeHoy(ahora) >= Progreso.metaDiaria,
      unidadCompletada: unidad,
    );
  }

  Celebracion completarLeccion({
    required Unidad unidad,
    required String leccionId,
    required int xp,
    required int correctas,
    required int respondidas,
  }) {
    final antes = state;
    final yaCompleta = unidadCompleta(unidad, antes);
    var nuevo = _conXp(antes, xp).copyWith(
      leccionesCompletadas: {...antes.leccionesCompletadas, leccionId},
      correctas: antes.correctas + correctas,
      respondidas: antes.respondidas + respondidas,
    );
    final completaAhora = !yaCompleta && unidadCompleta(unidad, nuevo);
    if (completaAhora) {
      nuevo = nuevo.copyWith(
        fechasCertificado: {...nuevo.fechasCertificado, unidad.id: _ahora()},
      );
    }
    _guardar(nuevo);
    return _celebrar(antes, nuevo, completaAhora ? unidad : null);
  }

  Celebracion registrarSimulacro(ResultadoSimulacro resultado) {
    final antes = state;
    final xp = 5 + resultado.aciertos;
    final nuevo = _conXp(
      antes,
      xp,
    ).copyWith(simulacros: [resultado, ...antes.simulacros]);
    _guardar(nuevo);
    return _celebrar(antes, nuevo);
  }
}
