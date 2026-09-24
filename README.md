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

```
main                                   → código estable / producción
develop                                → integración de features
feature/hu01-setup-arquitectura        → configuración inicial
feature/hu02-auth-login-registro       → autenticación backend
feature/hu02-ui-login-registro         → pantallas login/registro
feature/hu03-perfil-usuario            → perfil del egresado
feature/hu04-modelado-espacios         → modelado de espacios en BD
hotfix/*                               → correcciones urgentes sobre main
```

Todo cambio se integra a `develop` mediante **Pull Request** con al menos una aprobación antes del merge. `main` solo recibe código estable ya validado.

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
