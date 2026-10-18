# IMPORTANTE

# POR FAVOR, SEGUIR TODOS LOS PASOS PRESENTES EN EL README, SE PUEDE USAR TANTO EN EL NAVEGADOR(USADO PARA HACER PRUEBAS SOLO CON EL ROL DE ESTUDIANTE) COMO EN EL ANDROID ESTUDIO, SE USO EL DOCKER PARA QUE TODAS LAS PERSONAS QUE CLONARAN EL REPOSITORIO PUDIERAN CARGAR UNA BASE DE DATOS LOCAL CON UNOS REGISTROS DE PRUEBA CON ROLES DE ADMINISTRADOR Y LABORATORIO, ESTUDIANTE DEBE CREARSE DESDE EL LOGIN COMO UN NUEVO USUARIO. DE IGUAL MANERA SI NO TIENEN INSTALADO EL DOCKER PUEDEN LEVANTAR/ACTIVAR EL BACKEND Y BASE DE  DATOS A BASE DE COMANDOS POR MEDIO DE LA TERMINAL, (SE UTILIZO DOCKER PARA MAYOR FACILIDAD AL ACTIVAR EL BACKEND Y BASE DE DATOS Y TENER MENOS ERRORES, PARA UTILIZAR EL DOCKER HAY UNA SECCION EN EL README DONDE ESPICIFICA COMO ACTIVARLO), TAMBIEN GRACIAS AL DOCKER SE VISUALIZA LAS TABLAS EN EL PGADMIN.




# LabAcces · Sistema de Reserva de Espacios Universitarios (UCEVA)

Sistema integral para la gestión, control de asistencia y reserva de laboratorios y salas académicas de la **Unidad Central del Valle del Cauca (UCEVA)**.

> **Nota sobre el nombre:** el producto se llama **LabAcces**. Algunos identificadores internos conservan el nombre histórico `saici` (por ejemplo `saici_db`, `saici_token`, `saici_user`); son claves internas y **no deben cambiarse** sin una migración.

---

## 🏗️ Arquitectura

| Capa | Tecnología |
| :--- | :--- |
| **Backend / API REST** | Node.js 18+, Express 5, PostgreSQL 16, JWT, Bcrypt, Nodemailer |
| **Base de datos** | PostgreSQL 16 |
| **Frontend** | Flutter 3.x / Dart 3.x (Web y Android) |
| **Infraestructura local** | Docker + Docker Compose (PostgreSQL + Backend + pgAdmin) |

```text
Flutter (Web / Android)
        │  HTTP + JWT
        ▼
Backend Node/Express :3000
        │  SQL
        ▼
PostgreSQL 16 :5432  ◄── pgAdmin :5050 (opcional)
```

---

## ✨ Funcionalidades

- **Autenticación:** login, registro de estudiantes/egresados, recuperación de contraseña con código OTP y cambio de clave.
- **Panel de estudiante:** inicio, catálogo de laboratorios, asistente de reserva, mis reservas, historial y perfil.
- **Panel administrativo:** dashboard con KPIs, gestión de reservas, CRUD de espacios, horarios, usuarios y **estadísticas con gráficos de pastel y barras**.
- **Panel de encargado de laboratorio:** reservas asignadas y aprobación de solicitudes.
- **Horarios:** franjas por día, activables/desactivables, **globales o asociadas a un laboratorio específico**.
- **Validaciones de reserva:** fecha no pasada, horario permitido, cupo por laboratorio, cruces de horario del usuario y estado del laboratorio.

---

## ✅ Requisitos e Instalación de Herramientas

