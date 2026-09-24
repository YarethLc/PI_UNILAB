# PI_UNILAB
# Sistema de Reserva de Espacios — Laboratorios y Biblioteca

Aplicación móvil multiplataforma que permite a los egresados del programa de Ingeniería de Sistemas de la **Unidad Central del Valle (UCEVA)** consultar la disponibilidad y reservar espacios en laboratorios y biblioteca, optimizando el uso de los recursos tecnológicos de la universidad.

Proyecto integrador desarrollado con metodología ágil **SCRUM**.

## 📋 Descripción del proyecto

El presente proyecto integrador tiene como propósito el diseño, desarrollo e implementación de un Producto Mínimo Viable (MVP) que consiste en una aplicación móvil multiplataforma, dirigida a la comunidad de egresados del Programa de Ingeniería de Sistemas de la Unidad Central del Valle del Cauca (UCEVA). Dicha herramienta tecnológica que tiene como finalidad principal la automatización y gestión eficiente del proceso de reserva de espacios físicos institucionales, particularmente los laboratorios, las áreas destinadas al servicio de biblioteca,  optimizar la administración y el aprovechamiento de los recursos disponibles por parte de la institución.

La solución busca:

- Facilitar la autenticación de egresados.
- Consultar la disponibilidad de laboratorios y biblioteca en tiempo real.
- Permitir la realización de reservas sin solapamientos.
- Mantener un registro histórico de uso de los espacios.
- Proveer información útil para la toma de decisiones administrativas.

## 🧩 Roles del equipo (SCRUM)

| Rol | Responsable |
|---|---|
| Product Owner (PO) | Gestiona el backlog y las prioridades |
| Scrum Master (SM) | Facilita los eventos y elimina impedimentos |
| UI/UX Designer | Wireframes, prototipos y sistema de diseño |
| Frontend Developer | Interfaz móvil (Flutter / React Native) |
| Backend Developer | API REST, base de datos, autenticación |
| QA & Test Engineer | Casos de prueba y aseguramiento de calidad |
| Documentation & DevOps | Documentación técnica, ramas Git y despliegues |

## 🛠️ Stack tecnológico

- **Frontend móvil:** Flutter o React Native
- **Backend:** Node.js / Firebase
- **Base de datos:** PostgreSQL o MongoDB
- **Autenticación:** JWT / Firebase Auth
- **Documentación de API:** Swagger / Postman
- **Gestión del proyecto:** GitHub Projects / Jira / Trello

## 🌱 Estrategia de ramas (GitFlow)

El proyecto utiliza una estrategia de ramas basada en **GitFlow**, con el objetivo de mantener organizado el desarrollo y evitar cambios directos sobre las ramas principales.

```text
main
  │
  │  Código estable / producción
  │
  └── develop
       │
       │  Integración de funcionalidades
       │
       ├── backend
       │    │
       │    ├── feature/login-registro
       │    ├── feature/reservas
       │    └── feature/...
       │
       └── frontend
            │
            ├── feature/login-registro
            ├── feature/reservas
            └── feature/...
```

### 📌 Ramas principales

| Rama       | Propósito                                                                   |
| ---------- | ----------------------------------------------------------------------------|
| `main`     | Contiene únicamente código estable y listo para producción.                               |
| `develop`  | Rama principal de integración donde se incorporan los desarrollos terminados y revisados. |
| `backend`  | Rama destinada a integrar el desarrollo correspondiente al backend.                       |
| `frontend` | Rama destinada a integrar el desarrollo correspondiente al frontend móvil.  |

### 🔧 Ramas de funcionalidades

Cada integrante debe crear una rama `feature` a partir de la rama correspondiente a su área.

**Backend:**

```bash
git checkout backend
git pull origin backend
git checkout -b feature/nombre-funcionalidad
```

Ejemplo:

```bash
git checkout -b feature/login-registro
```

**Frontend:**

```bash
git checkout frontend
git pull origin frontend
git checkout -b feature/nombre-funcionalidad
```

Ejemplo:

```bash
git checkout -b feature/login-registro
```

### 🔄 Flujo de trabajo

El flujo general será:

```text
feature/*
    ↓
backend / frontend
    ↓
develop
    ↓
main
```

1. Crear una rama `feature` desde `backend` o `frontend`.
2. Desarrollar la funcionalidad correspondiente.
3. Realizar commits descriptivos.
4. Subir la rama al repositorio remoto.
5. Crear un **Pull Request (PR)** hacia `backend` o `frontend`.
6. Revisar y aprobar el Pull Request.
7. Una vez integradas las funcionalidades, realizar el Pull Request correspondiente hacia `develop`.
8. Después de las pruebas y validaciones finales, `develop` podrá integrarse en `main`.

### ⚠️ Reglas importantes

* No realizar `push` directamente sobre `main`.
* No realizar `push` directamente sobre `develop`.
* No trabajar directamente sobre `backend` o `frontend`.
* Cada funcionalidad debe desarrollarse en una rama `feature/*`.
* Los cambios deben ingresar mediante **Pull Requests**.
* Los Pull Requests deben ser revisados antes de realizar el merge.
* Los mensajes de commit deben describir claramente el cambio realizado.

### 📝 Convención para nombres de ramas

Se recomienda utilizar:

```text
feature/nombre-funcionalidad
fix/nombre-del-error
refactor/nombre-del-cambio
docs/nombre-documentacion
```

Ejemplos:

```text
feature/login-registro
feature/reservas
feature/perfil-usuario
fix/error-autenticacion
refactor/estructura-backend
docs/actualizar-readme
```


## 🚀 Sprint 1 — Objetivo

Desplegar una aplicación móvil funcional con autenticación segura de egresados, conectada a la base de datos, con la arquitectura base lista para el módulo de reservas.

**Historias de usuario:**

- **HU-01:** Configuración del entorno y arquitectura base
- **HU-02:** Registro e inicio de sesión de egresados
- **HU-03:** Visualización del perfil de usuario
- **HU-04:** Modelado de espacios (laboratorios y biblioteca)

## 📦 Instalación y ejecución local

### Requisitos previos

- Node.js (v18 o superior)
- Flutter SDK o React Native CLI (según framework elegido)
- Gestor de base de datos (PostgreSQL o MongoDB)
- Git

### Clonar el repositorio

```bash
git clone https://github.com/YarethLc/PI_UNILAB.git
cd PI_UNILAB
git checkout develop
git pull origin develop
```

### Backend

```bash
cd backend
npm install
cp .env.example .env   # configurar variables de entorno (BD, JWT, etc.)
npm run dev
```

### Frontend móvil

```bash
cd app
flutter pub get        # o: npm install (React Native)
flutter run             # o: npx react-native run-android
```

## 🧪 Pruebas

Las pruebas de autenticación y endpoints se documentan en la colección de Postman incluida en `/docs/postman`, junto con el reporte de QA de cada Sprint.

## 📄 Documentación adicional

- Diagramas UML (casos de uso, clases, despliegue): `/docs/uml`
- Documentación de la API (Swagger/Postman): `/docs/api`
- Manuales de usuario: `/docs/manuales`

## 👥 Equipo

_Agregar aquí los nombres e integrantes del equipo por Sprint._

## 📝 Licencia

Proyecto académico — Ingeniería de Sistemas, Unidad Central del Valle (UCEVA).
