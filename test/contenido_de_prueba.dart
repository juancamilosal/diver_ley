import 'dart:convert';
import 'dart:io';

import 'package:diver_ley/datos/repositorio_contenido.dart';
import 'package:diver_ley/modelos/contenido.dart';
import 'package:flutter/services.dart';

/// Lee los archivos de contenido directamente del disco.
class BundleDeDisco extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(key).readAsBytes();
    return ByteData.sublistView(bytes);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) =>
      File(key).readAsString(encoding: utf8);
}

Future<Contenido> cargarContenidoDePrueba() =>
    ContenidoLocal(BundleDeDisco()).cargar();