| Herramienta | Versión recomendada | ¿Para qué se necesita? | ¿Obligatoria? |
| :--- | :--- | :--- | :--- |
| **Git** | 2.40+ | Clonar el repositorio | Sí |
| **Docker Desktop** | 4.x+ (Docker 24+) | Levantar backend + PostgreSQL + pgAdmin | Recomendada |
| **Node.js** | 18+ (probado con 24) | Ejecutar el backend sin Docker | Solo opción nativa |
| **PostgreSQL** | 16 | BD sin Docker | Solo opción nativa |
| **Flutter SDK** | 3.x estable (probado con 3.47.7 / Dart 3.13.5) | Compilar y ejecutar el frontend | Sí |
| **Chrome o Edge** | Última versión | Ejecutar el frontend en Web | Sí (equipo web) |
| **Android Studio** | Hedgehog+ con SDK 34+ | Emulador y compilación Android | Opcional |
| **VS Code** (opcional) | Última versión | Editar código y scripts NPM | Opcional |

### Verificar que todo esté instalado

```powershell
git --version
docker --version
docker compose version
node --version
npm --version
flutter --version
flutter doctor
```

`flutter doctor` debe mostrar al menos **Flutter**, **Chrome** y, si usarás Android, **Android toolchain** en verde.

### Instalar Flutter en Windows (si no lo tienes)

Opción 1 (winget):

```powershell
winget install Google.Flutter
```

Opción 2 (manual):

1. Descarga el SDK: <https://docs.flutter.dev/get-started/install/windows>
2. Descomprímelo en una ruta sin espacios, por ejemplo `C:\src\flutter`.
3. Agrega `C:\src\flutter\bin` al **PATH** de Windows.
4. Cierra y abre la terminal, luego:

```powershell
flutter doctor
flutter doctor --android-licenses   # solo si usarás Android
```

---

## 🚀 Puesta en Marcha para un Clon Nuevo (Docker, recomendado)

No requiere instalar Node.js ni PostgreSQL manualmente.

### 1. Clonar el repositorio

```powershell
git clone https://github.com/YarethLc/PI_UNILAB.git
cd PI_UNILAB
```

### 2. Levantar los servicios

```powershell
docker compose up -d --build
```

Esto crea y arranca:

| Servicio | Contenedor | URL / Puerto |
| :--- | :--- | :--- |
| Backend / API | `saici-backend` | `http://localhost:3000` |
| PostgreSQL 16 | `saici-postgres` | `localhost:5432` |
| pgAdmin 4 | `saici-pgadmin` | `http://localhost:5050` |

La primera vez, PostgreSQL ejecuta automáticamente `BD_Saici.sql` (tablas, usuarios y horarios de prueba).

### 3. Verificar que el backend responde

```powershell
Invoke-WebRequest http://localhost:3000 -UseBasicParsing | Select-Object -ExpandProperty Content
```

Debe responder:

```json
{"mensaje":"API de reservas funcionando correctamente"}
```

### 4. Levantar el frontend

```powershell
cd src/frontend_flutter
flutter pub get
flutter run -d chrome
```

---

## 🔄 Si Ya Tenías el Proyecto Clonado (Actualización Obligatoria)

Si ya descargaste el proyecto antes y vas a usar la versión actualizada (por ejemplo, por los cambios de horarios, gráficos o backend), **no basta con `docker compose up -d`**. Debes bajar los contenedores y volver a levantarlos para reconstruir la imagen del backend:

```powershell
# 1. Ubicarte en la carpeta del proyecto
cd PI_UNILAB

# 2. Bajar los contenedores (conserva los datos de PostgreSQL)
docker compose down

# 3. Volver a levantar y reconstruir las imágenes
docker compose up -d --build
```

> ⚠️ **Importante:** al bajar y volver a crear los contenedores, **pgAdmin pierde el servidor registrado** (su configuración no está en un volumen persistente). Por eso, después de levantarlo de nuevo debes **volver a agregar la base de datos en pgAdmin web**:
>
> 1. Abre <http://localhost:5050> e inicia sesión con `admin@saici.com` / `admin`.
> 2. Clic derecho en **Servers → Register → Server…**
> 3. En la pestaña **Connection** usa:
>    - **Host name/address:** `db`
>    - **Port:** `5432`
>    - **Maintenance database:** `saici_db`
>    - **Username:** `postgres`
>    - **Password:** `postgres`
> 4. Clic en **Save**.

Si además quieres **reiniciar la base de datos desde cero** (⚠️ **borra todos los datos** y vuelve a ejecutar `BD_Saici.sql`):

