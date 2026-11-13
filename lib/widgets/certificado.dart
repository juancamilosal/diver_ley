import 'package:material_ui/material_ui.dart';

import '../datos/demo.dart';
import '../logica/fechas.dart';
import '../modelos/contenido.dart';
import '../tema.dart';
import 'boton.dart';
import 'logo.dart';

/// Cédula con puntos de miles: 1.020.345.678.
String cedulaConPuntos(String cedula) {
  final buffer = StringBuffer();
  for (var i = 0; i < cedula.length; i++) {
    if (i > 0 && (cedula.length - i) % 3 == 0) buffer.write('.');
    buffer.write(cedula[i]);
  }
  return buffer.toString();
}

/// Código corto para verificar el certificado (en la versión final lo
/// genera el servidor).
String codigoVerificacion(String unidadId, DateTime fecha) {
  final base = '$unidadId${Demo.usuario.cedula}${diaDe(fecha)}';
  final hash = base.codeUnits.fold<int>(7, (h, c) => (h * 31 + c) % 1679616);
  return 'DL-${unidadId.toUpperCase()}-${hash.toRadixString(36).toUpperCase().padLeft(4, '0')}';
}

Future<void> mostrarCertificado(
  BuildContext context,
  Unidad unidad,
  DateTime fecha,
) => showDialog<void>(
  context: context,
  builder: (context) => Dialog(
    insetPadding: const EdgeInsets.all(20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colores.crema,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colores.dorado, width: 3),
            ),
            child: Column(
              children: [
                const LogoDiverLey(tamano: 48),
                const SizedBox(height: 12),
                Text(
                  'CERTIFICADO DE CAPACITACIÓN',
                  textAlign: TextAlign.center,
                  style: nunito(
                    13,
                    peso: FontWeight.w800,
                    color: Colores.verde,
                  ).copyWith(letterSpacing: 1.4),
                ),
                const SizedBox(height: 14),
                Text('Se certifica que', style: nunito(14)),
                const SizedBox(height: 4),
                Text(
                  Demo.usuario.nombre,
                  textAlign: TextAlign.center,
                  style: rubik(24),
                ),
                Text(
                  'C.C. ${cedulaConPuntos(Demo.usuario.cedula)}',
                  style: nunito(14, color: Colores.textoSuave),
                ),
                const SizedBox(height: 12),
                Text('completó y aprobó la unidad', style: nunito(14)),
                const SizedBox(height: 4),
                Text(
                  unidad.titulo,
                  textAlign: TextAlign.center,
                  style: rubik(20, color: Colores.verde),
                ),
                Text(unidad.norma, style: nunito(14, peso: FontWeight.w700)),
                const SizedBox(height: 14),
                Text(
                  '${Demo.empresa.nombre} · ${fechaCorta(fecha)}',
                  textAlign: TextAlign.center,
                  style: nunito(13, color: Colores.textoSuave),
                ),
                const SizedBox(height: 4),
                Text(
                  'Código de verificación: ${codigoVerificacion(unidad.id, fecha)}',
                  textAlign: TextAlign.center,
                  style: nunito(12, color: Colores.textoSuave),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.verified, color: Colores.verde, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Queda en tu historial y en el panel del líder HSEQ como '
                  'evidencia para la auditoría.',
                  style: nunito(14, color: Colores.textoSuave),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Boton(texto: 'Cerrar', onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    ),
  ),
);
