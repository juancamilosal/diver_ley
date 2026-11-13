import 'package:diver_ley/datos/demo.dart';
import 'package:diver_ley/logica/fechas.dart';
import 'package:diver_ley/logica/ruta.dart';
import 'package:diver_ley/logica/sesion_simulacro.dart';
import 'package:diver_ley/modelos/contenido.dart';
import 'package:diver_ley/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contenido_de_prueba.dart';

Future<ProviderContainer> _contenedor(DateTime Function() reloj) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      relojProvider.overrideWithValue(reloj),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  late Contenido contenido;

  setUpAll(() async => contenido = await cargarContenidoDePrueba());

  test(
    'la demo arranca con 12 días de racha y la siguiente es res0312-2',
    () async {
      final hoy = DateTime(2026, 11, 13, 9);
      final c = await _contenedor(() => hoy);
      final p = c.read(progresoProvider);
      expect(p.rachaActual(hoy), 12);
      expect(p.practicoHoy(hoy), isFalse);
      expect(leccionActual(contenido, p)?.id, 'res0312-2');
      expect(estadoDe('sgsst-1', contenido, p), EstadoLeccion.completada);
      expect(estadoDe('alturas-1', contenido, p), EstadoLeccion.bloqueada);
    },
  );

  test('completar la primera lección del día sube la racha una vez', () async {
    final hoy = DateTime(2026, 11, 13, 9);
    final c = await _contenedor(() => hoy);
    final notifier = c.read(progresoProvider.notifier);
    final unidad = contenido.unidad('res0312');

    final primera = notifier.completarLeccion(
      unidad: unidad,
      leccionId: 'res0312-2',
      xp: 15,
      correctas: 5,
      respondidas: 5,
    );
    expect(primera.rachaAntes, 12);
    expect(primera.rachaDespues, 13);
    expect(primera.metaCumplidaAhora, isFalse);
    expect(primera.unidadCompletada, isNull);

    final segunda = notifier.completarLeccion(
      unidad: unidad,
      leccionId: 'res0312-3',
      xp: 20,
      correctas: 5,
      respondidas: 5,
    );
    expect(segunda.rachaDespues, 13);
    expect(segunda.metaCumplidaAhora, isTrue);
    expect(segunda.unidadCompletada?.id, 'res0312');

    final p = c.read(progresoProvider);
    expect(p.xp, 340 + 35);
    expect(p.xpDeHoy(hoy), 35);
    expect(p.fechasCertificado['res0312'], hoy);
    expect(leccionActual(contenido, p)?.id, 'alturas-1');
  });

  test('la racha se pierde tras un día sin practicar', () {
    final p = Demo.progresoInicial(DateTime(2026, 11, 10));
    expect(p.rachaActual(DateTime(2026, 11, 10)), 12);
    expect(p.rachaActual(DateTime(2026, 11, 11)), 0);
  });

  test('el progreso se guarda y se vuelve a leer', () async {
    final hoy = DateTime(2026, 11, 13, 9);
    final c = await _contenedor(() => hoy);
    c.read(progresoProvider.notifier)
      ..iniciarSesion()
      ..desbloquearTodo(true);
    final prefs = c.read(prefsProvider);
    final otro = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        relojProvider.overrideWithValue(() => hoy),
      ],
    );
    addTearDown(otro.dispose);
    final p = otro.read(progresoProvider);
    expect(p.sesionIniciada, isTrue);
    expect(p.desbloquearTodo, isTrue);
    expect(p.fechasCertificado['sgsst'], isNotNull);
    expect(estadoDe('calidad-1', contenido, p), EstadoLeccion.disponible);
  });

  test('el simulacro calcula puntaje y temas, y suma a la racha', () async {
    final hoy = DateTime(2026, 11, 13, 9);
    final c = await _contenedor(() => hoy);
    final sesion = SesionSimulacro(
      rol: contenido.rol('supervisor'),
      banco: contenido.preguntasDeRol('supervisor'),
    );
    expect(sesion.preguntas, hasLength(8));
    var n = 0;
    while (!sesion.terminada) {
      final p = sesion.actual;
      sesion.responder(n++ < 6 ? p.correcta : (p.correcta + 1) % 3);
    }
    final r = sesion.resultado(hoy);
    expect(r.aciertos, 6);
    expect(r.puntaje, 75);
    expect(nivelDe(r.puntaje), Nivel.porReforzar);
    expect(
      r.porTema.values.fold(0, (t, v) => t + v[1]),
      sesion.preguntas.length,
    );
    final celebracion = c.read(progresoProvider.notifier).registrarSimulacro(r);
    expect(celebracion.rachaDespues, 13);
    expect(c.read(progresoProvider).simulacros.single.puntaje, 75);
  });

  test('fechas en español', () {
    expect(fechaCorta(DateTime(2026, 11, 13)), '13 nov 2026');
    expect(fechaHora(DateTime(2026, 11, 13, 14, 5)), '13 nov 2026, 2:05 p. m.');
    expect(diasParaCierreDeLiga(DateTime(2026, 11, 13)), 3); // viernes
    expect(diasParaCierreDeLiga(DateTime(2026, 11, 15)), 1); // domingo
  });
}
