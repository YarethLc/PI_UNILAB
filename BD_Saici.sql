-- Tabla usuario
CREATE TABLE usuario (
	id_usuario serial primary key,
	nombres varchar(100) not null,
	apellidos varchar(100) not null,
	email varchar (100) unique not null,
	telefono varchar (20) unique not null,
	contrasena varchar (255) not null,
	rol varchar (30) not null default 'USUARIO',
    tipo_usuario varchar(30),

	CONSTRAINT chk_rol_usuario
		CHECK (rol IN ('ADMINISTRADOR', 'USUARIO', 'LABORATORIO')),

    CONSTRAINT chk_tipo_usuario
		CHECK (
            (rol IN ('ADMINISTRADOR', 'LABORATORIO') AND tipo_usuario IS NULL)
            OR
            (rol = 'USUARIO'
            AND tipo_usuario IN ('EGRESADO', 'ESTUDIANTE'))
            )
);

-- Tabla de laboratorio
CREATE TABLE laboratorio (
    id_laboratorio serial primary key,
    nombre varchar(100) not null,
    ubicacion varchar(150) not null,
    estado varchar(30) not null,
    capacidad smallint not null
);

-- Tabla de reserva
CREATE TABLE reserva (
	id_reserva serial primary key,
	id_usuario integer not null,
    id_laboratorio integer not null,
    fecha date not null,
    hora_inicio time not null,
    hora_fin time not null,
    estado varchar(30) not null,
    fecha_creacion timestamp default current_timestamp,

    CONSTRAINT fk_reserva_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario),

    CONSTRAINT fk_reserva_laboratorio
        FOREIGN KEY (id_laboratorio)
        REFERENCES laboratorio(id_laboratorio),

    CONSTRAINT chk_horas_reserva
        CHECK (hora_fin > hora_inicio),

    CONSTRAINT chk_estado_reserva
        CHECK (estado IN (
            'PENDIENTE',
            'CONFIRMADA',
            'CANCELADA',
            'FINALIZADA'
        ))
	
);

-- Tabla de horarios laboratorios
CREATE TABLE horario (
    id_horario serial primary key,
    dia_semana smallint not null,
    hora_apertura time not null,
    hora_cierre time not null,
    activo boolean not null default true,
    id_laboratorio integer,

    CONSTRAINT chk_dia_semana
        CHECK (dia_semana BETWEEN 1 AND 7),

    CONSTRAINT chk_horas
        CHECK (hora_cierre > hora_apertura),

    CONSTRAINT fk_horario_laboratorio
        FOREIGN KEY (id_laboratorio)
        REFERENCES laboratorio(id_laboratorio)
        ON DELETE CASCADE
);

-- Compatibilidad con bases ya creadas antes de asociar franjas a laboratorios.
ALTER TABLE horario
    ADD COLUMN IF NOT EXISTS id_laboratorio integer
    REFERENCES laboratorio(id_laboratorio) ON DELETE CASCADE;

-- Compatibilidad con bases ya creadas antes de agregar el estado del horario.
ALTER TABLE horario
    ADD COLUMN IF NOT EXISTS activo boolean not null default true;

-- Tabla de codigos de verificacion
CREATE TABLE codigos_verificacion (
    id_verificacion serial primary key,
    id_usuario integer not null,
    codigo varchar(10) not null,
    usado boolean not null default false,
    expiracion timestamp not null,
    token_recuperacion varchar(255),

    CONSTRAINT fk_codigo_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
);
-- ==============================================================================
-- DATOS INICIALES DEL SISTEMA (USUARIOS DE PRUEBA Y ESPACIOS)
-- Contraseñas hasheadas de forma segura con bcrypt (costo 10)
-- Admin: admin@uceva.edu.co / Admin123456!
-- Encargado Lab: laboratorio@uceva.edu.co / Lab123456!
-- Estudiante: estudiante.test@uceva.edu.co / Estudiante123!
-- ==============================================================================

INSERT INTO usuario (nombres, apellidos, email, telefono, contrasena, rol, tipo_usuario)
VALUES 
    ('Administrador', 'Principal UCEVA', 'admin@uceva.edu.co', '3000000001', '$2b$10$1siz4cmzbRovu//j82EEKuCkFd9vnrefkUjJlpWT4gOWoOZabAGUq', 'ADMINISTRADOR', NULL),
    ('Coordinador', 'Laboratorios UCEVA', 'laboratorio@uceva.edu.co', '3000000002', '$2b$10$BtwGCxRhMCLLsGfqYVOa8.s7uF0zsvr.88lbwTYD7Wdd2TQC7cYYC', 'LABORATORIO', NULL),
    ('Estudiante', 'Prueba UCEVA', 'estudiante.test@uceva.edu.co', '3000000003', '$2b$10$WEHGnjcHQPz4ANAnJRingO3/7JjeGmD6380/mmAAwTJ54lWIT4XuS', 'USUARIO', 'ESTUDIANTE')
ON CONFLICT (email) DO NOTHING;

INSERT INTO laboratorio (nombre, ubicacion, estado, capacidad)
VALUES 
    ('Laboratorio de Redes y Telecomunicaciones', 'Edificio de Ingeniería - Bloque B Piso 2', 'DISPONIBLE', 30),
    ('Laboratorio de Desarrollo de Software', 'Bloque C - Aula 204', 'DISPONIBLE', 25),
    ('Sala de Cómputo Especializado 301', 'Bloque A - Piso 3', 'DISPONIBLE', 35),
    ('Laboratorio de Robótica y Automatización', 'Centro de Innovación - Lab 1', 'DISPONIBLE', 20)
ON CONFLICT DO NOTHING;

-- 6. Horarios de atención (Lunes a Sábado)
INSERT INTO horario (dia_semana, hora_apertura, hora_cierre) VALUES
    (1, '07:00:00', '22:00:00'),
    (2, '07:00:00', '22:00:00'),
    (3, '07:00:00', '22:00:00'),
    (4, '07:00:00', '22:00:00'),
    (5, '07:00:00', '22:00:00'),
    (6, '08:00:00', '18:00:00')
ON CONFLICT DO NOTHING;

INSERT INTO horario (dia_semana, hora_apertura, hora_cierre, activo)
SELECT 7, '08:00:00', '14:00:00', FALSE
WHERE NOT EXISTS (
    SELECT 1 FROM horario WHERE dia_semana = 7
);