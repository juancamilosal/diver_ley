import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registrarLicenciasDeFuentes();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const DiverLeyApp(),
    ),
  );
}

/// Las fuentes Rubik y Nunito Sans van con su licencia OFL.
void _registrarLicenciasDeFuentes() {
  for (final (familia, archivo) in [
    ('Rubik', 'assets/fonts/OFL-Rubik.txt'),
    ('Nunito Sans', 'assets/fonts/OFL-NunitoSans.txt'),
  ]) {
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks([
        familia,
      ], await rootBundle.loadString(archivo));
    });
  }
}