```powershell
docker compose down -v
docker compose up -d --build
```

### Aplicar migraciones si conservaste una base anterior

Si hiciste `docker compose down` (sin `-v`), tus datos se conservan, pero debes aplicar las migraciones nuevas:

```powershell
docker exec -i saici-postgres psql -U postgres -d saici_db < migrations/001_horario_activo.sql
docker exec -i saici-postgres psql -U postgres -d saici_db < migrations/002_horario_laboratorio.sql
```

> Las migraciones usan `IF NOT EXISTS`, así que se pueden ejecutar varias veces sin problema.

### Actualizar el frontend

```powershell
cd src/frontend_flutter
flutter pub get
flutter clean          # recomendado si hubo errores de compilación
flutter run -d chrome
```

### ⚠️ Regla importante al modificar el backend

El código del backend se **copia dentro de la imagen** de Docker. Cada vez que cambie algo en `src/modules/`, `src/app.js`, `src/server.js`, etc., reconstruye:

```powershell
docker compose up -d --build backend
```

Si solo cambia el frontend Flutter, **no** hace falta reconstruir Docker; basta con hot reload / hot restart.

---

## 💻 Opción B — Ejecución Local Nativa (sin Docker)

### 1. Base de datos

1. Instala PostgreSQL 16 y crea la base de datos `saici_db`.
2. Ejecuta el script [`BD_Saici.sql`](./BD_Saici.sql) sobre esa base.
3. Si la base ya existía, aplica las migraciones pendientes (ver sección **Migraciones**).

### 2. Backend

En la raíz del proyecto:

```powershell
Copy-Item .env.example .env
npm install
npm run dev
```

- `npm run dev` → modo desarrollo con `nodemon` (recarga automática).
- `npm start` → modo normal (`node src/server.js`).

Variables de `.env`:

```env
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=saici_db
DB_USER=postgres
DB_PASSWORD=postgres
JWT_SECRET=saici_super_secret_jwt_token_2026_uceva
EMAIL_USER=soporte@uceva.edu.co
EMAIL_PASS=tu_clave_de_aplicacion
```

> Si usas Docker y un backend nativo al mismo tiempo, cambia `PORT` o detén uno de los dos para evitar conflictos en el puerto 3000.

#### Iniciar el backend desde VS Code (sin escribir comandos)

1. Abre la carpeta del proyecto en **Visual Studio Code**.
2. En la barra lateral abre **NPM Scripts** (o `Ctrl + Shift + P` → **Run Task**).
3. Pulsa **▶** en `dev`.
4. Se abre una terminal interna con el backend en ejecución y recarga automática.

### 3. Frontend

```powershell
cd src/frontend_flutter
flutter pub get
flutter run -d chrome
```

---

## 📱 Ejecutar el Frontend Flutter

La conexión al backend se define en [`lib/services/api_service.dart`](./src/frontend_flutter/lib/services/api_service.dart):

| Entorno | URL usada automáticamente |
| :--- | :--- |
| Web (Chrome / Edge) | `http://localhost:3000/api` |
| Emulador Android | `http://10.0.2.2:3000/api` (IP del host vista desde el emulador) |
| Celular físico | Requiere cambiar a la **IP LAN del PC** (ver abajo) |

### Web

```powershell
cd src/frontend_flutter
flutter run -d chrome
# Puerto fijo opcional:
flutter run -d chrome --web-port=8080
```

### Emulador Android

1. Abre Android Studio → **Device Manager** → inicia un emulador.
2. Verifica que Flutter lo detecte:

```powershell
flutter devices
flutter run -d emulator-5554
```

### Celular físico (USB)

1. Activa **Opciones de desarrollador** y **Depuración USB**.
2. Conecta el celular y acepta la autorización.
3. El celular y el PC deben estar en la **misma red Wi-Fi**.
4. Obtén la IP del PC:

```powershell
ipconfig
```

5. En `api_service.dart`, reemplaza la URL de Android por la IP LAN, por ejemplo:

