ALTER TABLE horario
    ADD COLUMN IF NOT EXISTS activo boolean NOT NULL DEFAULT true;

INSERT INTO horario (dia_semana, hora_apertura, hora_cierre, activo)
SELECT 7, '08:00:00', '14:00:00', FALSE
WHERE NOT EXISTS (
    SELECT 1 FROM horario WHERE dia_semana = 7
);
