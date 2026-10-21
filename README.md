# LabAcces UCEVA — Frontend (Flutter Web)

Aplicación web del sistema **LabAcces** de la **Unidad Central del Valle del Cauca (UCEVA)** para la
gestión y reserva de laboratorios. Este repositorio, en la rama `frontend`, contiene **únicamente el
proyecto Flutter**; el backend (Node.js + Express + MySQL) vive en otra rama/carpeta del repositorio
(ver `READMEAPI.md` en la rama del backend).

## Contenido del proyecto

```
lib/                      Código fuente (pantallas, widgets, modelos y servicios)
test/                     Pruebas unitarias y de widgets (flutter_test)
web/                      Plantilla web (index.html, manifest.json)
android/                  Proyecto Android (sin local.properties, que es local)
assets/images/            Logos e ilustraciones de la aplicación
pubspec.yaml              Dependencias del proyecto
analysis_options.yaml     Reglas de análisis estático
```

Organización de `lib/`:

- `core/` — colores, rutas y tema de la aplicación.
- `models/` — modelos de datos (espacios, reservas, horarios, usuarios, asistencias).
- `screens/` — pantallas por rol (auth, user, admin, lab).
- `services/` — consumo de la API y manejo de sesión.
- `widgets/` — componentes reutilizables (layout, tarjetas, tablas, footer).

## Requisitos

- Flutter (canal `stable`, SDK de Dart 3.x)
- Chrome o Edge para ejecutar en modo web

Verifica tu instalación con:

```bash
flutter doctor
```

## Ejecutar en local

```bash
flutter pub get
flutter run -d chrome
```

Si necesitas apuntar a un backend distinto, revisa la configuración de la URL base en
`lib/services/api_service.dart`.

## Pruebas y análisis

```bash
flutter analyze
flutter test
```

## Compilar para producción (despliegue web)

```bash
flutter build web --release
```

El resultado queda en `build/web/`, que puede publicarse en cualquier servidor estático
(GitHub Pages, Netlify, Nginx, etc.) o servirse desde el backend.

## Notas

- `android/local.properties` **no** se versiona: se genera automáticamente con `flutter pub get` o
  desde tu IDE según la ruta de tu SDK de Android.
- El backend, las migraciones SQL y los archivos de Docker **no** forman parte de esta rama.
