# UniLab – SAICI

Sistema de reserva de espacios (laboratorios y biblioteca) de la UCEVA para egresados y estudiantes de Ingeniería de Sistemas.

Proyecto Integrador · Semestre VI · Periodo 2026-2 · Asignatura líder: Ingeniería de Software I.

---

## ¿Qué es este proyecto?

Una aplicación multiplataforma, desarrollada con la metodología ágil SCRUM, que permite:

- Registrarse e iniciar sesión.
- Recuperar la contraseña mediante un código enviado al correo.
- Consultar laboratorios y su disponibilidad.
- Reservar, editar y cancelar espacios.
- Que la administración gestione laboratorios y consulte las reservas.

**Por qué existe:** muchos egresados trabajan en remoto y necesitan espacios alternativos. La universidad tiene laboratorios que pueden servir para eso, pero no existía una herramienta para gestionar su disponibilidad, sus reservas ni su uso. El proyecto resuelve ese vacío y acerca de nuevo a los egresados al campus.

El proyecto se articula con Análisis de algoritmos, Redes de computadores I, Matemáticas discretas II, Modelamiento y Simulación y Electiva I (Green IT).

---

## Contenido del repositorio

Todo el proyecto vive en este repositorio, organizado por ramas según el área de trabajo:

| Área | Qué contiene | Rama |
| --- | --- | --- |
| Backend | API REST con Node.js y Express | `backend` |
| Base de datos | Script SQL de PostgreSQL (`BD_Saici.sql`) | `backend` |
| Frontend | Interfaz de la aplicación | `frontend` |
| Pruebas | Informes de pruebas con evidencias de Postman | `pruebas` |
| Documentación | Informes, catálogo de pantallas y diagramas (UML, entidad-relación) | `Documentos` |

---

## Ramas

| Rama | Para qué sirve |
| --- | --- |
| `main` | Rama principal. Contiene la versión final y estable. |
| `develop` | Rama de integración: aquí se juntan las funcionalidades antes de pasar a `main`. |
| `backend` | Código del servidor y la base de datos. |
| `frontend` | Código de la interfaz. |
| `Documentos` | Documentación y diagramas del proyecto. |
| `pruebas` | Informes y evidencias de pruebas. |
| `feature/login-registro` | Funcionalidad de registro e inicio de sesión. |
| `feature/reserva` | Funcionalidad de reservas. |
| `feature/aplicativofuncional` | Integración del aplicativo funcional. |

## Reglas de trabajo

1. No se trabaja directamente sobre `main`. Esa rama solo recibe versiones ya probadas.
2. Cada funcionalidad nueva se desarrolla en una rama `feature/nombre-de-la-funcionalidad`.
3. Los cambios se incorporan mediante *Pull Request*, con al menos una revisión aprobada.
4. El código debe compilar y ejecutarse sin errores antes de fusionarse.
5. Las funcionalidades nuevas deben tener casos de prueba documentados en la rama `pruebas`.
6. Si se modifican endpoints, se actualiza la colección de Postman; si cambia la base de datos, se actualiza el diagrama entidad-relación.
7. Nunca se suben credenciales ni el archivo `.env` (ya está en `.gitignore`).

### Ramas protegidas

Las ramas protegidas son:

- `main`: contiene la versión estable y final del proyecto.
- `develop`: contiene la integración de las funcionalidades antes de pasar a `main`.

### Reglas aplicadas

Para estas ramas se establecen las siguientes condiciones:

- No se permite realizar cambios directamente mediante *push*.
- Los cambios deben ingresar mediante un **Pull Request**.
- Cada Pull Request debe contar con **al menos una aprobación** antes de realizar el *merge*.
- No se permiten *force push* sobre las ramas protegidas.
- No se permite eliminar las ramas protegidas.
- Los comentarios o conversaciones pendientes deben resolverse antes de realizar el *merge*.
- Si se realizan nuevos cambios después de una aprobación, la revisión puede requerir una nueva aprobación.
- Los colaboradores trabajan en ramas de funcionalidad y solicitan la integración mediante Pull Request.

### Flujo de integración

El flujo establecido para el proyecto es:

```text
feature/*
    │
    ▼
backend / frontend
    │
    ▼
develop
    │
    ▼
main

---

## Cómo clonar el repositorio

1. Instalar [Git](https://git-scm.com/downloads) si no lo tienes.
2. Abrir una terminal y clonar:
   ```bash
   git clone https://github.com/YarethLc/PI_UNILAB.git
   ```
3. Entrar a la carpeta del proyecto:
   ```bash
   cd PI_UNILAB
   ```
4. Descargar todas las ramas y ver cuáles existen:
   ```bash
   git fetch --all
   git branch -a
   ```
5. Cambiarte a la rama que necesites, por ejemplo:
   ```bash
   git checkout backend      # servidor y base de datos
   git checkout frontend     # interfaz
   git checkout Documentos   # documentación y diagramas
   git checkout pruebas      # informes de pruebas
   ```
6. Para aportar una funcionalidad nueva, crea tu rama a partir de `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/nombre-de-tu-tarea
   ```
7. Al terminar, súbela y abre un Pull Request en GitHub:
   ```bash
   git add .
   git commit -m "Descripción clara del cambio"
   git push origin feature/nombre-de-tu-tarea
   ```

---

## Tecnologías del backend

- Node.js y Express 5
- PostgreSQL 17 (base de datos `bd_saici`)
- `pg` para la conexión
- `bcrypt` para cifrar contraseñas
- `jsonwebtoken` para las sesiones (token válido por 8 horas)
- `nodemailer` para enviar el código de recuperación (Gmail SMTP)
- `dotenv` para variables de entorno
- `nodemon` en desarrollo

---

## Cómo ejecutar el backend en local

1. Cambiarte a la rama `backend` (ver sección anterior) e instalar dependencias:
   ```bash
   npm install
   ```
2. Crear la base de datos `bd_saici` en PostgreSQL y ejecutar el script `BD_Saici.sql`.
3. Crear un archivo `.env` en la raíz del backend:
   ```env
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=bd_saici
   DB_USER=tu_usuario
   DB_PASSWORD=tu_contraseña
   JWT_SECRET=una_clave_larga_y_secreta
   EMAIL_USER=correo_que_envia_los_codigos@gmail.com
   EMAIL_PASS=contraseña_de_aplicacion_de_gmail
   ```
4. Iniciar el servidor:
   ```bash
   npm run dev     # desarrollo, se reinicia solo
   npm start       # ejecución normal
   ```
5. Comprobar que funciona: abrir `http://localhost:3000/`. Debe responder `{"mensaje": "API de reservas funcionando correctamente"}`.

---

## Base de datos

Tablas del script `BD_Saici.sql`:

- **usuario**: datos personales, correo y teléfono únicos, rol (`ADMINISTRADOR` o `USUARIO`) y tipo (`EGRESADO` o `ESTUDIANTE`).
- **laboratorio**: nombre, ubicación, estado y capacidad.
- **reserva**: usuario, laboratorio, fecha, hora de inicio y fin, estado (`PENDIENTE`, `CONFIRMADA`, `CANCELADA`, `FINALIZADA`).
- **horario**: día de la semana (1 a 7), hora de apertura y de cierre.
- **codigos_verificacion**: códigos de un solo uso para recuperar la contraseña.

---

## Endpoints

### Autenticación (`/api/auth`)

| Método | Ruta | Qué hace |
| --- | --- | --- |
| POST | `/register` | Registra un usuario (ESTUDIANTE o EGRESADO) |
| POST | `/login` | Inicia sesión y devuelve el token |
| POST | `/recuperar-password` | Envía un código de 6 dígitos al correo (vale 15 minutos) |
| POST | `/verificar-codigo` | Valida el código y entrega un token de recuperación |
| POST | `/nueva-password` | Cambia la contraseña con ese token |
| GET | `/perfil` | Ruta protegida; requiere `Authorization: Bearer <token>` |

### Reservas (`/api/reservas`) – requieren token

| Método | Ruta | Qué hace |
| --- | --- | --- |
| POST | `/` | Crea una reserva |
| GET | `/` | Lista reservas |
| GET | `/:id` | Consulta una reserva |
| PUT | `/:id` | Edita una reserva propia |
| DELETE | `/:id` | Cancela una reserva propia |

Al reservar, el sistema valida que el usuario sea estudiante o egresado, que el laboratorio esté disponible, que la fecha no sea pasada, que el horario esté dentro del funcionamiento, que el usuario no tenga otra reserva que se cruce y que haya cupo.

### Laboratorios (`/api/laboratorios`)

| Método | Ruta | Qué hace |
| --- | --- | --- |
| GET | `/` | Lista laboratorios |
| GET | `/:id` | Consulta uno |
| POST | `/` | Crea un laboratorio |
| PUT | `/:id` | Edita un laboratorio |
| DELETE | `/:id` | Elimina (falla si tiene reservas) |

---

## Pruebas

Los informes están en la rama `pruebas`. Documentan los casos ejecutados con Postman sobre servidor, registro, inicio de sesión, rutas protegidas, recuperación de contraseña, laboratorios y reservas.

---

## Limitaciones conocidas

- Las rutas de laboratorios no exigen token ni rol de administrador.
- Los horarios no están vinculados a un laboratorio concreto: aplican por igual a todos.

---

Proyecto Integrador · Ingeniería de Sistemas · UCEVA
