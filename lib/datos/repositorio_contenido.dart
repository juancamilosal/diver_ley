import 'dart:convert';

import 'package:flutter/services.dart';

import '../modelos/contenido.dart';

/// Origen del contenido. En la demo sale de los archivos de la app; después
/// habrá una versión que lo descargue de Directus y lo guarde para usarlo
/// sin conexión.
abstract interface class RepositorioContenido {
  Future<Contenido> cargar();
}

class ContenidoLocal implements RepositorioContenido {
  const ContenidoLocal([this.bundle]);

  final AssetBundle? bundle;

  @override
  Future<Contenido> cargar() async {
    final origen = bundle ?? rootBundle;
    final unidades = jsonDecode(
      await origen.loadString('assets/contenido/unidades.json'),
    ) as Map<String, dynamic>;
    final simulacro = jsonDecode(
      await origen.loadString('assets/contenido/simulacro.json'),
    ) as Map<String, dynamic>;
    return Contenido(
      version: unidades['version'] as String,
      unidades: [
        for (final u in unidades['unidades'] as List)
          Unidad.fromJson(u as Map<String, dynamic>),
      ],
      roles: [
        for (final r in simulacro['roles'] as List)
          Rol.fromJson(r as Map<String, dynamic>),
      ],
      preguntasAuditor: [
        for (final p in simulacro['preguntas'] as List)
          PreguntaAuditor.fromJson(p as Map<String, dynamic>),
      ],
    );
  }
}
