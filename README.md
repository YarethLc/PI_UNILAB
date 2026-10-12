# IMPORTANTE

# POR FAVOR, SEGUIR TODOS LOS PASOS PRESENTES EN EL README, SE PUEDE USAR TANTO EN EL NAVEGADOR COMO EN EL ANDROID ESTUDIO, SE USO EL DOCKER PARA QUE TODAS LAS PERSONAS QUE CLONARAN EL REPOSITORIO PUDIERAN CARGAR UNA BASE DE DATOS LOCAL CON UNOS REGISTROS DE PRUEBA CON ROLES DE ADMINISTRADOR Y LABORATORIO, ESTUDIANTE DEBE CREARSE DESDE EL LOGIN COMO UN NUEVO USUARIO. DE IGUAL MANERA SI NO TIENEN INSTALADO EL DOCKER PUEDEN LEVANTAR/ACTIVAR EL BACKEND Y BASE DE  DATOS A BASE DE COMANDOS POR MEDIO DE LA TERMINAL, (SE UTILIZO DOCKER PARA MAYOR FACILIDAD AL ACTIVAR EL BACKEND Y BASE DE DATOS Y TENER MENOS ERRORES, PARA UTILIZAR EL DOCKER HAY UNA SECCION EN EL README DONDE ESPICIFICA COMO ACTIVARLO), TAMBIEN GRACIAS AL DOCKER SE VISUALIZA LAS TABLAS EN EL PGADMIN.




# SAICI - Sistema de Reserva de Espacios Universitarios (UCEVA)

Sistema integral de gestión, control de asistencia y reservas de laboratorios y salas académicas para la **Unidad Central del Valle del Cauca (UCEVA)**.

El proyecto está diseñado bajo una arquitectura desacoplada:
* **Backend:** Node.js, Express, PostgreSQL 16, JSON Web Tokens (JWT) y hashing criptográfico con Bcrypt.
* **Frontend:** Flutter & Dart (aplicación multiplataforma adaptada para Web y Móvil Android).

---

## 🚀 Puesta en Marcha Rápida (Para Nuevos Clones)

Si un compañero clona el repositorio, tiene dos formas de ejecutarlo:

### Opción A: Con Docker (Recomendada para todo el equipo) 🐳
No requiere instalar PostgreSQL ni Node.js manualmente.
1. Clona el repositorio y entra a la carpeta:
   ```bash
   git clone https://github.com/AndresBy02/Front-End_PI
   cd Front-End_PI
   ```
2. Levanta la base de datos (con tablas y horarios automáticos) y el backend con un solo comando:
   ```bash
   docker compose up -d
   ```
   *El backend estará listo y escuchando en:* `http://localhost:3000`

---

# Acceso a la Base de Datos — Proyecto Saici

Este documento explica cómo conectarse a la base de datos PostgreSQL del proyecto
usando **PgAdmin** (interfaz web incluida en Docker) y **TablePlus** (cliente de escritorio).

La diferencia clave está en el **host**:

- **PgAdmin** corre *dentro* de Docker → el host es el **nombre del servicio** (`db`).
- **TablePlus** corre en tu máquina → el host es **`localhost`**.

---

## 1. Datos generales de la BD

| Parámetro        | Valor       |
|------------------|-------------|
| Motor            | PostgreSQL 16 |
| Nombre de la BD  | `saici_db`  |
| Usuario          | `postgres`  |
| Contraseña       | `postgres`  |
| Puerto interno   | `5432`      |

Estos valores se definen en `docker-compose.yml`:

```yaml
environment:
  POSTGRES_DB: saici_db
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: postgres
```

---

## 2. Ingresar desde PgAdmin (navegador)

### 2.1 Abrir PgAdmin

Con los contenedores levantados (`docker compose up -d`), entra desde el navegador a:

```
http://localhost:5050
```

> El enlace también aparece en Docker Desktop al hacer clic en el contenedor `saici-pgadmin`
> (puerto **5050** → 80).

### 2.2 Credenciales de la aplicación PgAdmin

| Campo    | Valor             |
|----------|-------------------|
| Email    | `admin@saici.com` |
| Password | `admin`           |

### 2.3 Registrar el servidor PostgreSQL

Una vez dentro, click derecho en **Servers → Register → Server…** y en la pestaña **Connection** usa:

