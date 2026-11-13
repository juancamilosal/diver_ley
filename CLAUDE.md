# Contexto del proyecto Diver_Ley

Resumen para que cualquier sesión nueva sepa en qué va el proyecto. Los
detalles están en `README.md`.

## Proyecto y forma de trabajar

- **App:** Diver_Ley, capacitación HSEQ tipo juego (rachas, XP, ligas)
  para empresas colombianas, en Flutter (Android primero). Cliente: Diego
  (la propuesta original se llamaba también "Norma Lingo").
- **Repositorio:** `juancamilosal/diver_ley`. Se trabaja en la rama
  **`develop`**; `main` queda para los lanzamientos.
- **Idioma:** se responde en español. Textos de la app, código y
  comentarios también en español.
- **Antes de cada commit:** `git pull`, `dart format lib test`,
  `flutter analyze`, `flutter test` y actualizar `README.md`. Luego commit
  y push a `develop`.
- **No crear PR** salvo que se pida.
- Flutter **3.50** (Dart 3.14). La interfaz se importa de
  `package:material_ui/material_ui.dart` (`package:flutter/material.dart`
  está obsoleto desde 3.50). Riverpod 3 y go_router 18.

## Documentos del negocio (artefactos de claude.ai)

- "Diver_Ley — Opinión y análisis de mercado (Colombia)":
  https://claude.ai/artifact/Eg6wudXxwgLgjkUr4oJL22
- "Diver_Ley — Propuesta de negocio" (presentación, con los prototipos de
  pantallas y la paleta de colores): https://claude.ai/artifact/EmEVeU1ikg1CrwmMdyuuMX

Conclusiones clave: venta B2B al líder HSEQ (no app para el ciudadano);
diferencial = norma colombiana + procedimientos propios de la empresa
(PDF → preguntas con IA, revisadas por el líder HSEQ) + evidencia para
auditoría; simulacro de auditoría por cargo; modo sin conexión; cada
pregunta normativa con revisor SST licenciado y fecha de vigencia.

## En qué va

- **13 nov 2026:** demo de la app del trabajador para mostrar al cliente,
  sin servidor (contenido en `assets/contenido/`, avance en el celular).
  Empresa ficticia Constructora Andina S.A.S.; usuario Andrés Gómez,
  supervisor de obra (código `ANDINA`, cédula `1020345678`). Pantallas:
  bienvenida, ruta Aprender, lección (4 tipos de pregunta), simulacro de
  auditoría, liga y perfil con certificados.
- Las preguntas son **de ejemplo**: falta que el profesional SST las valide.
- **Sigue:** Directus como servidor, panel web del líder HSEQ, carga de
  procedimientos con IA, reporte PDF de evidencia, ingreso por invitación.

## Reglas de seguridad

- Nunca pedir ni pegar tokens en el chat ni subirlos al repositorio.
- **Directus: siempre confirmar con el usuario antes de crear, editar o
  eliminar** cualquier cosa. Las consultas de solo lectura están permitidas.
- No subir datos reales de trabajadores ni de clientes al repositorio.

## Detalles técnicos

- Las fuentes Rubik y Nunito Sans son variables: `rubik()` y `nunito()` en
  `lib/tema.dart` aplican el peso también como `FontVariation`.
- `relojProvider` da la hora; las pruebas lo reemplazan para controlar la
  racha. `prefsProvider` se sobrescribe en `main`.
- La racha se pierde si pasa más de un día sin practicar; el simulacro
  también cuenta para la racha.
- Las capturas de la versión web se toman con Playwright: en Flutter web
  hay que activar la accesibilidad (`flt-semantics-placeholder`) para tocar
  por nombre; el avance se siembra en `localStorage` con la clave
  `flutter.progreso`.
