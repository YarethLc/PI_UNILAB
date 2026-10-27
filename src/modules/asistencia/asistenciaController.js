const asistenciaService = require("./asistenciaService");
const pool = require("../../config/db");

const registrarEntrada = async (req, res) => {
    try {
        const idUsuario = req.usuario.id_usuario;
        const { id_laboratorio } = req.body;

        if (!id_laboratorio || !Number.isInteger(Number(id_laboratorio))) {
            return res.status(400).json({
                mensaje: "Debes seleccionar un laboratorio válido."
            });
        }

        const laboratorio = await pool.query(
            "SELECT id_laboratorio FROM laboratorio WHERE id_laboratorio = $1",
            [Number(id_laboratorio)]
        );

        if (laboratorio.rowCount === 0) {
            return res.status(404).json({
                mensaje: "El laboratorio seleccionado no existe."
            });
        }

        const asistencia = await asistenciaService.registrarEntrada(
            idUsuario,
            Number(id_laboratorio)
        );

        return res.status(201).json({
            mensaje: "Entrada registrada correctamente.",
            asistencia
        });
    } catch (error) {
        if (error.code === "23505") {
            return res.status(409).json({
                mensaje: "Ya tienes una asistencia abierta. Registra tu salida primero."
            });
        }

        console.error("Error al registrar entrada:", error);

        return res.status(500).json({
            mensaje: "No fue posible registrar la entrada."
        });
    }
};

const registrarSalida = async (req, res) => {
    try {
        const idUsuario = req.usuario.id_usuario;

        const asistencia = await asistenciaService.registrarSalida(idUsuario);

        if (!asistencia) {
            return res.status(404).json({
                mensaje: "No tienes una entrada pendiente de salida."
            });
        }

        return res.status(200).json({
            mensaje: "Salida registrada correctamente.",
            asistencia
        });
    } catch (error) {
        console.error("Error al registrar salida:", error);

        return res.status(500).json({
            mensaje: "No fue posible registrar la salida."
        });
    }
};


const obtenerHistorial = async (req, res) => {
    try {
        const idUsuario = req.usuario.id_usuario;

        const asistencias =
            await asistenciaService.obtenerHistorial(idUsuario);

        return res.status(200).json(asistencias);
    } catch (error) {
        console.error("Error al consultar asistencias:", error);

        return res.status(500).json({
            mensaje: "No fue posible consultar el historial."
        });
    }
};


module.exports = {
    registrarEntrada,
    registrarSalida,
    obtenerHistorial
};