| Campo                     | Valor        |
|---------------------------|--------------|
| **Host name/address**     | `db`         |
| **Port**                  | `5432`       |
| **Maintenance database**  | `saici_db`   |
| **Username**              | `postgres`   |
| **Password**              | `postgres`   |
| **Save password?**        | ✅ Activado  |

> ⚠️ Importante: en PgAdmin el host es **`db`** (el nombre del servicio en Docker),
> **NO** `localhost`. PgAdmin corre dentro de la misma red Docker que PostgreSQL.

Click en **Save** → la base `saici_db` aparecerá en el panel izquierdo.

---

## 3. Ingresar desde TablePlus (cliente de escritorio)

TablePlus corre **en tu máquina**, no dentro de Docker, por eso usa `localhost`
y el puerto publicado en el `docker-compose.yml` (`5432:5432`).

### 3.1 Crear la conexión

En TablePlus: **Create a new connection → PostgreSQL** y llena:

| Campo     | Valor        |
|-----------|--------------|
| **Name**  | `Saici (Docker)` |
| **Host**  | `localhost`  |
| **Port**  | `5432`       |
| **User**  | `postgres`   |
| **Password** | `postgres` |
| **Database** | `saici_db` |

### 3.2 Configuración SSL

En la pestaña **TLS/SSL**, deja SSL **desactivado** (PostgreSQL en Docker no usa SSL en local).

Click en **Test** → **Connect**.

> ⚠️ En TablePlus el host es **`localhost`** (o `127.0.0.1`), **NO** `db`.
> El nombre `db` solo existe dentro de la red de Docker.

---

## 4. Resumen comparativo

| Parámetro      | PgAdmin (navegador) | TablePlus (escritorio) |
|----------------|---------------------|------------------------|
| Host           | `db`                | `localhost`            |
| Puerto         | `5432`              | `5432`                 |
| Database       | `saici_db`          | `saici_db`             |
| Usuario        | `postgres`          | `postgres`             |
| Contraseña     | `postgres`          | `postgres`             |
| SSL            | N/A                 | Desactivado            |
| URL de acceso  | `http://localhost:5050` | —                  |

---

## 5. URLs del proyecto

| URL                          | Servicio                |
|------------------------------|-------------------------|
| `http://localhost:5050`      | PgAdmin (ver la BD)     |
| `http://localhost:3000`      | Backend / API Saici     |
| `localhost:5432`             | Puerto crudo de Postgres (solo clientes SQL, **no navegador**) |

> 🔴 `http://localhost:5432` **NO abre en el navegador**. PostgreSQL no habla HTTP;
> es un protocolo binario propio. Para verlo en navegador usa PgAdmin (`5050`).

---

## 6. Comandos útiles

```bash
# Levantar todo
docker compose up -d

# Ver contenedores activos
docker ps

# Logs del backend
docker logs saici-backend

# Logs de PgAdmin
docker logs saici-pgadmin

# Entrar a psql desde consola
docker exec -it saici-postgres psql -U postgres -d saici_db

# Reinicio limpio (⚠️ borra datos de la BD)
docker compose down -v
docker compose up -d
```

---

## 7. Solución de problemas

| Problema | Causa | Solución |
|---|---|---|
| PgAdmin no abre en `localhost:5050` | Contenedor caído o puerto ocupado | `docker logs saici-pgadmin`; cambiar a `"5051:80"` |
| Error "password authentication failed" | Credenciales viejas en el volumen | `docker compose down -v` y volver a levantar |
| TablePlus no conecta | Host incorrecto (`db` en vez de `localhost`) | Cambiar host a `localhost` |
| Error SSL en TablePlus | SSL activado | Desactivar SSL en pestaña TLS/SSL |
| `saici_db` no existe | `init.sql` falló o volumen previo | Revisar `docker logs saici-postgres` y limpiar volumen |

### Opción B: Ejecución Local Nativa (Sin Docker) 💻

#### 1. Configurar Base de Datos (PostgreSQL)
1. Abre tu cliente de PostgreSQL (pgAdmin / TablePlus / DBeaver).
2. Crea la base de datos: `saici_db`.
3. Ejecuta el archivo [`BD_Saici.sql`](./BD_Saici.sql) para crear las tablas, usuarios y horarios de atención.

#### 2. Configurar y Levantar el Backend (Node.js)
1. En la raíz del proyecto, copia las variables de entorno:
   ```powershell
   Copy-Item .env.example .env
   ```
2. Instala las dependencias:
   ```powershell
   npm install
   ```