```dart
return 'http://192.168.1.50:3000/api';
```

6. El backend ya permite conexiones externas (`cors: *`), pero verifica el Firewall de Windows si no conecta.

### Compilar para producción (Web)

```powershell
cd src/frontend_flutter
flutter build web
```

El resultado queda en `build/web`. Para probarlo localmente:

```powershell
python -m http.server 8090 --directory build/web
# Abrir http://localhost:8090
```

> Para producción, cambia `baseUrl` en `api_service.dart` por el dominio real del backend (HTTPS).

---

## 🗄️ Acceso a la Base de Datos

### Datos generales

| Parámetro | Valor |
| :--- | :--- |
| Motor | PostgreSQL 16 |
| Base de datos | `saici_db` |
| Usuario | `postgres` |
| Contraseña | `postgres` |
| Puerto | `5432` |

### pgAdmin (navegador)

1. Abre <http://localhost:5050>.
2. Inicia sesión con:
   - **Email:** `admin@saici.com`
   - **Password:** `admin`
3. Clic derecho en **Servers → Register → Server…** y en la pestaña **Connection**:

| Campo | Valor |
| :--- | :--- |
| Host name/address | `db` |
| Port | `5432` |
| Maintenance database | `saici_db` |
| Username | `postgres` |
| Password | `postgres` |

> ⚠️ En pgAdmin el host es **`db`** porque corre dentro de la red Docker. **No** uses `localhost` ahí.

### TablePlus / DBeaver / cliente de escritorio

Estos clientes corren **en tu máquina**, no dentro de Docker, por eso usan `localhost` y el puerto publicado (`5432:5432`).

**TablePlus:** *Create a new connection → PostgreSQL* y completa:

| Campo | Valor |
| :--- | :--- |
| Name | `LabAcces (Docker)` |
| Host | `localhost` (o `127.0.0.1`) |
| Port | `5432` |
| User | `postgres` |
| Password | `postgres` |
| Database | `saici_db` |
| SSL | Desactivado (pestaña **TLS/SSL**) |

Pulsa **Test** y luego **Connect**.

> ⚠️ En clientes de escritorio el host es **`localhost`**; el nombre `db` solo existe dentro de Docker.

> 🔴 `http://localhost:5432` **no abre en el navegador**: PostgreSQL usa un protocolo binario propio, no HTTP. Para verlo en el navegador entra a pgAdmin (`http://localhost:5050`); para consultarlo por consola usa `psql` o un cliente SQL.

### Resumen comparativo de conexión

| Parámetro | pgAdmin (navegador) | TablePlus / DBeaver (escritorio) |
| :--- | :--- | :--- |
| Host | `db` | `localhost` / `127.0.0.1` |
| Puerto | `5432` | `5432` |
| Base de datos | `saici_db` | `saici_db` |
| Usuario | `postgres` | `postgres` |
| Contraseña | `postgres` | `postgres` |
| SSL | N/A | Desactivado |

### URLs del proyecto

| URL | Servicio |
| :--- | :--- |
| `http://localhost:3000` | Backend / API |
| `http://localhost:5050` | pgAdmin (ver la BD en el navegador) |
| `localhost:5432` | Puerto de PostgreSQL (solo clientes SQL, **no navegador**) |


### Migraciones

| Migración | Qué agrega |
| :--- | :--- |
| `001_horario_activo.sql` | Columna `activo` en `horario` y domingo desactivado |
| `002_horario_laboratorio.sql` | Columna `id_laboratorio` en `horario` (franjas por laboratorio) |

```powershell
# Con psql local
psql -U postgres -d saici_db -f migrations/001_horario_activo.sql
psql -U postgres -d saici_db -f migrations/002_horario_laboratorio.sql

# Con Docker
docker exec -i saici-postgres psql -U postgres -d saici_db < migrations/001_horario_activo.sql
docker exec -i saici-postgres psql -U postgres -d saici_db < migrations/002_horario_laboratorio.sql
```

> Las migraciones usan `IF NOT EXISTS`, por lo que son seguras de re-ejecutar.

