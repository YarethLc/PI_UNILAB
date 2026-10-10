const pool = require("../../config/db");

const obtenerLaboratorios = async (req, res) => {
    try {
        const resultado = await pool.query(
            `SELECT 
                id_laboratorio,
                nombre,
                ubicacion,
                estado,
                capacidad
             FROM laboratorio`
        );

        res.status(200).json(resultado.rows);

    } catch (error) {
        console.error("Error obteniendo laboratorios:", error);

        res.status(500).json({
            mensaje: "Error al obtener el laboratorio"
        });
    }
};

const obtenerLaboratoriosPorId = async (req, res) => {
    const { id } = req.params;

    try {
        if (isNaN(id)) {
            return res.status(400).json({
                mensaje: "El ID del laboratorio debe ser un número"
            });
        }

        const resultado = await pool.query(
            `SELECT 
                id_laboratorio,
                nombre,
                ubicacion,
                estado,
                capacidad
             FROM laboratorio
             WHERE id_laboratorio = $1`,
            [id]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({
                mensaje: "Laboratorio no encontrado"
            });
        }

        res.status(200).json(resultado.rows[0]);

    } catch (error) {
        console.error("Error obteniendo laboratorio por ID:", error);

        res.status(500).json({
            mensaje: "Error al obtener el laboratorio"
        });
    }
};

const crearLaboratorio = async (req, res) => {
    const { nombre, ubicacion, estado, capacidad } = req.body;

    try {

        if (!nombre || !ubicacion || !estado || capacidad == null) {
            return res.status(400).json({
                mensaje: "Todos los campos son obligatorios"
            });
        }

        if (isNaN(capacidad)) {
            return res.status(400).json({
                mensaje: "La capacidad debe ser un número"
            });
        }

        if (capacidad <= 0) {
            return res.status(400).json({
                mensaje: "La capacidad debe ser mayor que cero"
            });
        }

        const laboratorioExistente = await pool.query(
            `SELECT
                id_laboratorio
             FROM laboratorio
             WHERE LOWER(nombre) = LOWER($1)`,
            [nombre]
        );

        if (laboratorioExistente.rows.length > 0) {
            return res.status(409).json({
                mensaje: "Ya existe un laboratorio con ese nombre"
            });
        }

        const nuevoLaboratorio = await pool.query(
            `INSERT INTO laboratorio
                (nombre,
                ubicacion,
                estado,
                capacidad)
            VALUES ($1, $2, $3, $4)
            RETURNING
                id_laboratorio,
                nombre,
                ubicacion,
                estado,
                capacidad`,
            [nombre, ubicacion, estado, capacidad]
        );

        res.status(201).json({
            mensaje: "Laboratorio creado exitosamente",
            laboratorio: nuevoLaboratorio.rows[0]
        });

    } catch (error) {
        console.error("Error creando laboratorio:", error);

        res.status(500).json({
            mensaje: "Error al crear el laboratorio"
        });
    }
};

const eliminarLaboratorio = async (req, res) => {
    const { id } = req.params;

    try {
        if (isNaN(id)) {
            return res.status(400).json({
                mensaje: "El ID del laboratorio debe ser un número"
            });
        }

        const laboratorio = await pool.query(
            `SELECT
                id_laboratorio
                FROM laboratorio
                WHERE id_laboratorio = $1`,
            [id]
        );

        if (laboratorio.rows.length === 0) {
            return res.status(404).json({
                mensaje: "Laboratorio no encontrado"
            });
        }

        const laboratorioEliminado = await pool.query(
            `DELETE FROM laboratorio
             WHERE id_laboratorio = $1
             RETURNING
                id_laboratorio,
                nombre,
                ubicacion,
                estado,
                capacidad`,
            [id]
        );

        res.status(200).json({
            mensaje: "Laboratorio eliminado exitosamente",
            laboratorio: laboratorioEliminado.rows[0]
        });

    }
    catch (error) {

        if (error.code === "23503") {
            return res.status(409).json({
                mensaje: "No se puede eliminar el laboratorio porque tiene reservas registradas."
            });
        }

        console.error(
            "Error eliminando laboratorio:",
            error
        );

        res.status(500).json({
            mensaje: "Error al eliminar el laboratorio"
        });

    }
};

const editarLaboratorio = async (req, res) => {

    const { id } = req.params;

    const { nombre, ubicacion, estado, capacidad } = req.body;

    try {

        if (isNaN(id)) {
            return res.status(400).json({
                mensaje: "El ID del laboratorio debe ser un número"
            });
        }

        if (!nombre || !ubicacion || !estado || capacidad == null) {
            return res.status(400).json({
                mensaje: "Todos los campos son obligatorios"
            });
        }

        if (isNaN(capacidad)) {
            return res.status(400).json({
                mensaje: "La capacidad debe ser un número"
            });
        }

        if (capacidad <= 0) {
            return res.status(400).json({
                mensaje: "La capacidad debe ser mayor que cero"
            });
        }

        const laboratorio = await pool.query(
            `SELECT
                id_laboratorio
            FROM laboratorio
            WHERE id_laboratorio = $1`,
            [id]
        );

        if (laboratorio.rows.length === 0) {
            return res.status(404).json({
                mensaje: "Laboratorio no encontrado"
            });
        }

        const laboratorioExistente = await pool.query(
            `SELECT
                id_laboratorio
            FROM laboratorio
            WHERE LOWER(nombre) = LOWER($1)
            AND id_laboratorio <> $2`,
            [nombre, id]
        );

        if (laboratorioExistente.rows.length > 0) {
            return res.status(409).json({
                mensaje: "Ya existe un laboratorio con ese nombre"
            });
        }

        const laboratorioActualizado = await pool.query(
            `UPDATE laboratorio
            SET
                nombre = $1,
                ubicacion = $2,
                estado = $3,
                capacidad = $4
            WHERE id_laboratorio = $5
            RETURNING
                id_laboratorio,
                nombre,
                ubicacion,
                estado,
                capacidad`,
            [nombre, ubicacion, estado, capacidad, id]
        );

        res.status(200).json({
            mensaje: "Laboratorio actualizado exitosamente",
            laboratorio: laboratorioActualizado.rows[0]
        });


    } catch (error) {

        console.error(
            "Error editando laboratorio:",
            error
        );

        res.status(500).json({
            mensaje: "Error al editar el laboratorio"
        });

    }

};

module.exports = {
    obtenerLaboratorios,
    obtenerLaboratoriosPorId,
    crearLaboratorio,
    eliminarLaboratorio,
    editarLaboratorio
};