3. Inicia el servidor:
   * **Modo desarrollo (Recomendado):**
     ```powershell
     npm run dev
     ```
     *(Usa `nodemon`: reinicia automáticamente el servidor cada vez que guardas un cambio en el código).*
   * **Modo producción simple:**
     ```powershell
     node src/server.js
     # o
     npm start
     ```
     *(Inicia el servidor directamente sin recarga automática).*

---

## 💻 Cómo Iniciar el Backend desde VS Code (Sin escribir comandos)

1. Abre la carpeta del proyecto en **Visual Studio Code**.
2. En la barra lateral izquierda, abre la pestaña de **NPM Scripts** (o presiona `Ctrl + Shift + P` y escribe `Run Task`).
3. Verás una lista con `dev`, `start`, `test`:
   - Haz clic en el botón de **Play ▶** al lado de **`dev`**.
4. Se abrirá una terminal interna ejecutando el servidor backend automáticamente.

---

## 📱 Ejecutar el Frontend (Flutter & Dart)

Abre una terminal y dirígete a la carpeta de Flutter:
```powershell
cd src/frontend_flutter
flutter pub get
```

### 1. En Navegador Web (Chrome / Edge)
```powershell
flutter run -d chrome
```
*También puedes fijar el puerto si lo deseas:* `flutter run -d chrome --web-port=8080`.

### 2. En Android Studio o Celular Físico
1. Abre la carpeta `src/frontend_flutter` en **Android Studio**.
2. Selecciona tu emulador o tu celular físico conectado por USB.
3. Presiona el botón verde de **Run (Play)** ▶.

> [!NOTE]
> La aplicación detecta automáticamente si corre en Web o en Android. En Android se conecta a la máquina host a través de `http://10.0.2.2:3000/api` y en Web mediante `http://localhost:3000/api`.

---

## 👥 Credenciales de Prueba del Sistema

La base de datos viene precargada con las siguientes cuentas de prueba:

| Rol | Correo Electrónico | Contraseña | Panel Destino |
| :--- | :--- | :--- | :--- |
| **Administrador** | `admin@uceva.edu.co` | `Admin123456!` | Panel Administrativo (`/admin/dashboard`) |
| **Laboratorio** | `laboratorio@uceva.edu.co` | `Lab123456!` | Panel de Encargado (`/lab/dashboard`) |
| **Estudiante / Egresado** | `estudiante.test@uceva.edu.co` | `Estudiante123!` | Panel de Estudiante (`/user/home`) |

*(También puedes registrar un usuario nuevo directamente desde el formulario de **"Regístrate aquí"**).*

---

## ⏰ Horarios de Atención Registrados

| Días | Horario de Apertura y Cierre |
| :--- | :--- |
| **Lunes a Viernes** | 07:00:00 a 22:00:00 |
| **Sábados** | 08:00:00 a 18:00:00 |

---

## 📁 Estructura del Repositorio

```text
Front-End_PI/
├── Dockerfile                   # Configuración para contenerizar el Backend
├── docker-compose.yml           # Orquestación de PostgreSQL + Backend en 1 comando
├── BD_Saici.sql                 # Script DDL/DML (Tablas, Semillas y Horarios)
├── .env.example                 # Plantilla de variables de entorno
├── package.json                 # Dependencias y scripts de Node.js
├── src/
│   ├── app.js                   # Configuración Express y middlewares
│   ├── server.js                # Entrada del servidor HTTP (Puerto 3000)
│   ├── config/db.js             # Pool de conexión a PostgreSQL
│   ├── modules/
│   │   ├── auth/                # Login, registro, perfil, cambio de clave
│   │   ├── reserva/             # Validaciones, horarios y reservas
│   │   └── laboratorios/        # Catálogo de laboratorios y espacios
│   └── frontend_flutter/        # APLICACIÓN FLUTTER MULTIPLATAFORMA
│       ├── pubspec.yaml         # Dependencias Flutter
│       ├── android/             # Configuración nativa Android / Gradle
│       └── lib/
│           ├── main.dart        # Entrada de Flutter
│           ├── services/        # ApiService con conexión dinámica a backend
│           └── screens/
│               ├── auth/        # Login y registro
│               ├── admin/       # Dashboard administrativo y gestión de reservas
│               ├── user/        # Reservas, catálogo y perfil de estudiante
│               └── lab/         # Dashboard del encargado de laboratorio
```