---

## 👥 Credenciales de Prueba

| Rol | Correo | Contraseña | Panel |
| :--- | :--- | :--- | :--- |
| **Administrador** | `admin@uceva.edu.co` | `Admin123456!` | `/admin/dashboard` |
| **Encargado de laboratorio** | `laboratorio@uceva.edu.co` | `Lab123456!` | `/lab/dashboard` |
| **Estudiante** | `estudiante.test@uceva.edu.co` | `Estudiante123!` | `/user/home` |

También puedes registrar un usuario nuevo desde **“Regístrate aquí”** en el login.

### Roles del sistema

- `ADMINISTRADOR` → acceso total (reservas, espacios, horarios, usuarios, reportes).
- `LABORATORIO` → reservas asignadas y aprobación.
- `USUARIO` + `tipo_usuario` (`ESTUDIANTE` / `EGRESADO`) → catálogo, reservas, historial y perfil.

---

## ⏰ Horarios y Franjas

Por defecto:

| Días | Horario |
| :--- | :--- |
| Lunes a Viernes | 07:00 – 22:00 |
| Sábados | 08:00 – 18:00 |
| Domingos | Desactivado (franja 08:00 – 14:00, apagada) |

En **Administración → Configurar Horarios** puedes:

- Crear una franja **para todos los laboratorios** (global).
- Crear una franja **para un laboratorio específico**.
- Filtrar la tabla por laboratorio.
- Activar/desactivar cada franja.

**Prioridad de validación:** si un laboratorio tiene una franja propia para ese día, se usa esa; si no, se aplica la franja global.

---

## 🔌 Endpoints Principales de la API

Todas las rutas (excepto login/registro/recuperación) requieren `Authorization: Bearer <token>`.

### Autenticación — `/api/auth`

| Método | Ruta | Descripción |
| :--- | :--- | :--- |
| POST | `/register` · `/registro` | Registrar usuario |
| POST | `/login` | Iniciar sesión (devuelve JWT + usuario) |
| POST | `/recuperar-password` | Enviar código OTP |
| POST | `/verificar-codigo` | Validar OTP |
| POST | `/nueva-password` | Cambiar contraseña con OTP |
| GET | `/perfil` | Datos del usuario autenticado |
| PUT | `/perfil` | Actualizar perfil |
| PUT | `/cambiar-password` | Cambiar contraseña |
| GET | `/usuarios` | Listar usuarios (solo ADMINISTRADOR) |

### Reservas — `/api/reservas`

| Método | Ruta | Descripción |
| :--- | :--- | :--- |
| POST | `/` | Crear reserva |
| GET | `/` | Listar (propias o todas según rol) |
| GET | `/:id` | Detalle |
| PUT | `/:id` | Editar |
| DELETE | `/:id` | Cancelar |
| PATCH | `/:id/estado` | Aprobar / finalizar (ADMIN o LAB) |

### Laboratorios — `/api/laboratorios`

| Método | Ruta | Descripción |
| :--- | :--- | :--- |
| GET | `/` · `/:id` | Consultar |
| POST | `/` | Crear (ADMIN o LAB) |
| PUT | `/:id` | Editar (ADMIN o LAB) |
| DELETE | `/:id` | Eliminar (solo ADMIN) |

### Horarios — `/api/horarios`

| Método | Ruta | Descripción |
| :--- | :--- | :--- |
| GET | `/` · `/?id_laboratorio=1` | Listar (opcionalmente filtrado) |
| POST | `/` | Crear franja (solo ADMIN) |
| PATCH | `/:id/estado` | Activar/desactivar (solo ADMIN) |

---

## 🧪 Pruebas y Calidad

```powershell
# Backend: verificación de seguridad y roles (requiere BD y backend activos)
npm test

# Frontend: análisis estático
cd src/frontend_flutter
flutter analyze

# Frontend: pruebas
flutter test
```

---

## 🧰 Comandos Útiles

