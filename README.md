# Diver_Ley

Capacitación HSEQ (Seguridad y Salud en el Trabajo, Calidad y Medio
Ambiente) con la mecánica de las apps de idiomas: lecciones cortas, rachas,
XP y ligas. Se vende a empresas (B2B): el trabajador aprende la norma
colombiana y los procedimientos de su empresa en cinco minutos al día, y el
líder HSEQ tiene la evidencia de capacitación lista para el auditor.

## Estado: demo para el cliente

Esta versión es una **demo de la app del trabajador**, sin servidor:

- Empresa ficticia **Constructora Andina S.A.S.** y un supervisor de obra,
  Andrés Gómez, que arranca con 12 días de racha y la primera unidad
  completa (así la ruta se ve en uso).
- Ingreso con el código de la empresa (`ANDINA`) y la cédula
  (`1020345678`); ya vienen escritos.
- Todo el contenido está dentro de la app, así que **funciona sin
  conexión**. El avance se guarda en el celular (`shared_preferences`).
- **Las preguntas son de ejemplo.** Antes de usarlas con trabajadores, un
  profesional SST con licencia las revisa y les pone fecha de vigencia.

## Lo que muestra la demo

| Pantalla | Qué hace |
| --- | --- |
| Bienvenida | Ingreso con código de empresa y cédula (los operarios no siempre tienen correo). |
| Aprender | Ruta por unidades con lecciones en camino, racha, XP y meta diaria de 30 XP. Cada unidad termina en un certificado. La guía de cada unidad muestra la norma; en los procedimientos propios, el documento, quién lo aprobó y que las preguntas se generaron con IA. |
| Lección | 5 preguntas de 4 tipos: elegir, verdadero o falso, completar la frase y ordenar pasos. Cada respuesta muestra la explicación y la norma que la sustenta; las falladas vuelven al final. Al terminar: XP, precisión, racha y meta del día. |
| Simulacro | Preguntas de auditor según el cargo (operario, supervisor de obra, coordinador HSEQ): 8 preguntas, 4 minutos, sin pistas. Resultado con puntaje (Preparado ≥ 85 %, Por reforzar ≥ 60 %, Crítico), aciertos por tema con "Repasar" y la revisión de cada respuesta. Queda guardado como evidencia. |
| Liga | Liga semanal del área (los 3 primeros suben) y "Por áreas": porcentaje del personal al día en cada área. |
| Perfil | Racha, XP, lecciones, precisión, certificados, historial de simulacros y opciones de la demo: desbloquear todas las lecciones, reiniciar la demo y cerrar sesión. |

### Contenido de ejemplo

7 unidades, 14 lecciones (70 preguntas) y 22 preguntas de simulacro:

1. Fundamentos del SG-SST (Decreto 1072 de 2015)
2. Estándares mínimos (Res. 0312 de 2019)
3. Trabajo en alturas (Res. 4272 de 2021)
4. Plan de emergencias Torre Norte: **procedimiento propio** de la empresa
   ficticia (PR-SST-004)
5. Accidentes e incidentes (Res. 1401 de 2007)
6. Gestión ambiental en obra (Res. 2184 de 2019)
7. Calidad ISO 9001

## Cómo correrla

Necesita **Flutter 3.50 o superior** (Dart 3.14): la app usa el paquete
`material_ui`, que reemplaza a `package:flutter/material.dart` desde
Flutter 3.50.

```bash
flutter pub get
```

```bash
flutter run
```

APK para instalar en el celular del cliente (queda en
`build/app/outputs/flutter-apk/app-release.apk`; se firma con la llave de
depuración, suficiente para la demo):

```bash
flutter build apk --release
```

### Instalar la demo en un celular

**Android:** instalar el APK (`flutter build apk --release`). Al abrirlo,
Android pide permitir "instalar apps desconocidas" y Play Protect puede
avisar que no viene de Play Store ("Instalar de todas formas"). Con el
celular conectado por USB y la depuración USB activa también sirve
`flutter run --release`.

**iPhone:** se compila en un Mac con Xcode (en Linux o Windows no se puede):

1. `flutter pub get` y abrir `ios/Runner.xcworkspace` en Xcode.
2. En *Runner → Signing & Capabilities*, elegir el equipo (un Apple ID
   gratis sirve) y, si Xcode lo pide, cambiar el *Bundle Identifier*
   (hoy `com.valkiriacode.diverLey`).
3. Conectar el iPhone, activar el Modo de desarrollador (*Ajustes →
   Privacidad y seguridad*) y correr `flutter run --release`.
4. En el iPhone, confiar en el desarrollador (*Ajustes → General → VPN y
   gestión de dispositivos*).

Con un Apple ID gratis la app deja de abrir a los 7 días y hay que volver a
instalarla. Para entregarla al cliente sin cable se usa TestFlight, que
necesita la cuenta de Apple Developer (US$ 99 al año).

Versión web (sirve para mostrarla en un computador):

```bash
flutter build web --no-web-resources-cdn
```

Antes de cada commit:

```bash
dart format lib test
```

```bash
flutter analyze
```

```bash
flutter test
```

## Estructura

```
assets/contenido/unidades.json   Unidades, lecciones y preguntas
assets/contenido/simulacro.json  Cargos y preguntas del simulacro
assets/fonts/                    Rubik y Nunito Sans (licencia OFL)
lib/modelos/                     Contenido y progreso
lib/datos/                       Datos de la demo y carga del contenido
lib/logica/                      Sesión de lección, simulacro, ruta y fechas
lib/pantallas/                   Pantallas
lib/widgets/                     Botón, tarjeta, certificado, estado, logo
lib/providers.dart               Estado con Riverpod
lib/tema.dart                    Colores y fuentes de la marca
```

- Riverpod 3 para el estado y go_router con `StatefulShellRoute` para la
  barra de abajo.
- `RepositorioContenido` separa de dónde sale el contenido: hoy
  `ContenidoLocal` (archivos de la app); después, una versión que lo
  descargue de Directus y lo guarde para usarlo sin conexión.
- Los JSON de `assets/contenido/` tienen la forma que tendrán las
  colecciones de Directus.

### Agregar preguntas

Cada pregunta lleva `id`, `tipo`, `enunciado`, `explicacion` y `fuente`
(norma y artículo). Según el tipo:

- `opcion` y `completar`: `opciones` y `correcta` (índice). En `completar`
  el enunciado lleva `___` donde va la palabra.
- `vf`: `respuesta` (`true` o `false`).
- `ordenar`: `pasos`, en el orden correcto (la app los revuelve).

Las opciones se revuelven al mostrarse (menos en verdadero o falso). La
prueba `test/contenido_test.dart` revisa que cada lección tenga 5
preguntas, que los ids no se repitan y que cada pregunta tenga respuesta
válida, explicación y fuente.

## Lo que sigue después de la demo

- Servidor en **Directus**: empresas, sedes, áreas, cargos, personas y
  contratistas; contenido con revisor y fecha de vigencia por pregunta.
- **Panel del líder HSEQ** (web): avance por área, sede y contratista,
  brechas y reporte PDF de evidencia generado en el servidor.
- **Procedimientos con IA:** la empresa sube el PDF, la IA propone
  preguntas y el líder HSEQ las aprueba antes de publicarlas.
- Ingreso real por invitación (QR o enlace) con código por SMS o WhatsApp.
- Recordatorios por notificación o WhatsApp.
- Datos personales según la Ley 1581 de 2012 (política de tratamiento y
  contrato de encargo con cada cliente).
