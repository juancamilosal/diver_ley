import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../datos/demo.dart';
import '../providers.dart';
import '../tema.dart';
import '../widgets/boton.dart';
import '../widgets/logo.dart';

/// Ingreso con el código de la empresa y la cédula.
///
/// Los operarios no siempre tienen correo corporativo: la empresa los invita
/// con un código y cada uno entra con su cédula.
class PantallaBienvenida extends ConsumerStatefulWidget {
  const PantallaBienvenida({super.key});

  @override
  ConsumerState<PantallaBienvenida> createState() => _PantallaBienvenidaState();
}

class _PantallaBienvenidaState extends ConsumerState<PantallaBienvenida> {
  final _codigo = TextEditingController(text: Demo.empresa.codigo);
  final _cedula = TextEditingController(text: Demo.usuario.cedula);

  @override
  void dispose() {
    _codigo.dispose();
    _cedula.dispose();
    super.dispose();
  }

  void _ingresar() {
    final codigo = _codigo.text.trim().toUpperCase();
    final cedula = _cedula.text.replaceAll(RegExp(r'\D'), '');
    if (codigo != Demo.empresa.codigo || cedula != Demo.usuario.cedula) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'En la demo usa el código ${Demo.empresa.codigo} y la cédula '
            '${Demo.usuario.cedula}.',
          ),
        ),
      );
      return;
    }
    ref.read(progresoProvider.notifier).iniciarSesion();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colores.navy,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: LogoDiverLey(tamano: 88)),
                const SizedBox(height: 20),
                Text(
                  'Diver_Ley',
                  textAlign: TextAlign.center,
                  style: rubik(40, color: Colores.crema),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cinco minutos al día para llegar preparado a la auditoría.',
                  textAlign: TextAlign.center,
                  style: nunito(18, color: const Color(0xFFC9D3E3), alto: 1.35),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colores.crema,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Ingresa con tu empresa', style: rubik(20)),
                      const SizedBox(height: 4),
                      Text(
                        'Tu líder HSEQ te comparte el código de la empresa.',
                        style: nunito(15, color: Colores.textoSuave),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _codigo,
                        textCapitalization: TextCapitalization.characters,
                        style: nunito(17, peso: FontWeight.w700),
                        decoration: const InputDecoration(
                          labelText: 'Código de la empresa',
                          prefixIcon: Icon(Icons.apartment),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _cedula,
                        keyboardType: TextInputType.number,
                        style: nunito(17, peso: FontWeight.w700),
                        decoration: const InputDecoration(
                          labelText: 'Número de cédula',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        onSubmitted: (_) => _ingresar(),
                      ),
                      const SizedBox(height: 24),
                      Boton(texto: 'Ingresar', onPressed: _ingresar),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Demo con datos de ejemplo de una empresa ficticia.',
                  textAlign: TextAlign.center,
                  style: nunito(14, color: const Color(0xFF9AA8BF)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