```powershell
# Levantar todo (primera vez o tras cambios de backend)
docker compose up -d --build

# Reconstruir solo el backend tras cambiar código
docker compose up -d --build backend

# Bajar los contenedores (conserva los datos de PostgreSQL)
docker compose down

# Reinicio limpio (⚠️ BORRA todos los datos de la BD)
docker compose down -v
docker compose up -d --build

# Ver contenedores
docker ps

# Logs del backend (seguimiento en vivo)
docker logs -f saici-backend

# Logs de PostgreSQL
docker logs saici-postgres

# Logs de pgAdmin
docker logs saici-pgadmin

# Entrar a psql
docker exec -it saici-postgres psql -U postgres -d saici_db

# Flutter
cd src/frontend_flutter
flutter pub get
flutter clean          # si hay errores raros de compilación
flutter run -d chrome
flutter build web
```

---

## 🆘 Solución de Problemas

| Problema | Causa probable | Solución |
| :--- | :--- | :--- |
| `fflutter` / `flutter` no se reconoce | Error de escritura o PATH | Escribe `flutter`. Agrega `C:\...\flutter\bin` al PATH y reinicia la terminal |
| `Failed to compile application` en Flutter | Error de Dart | Ejecuta `flutter analyze` y corrige el archivo indicado |
| Pantalla en blanco tras iniciar sesión | Error de layout/excepción | Detén y vuelve a ejecutar (no solo hot reload); revisa la consola del navegador |
| El footer ocupa toda la pantalla / no aparece | Botón con `minimumSize` infinito dentro de un `Row` | Revisar `custom_footer.dart` (ya corregido: `minimumSize: Size(0, 40)`) |
| `A ScrollController is required when Scrollbar.thumbVisibility is true` | `Scrollbar` con `thumbVisibility` sin controlador | Pasa el mismo `ScrollController` al `Scrollbar` y al scroll |
| El backend no refleja cambios | Imagen Docker antigua | `docker compose up -d --build backend` |
| pgAdmin aparece vacío tras reiniciar contenedores | pgAdmin perdió el servidor registrado | Volver a registrarlo: host `db`, puerto `5432`, base `saici_db` |
| `401 No autorizado` | Token vencido o sesión inválida | Cerrar sesión y volver a iniciar |
| `Recurso no encontrado` en horarios | Backend/imagen sin el módulo de horarios | Reconstruir backend y verificar `/api/horarios` |
| `connection refused` en Web | Backend apagado o puerto ocupado | `docker ps`; revisar `docker logs saici-backend`; liberar el puerto 3000 |
| `connection refused` en celular físico | Usa `localhost` o IP incorrecta | Cambiar `baseUrl` a la IP LAN del PC y estar en la misma red |
| pgAdmin no conecta a la BD | Host incorrecto | Usar `db` en pgAdmin y `localhost` en clientes de escritorio |
| `password authentication failed` | Volumen con credenciales antiguas | `docker compose down -v` y volver a levantar (⚠️ borra datos) |
| La BD no tiene `id_laboratorio` en `horario` | Falta migración | Aplicar `migrations/002_horario_laboratorio.sql` |
| Emulador Android en negro desde el arranque | Problema gráfico del emulador/Impeller | Cold Boot del AVD, Graphics = Software GLES 2.0, o `flutter run --no-enable-impeller` |
| Error de CORS | Backend no iniciado o proxy | El backend ya permite `*`; verifica que la API responda en `:3000` |
| Puerto 3000/5050/5432 ocupado | Otro proceso o contenedor | `docker compose down`, cerrar el proceso o cambiar el puerto en `docker-compose.yml` |

---

## 📁 Estructura del Repositorio

