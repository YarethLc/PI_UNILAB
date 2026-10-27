const pool = require("../../config/db");

// Obtener todos los horarios
const obtenerHorarios = async (req, res) => {
    try {
        const resultado = await pool.query(`
      SELECT
        id_horario,
        dia_semana,
        TO_CHAR(hora_apertura, 'HH24:MI:SS') AS hora_apertura,
        TO_CHAR(hora_cierre, 'HH24:MI:SS') AS hora_cierre
      FROM horario
      ORDER BY dia_semana, hora_apertura
    `);

        return res.status(200).json(resultado.rows);
    } catch (error) {
        console.error('Error al obtener horarios:', error);
        return res.status(500).json({
            mensaje: 'Error al consultar los horarios.',
        });
    }
};

// Crear un horario
const crearHorario = async (req, res) => {
    try {
        const { dia_semana, hora_apertura, hora_cierre } = req.body;

        const dia = Number(dia_semana);

        if (
            !Number.isInteger(dia) ||
            dia < 1 ||
            dia > 7 ||
            !hora_apertura ||
            !hora_cierre
        ) {
            return res.status(400).json({
                mensaje: 'Ingresa un día válido y ambas horas.',
            });
        }

        if (hora_apertura >= hora_cierre) {
            return res.status(400).json({
                mensaje: 'La hora de cierre debe ser posterior a la apertura.',
            });
        }

        const resultado = await pool.query(
            `INSERT INTO horario
        (dia_semana, hora_apertura, hora_cierre)
       VALUES ($1, $2, $3)
       RETURNING
         id_horario,
         dia_semana,
         TO_CHAR(hora_apertura, 'HH24:MI:SS') AS hora_apertura,
         TO_CHAR(hora_cierre, 'HH24:MI:SS') AS hora_cierre`,
            [dia, hora_apertura, hora_cierre]
        );

        return res.status(201).json({
            mensaje: 'Horario creado correctamente.',
            horario: resultado.rows[0],
        });
    } catch (error) {
        console.error('Error al crear horario:', error);

        if (error.code === '23514') {
            return res.status(400).json({
                mensaje: 'El día o las horas no cumplen las restricciones.',
            });
        }

        return res.status(500).json({
            mensaje: 'Error al crear el horario.',
        });
    }
};

// Modificar un horario existente
const actualizarHorario = async (req, res) => {
    try {
        const id = Number(req.params.id);
        const { dia_semana, hora_apertura, hora_cierre } = req.body;
        const dia = Number(dia_semana);

        if (!Number.isInteger(id) || id < 1) {
            return res.status(400).json({
                mensaje: 'El identificador del horario no es válido.',
            });
        }

        if (
            !Number.isInteger(dia) ||
            dia < 1 ||
            dia > 7 ||
            !hora_apertura ||
            !hora_cierre
        ) {
            return res.status(400).json({
                mensaje: 'Ingresa un día válido y ambas horas.',
            });
        }

        if (hora_apertura >= hora_cierre) {
            return res.status(400).json({
                mensaje: 'La hora de cierre debe ser posterior a la apertura.',
            });
        }

        const resultado = await pool.query(
            `UPDATE horario
       SET dia_semana = $1,
           hora_apertura = $2,
           hora_cierre = $3
       WHERE id_horario = $4
       RETURNING
         id_horario,
         dia_semana,
         TO_CHAR(hora_apertura, 'HH24:MI:SS') AS hora_apertura,
         TO_CHAR(hora_cierre, 'HH24:MI:SS') AS hora_cierre`,
            [dia, hora_apertura, hora_cierre, id]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({
                mensaje: 'No se encontró el horario que deseas modificar.',
            });
        }

        return res.status(200).json({
            mensaje: 'Horario actualizado correctamente.',
            horario: resultado.rows[0],
        });
    } catch (error) {
        console.error('Error al actualizar horario:', error);

        if (error.code === '23514') {
            return res.status(400).json({
                mensaje: 'El día o las horas no cumplen las restricciones.',
            });
        }

        return res.status(500).json({
            mensaje: 'Error al actualizar el horario.',
        });
    }
};

// Eliminar un horario
const eliminarHorario = async (req, res) => {
    try {
        const id = Number(req.params.id);

        if (!Number.isInteger(id) || id < 1) {
            return res.status(400).json({
                mensaje: 'El identificador del horario no es válido.',
            });
        }

        const resultado = await pool.query(
            `DELETE FROM horario
       WHERE id_horario = $1
       RETURNING id_horario`,
            [id]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({
                mensaje: 'No se encontró el horario que deseas eliminar.',
            });
        }

        return res.status(200).json({
            mensaje: 'Horario eliminado correctamente.',
        });
    } catch (error) {
        console.error('Error al eliminar horario:', error);

        if (error.code === '23503') {
            return res.status(409).json({
                mensaje: 'No se puede eliminar el horario porque está relacionado con otros registros.',
            });
        }

        return res.status(500).json({
            mensaje: 'Error al eliminar el horario.',
        });
    }
};

module.exports = {
    obtenerHorarios,
    crearHorario,
    actualizarHorario,
    eliminarHorario,
};
