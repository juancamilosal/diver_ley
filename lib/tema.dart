import 'package:material_ui/material_ui.dart';

/// Colores de la marca, tomados de la propuesta de negocio.
abstract final class Colores {
  static const navy = Color(0xFF14213D);
  static const navyClaro = Color(0xFF1E2F52);
  static const verde = Color(0xFF17733F);
  static const verdeOscuro = Color(0xFF0F5A30);
  static const verdeSuave = Color(0xFFE3F4E9);
  static const menta = Color(0xFF7FD6A0);
  static const crema = Color(0xFFF6F5EF);
  static const naranja = Color(0xFFD9661F);
  static const naranjaOscuro = Color(0xFFC2541A);
  static const naranjaSuave = Color(0xFFFBEADF);
  static const dorado = Color(0xFFD9A21F);
  static const doradoSuave = Color(0xFFFBF1D9);
  static const borde = Color(0xFFDDE3EA);
  static const gris = Color(0xFFECEEF1);
  static const grisOscuro = Color(0xFF7A8494);
  static const texto = Color(0xFF14213D);
  static const textoSuave = Color(0xFF4A5568);
  static const blanco = Color(0xFFFFFFFF);
}

/// Las fuentes son variables: el peso se aplica también como variación.
TextStyle _fuente(
  String familia,
  double tamano,
  FontWeight peso,
  Color? color,
  double? alto,
) => TextStyle(
  fontFamily: familia,
  fontSize: tamano,
  fontWeight: peso,
  fontVariations: [FontVariation('wght', peso.value.toDouble())],
  color: color,
  height: alto,
);

/// Títulos y números.
TextStyle rubik(
  double tamano, {
  FontWeight peso = FontWeight.w700,
  Color? color,
  double? alto,
}) => _fuente('Rubik', tamano, peso, color, alto);

/// Texto corrido.
TextStyle nunito(
  double tamano, {
  FontWeight peso = FontWeight.w400,
  Color? color,
  double? alto,
}) => _fuente('NunitoSans', tamano, peso, color, alto);

ThemeData temaDiverLey() {
  final esquema = ColorScheme.fromSeed(
    seedColor: Colores.verde,
    primary: Colores.verde,
    secondary: Colores.navy,
    surface: Colores.crema,
    error: Colores.naranjaOscuro,
  );
  return ThemeData(
    colorScheme: esquema,
    scaffoldBackgroundColor: Colores.crema,
    fontFamily: 'NunitoSans',
    textTheme: TextTheme(
      bodyLarge: nunito(17, color: Colores.texto),
      bodyMedium: nunito(15, color: Colores.texto),
      bodySmall: nunito(13, color: Colores.textoSuave),
      titleLarge: rubik(22, color: Colores.texto),
      titleMedium: rubik(18, color: Colores.texto),
      titleSmall: rubik(15, color: Colores.texto),
      labelLarge: nunito(15, peso: FontWeight.w700),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colores.crema,
      foregroundColor: Colores.texto,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: rubik(22, color: Colores.texto),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colores.blanco,
      indicatorColor: Colores.verdeSuave,
      surfaceTintColor: Colores.blanco,
      labelTextStyle: WidgetStatePropertyAll(
        nunito(12, peso: FontWeight.w700, color: Colores.texto),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colores.blanco,
      surfaceTintColor: Colores.blanco,
      showDragHandle: true,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colores.blanco,
      surfaceTintColor: Colores.blanco,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colores.navy,
      contentTextStyle: nunito(15, color: Colores.blanco),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colores.blanco : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colores.verde : null,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colores.blanco,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colores.borde, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colores.borde, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colores.verde, width: 2),
      ),
    ),
  );
}