```text
PI_UNILAB/
├── Dockerfile                          # Imagen del backend (Node 18 Alpine)
├── docker-compose.yml                  # PostgreSQL + Backend + pgAdmin
├── BD_Saici.sql                        # Esquema, usuarios, laboratorios y horarios
├── package.json                        # Scripts y dependencias del backend
├── package-lock.json
├── .env.example                        # Plantilla de variables de entorno
├── .gitignore
├── README.md
├── migrations/
│   ├── 001_horario_activo.sql
│   └── 002_horario_laboratorio.sql
├── test/
│   └── verify_security_and_roles.js    # Pruebas de seguridad y roles
├── .github/                            # Configuración de GitHub (modernize)
├── .vscode/
│   └── launch.json
└── src/
    ├── app.js                          # Express, CORS y montaje de rutas
    ├── server.js                       # Arranque HTTP (puerto 3000)
    ├── config/
    │   └── db.js                       # Pool de conexión a PostgreSQL
    ├── middlewares/
    │   └── authMiddleware.js           # verificarToken y autorizarRoles
    ├── utils/
    │   └── generarOTP.js               # Generación de códigos de recuperación
    ├── modules/
    │   ├── auth/
    │   │   ├── authController.js
    │   │   ├── authRoutes.js
    │   │   └── emailService.js
    │   ├── reserva/
    │   │   ├── reservaController.js
    │   │   ├── reservaRoutes.js
    │   │   └── reservaService.js
    │   ├── laboratorios/
    │   │   ├── laboratorioController.js
    │   │   └── laboratorioRoutes.js
    │   └── horarios/
    │       ├── horarioController.js
    │       └── horarioRoutes.js
    └── frontend_flutter/               # Aplicación Flutter (Web y Android)
        ├── pubspec.yaml
        ├── android/                    # Configuración nativa Android/Gradle
        ├── web/                        # index.html y assets web
        ├── assets/
        │   └── images/                 # Logos y banner institucional
        ├── test/
        └── lib/
            ├── main.dart
            ├── core/
            │   ├── constants/app_colors.dart
            │   ├── routes/app_routes.dart
            │   └── theme/app_theme.dart
            ├── models/
            │   ├── attendance_model.dart
            │   ├── reservation_model.dart
            │   ├── schedule_model.dart
            │   ├── space_model.dart
            │   └── user_model.dart
            ├── services/
            │   ├── api_service.dart
            │   └── auth_session_service.dart
            ├── widgets/
            │   ├── app_layout.dart
            │   ├── app_page_scroll_view.dart
            │   ├── custom_footer.dart
            │   ├── custom_text_field.dart
            │   ├── horizontal_table_scroll.dart
            │   ├── reservation_card.dart
            │   ├── simple_charts.dart
            │   ├── space_card.dart
            │   └── status_badge.dart
            └── screens/
                ├── auth/
                │   ├── login_screen.dart
                │   ├── register_egresado_screen.dart
                │   ├── forgot_password_screen.dart
                │   ├── otp_verification_screen.dart
                │   └── reset_password_screen.dart
                ├── admin/
                │   ├── admin_dashboard_screen.dart
                │   ├── manage_reservations_screen.dart
                │   ├── manage_spaces_screen.dart
                │   ├── manage_schedules_screen.dart
                │   ├── manage_users_screen.dart
                │   └── reports_screen.dart
                ├── user/
                │   ├── user_home_screen.dart
                │   ├── explore_spaces_screen.dart
                │   ├── space_detail_screen.dart
                │   ├── reservation_wizard_screen.dart
                │   ├── my_reservations_screen.dart
                │   ├── reservation_history_screen.dart
                │   ├── attendance_screen.dart
                │   └── profile_screen.dart
                └── lab/
                    ├── lab_dashboard_screen.dart
                    └── lab_reservations_screen.dart
```

> Las carpetas `build/`, `.dart_tool/` y `.idea/` se generan automáticamente al compilar o abrir el proyecto; no forman parte del código fuente y están excluidas por `.gitignore`.

---

## 🤝 Flujo de Trabajo Recomendado

1. Crea una rama por funcionalidad: `git checkout -b feature/mi-cambio`.
2. Haz cambios pequeños y verifica:
   ```powershell
   flutter analyze
   npm test
   ```
3. Haz commit con un mensaje claro:
   ```powershell
   git add .
   git commit -m "feat: descripción del cambio"
   ```
4. Sube la rama y abre un Pull Request.

> Evita cambiar de rama con cambios sin commitear: es la causa más común de perder trabajo.
