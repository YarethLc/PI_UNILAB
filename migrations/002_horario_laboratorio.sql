-- Asocia una franja horaria a un laboratorio específico.
-- Si id_laboratorio es NULL, la franja aplica a TODOS los laboratorios.
--
-- Aplicar sobre bases ya creadas:
--   psql -U postgres -d saici_db -f migrations/002_horario_laboratorio.sql
--   o dentro de Docker:
--   docker exec -i saici-postgres psql -U postgres -d saici_db < migrations/002_horario_laboratorio.sql

ALTER TABLE horario
    ADD COLUMN IF NOT EXISTS id_laboratorio integer
    REFERENCES laboratorio(id_laboratorio) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_horario_laboratorio_dia
    ON horario (id_laboratorio, dia_semana);
