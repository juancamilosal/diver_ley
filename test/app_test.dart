import 'package:diver_ley/app.dart';
import 'package:diver_ley/datos/repositorio_contenido.dart';
import 'package:diver_ley/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contenido_de_prueba.dart';

Future<void> _abrir(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final contenido = await tester.runAsync(cargarContenidoDePrueba);
  await tester.binding.setSurfaceSize(const Size(400, 860));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        relojProvider.overrideWithValue(() => DateTime(2026, 11, 13, 9)),
        contenidoProvider.overrideWith((ref) => contenido!),
        repositorioProvider.overrideWithValue(ContenidoLocal(BundleDeDisco())),
      ],
      child: const DiverLeyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ingresar y completar una lección', (tester) async {
    await _abrir(tester);
    expect(find.text('Ingresa con tu empresa'), findsOneWidget);

    await tester.tap(find.text('INGRESAR'));
    await tester.pumpAndSettle();
    expect(find.text('EMPEZAR'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Lección 2: La autoevaluación'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EMPEZAR').last);
    await tester.pumpAndSettle();

    // Responde mal la primera para ver que vuelve al final.
    expect(
      find.text(
        '¿Cada cuánto se hace la autoevaluación de los estándares mínimos?',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cada cinco años'));
    await tester.pump();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pumpAndSettle();
    expect(find.text('Respuesta correcta:'), findsOneWidget);
    expect(find.text('Res. 0312 de 2019, art. 27'), findsOneWidget);
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();

    final respuestas = {
      'Si el resultado': 'Crítica',
      'Un resultado mayor': 'aceptable',
      'Con una valoración': 'Verdadero',
      '¿Cada cuánto se hace': 'Una vez al año',
    };
    for (var i = 0; i < 5; i++) {
      if (find
          .text('Ordena el proceso anual de los estándares mínimos.')
          .evaluate()
          .isNotEmpty) {
        for (final paso in [
          'Hacer la autoevaluación',
          'Identificar los estándares que no se cumplen',
          'Formular el plan de mejoramiento',
          'Ejecutar el plan y hacerle seguimiento',
        ]) {
          await tester.tap(find.text(paso));
          await tester.pump();
        }
      } else {
        final clave = respuestas.keys.firstWhere(
          (k) => find.textContaining(k).evaluate().isNotEmpty,
        );
        await tester.tap(find.text(respuestas[clave]!));
        await tester.pump();
      }
      await tester.tap(find.text('COMPROBAR'));
      await tester.pumpAndSettle();
      expect(find.text('¡Correcto!'), findsOneWidget);
      await tester.tap(find.text('CONTINUAR'));
      await tester.pumpAndSettle();
    }

    expect(find.text('¡Lección completada!'), findsOneWidget);
    expect(find.text('¡Tu racha subió a 13 días!'), findsOneWidget);
    expect(find.text('80 %'), findsOneWidget);
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
    expect(find.text('13'), findsOneWidget);
  });

  testWidgets('las pestañas abren sin errores', (tester) async {
    await _abrir(tester);
    await tester.tap(find.text('INGRESAR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simulacro'));
    await tester.pumpAndSettle();
    expect(find.text('Tu cargo'), findsOneWidget);
    await tester.tap(find.text('Liga'));
    await tester.pumpAndSettle();
    expect(find.text('Andrés Gómez (tú)'), findsOneWidget);
    await tester.tap(find.text('Por áreas'));
    await tester.pumpAndSettle();
    expect(find.text('Obra Torre Norte (tu área)'), findsOneWidget);
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Fundamentos del SG-SST'), findsOneWidget);
  });
}
