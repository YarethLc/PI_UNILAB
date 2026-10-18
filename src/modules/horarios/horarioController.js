const pool = require("../../config/db");

const timeToSeconds = (value) => {
    const [hours, minutes, seconds = "0"] = value.split(":");
    return Number(hours) * 3600 + Number(minutes) * 60 + Number(seconds);
};

const listarHorarios = async (req, res) => {
    try {
        const { id_laboratorio } = req.query;
        let query = `
            SELECT h.id_horario, h.dia_semana, h.hora_apertura, h.hora_cierre, h.activo,
                   h.id_laboratorio, l.nombre AS nombre_laboratorio
            FROM horario h
            LEFT JOIN laboratorio l ON h.id_laboratorio = l.id_laboratorio
        `;
        const params = [];
        if (id_laboratorio !== undefined && id_laboratorio !== null && id_laboratorio !== "") {
            query += ` WHERE h.id_laboratorio = $1 OR h.id_laboratorio IS NULL`;
            params.push(Number(id_laboratorio));
        }
        query += ` ORDER BY h.dia_semana, h.hora_apertura, h.id_horario`;

        const resultado = await pool.query(query, params);
        return res.status(200).json(resultado.rows);
    } catch (error) {
        console.error("Error obteniendo horarios:", error);
        return res.status(500).json({ mensaje: "Error al obtener los horarios" });
    }
};

const crearHorario = async (req, res) => {
    const { dia_semana, hora_apertura, hora_cierre, id_laboratorio } = req.body;
    const weekday = Number(dia_semana);
    const labId = id_laboratorio ? Number(id_laboratorio) : null;
    const timePattern = /^([01]\d|2[0-3]):[0-5]\d(?::[0-5]\d)?$/;

    if (!Number.isInteger(weekday) || weekday < 1 || weekday > 7) {
        return res.status(400).json({ mensaje: "El día debe ser un valor entre 1 (lunes) y 7 (domingo)" });
    }
    if (!timePattern.test(hora_apertura || "") || !timePattern.test(hora_cierre || "")) {
        return res.status(400).json({ mensaje: "Las horas deben tener formato HH:mm" });
    }
    if (timeToSeconds(hora_cierre) <= timeToSeconds(hora_apertura)) {
        return res.status(400).json({ mensaje: "La hora de cierre debe ser posterior a la apertura" });
    }

    try {
        const resultado = await pool.query(
            `INSERT INTO horario (dia_semana, hora_apertura, hora_cierre, activo, id_laboratorio)
             VALUES ($1, $2, $3, TRUE, $4)
             RETURNING id_horario, dia_semana, hora_apertura, hora_cierre, activo, id_laboratorio`,
            [weekday, hora_apertura, hora_cierre, labId]
        );
        let horarioCreado = resultado.rows[0];
        if (labId) {
            const labRes = await pool.query("SELECT nombre FROM laboratorio WHERE id_laboratorio = $1", [labId]);
            if (labRes.rows.length > 0) {
                horarioCreado.nombre_laboratorio = labRes.rows[0].nombre;
            }
        }
        return res.status(201).json({
            mensaje: "Franja horaria creada exitosamente",
            horario: horarioCreado
        });
    } catch (error) {
        console.error("Error creando horario:", error);
        return res.status(500).json({ mensaje: "Error al crear la franja horaria" });
    }
};

const actualizarEstadoHorario = async (req, res) => {
    const id = Number(req.params.id);
    const { activo } = req.body;

    if (!Number.isInteger(id) || id <= 0) {
        return res.status(400).json({ mensaje: "El ID del horario debe ser un número válido" });
    }
    if (typeof activo !== "boolean") {
        return res.status(400).json({ mensaje: "El estado activo debe ser verdadero o falso" });
    }

    try {
        const resultado = await pool.query(
            `UPDATE horario
             SET activo = $1
             WHERE id_horario = $2
             RETURNING id_horario, dia_semana, hora_apertura, hora_cierre, activo, id_laboratorio`,
            [activo, id]
        );
        if (resultado.rows.length === 0) {
            return res.status(404).json({ mensaje: "Franja horaria no encontrada" });
        }
        const horarioActualizado = resultado.rows[0];
        if (horarioActualizado.id_laboratorio) {
            const labRes = await pool.query("SELECT nombre FROM laboratorio WHERE id_laboratorio = $1", [horarioActualizado.id_laboratorio]);
            if (labRes.rows.length > 0) {
                horarioActualizado.nombre_laboratorio = labRes.rows[0].nombre;
            }
        }
        return res.status(200).json({
            mensaje: "Estado del horario actualizado",
            horario: horarioActualizado
        });
    } catch (error) {
        console.error("Error actualizando horario:", error);
        return res.status(500).json({ mensaje: "Error al actualizar el estado del horario" });
    }
};

module.exports = { listarHorarios, crearHorario, actualizarEstadoHorario };
